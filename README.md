# Fipe Search

Este projeto é uma **Prova de Conceito (POC)** de alta performance desenvolvida para demonstrar o impacto do uso de **Redis** como camada de cache na redução de latência e alívio de carga em bancos de dados relacionais (**PostgreSQL**).

Baseado em conceitos de **sistemas distribuídos**, o projeto simula cenários de alta concorrência utilizando **Grafana k6** para validar fenômenos como:

* Cache Stampede
* Cache Warming
* Gargalos de banco de dados

---

## Tecnologias Utilizadas

* **Java 25**
* **Spring Boot 4.0.5**

  * Spring Data JPA
  * Spring Data Redis
* **PostgreSQL**
* **Redis** (Camada de cache em memória)
* **Docker & Docker Compose**
* **Grafana k6** (Testes de carga)

---

## Diferenciais da Implementação

### Cache eficiente

* Serialização em **JSON** (legível via `redis-cli`)
* Chaves organizadas no padrão:

```
fipe::modeloId:anoModelo
```

### Cenários de stress controlados

* TTL reduzido (**6 segundos**) para forçar expiração
* Delay artificial no banco (`pg_sleep`) simulando latência real
* Pool de conexões limitado para simular gargalo real

### Automação completa

* Script `run_poc.sh`:

  * Sobe ambiente
  * Executa testes
  * Coleta métricas
  * Gera relatório automático

---

## Como Rodar o Projeto

### Pré-requisitos

* Docker Desktop rodando
* Git Bash (Windows) ou terminal Linux/macOS

---

### 1. Build da aplicação

```bash
./mvnw clean install -DskipTests
```

### 2. Executar a POC completa

```bash
chmod +x run_poc.sh
./run_poc.sh
```

O script irá:

* Subir PostgreSQL + Redis + aplicação
* Executar 3 cenários de carga
* Gerar relatório automaticamente

---

## Resultados Obtidos

Testes com 200 usuários virtuais (VUs) durante 20 segundos:

| Cenário                  | RPS Médio | Latência p95 | Erros  |
| ------------------------ | --------- | ------------ | ------ |
| Direct DB (Gargalo)      | ~5.3k     | 79.6ms       | > 900  |
| Cache com TTL (Stampede) | ~5.3k     | 69.1ms       | > 1000 |
| Cache Aquecido (Ideal)   | ~7.6k     | 57.0ms       | 0      |

> O relatório detalhado é gerado automaticamente em:
> `poc-results-live.md`

---

## O que esse projeto prova

* Redis reduz drasticamente latência
* Diminui pressão no banco de dados
* Cache mal configurado pode causar Cache Stampede
* Cache aquecido entrega performance máxima

---

## Estrutura relevante

* `CacheConfig.java` → Configuração de cache e warmup
* `FipeService.java` → Uso de `@Cacheable` e `@CacheEvict`
* `loadtest/k6-script.js` → Simulação de carga
* `docker-compose.yml` → Infraestrutura

---

## Inspecionando o Redis

```bash
docker exec -it fipesearch-redis redis-cli
GET fipe::1:2023
```

---

## Autor

José Victor

---

## Objetivo

Este projeto foi desenvolvido com foco em:

* Evolução técnica em backend
* Domínio de arquitetura de alta performance
* Demonstração prática
