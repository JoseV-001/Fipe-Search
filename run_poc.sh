#!/bin/bash

echo "=================================================="
echo "🚀 INICIANDO ORQUESTRADOR FIPE SEARCH POC 🚀"
echo "=================================================="
echo ""

# Limpar ambiente
echo ">> Reiniciando containers para ambiente limpo..."
cd docker && docker-compose rm -sf app redis > /dev/null 2>&1 && docker-compose up -d app redis > /dev/null 2>&1 && cd ..
echo ">> Aguardando inicializacao do backend (20s)..."
sleep 20

echo "Criando cabecalho do Relatorio..."
cat << 'EOF' > poc-results-live.md
# Relatório POC: Resultados Reais dos Cenários FIPE

Este documento captura a execução simulando alta volumetria e valida os cenários esperados.

## 1. Tabela de Performance (K6 - 200 VUs por 20s)

| Cenário | Volumetria (Reqs) | RPS | Cache MISS | Erros (Timeouts/Fails) | Latência p90 | Latência p95 |
|---------|-------------------|-----|------------|-------------------------|--------------|--------------|
EOF

scenarios=( "1|Direct DB (Gargalo)" "2|Cache com TTL (Stampede)" "3|Cache com Warming (Ideal)" )

printf "%-30s | %-12s | %-8s | %-10s | %-12s | %-10s | %-10s\n" "Cenario" "Requisicoes" "RPS" "Cache MISS" "Erros" "p90 (ms)" "p95 (ms)"
echo "----------------------------------------------------------------------------------------------------------------"

for sc in "${scenarios[@]}"; do
    id="${sc%%|*}"
    name="${sc##*|}"
    scenario_log_file="backend_scenario_${id}.tmp"

    app_cache_warm="false"
    if [ "$id" == "3" ]; then
        app_cache_warm="true"
    fi

    echo ">> Recriando app com APP_CACHE_WARM=${app_cache_warm}..."
    cd docker && APP_CACHE_WARM=${app_cache_warm} docker-compose up -d --force-recreate app > /dev/null 2>&1 && cd ..
    sleep 20

    echo -e "\n⏳ Executando Cenario ${id}: ${name}..."

    # Executa K6
    MSYS_NO_PATHCONV=1 docker run --rm -i -e SCENARIO=${id} --network docker_default grafana/k6 run - < loadtest/k6-script.js > k6_out.tmp 2> /dev/null

    # Extração limpa de métricas
    reqs=$(grep -E '^\s*http_reqs' k6_out.tmp | awk '{print $2}' | tr -d '\r')
    rps_raw=$(grep -E '^\s*http_reqs' k6_out.tmp | awk '{print $3}' | cut -d/ -f1 | tr -d '\r')
    rps=${rps_raw%.*}

    # Pega logs do container correto (fipe-backend)
    docker logs fipe-backend > "${scenario_log_file}" 2>&1

    if [ "$id" == "1" ]; then
        miss="-"
    else
        # CONTAGEM CORRIGIDA AQUI
        miss=$(grep -c "Cache MISS" "${scenario_log_file}")
    fi

    errs=$(grep -E '^\s*checks_failed' k6_out.tmp | awk '{print $3}' | tr -d '\r' || echo "0")
    if [ -z "$errs" ] || [ "$errs" == " " ]; then errs="0"; fi

    p90=$(grep -E '^\s*http_req_duration' k6_out.tmp | grep -o 'p(90)=[0-9.]*' | cut -d= -f2 | tr -d '\r')
    p95=$(grep -E '^\s*http_req_duration' k6_out.tmp | grep -o 'p(95)=[0-9.]*' | cut -d= -f2 | tr -d '\r')

    printf "%-30s | %-12s | %-8s | %-10s | %-12s | %-10s | %-10s\n" "$name" "$reqs" "$rps" "$miss" "$errs" "${p90}" "${p95}"
    echo "| $name | $reqs | $rps | $miss | $errs | ${p90}ms | ${p95}ms |" >> poc-results-live.md
done

cat << 'EOF' >> poc-results-live.md

## 2. Evidência do Fenômeno "Cache Stampede" (Cenário 2)
EOF

echo -e "\n🔎 EXTRAINDO EVIDENCIAS DE STAMPEDE..."
backend_logs_file="backend_scenario_2.tmp"

# SED CORRIGIDO PARA PEGAR O LOG DO PACOTE
stampedes=$(grep "Cache MISS" "${backend_logs_file}" | sed -E 's/^.*([0-9]{2}:[0-9]{2}:[0-9]{2}).*modelo=([0-9]+),\s*ano=([0-9]+)/\1 \2 \3/' | sort | uniq -c | awk '$1 > 1')

if [ -n "$stampedes" ]; then
    echo "✅ EVIDENCIA CONFIRMADA!"
    while read -r count sec mod ano; do
        echo "   -> Segundo [$sec]: $count threads simultaneas em {modelo=$mod, ano=$ano}"
        echo "- No horario \`$sec\`, exatas **$count threads** tiveram \`Cache MISS\` simultaneamente para \`modelo=$mod, ano=$ano\`." >> poc-results-live.md
    done <<< "$stampedes"
else
    echo "❌ Stampede nao detectado."
    echo "- Nenhum stampede capturado nos logs." >> poc-results-live.md
fi

rm -f k6_out.tmp backend_scenario_*.tmp
echo -e "\n=> Relatorio 'poc-results-live.md' gerado com sucesso!"