# NEXA — Plataforma CitizenTech de Saúde Pública Inteligente
### Monitoramento de Filas em Tempo Real e Roteamento Geoespacial de Unidades do SUS

**Global Solution 2026/2**  
**Tema:** *CitizenTech* (Tecnologia voltada para o cidadão e comunidades)  
**Disciplina:** Mastering Relational and Non-Relational Database  
**Instituição:** FIAP — Faculdade de Informática e Administração Paulista  
**Tecnologias:** Oracle Database | PL/SQL | Java Spring Boot | Python ETL  

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

## 🏛️ 2. Arquitetura do Modelo Relacional e Normalização (3FN)

O banco de dados foi projetado seguindo rigorosamente a **3ª Forma Normal (3FN)**, garantindo integridade referencial estrita, eliminação de redundâncias e alta eficiência para o backend Spring Boot e consultas geoespaciais.

### 2.1. Aplicação Prática das Formas Normais (1FN, 2FN e 3FN)
- **1ª Forma Normal (1FN — Atomicidade):** Todos os atributos são atômicos e indivisíveis (ex.: endereço particionado em `cep`, `logradouro`, `numero`, `bairro`, `latitude` e `longitude`; nenhuma coluna multivalorada ou lista em texto).
- **2ª Forma Normal (2FN — Dependência Funcional Total):** Todas as colunas não-chave dependem integralmente da chave primária. Na tabela associativa `tb_cidadao_unidade_saude`, cuja chave primária é composta `(id_cidadao, id_unidade_saude)`, não há atributos parciais dependentes de apenas uma das partes da chave.
- **3ª Forma Normal (3FN — Eliminação de Dependências Transitivas):** Nenhum atributo não-chave depende de outro atributo não-chave:
  - A hierarquia territorial foi totalmente desacoplada em `tb_unidade_saude` $\rightarrow$ `tb_localizacao` $\rightarrow$ `tb_municipio` $\rightarrow$ `tb_estado` (impedindo que nome de cidade ou sigla de UF se repitam 90 mil vezes nas unidades de saúde).
  - O **Paciente** (`tb_paciente`) foi desacoplado do **Cidadão/App** (`tb_cidadao`) e do **Atendimento** (`tb_atendimento`), permitindo que um paciente presencial sem conta no app receba senha no totem sem violar a integridade do cadastro de usuários.
  - O **Colaborador** (`tb_colaborador`) é referenciado apenas por `id_colaborador` em `tb_atendimento`, sem duplicar nome ou cargo do médico no histórico da fila.

### 2.2. Diagrama Entidade-Relacionamento (DER)

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
        NUMBER_19 id_localizacao FK,UK
        NUMBER_10_2 tempo_espera
        VARCHAR2_60 tipo_unidade
    }

    TB_PACIENTE {
        NUMBER_19 id PK
        VARCHAR2_11 cpf UK
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
        NUMBER_19 id_cidadao PK,FK
        NUMBER_19 id_unidade_saude PK,FK
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

### 4.2. Pipeline de Carga Massiva Nacional em Python ETL (`carga.py`)

Para enriquecer o projeto com dados reais de todo o território brasileiro sem comprometer o tempo de execução do script acadêmico, foi desenvolvido um pipeline ETL em Python (`RegistrosSus/CargaDadosUnidadesSaude/carga.py`) utilizando o driver oficial **`python-oracledb`**.

#### Arquitetura e Etapas do Pipeline (`carga.py`):
1. **Leitura de Fonte Oficial (`cnes_estabelecimentos.csv` — ~232 MB / +640 mil linhas):**
   - Processamento *streaming* em codificação nativa `latin-1` (ISO-8859-1) do DataSUS com detecção automática de delimitador.
2. **Filtros de Qualidade e Regras de Negócio:**
   - **Atendimento SUS:** Seleciona exclusivamente estabelecimentos com `CO_AMBULATORIAL_SUS = 'SIM'`.
   - **Unidades Ativas:** Descarta registros com motivo de desativação preenchido (`CO_MOTIVO_DESAB`), reduzindo a base para ~90 mil unidades ativas.
   - **Mapeamento de Domínio Java:** Converte os 33 códigos numéricos do CNES (`TP_UNIDADE`) para os literais exatos do Enum `TipoUnidade` do Spring Boot (ex.: `2` $\rightarrow$ `CENTRO_DE_SAUDE_UNIDADE_BASICA`, `73` $\rightarrow$ `PRONTO_ATENDIMENTO`).
   - **Saneamento Geoespacial (WGS84):** Valida `NU_LATITUDE` (`-90` a `90`) e `NU_LONGITUDE` (`-180` a `180`), descartando coordenadas nulas ou zeradas e padronizando para 7 casas decimais (`NUMBER(10,7)`).
   - **Proteção contra `ORA-12899`:** Função dedicada `truncar()` em UTF-8 para garantir que nomes e endereços não ultrapassem o limite em bytes do banco Oracle (`AL32UTF8`).
3. **Enriquecimento Territorial (API IBGE):**
   - Consulta a API oficial de localidades do IBGE (`servicodados.ibge.gov.br`), com descompressão `gzip`, sincronizando de forma idempotente as **27 UFs** (`tb_estado`) e os **5.570 municípios** (`tb_municipio`).
4. **Inserção em Lotes Atômicos de Alta Performance (`BATCH_SIZE = 5000`):**
   - **Pré-alocação de Sequences em Lote:** Utiliza `SELECT seq_localizacao.NEXTVAL FROM dual CONNECT BY LEVEL <= :qtd` para reservar 5.000 IDs de uma só vez sem *round-trips* extras, garantindo o vínculo 1:1 entre `tb_localizacao` e `tb_unidade_saude`.
   - **Execução em Batch e Atomicidade:** Insere via `cursor.executemany()` com `conn.commit()` por lote (e `conn.rollback()` em caso de falha), evitando estouro da área de UNDO/REDO do Oracle compartilhado.

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

### 4.3. Contagem Atualizada de Registros Verificados na Base

Após a execução completa da carga massiva nacional (IBGE + CNES/SUS), do seed transacional e dos testes de check-in no Oracle, a consulta de auditoria (`UNION ALL` com `COUNT(*)`) confirmou exatamente os seguintes quantitativos por tabela:

| Tabela | Quantidade Verificada | Origem / Observação |
| :--- | :---: | :--- |
| `TB_ESTADO` | **27** | 26 estados brasileiros + Distrito Federal (IBGE). |
| `TB_MUNICIPIO` | **5.570** | 100% dos municípios brasileiros vinculados às UFs. |
| `TB_LOCALIZACAO` | **90.396** | Endereços e coordenadas geográficas WGS84 (CNES/SUS). |
| `TB_UNIDADE_SAUDE` | **90.396** | Estabelecimentos públicos de saúde ativos em relação 1:1 com localização. |
| `TB_PACIENTE` | **15** | Pacientes cadastrados para atendimento e testes de check-in. |
| `TB_CIDADAO` | **11** | Usuários do aplicativo móvel com aceite LGPD. |
| `TB_COLABORADOR` | **11** | Profissionais de saúde vinculados às unidades. |
| `TB_ATENDIMENTO` | **24** | Registros de fila (seed inicial + atendimentos gerados via `prc_realizar_checkin`). |
| `TB_CIDADAO_UNIDADE_SAUDE` | **12** | Vínculos NxM de unidades favoritadas pelos cidadãos. |

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

### 5.3. Cursor Explícito e Laço de Repetição (`OPEN / FETCH / CLOSE`)
- Declaração explícita de `CURSOR c_fila_espera IS SELECT ...` realizando `JOIN` entre `tb_atendimento` (`a`) e `tb_paciente` (`p`), filtrando especificamente a unidade real **`8922`** (**PA MUN SAO MATEUS II**) com `a.status_atendimento = 'AGUARDANDO'` e ordenação cronológica crescente (`ORDER BY a.data_hora_chegada ASC` — padrão FIFO).
- Calcula dinamicamente o tempo de espera em minutos (`minutos_espera`) a partir da diferença entre `CURRENT_TIMESTAMP` e `a.data_hora_chegada`.
- Ciclo de vida completo de controle manual do cursor:
  1. **`OPEN c_fila_espera;`**: Aloca o contexto de execução e executa a consulta da fila.
  2. **`LOOP ... FETCH c_fila_espera INTO v_senha, v_paciente, v_servico, v_minutos;`**: Extrai linha a linha para variáveis tipadas com `%TYPE`.
  3. **`EXIT WHEN c_fila_espera%NOTFOUND;`**: Interrompe o laço de repetição de forma segura ao atingir o fim do conjunto de resultados.
  4. **`CLOSE c_fila_espera;`**: Libera a memória do cursor após exibir cada posição da fila e o total de pacientes aguardando (`v_total`) via `DBMS_OUTPUT.PUT_LINE`.

### 5.4. Stored Procedures Implementadas
1. **`pr_buscar_unidades_proximas` (Analítica / Consulta Geoespacial com `SYS_REFCURSOR`):**
   - Recebe `p_latitude`, `p_longitude`, `p_raio_km` (padrão `5.0`) e `p_limite` (padrão `10`), retornando `p_resultado OUT SYS_REFCURSOR`.
   - Aplica **Bounding Box trigonométrico dinâmico** (`v_delta_lat` e `v_delta_lon` ajustado pelo cosseno da latitude) para ativar o índice espacial B-Tree `idx_localizacao_latitude_longitude`.
   - Calcula a distância esférica exata em quilômetros via **fórmula de Haversine** (`6371.0 * 2 * atan2(...)`) dentro de uma CTE (`WITH calculo AS (...)`) e retorna os resultados ordenados por proximidade (`FETCH FIRST v_limite ROWS ONLY`).
2. **`prc_realizar_checkin` (Transacional / Operação DML com `IN`/`OUT` e Controle Transacional):**
   - Espelha o endpoint de Check-in do backend Spring Boot (`POST /api/atendimentos/checkIn`).
   - **Parâmetros:** `p_cpf_paciente IN VARCHAR2`, `p_id_unidade IN NUMBER`, `p_servico IN VARCHAR2` e `p_senha_gerada OUT VARCHAR2`.
   - **Busca de Paciente por CPF:** Localiza o identificador do paciente em `tb_paciente` usando o CPF de 11 dígitos (`SELECT id INTO v_id_paciente FROM tb_paciente WHERE cpf = p_cpf_paciente`).
   - **Mapeamento de Prefixos do Enum:** Converte o serviço informado para o prefixo padronizado da senha (`CLINICO_GERAL` $\rightarrow$ `CLI`, `TRIAGEM` $\rightarrow$ `TRI`, `PEDIATRIA` $\rightarrow$ `PED`, `VACINACAO` $\rightarrow$ `VAC`, `ODONTOLOGIA` $\rightarrow$ `ODO`, ou `GER` como fallback).
   - **Geração Sequencial de Senha Única:** Executa `SELECT COUNT(*) + 1 INTO v_proximo_num` filtrando `id_unidade_saude = p_id_unidade` e `servico = p_servico`, formatando a senha com zero à esquerda via `LPAD(v_proximo_num, 3, '0')` (ex.: `CLI-001`, `PED-002`).
   - **Persistência e Controle Transacional:** Insere o novo registro em `tb_atendimento` com status `'AGUARDANDO'` e `CURRENT_TIMESTAMP` em `data_hora_chegada`, confirma a transação com `COMMIT;` e retorna `p_senha_gerada`.
   - **Tratamento de Exceções:** Trata explicitamente `WHEN NO_DATA_FOUND` (informando quando o CPF não é encontrado em `tb_paciente`) e `WHEN OTHERS` (executando `ROLLBACK;` para preservar a integridade transacional e registrando `SQLERRM`).

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
   - Habilitação de console (`SET SERVEROUTPUT ON SIZE UNLIMITED;`).
   - Limpeza idempotente (`DROP TABLE` e `DROP SEQUENCE`).
   - Criação das 8 Sequences e 9 Tabelas com Constraints (PK, FK, UK, CHECK).
   - Criação dos 6 Índices de Otimização.
   - Carga inicial controlada dos registros de teste (`INSERT` + `COMMIT`).
   - Execução do Bloco Anônimo com Protocolo de Manchester e verificação de SLA.
   - Execução do Bloco de Fila da UBS com Cursor Explícito (`c_fila_espera`).
   - Compilação das Stored Procedures (`pr_buscar_unidades_proximas` e `prc_realizar_checkin`).
   - Consultas finais de conferência das 9 tabelas.

---

## 📸 7. Evidências de Execução no Oracle (`Evidencias/`)

Abaixo estão reunidas todas as evidências capturadas diretamente no ambiente Oracle Database comprovando a criação da base, a integridade da carga nacional e transacional, e a execução dos blocos PL/SQL e Stored Procedures.

### 7.1. Criação da Base e Logs

- **Logs de Criação da Base (`logs_criacao_base.png`)**  
  Comprova a execução do script DDL com a criação das 8 *sequences*, das 9 tabelas normalizadas em 3FN (com suas respectivas constraints `PK`, `FK`, `UK` e `CHECK`) e dos 6 índices de otimização sem erros de compilação.  
  ![Logs de criação da base no Oracle](Evidencias/logs_criacao_base.png)

---

### 7.2. Verificação das Tabelas e Carga de Dados

- **Consulta em `TB_ESTADO` (`tb_estado_select.png`)**  
  Comprova a carga dos 27 registros oficiais das Unidades Federativas brasileiras (códigos IBGE, siglas e nomes).  
  ![SELECT na tabela TB_ESTADO](Evidencias/tb_estado_select.png)

- **Consulta com `JOIN` em `TB_MUNICIPIO` (`tb_municipio_select_join.png`)**  
  Comprova a integridade referencial entre municípios e estados na malha nacional de 5.570 municípios brasileiros.  
  ![SELECT com JOIN na tabela TB_MUNICIPIO](Evidencias/tb_municipio_select_join.png)

- **Consulta em `TB_LOCALIZACAO` (`select_tb_localizacao.png`)**  
  Comprova a carga georreferenciada dos 90.396 endereços com CEP, logradouro, bairro e coordenadas `latitude`/`longitude` no padrão WGS84.  
  ![SELECT na tabela TB_LOCALIZACAO](Evidencias/select_tb_localizacao.png)

- **Consulta em `TB_UNIDADE_SAUDE` (`select_unidades.png`)**  
  Comprova a carga das 90.396 unidades públicas de saúde do SUS vinculadas em relação 1:1 com `TB_LOCALIZACAO`.  
  ![SELECT na tabela TB_UNIDADE_SAUDE](Evidencias/select_unidades.png)

- **Consulta em `TB_PACIENTE` (`select_pacientes.png`)**  
  Comprova os 15 registros de pacientes cadastrados com CPF único para atendimento e testes operacionais.  
  ![SELECT na tabela TB_PACIENTE](Evidencias/select_pacientes.png)

- **Consulta em `TB_CIDADAO` (`select_cidadaos.png`)**  
  Comprova os 11 registros de cidadãos usuários do aplicativo móvel, incluindo e-mail único, hash de senha e timestamp de aceite LGPD (`aceite_localizacao`).  
  ![SELECT na tabela TB_CIDADAO](Evidencias/select_cidadaos.png)

- **Consulta em `TB_COLABORADOR` (`select_colaboradores.png`)**  
  Comprova os 11 profissionais de saúde cadastrados e devidamente vinculados às respectivas unidades de saúde.  
  ![SELECT na tabela TB_COLABORADOR](Evidencias/select_colaboradores.png)

- **Consulta em `TB_ATENDIMENTO` (`select_atendimentos.png`)**  
  Comprova os 24 registros de atendimentos em fila, incluindo senhas, serviços, status (`AGUARDANDO`, `CHAMADO`, `FINALIZADO`) e timestamps de chegada/chamada.  
  ![SELECT na tabela TB_ATENDIMENTO](Evidencias/select_atendimentos.png)

- **Consulta em `TB_CIDADAO_UNIDADE_SAUDE` (`select_favoritos_cidadao_unidade.png`)**  
  Comprova os 12 relacionamentos NxM de unidades de saúde marcadas como favoritas pelos cidadãos.  
  ![SELECT na tabela TB_CIDADAO_UNIDADE_SAUDE](Evidencias/select_favoritos_cidadao_unidade.png)

- **Execução Consolidada de Todos os `SELECT`s (`todos_selects_executados.png`)**  
  Comprova a execução em lote das consultas de verificação final sobre todas as 9 tabelas do modelo sem falhas ou inconsistências.  
  ![Execução consolidada de todos os SELECTs](Evidencias/todos_selects_executados.png)

- **Auditoria da Quantidade de Registros (`quantidade_registros.png`)**  
  Comprova o resultado exato da query `UNION ALL` de contagem total por tabela (`TB_ESTADO`: 27, `TB_MUNICIPIO`: 5.570, `TB_LOCALIZACAO`: 90.396, `TB_UNIDADE_SAUDE`: 90.396, `TB_PACIENTE`: 15, `TB_CIDADAO`: 11, `TB_COLABORADOR`: 11, `TB_ATENDIMENTO`: 24 e `TB_CIDADAO_UNIDADE_SAUDE`: 12).  
  ![Contagem verificada de registros por tabela](Evidencias/quantidade_registros.png)

---

### 7.3. Execução PL/SQL: Bloco Anônimo e Cursor

- **Execução do Bloco Anônimo com Protocolo de Manchester (`bloco_anonimo_executado.png`)**  
  Comprova a execução do bloco anônimo com `SELECT ... INTO`, cálculo de tempo de espera, classificação de risco clínico (`IF / ELSIF / ELSE`), verificação de SLA e saída formatada via `DBMS_OUTPUT`.  
  ![Execução do bloco anônimo PL/SQL](Evidencias/bloco_anonimo_executado.png)

- **Execução do Cursor Explícito (`cursor_explicito_loop.png`)**  
  Comprova o funcionamento do cursor `c_fila_espera` filtrando a unidade `8922` (`PA MUN SAO MATEUS II`), percorrendo os pacientes com `OPEN`, `FETCH ... INTO`, `EXIT WHEN %NOTFOUND` e `CLOSE`.  
  ![Execução do cursor explícito em loop](Evidencias/cursor_explicito_loop.png)

---

### 7.4. Compilação e Execução das Stored Procedures

- **Compilação das Duas Stored Procedures (`duas_procedures_criacao.png`)**  
  Comprova a compilação bem-sucedida de `pr_buscar_unidades_proximas` e `prc_realizar_checkin` no schema Oracle sem erros ou warnings.  
  ![Compilação das duas Stored Procedures](Evidencias/duas_procedures_criacao.png)

- **Execução da Procedure `prc_realizar_checkin` (`procedure_checkin.png`)**  
  Comprova o check-in transacional para o paciente de CPF `'00000000007'` na unidade `8922` (`CLINICO_GERAL`), gerando e retornando a senha sequencial via parâmetro `OUT` com `COMMIT`.  
  ![Execução da procedure prc_realizar_checkin](Evidencias/procedure_checkin.png)

- **Execução da Procedure `pr_buscar_unidades_proximas` (`procedure_unidades_proximas_mim.png`)**  
  Comprova a busca geoespacial por Haversine + Bounding Box (raio de `5.0 km`, limite `5`) retornando as unidades mais próximas ordenadas por distância em quilômetros via `SYS_REFCURSOR`.  
  ![Execução da procedure pr_buscar_unidades_proximas](Evidencias/procedure_unidades_proximas_mim.png)

---

## ✅ 8. Matriz de Conformidade com o Edital FIAP (70 Pontos)

### 8.1. Mapeamento Direto: Requisitos Obrigatórios vs. Implementação

| Requisito | Critério Oficial do Edital | Pontuação | Implementação no `scriptoracle.sql` | Evidência Comprobatória |
| :---: | :--- | :---: | :--- | :--- |
| **01** | **Modelo Oracle:** Mínimo 4 tabelas relacionadas (3FN) + mínimo 10 registros por tabela. | **10 pts** | **9 tabelas** normalizadas em 3FN, 8 sequences, 6 índices + 10 a 13 registros semente (e **90.396** via Python ETL). | `logs_criacao_base.png`, `quantidade_registros.png`, `todos_selects_executados.png` |
| **02** | **Bloco Anônimo PL/SQL:** Variáveis locais, `SELECT ... INTO`, `DBMS_OUTPUT` e exceções. | **10 pts** | **Seção 7** (linhas 267–375): Variáveis `%TYPE`, junção quádrupla com `SELECT INTO` e tratamento de `NO_DATA_FOUND` e `TOO_MANY_ROWS`. | `bloco_anonimo_executado.png` |
| **03** | **Decisão `IF / ELSIF / ELSE`:** Regra de negócio justificada no contexto CitizenTech. | **10 pts** | **Seção 7** (linhas 318–343): Classificação de risco clínico baseada no **Protocolo de Manchester** e verificação de violação de SLA. | `bloco_anonimo_executado.png` |
| **04** | **Repetição (`LOOP` / `FOR` / `WHILE`):** Processamento funcional em lote de registros. | **10 pts** | **Seção 8** (linhas 397–405): Laço `LOOP` iterando sobre a fila ativa da UBS e contabilizando o total de pacientes aguardando. | `cursor_explicito_loop.png` |
| **05** | **Cursor Explícito:** Declaração, `OPEN`, `FETCH`, `%NOTFOUND` e `CLOSE` percorrendo dados do projeto. | **15 pts** | **Seção 8** (linhas 378–409): `CURSOR c_fila_espera` listando a fila FIFO da unidade `8922` (`PA MUN SAO MATEUS II`). | `cursor_explicito_loop.png` |
| **06** | **2 Stored Procedures:** 1 de Operação (DML) e 1 de Consulta/Processamento em lote. | **15 pts** | **Seção 9:** `pr_buscar_unidades_proximas` (Haversine + `SYS_REFCURSOR`) e `prc_realizar_checkin` (DML `INSERT` com `IN`/`OUT` e `COMMIT`). | `duas_procedures_criacao.png`, `procedure_checkin.png`, `procedure_unidades_proximas_mim.png` |
| **TOTAL** | **COBERTURA INTEGRAL DOS REQUISITOS TÉCNICOS** | **70 pts** | **100% dos requisitos implementados e executados sem erros** | **17 evidências verificadas** |

### 8.2. Prevenção de Penalidades do Edital
- **Entrega no prazo e via Portal do Aluno:** Pacote estruturado para submissão até 19/11/2026 às 23h55.
- **Aderência ao tema CitizenTech:** Solução voltada à saúde pública (SUS), transparência de filas e acesso geolocalizado ao cidadão.
- **Identificação formal do grupo:** Arquivo [`identificacao_grupo.txt`](identificacao_grupo.txt) incluído na raiz com RM, nome completo e turma.
- **Execução limpa e evidenciada:** Scripts testados de ponta a ponta no Oracle com 17 capturas de tela em `Evidencias/`.

---

## 📁 9. Estrutura dos Arquivos do Repositório

```text
oracle-database-nexa/
│
├── Evidencias/                   # 17 prints de execução e validação no Oracle Database
├── scriptoracle.sql              # Script mestre completo (DDL, DML, Procedures e Blocos PL/SQL)
├── identificacao_grupo.txt       # Arquivo de identificação formal da equipe (RM, Nome, Turma)
└── README.md                     # Documentação conceitual, 3FN, DER, ETL Python, evidências e matriz FIAP
```

---

## ⚖️ 10. Licença e Direitos

Projeto desenvolvido exclusivamente para fins acadêmicos como parte da **Global Solution 2026/2 da FIAP**.  
Tema: **CitizenTech — Tecnologia a Serviço do Cidadão**.
