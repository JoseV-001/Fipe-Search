# Relatório POC: Resultados Reais dos Cenários FIPE

Este documento captura a execução simulando alta volumetria e valida os cenários esperados.

## 1. Tabela de Performance (K6 - 200 VUs por 20s)

| Cenário                   | Volumetria (Reqs) | RPS  | Cache MISS | Erros (Timeouts/Fails) | Latência p90 | Latência p95 |
|---------------------------|-------------------|------|------------|------------------------|--------------|--------------|
| Direct DB (Gargalo)       | 105991            | 5297 | -          | 938                    | 57.37ms      | 79.67ms      |
| Cache com TTL (Stampede)  | 106356            | 5313 | 1191       | 1038                   | 51.72ms      | 69.17ms      |
| Cache com Warming (Ideal) | 152810            | 7635 | 10         | 0                      | 42.08ms      | 57.09ms      |

## 2. Evidência do Fenômeno "Cache Stampede" (Cenário 2)
- No horario `05:01:50`, exatas **43 threads** tiveram `Cache MISS`  simultaneamente para `modelo=1, ano=2023`.
- No horario `05:01:50`, exatas **41 threads** tiveram `Cache MISS` simultaneamente para `modelo=2, ano=2021`.
- No horario `05:01:50`, exatas **40 threads** tiveram `Cache MISS` simultaneamente para `modelo=3, ano=2021`.
- No horario `05:01:50`, exatas **34 threads** tiveram `Cache MISS` simultaneamente para `modelo=4, ano=2021`.
- No horario `05:01:50`, exatas **42 threads** tiveram `Cache MISS` simultaneamente para `modelo=5, ano=2021`.
- No horario `05:01:52`, exatas **38 threads** tiveram `Cache MISS` simultaneamente para `modelo=1, ano=2023`.
- No horario `05:01:52`, exatas **65 threads** tiveram `Cache MISS` simultaneamente para `modelo=2, ano=2021`.
- No horario `05:01:52`, exatas **35 threads** tiveram `Cache MISS` simultaneamente para `modelo=3, ano=2021`.
- No horario `05:01:52`, exatas **52 threads** tiveram `Cache MISS` simultaneamente para `modelo=4, ano=2021`.
- No horario `05:01:52`, exatas **36 threads** tiveram `Cache MISS` simultaneamente para `modelo=5, ano=2021`.
- No horario `05:01:53`, exatas **30 threads** tiveram `Cache MISS` simultaneamente para `modelo=2, ano=2021`.
- No horario `05:01:58`, exatas **49 threads** tiveram `Cache MISS` simultaneamente para `modelo=1, ano=2023`.
- No horario `05:01:58`, exatas **52 threads** tiveram `Cache MISS` simultaneamente para `modelo=3, ano=2021`.
- No horario `05:01:58`, exatas **55 threads** tiveram `Cache MISS` simultaneamente para `modelo=4, ano=2021`.
- No horario `05:01:58`, exatas **49 threads** tiveram `Cache MISS` simultaneamente para `modelo=5, ano=2021`.
- No horario `05:01:59`, exatas **66 threads** tiveram `Cache MISS` simultaneamente para `modelo=2, ano=2021`.
- No horario `05:02:04`, exatas **116 threads** tiveram `Cache MISS` simultaneamente para `modelo=1, ano=2023`.
- No horario `05:02:05`, exatas **139 threads** tiveram `Cache MISS` simultaneamente para `modelo=2, ano=2021`.
- No horario `05:02:05`, exatas **47 threads** tiveram `Cache MISS` simultaneamente para `modelo=3, ano=2021`.
- No horario `05:02:05`, exatas **100 threads** tiveram `Cache MISS` simultaneamente para `modelo=4, ano=2021`.
- No horario `05:02:05`, exatas **62 threads** tiveram `Cache MISS` simultaneamente para `modelo=5, ano=2021`.
