# Hotel Booking Analysis - Snowflake

Projeto de análise de dados de reservas de hotel utilizando **Snowflake** como data warehouse. Este projeto implementa um pipeline de dados seguindo a arquitetura **Medallion** (Bronze → Silver → Gold).

## 📋 Sobre o Projeto

Este projeto realiza:
- ✅ **Extração e Carregamento (EL)** de dados de reservas de hotel
- ✅ **Validação e Limpeza** de qualidade dos dados
- ✅ **Transformação de Dados** para um formato padronizado
- ✅ **Análise** de padrões de reservas, ocupação e receitas

## 📁 Estrutura do Projeto

```
hotel-booking-analysis-snowflake/
├── Hotel_analitics.sql          # Script principal com todo o pipeline de dados
├── hotel_bookings_raw.csv       # Dados brutos de reservas de hotel
└── README.md                     # Este arquivo
```

## 🏗️ Arquitetura do Pipeline

### Bronze Layer (Raw Data)
- **Tabela**: `BRONZE_HOTEL_BOOKING`
- **Propósito**: Armazenar dados brutos do CSV sem transformações
- **Campos**: booking_id, hotel_id, hotel_city, customer_id, customer_name, customer_email, check_in_date, check_out_date, room_type, num_guests, total_amount, currency, booking_status

### Silver Layer (Clean Data)
- **Tabela**: `SILVER_HOTEL_BOOKING`
- **Propósito**: Dados limpos e transformados
- **Transformações Aplicadas**:
  - Normalização de nomes de cidades e clientes (INITCAP + TRIM)
  - Validação de e-mails (padrão válido)
  - Conversão de tipos de dados adequados
  - Correção de valores negativos (ABS)
  - Padronização de status de reservas

## 🗄️ Infraestrutura Snowflake

O script cria automaticamente:

| Recurso | Nome | Descrição |
|---------|------|-----------|
| **Role** | sysadmin | Papel administrativo |
| **Warehouse** | hotel_wh | Recurso computacional |
| **Database** | hotel_db | Banco de dados principal |
| **Schema** | hotel_schema | Esquema para organizar tabelas |
| **File Format** | FF_CSV | Configuração para parse de CSV |
| **Stage** | STG_HOTELBOOKINGS | Área de entrada para arquivos |

## 🚀 Como Usar

### Pré-requisitos
- Conta Snowflake ativa
- Acesso ao Snowflake Web UI ou SnowSQL
- Arquivo `hotel_bookings_raw.csv` preparado

### Passos de Execução

1. **Conecte-se ao Snowflake**
   ```sql
   -- Use seu cliente Snowflake preferido
   ```

2. **Execute o script completo**
   ```sql
   -- Copie e execute todo o conteúdo de Hotel_analitics.sql
   ```

3. **O script automaticamente irá**:
   - Criar warehouse, database e schema
   - Definir formato de arquivo e stage
   - Criar tabelas Bronze e Silver
   - Realizar validações de qualidade
   - Carregar e transformar dados

## 📊 Validações de Qualidade

O projeto inclui verificações para:

- ✅ **E-mails inválidos**: Detecta e valida formato `nome@domínio.extensão`
- ✅ **Valores negativos**: Identifica montantes negativos na receita
- ✅ **Datas inconsistentes**: Valida que check-in < check-out
- ✅ **Status de reserva**: Normaliza variações de status (ex: "confirmeeed" → "confirmed")

## 📈 Dados de Entrada

O arquivo `hotel_bookings_raw.csv` contém:
- **13 campos** de informações de reservas
- Dados de múltiplas cidades e moedas
- Estados de reserva variados (Confirmed, No-Show, etc.)
- Períodos de hospedagem diversos

## 🔄 Próximas Etapas (Sugestões)

- [ ] Criar **Gold Layer** para análises agregadas
- [ ] Adicionar métricas de KPI (revenue, occupancy rate)
- [ ] Implementar dashboards (Tableau, Looker, etc.)
- [ ] Automatizar pipeline com Snowflake Tasks
- [ ] Adicionar testes de qualidade de dados

## 📝 Notas Importantes

- Os dados são inseridos em modo **CONTINUE ON ERROR** para maior robustez
- E-mails com valor 'invalid-email' são marcados como NULL após validação
- Valores de data/valor inválidos são tratados com funções TRY_TO_*
- O script usa **IF NOT EXISTS** para segurança de re-execução

## 👤 Autor

Projeto de análise de dados - Hotel Booking Analysis

## 📄 Licença

Este projeto está disponível para uso livre.

---

**Última atualização**: Maio de 2026
