# NEXA — Plataforma CitizenTech de Saúde Pública Inteligente
### Monitoramento de Filas em Tempo Real e Roteamento Geoespacial de Unidades do SUS

**Global Solution 2026/2**  
**Tema:** *CitizenTech* (Tecnologia voltada para o cidadão e comunidades)  
**Disciplina:** Mastering Relational and Non-Relational Database  
**Instituição:** FIAP — Faculdade de Informática e Administração Paulista  
**Tecnologias:** Oracle Database (19c/21c/23ai) | PL/SQL | Java Spring Boot | Python ETL  

---

## 👥 Integrantes do Grupo

| Nome Completo | RM | Turma |
| :--- | :---: | :---: |
| **Paulo Cavalcante Caroba** | **RM566667** | 2TDSPS |
| **Renan da Silva Paulino** | **RM566610** | 2TDSPS |
| **Sergio Henrique da Silva Santos** | **RM567254** | 2TDSPS |

---

## 📌 1. Visão Geral do Projeto (Contexto CitizenTech)

No Brasil, a superlotação e a assimetria de informações sobre o tempo de espera nas Unidades Básicas de Saúde (UBS), Prontos Atendimentos (UPA) e hospitais da rede pública são gargalos históricos que impactam a vida do cidadão e violam o **ODS 3 da ONU (Saúde e Bem-Estar)**.

O **NEXA** é uma solução de tecnologia cívica (*CitizenTech*) desenvolvida para empoderar o cidadão brasileiro e os gestores municipais através de:
1. **Roteamento Geoespacial Inteligente:** Localização em tempo real das unidades de saúde públicas mais próximas utilizando a fórmula esférica de **Haversine com Bounding Box dinâmico**.
2. **Painel de Filas em Tempo Real (FIFO):** Acompanhamento transparente do status do atendimento (`AGUARDANDO`, `CHAMADO`, `FINALIZADO`), posição na fila e tempo de espera estimado.
3. **Auditoria de Triagem e SLA Clínico:** Regras de negócio em banco de dados baseadas no **Protocolo de Manchester**, priorizando casos urgentes (`TRIAGEM`, `PEDIATRIA`) e emitindo alertas de estouro de SLA.
4. **Base de Dados Oficial Integrada:** Carga massiva georreferenciada de estabelecimentos de saúde ativos do SUS em todo o território nacional.

---

## 🏛️ 2. Arquitetura do Modelo Relacional (3FN)

O banco de dados foi modelado e implementado na **3ª Forma Normal (3FN)**, garantindo integridade referencial estrita, ausência de redundâncias e alta performance analítica.

### 2.1. Diagrama Entidade-Relacionamento (DER)

```mermaid
erDiagram
    TB_ESTADO ||--o{ TB_MUNICIPIO : "possui"
    TB_MUNICIPIO ||--o{ TB_LOCALIZACAO : "contem"
    TB_LOCALIZACAO ||--|| TB_UNIDADE_SAUDE : "localiza"
    TB_UNIDADE_SAUDE ||--o{ TB_COLABORADOR : "emprega"
    TB_UNIDADE_SAUDE ||--o{ TB_ATENDIMENTO : "atende"
    TB_PACIENTE ||--o{ TB_ATENDIMENTO : "recebe"
    TB_COLABORADOR ||--o{ TB_ATENDIMENTO : "realiza"
    TB_CIDADAO ||--o{ TB_CIDADAO_UNIDADE_SAUDE : "favorita"
    TB_UNIDADE_SAUDE ||--o{ TB_CIDADAO_UNIDADE_SAUDE : "e_favoritada_por"

    TB_ESTADO {
        NUMBER_19 id PK
        VARCHAR2_10 codigo_uf
        VARCHAR2_2 sigla UK
        VARCHAR2_100 nome
    }

    TB_MUNICIPIO {
        NUMBER_19 id PK
        VARCHAR2_20 codigo_municipio_ibge
        VARCHAR2_120 nome
        NUMBER_19 id_estado FK
    }

    TB_LOCALIZACAO {
        NUMBER_19 id PK
        VARCHAR2_15 cep
        VARCHAR2_120 logradouro
        VARCHAR2_120 numero
        VARCHAR2_120 bairro
        NUMBER_19 id_municipio FK
        NUMBER_10_7 latitude
        NUMBER_10_7 longitude
    }

    TB_UNIDADE_SAUDE {
        NUMBER_19 id PK
        VARCHAR2_255 nome
        NUMBER_19 id_localizacao FK_UK
        NUMBER_10_2 tempo_espera
        VARCHAR2_60 tipo_unidade
    }

    TB_PACIENTE {
        NUMBER_19 id PK
        VARCHAR2_15 cpf UK
        VARCHAR2_150 nome
    }

    TB_CIDADAO {
        NUMBER_19 id PK
        VARCHAR2_150 nome
        VARCHAR2_150 email UK
        VARCHAR2_255 senha
        TIMESTAMP aceite_localizacao
    }

    TB_COLABORADOR {
        NUMBER_19 id PK
        VARCHAR2_150 nome
        VARCHAR2_100 cargo
        VARCHAR2_150 email UK
        VARCHAR2_255 senha
        NUMBER_19 id_unidade FK
    }

    TB_ATENDIMENTO {
        NUMBER_19 id PK
        NUMBER_19 id_unidade_saude FK
        NUMBER_19 id_paciente FK
        NUMBER_19 id_colaborador FK
        VARCHAR2_30 status_atendimento
        TIMESTAMP data_hora_chegada
        TIMESTAMP data_hora_chamada
        TIMESTAMP data_hora_fim
        VARCHAR2_10 senha
        VARCHAR2_30 servico
    }

    TB_CIDADAO_UNIDADE_SAUDE {
        NUMBER_19 id_cidadao PK_FK
        NUMBER_19 id_unidade_saude PK_FK
    }
```

---

## 📊 3. Dicionário de Tabelas e Índices de Performance

| Tabela | Responsabilidade de Domínio | Principais Constraints |
| :--- | :--- | :--- |
| `tb_estado` | Cadastro oficial de Unidades Federativas (IBGE). | `PK_TB_ESTADO`, `UK` na sigla (`SP`, `RJ`, etc.). |
| `tb_municipio` | Malha de municípios brasileiros associados aos estados. | `PK_TB_MUNICIPIO`, `FK` para `tb_estado`. |
| `tb_localizacao` | Endereços completos e coordenadas geográficas WGS84. | `CHECK (latitude BETWEEN -90 AND 90)`, `CHECK (longitude BETWEEN -180 AND 180)`. |
| `tb_unidade_saude` | Estabelecimentos públicos do SUS (UBS, UPA, Hospitais). | Relação 1:1 (`UNIQUE` em `id_localizacao`). |
| `tb_paciente` | Registro de pacientes identificados no atendimento. | `UK` no CPF. Desacoplado da autenticação. |
| `tb_cidadao` | Usuários do aplicativo móvel com consentimento LGPD. | `UK` no e-mail, hash BCrypt, `aceite_localizacao`. |
| `tb_colaborador` | Profissionais de saúde alocados nas unidades. | `UK` no e-mail, `FK` para `tb_unidade_saude`. |
| `tb_atendimento` | Fila em tempo real, roteamento e histórico de chamadas. | `CHECK (status_atendimento IN ('AGUARDANDO','CHAMADO','FINALIZADO'))`, `CHECK (servico IN ('CLINICO_GERAL','TRIAGEM','VACINACAO','PEDIATRIA','ODONTOLOGIA'))`. |
| `tb_cidadao_unidade_saude`| Associação NxM de unidades de saúde favoritas. | PK Composta (`id_cidadao`, `id_unidade_saude`) com `ON DELETE CASCADE`. |

### Índices de Alta Performance Criados:
- `idx_localizacao_latitude_longitude`: Índice B-Tree composto sobre `(latitude, longitude)`. Ativado dinamicamente pelo **Bounding Box** das buscas de geolocalização, eliminando *Full Table Scans* na base de 90k registros.
- `idx_atendimento_fila`: Índice composto sobre `(id_unidade_saude, servico, status_atendimento, data_hora_chegada)` para respostas em milissegundos nas consultas da fila FIFO.
- Índices de cobertura em todas as Chaves Estrangeiras (`id_estado`, `id_unidade`, `id_paciente`, `id_colaborador`).

---

## 🚀 4. Carga de Dados (Data Pipeline & Seed Oficial)

### 4.1. Carga Controlada de Teste (`02_dml_seed` / `scriptoracle.sql`)
- Carga de semente oficial obrigatória da disciplina contendo **10 a 13 registros consistentes por tabela** (totalizando mais de 100 inserts relacionados).
- Dados realistas com capitais, UBSs reais de SP/RJ/MG, médicos, pacientes e fila ativa simulada com intervalos de chegada.

### 4.2. Carga Massiva Nacional (Python ETL — Ministério da Saúde / CNES)
Através de um pipeline ETL em Python com a biblioteca `python-oracledb`, a base bruta de mais de 600.000 registros do Ministério da Saúde foi tratada, filtrada e inserida em lotes (*batch insert* de 5.000 registros com `COMMIT` segmentado):

```text
================================================================================
                    NEXA - RESUMO DA CARGA MASSIVA DE DADOS
================================================================================
  • tb_estado ........................ 27 registros   (Todos os estados + DF)
  • tb_municipio ..................... 5.570 registros (100% dos municípios do Brasil)
  • tb_localizacao ................... 90.396 registros (Geolocalização com WGS84)
  • tb_unidade_saude ................. 90.396 registros (Estabelecimentos ativos SUS)
  • Registros órfãos / inconsistentes: 0
================================================================================
```

---

## ⚙️ 5. Componentes Programáveis PL/SQL (Requisitos Oficiais FIAP)

### 5.1. Bloco Anônimo com `SELECT ... INTO` e Exceções
- Recupera dados de atendimento, paciente, unidade e profissional via junção relacional quádrupla.
- Tratamento explícito de exceções: `WHEN NO_DATA_FOUND THEN`, `WHEN TOO_MANY_ROWS THEN` e `WHEN OTHERS THEN` com rastreamento via `SQLCODE` e `SQLERRM`.

### 5.2. Estrutura de Decisão (`IF / ELSIF / ELSE` — Protocolo de Manchester)
- Implementa a classificação de risco clínico e auditoria de cumprimento de SLA:
  - `TRIAGEM` $\rightarrow$ **Emergência / Risco Crítico (Vermelho)** — SLA máximo: 10 minutos.
  - `PEDIATRIA` $\rightarrow$ **Prioritário / Urgência Infantil (Amarelo)** — SLA: 20 minutos.
  - `CLINICO_GERAL` com espera $> 30$ min $\rightarrow$ **Urgência Moderada (Laranja)** — Alerta de SLA violado.
  - `CLINICO_GERAL` $\rightarrow$ **Consulta Regular (Verde)** — SLA: 45 minutos.
  - `VACINACAO` / `ODONTOLOGIA` $\rightarrow$ **Procedimento Eletivo (Azul)** — SLA: 60 minutos.
- Auditoria de unidade preferencial via verificação em `tb_cidadao_unidade_saude`.

### 5.3. Cursor Explícito e Laço de Repetição (`LOOP / FETCH / CLOSE`)
- Declaração explícita de `CURSOR c_painel_fila IS SELECT ...`.
- Percorre iterativamente os atendimentos ativos da fila ordenados por ordem de chegada (FIFO), calculando em lote o tempo decorrido de espera e emitindo os totalizadores no buffer `DBMS_OUTPUT`.

### 5.4. Stored Procedures Implementadas
1. **`prc_buscar_unidades_proximas` (Analítica / Consulta com `SYS_REFCURSOR`):**
   - Recebe latitude, longitude, raio máximo em km e limite de resultados.
   - Aplica **Bounding Box trigonométrico dinâmico** para acionar o índice espacial B-Tree.
   - Calcula a distância esférica exata em quilômetros via **fórmula de Haversine** e retorna o cursor paginado em milissegundos.
2. **`prc_chamar_proximo_fila` (Transacional / Operação DML com `IN` e `COMMIT`):**
   - Espelha o método Java `chamarProximoDaFila` do backend Spring Boot.
   - Recebe a unidade, especialidade e o médico responsável.
   - Localiza o primeiro paciente aguardando (FIFO), atualiza o status para `'CHAMADO'`, carimba o `CURRENT_TIMESTAMP`, efetua o `COMMIT;` e devolve a senha chamada via parâmetro `OUT`.
3. **Função Determinística `radians(deg)`:**
   - Blindagem matemática que permite ao Hibernate/Spring Boot rodar consultas trigonométricas nativas no Oracle sem dependência de emulação de dialeto.

---

## 🛠️ 6. Guia Passo a Passo de Execução

### Pré-requisitos
- Oracle Database (19c, 21c ou 23ai).
- Ferramenta de administração: Oracle SQL Developer, SQLcl, DBeaver ou PL/SQL Developer.

### Ordem de Execução dos Scripts:
1. Conecte-se ao schema do seu usuário (ex.: `RM566667`).
2. Abra e execute o arquivo mestre consolidado:
   ```sql
   @scriptoracle.sql
   ```
3. O script executa automaticamente a seguinte esteira:
   - Limpeza idempotente (`DROP TABLE` e `DROP SEQUENCE`).
   - Criação das 8 Sequences e 9 Tabelas com Constraints (PK, FK, UK, CHECK).
   - Criação dos 6 Índices de Otimização.
   - Carga inicial controlada dos registros de teste (`INSERT` + `COMMIT`).
   - Criação da function `radians` e das Stored Procedures (`prc_buscar_unidades_proximas` e `prc_chamar_proximo_fila`).
   - Execução do Bloco Anônimo com Protocolo de Manchester e verificação de SLA.
   - Execução do Bloco de Monitoramento com Cursor Explícito e Loop.
   - Bloco anônimo de teste executando a chamada das Stored Procedures.

---

## 📁 7. Estrutura dos Arquivos do Repositório

```text
oracle-database-nexa/
│
├── scriptoracle.sql              # Script mestre completo (DDL, DML, Procedures e Blocos PL/SQL)
├── procedure.sql                 # Procedures de busca geoespacial e consultas avançadas
├── REQUISITOS.MD                 # Especificação oficial de requisitos e matriz de avaliação FIAP
├── STATUS_E_GUIA_EXECUCAO.md     # Relatório executivo de conformidade e auditoria técnica
├── identificacao_grupo.txt       # Arquivo de identificação formal da equipe (RM, Nome, Turma)
├── identificacao.txt             # Identificação resumida dos integrantes
└── README.md                     # Documentação conceitual, DER, dicionário e guia do projeto
```

---

## ⚖️ 8. Licença e Direitos

Projeto desenvolvido exclusivamente para fins acadêmicos como parte da **Global Solution 2026/2 da FIAP**.  
Tema: **CitizenTech — Tecnologia a Serviço do Cidadão**.
