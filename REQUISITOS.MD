# Documento Oficial de Requisitos — Mastering Relational and Non-Relational Database (Global Solution 2026/2)

---

## 1. Identificação da Disciplina e do Projeto

| Campo | Descrição |
| :--- | :--- |
| **Instituição** | FIAP |
| **Avaliação** | Global Solution 2026/2 |
| **Disciplina** | Mastering Relational and Non-Relational Database |
| **Tema** | CitizenTech |
| **Projeto** | **Nexa** *(anteriormente apresentado como Atendimento Claro)* |
| **Foco da Disciplina** | Camada de processamento de dados e regras de negócio em **Oracle PL/SQL** |

---

## 2. Objetivo da Entrega

### Desafio Oficial (Extraído do PDF da Global Solution 2026/2)

> **Desafio:** desenvolver a camada de processamento de dados da solução CitizenTech utilizando Oracle PL/SQL. O grupo deverá implementar regras de negócio que atendam ao problema real escolhido, com dados consistentes e execução demonstrável.
>
> Utilizar tabelas relacionadas do projeto (mínimo de quatro), com registros de teste (mínimo de 10 linhas por tabela, e construir blocos anônimos, decisões, repetições, cursores e procedimentos armazenados.
>
> **Ex.:** priorizar solicitações cidadãs, classificar riscos ou processar atendimentos.
>
> A avaliação considera funcionamento, aderência ao contexto, clareza do código e demonstração dos resultados.

> [!IMPORTANT]
> **Escopo Exclusivo de Banco de Dados:** O objetivo desta disciplina é desenvolver a camada de processamento de dados utilizando **Oracle PL/SQL**. Esta entrega não deve ser confundida com a implementação das APIs em Java Spring Boot ou .NET. Todo o foco recai sobre a demonstração de regras de negócio e processamento diretamente no banco de dados Oracle, utilizando os recursos exigidos pela FIAP.

---

## 3. Contexto do Nexa

O **Nexa** (anteriormente apresentado como *Atendimento Claro*) é uma solução **CitizenTech** que auxilia cidadãos a encontrar unidades de saúde que oferecem o serviço desejado, comparando distância, quantidade de pessoas aguardando, situação da fila e faixa estimada de espera.

### Funcionalidades do Ecossistema Nexa
- Permitir que o **cidadão** consulte unidades de saúde compatíveis com o serviço escolhido.
- Permitir que a **equipe** registre chegadas e atualize o andamento dos atendimentos.
- Garantir que o **sistema** mantenha informações operacionais das filas.
- Permitir que o **aplicativo** apresente informações atualizadas ao cidadão.

### Contexto Técnico Geral da Solução
- **Banco de Dados Oficial:** Oracle Database (com Oracle SQL e PL/SQL).
- **Aplicação Operacional (integração externa ao escopo PL/SQL):** Java Spring Boot para gestão operacional das filas.
- **Aplicação Administrativa (integração externa ao escopo PL/SQL):** .NET com EF Core para administração de unidades e serviços.
- **Massa de Dados:** Dados fictícios consistentes para demonstração acadêmica.
- **Flexibilidade de Modelagem:** O banco e as entidades definitivas ainda podem ser ajustados durante a implementação, desde que respeitem integralmente os requisitos mínimos da disciplina.

---

## 4. Tecnologias Exigidas

Para o cumprimento estrito dos requisitos desta disciplina, as tecnologias obrigatórias são:

1. **Oracle Database** — Sistema Gerenciador de Banco de Dados Relacional onde as tabelas, restrições de integridade e objetos programáveis serão criados.
2. **Oracle SQL (DDL e DML)** — Para criação das tabelas relacionadas (mínimo de 4 tabelas) e carga dos registros de teste (mínimo de 10 linhas por tabela).
3. **Oracle PL/SQL** — Para implementação obrigatória de:
   - Blocos anônimos com variáveis, `SELECT INTO` e `DBMS_OUTPUT`.
   - Estruturas de decisão (`IF` / `ELSIF` / `ELSE`).
   - Estruturas de repetição (`FOR`, `WHILE` ou `LOOP`).
   - Cursores explícitos (`CURSOR`, `OPEN`, `FETCH`, `CLOSE` ou uso de cursor explícito declarado).
   - Procedimentos armazenados (`CREATE OR REPLACE PROCEDURE`).

> [!WARNING]
> Não substitua recursos de **Oracle PL/SQL** por código de aplicação externa (Java/.NET) nem substitua **procedimentos armazenados (`PROCEDURE`)** por funções (`FUNCTION`).

---

## 5. Requisitos Oficiais Numerados

Requisitos extraídos integralmente do documento oficial da Global Solution 2026/2:

- **01.** Modelo Oracle: ao menos 4 tabelas relacionadas, com dados de teste *(mínimo de 10 linhas por tabela, conforme detalhamento da entrega)*.
- **02.** Bloco anônimo PL/SQL com variáveis, SELECT INTO e saída DBMS_OUTPUT.
- **03.** Decisão IF/ELSIF/ELSE para regra de negócio justificada.
- **04.** Repetição FOR, WHILE ou LOOP para processamento de registros.
- **05.** Cursor explícito para percorrer e apresentar dados do projeto.
- **06.** 2 procedimentos armazenados: um de operação e outro de consulta/processamento.

---

## 6. Pontuação Oficial (Entrega — 70% da Nota)

> [!NOTE]
> Os valores entre colchetes abaixo preservam **exatamente** a grafia/placeholders apresentados no PDF oficial da FIAP. Esses campos não foram alterados ou presumidos e devem ser confirmados caso haja atualização do documento oficial no Portal do Aluno.

| Item | Critério de Avaliação | Pontuação (conforme PDF) |
| :--- | :--- | :--- |
| **01.** | Modelo de dados e carga coerentes | `[_1 0 _]` pts. |
| **02.** | Bloco anônimo e saída verificável | `[_1 0 _]` pts. |
| **03.** | Decisão aplicada à regra de negócio | `[_1 0 _]` pts. |
| **04.** | Repetição com processamento funcional | `[_1 0 _]` pts. |
| **05.** | Cursor explícito com leitura de registros | `[_1 5 _]` pts. |
| **06.** | Dois procedimentos executáveis | `[_1 5 _]` pts. |
| **TOTAL** | **Pontuação da Entrega** | **70 pts.** |

---

## 7. Penalidades Oficiais (O Que Tira Pontos)

> [!CAUTION]
> Os valores entre colchetes abaixo foram mantidos **exatamente** como constam no PDF oficial da Global Solution 2026/2, sem alterações ou presunções.

- **01.** Entrega fora do prazo ou fora do Portal do Aluno — **Nota ZERO**.
- **02.** Arquivo corrompido, incompleto ou sem o .txt de identificação — **Até `[_1 0 _]` pts.**
- **03.** Solução sem relação com o tema CitizenTech — **Nota ZERO**.
- **04.** Scripts com erros que impedem a execução — **Até `[_30 ]` pts.**
- **05.** Ausência de evidências ou dados de teste — **Até `[_3 0 ]` pts.**

---

## 8. Entregáveis

A entrega oficial é composta por **três grupos obrigatórios de artefatos**:

### 8.1. Scripts `.sql`
- Criação das tabelas.
- Carga das tabelas.
- Códigos PL/SQL organizados.

### 8.2. `README` ou `PDF`
- Problema.
- Regras de negócio.
- Instruções de execução.
- Resultados.

### 8.3. Evidências
- Capturas das execuções dos blocos.
- Capturas da execução do cursor.
- Capturas da execução dos procedimentos.

### Formato de Submissão (conforme PDF)
```text
[ex.: um .zip com o código-fonte e o .txt de identificação do grupo]
```
> [!NOTE]
> A indicação `[ex.: um .zip com o código-fonte e o .txt de identificação do grupo]` aparece como exemplo/placeholder no PDF oficial. Confirme as instruções de empacotamento no Portal do Aluno antes da submissão final, garantindo sempre a presença do arquivo `.txt` de identificação do grupo citado nas regras de penalidade.

---

## 9. Critérios da Apresentação Presencial — 30% da Nota

- **Período:** 23 a 27/11, na aula da disciplina.

> [!NOTE]
> Assim como na seção de pontuação da entrega, os placeholders entre colchetes abaixo reproduzem fielmente o documento oficial e devem ser confirmados na versão final do professor/coordenação.

| Item | Critério da Apresentação Presencial | Pontuação (conforme PDF) |
| :--- | :--- | :--- |
| **01.** | Contexto e regras de negócio do projeto | `[_5 _]` pts. |
| **02.** | Execução do bloco anônimo e decisão | `[_5 _]` pts. |
| **03.** | Demonstração da estrutura de repetição | `[_5 _]` pts. |
| **04.** | Execução e explicação do cursor | `[_5 _]` pts. |
| **05.** | Execução dos dois procedimentos | `[_5 _]` pts. |
| **06.** | Domínio técnico e respostas do grupo | `[_5 _]` pts. |
| **TOTAL** | **Pontuação da Apresentação Presencial** | **30 pts.** |

**Composição Total da Nota da Disciplina:** `70 pts (Entrega)` + `30 pts (Apresentação Presencial)` = `100 pts`.

---

## 10. PROPOSTA TÉCNICA PARA O NEXA (Sugestões de Aplicação)

> [!IMPORTANT]
> **Aviso de Escopo:** Esta seção constitui uma **PROPOSTA TÉCNICA PARA O NEXA** com caráter orientativo para auxiliar o grupo na implementação. **Não se trata de exigência adicional da FIAP**, nem substitui ou engessa a modelagem definitiva do projeto, que pode ser ajustada durante o desenvolvimento desde que cumpra os Requisitos 01 a 06.

### 10.1. Sugestão de Modelagem Relacional (Mínimo de 4 Tabelas Relacionadas e 10 Linhas por Tabela)

Como o banco e as entidades definitivas ainda podem ser ajustados, sugere-se abaixo uma estrutura possível de quatro ou mais tabelas relacionadas aderentes ao domínio do Nexa:

1. **Unidades de Saúde (ex.: `TB_NEXA_UNIDADE_SAUDE`)**
   - Representa os locais de atendimento (UBS, UPA, AMA, Hospital Municipal), contendo localização, bairro/cidade, capacidade operacional e status de funcionamento.
2. **Serviços de Saúde (ex.: `TB_NEXA_SERVICO`)**
   - Catálogo de serviços buscados pelo cidadão (ex.: Clínico Geral, Pediatria, Vacinação, Ortopedia, Triagem Odontológica), com tempo médio base estimado de atendimento.
3. **Oferta de Serviço / Fila por Unidade (ex.: `TB_NEXA_UNIDADE_SERVICO` ou `TB_NEXA_FILA_OPERACIONAL`)**
   - Relaciona quais unidades oferecem quais serviços (`FK` para Unidade e `FK` para Serviço) e consolida informações operacionais da fila (quantidade de pessoas aguardando, situação atual da fila, faixa estimada de espera).
4. **Registros de Atendimento / Chegadas na Fila (ex.: `TB_NEXA_ATENDIMENTO`)**
   - Registra os atendimentos/chegadas de cidadãos vinculados a uma unidade/serviço ou fila operacional, contendo horário de chegada, prioridade/risco, status do atendimento (`AGUARDANDO`, `EM_ATENDIMENTO`, `FINALIZADO`, `CANCELADO`) e horários de início/conclusão.
5. *(Opcional)* **Cidadão / Paciente (ex.: `TB_NEXA_CIDADAO`)**
   - Caso o grupo deseje separar os dados cadastrais básicos do cidadão em uma quinta tabela vinculada aos registros de atendimento.

**Como garantir a consistência exigida:**
- Cada tabela criada deve possuir chave primária (`PK`), chaves estrangeiras (`FK`) conectando o fluxo de ponta a ponta e ao menos **10 registros fictícios coerentes por tabela** (`INSERT INTO`).

---

### 10.2. Sugestões Práticas para Cada Requisito de PL/SQL no Contexto do Nexa

#### A. Bloco Anônimo (`Requisito 02`)
- **Objetivo Técnico:** Demonstrar consulta de dados de atendimento utilizando variáveis declaradas em `DECLARE`, `SELECT INTO` e exibição via `DBMS_OUTPUT.PUT_LINE`.
- **Aplicação Sugerida no Nexa:**
  - Consultar o resumo de um atendimento específico ou de uma fila operacional específica (por ID), armazenando em variáveis PL/SQL o nome da unidade de saúde, o nome do serviço buscado, a quantidade atual de pessoas aguardando e o tempo/faixa estimada de espera, imprimindo um boletim formatado no console com `DBMS_OUTPUT`.

#### B. Estrutura de Decisão `IF / ELSIF / ELSE` (`Requisito 03`)
- **Objetivo Técnico:** Utilizar `IF / ELSIF / ELSE` para aplicar uma regra operacional justificada ao contexto da fila.
- **Aplicação Sugerida no Nexa:**
  - Avaliar a quantidade de pessoas aguardando ou o tempo estimado de espera de uma fila/unidade para classificar operacionalmente a situação de atendimento:
    - `IF` a quantidade aguardando for baixa (ex.: `<= 5` pessoas ou espera `<= 15 min`) $\rightarrow$ Classificar situação como `'NORMAL / FLUXO LIVRE'` (Faixa Rápida).
    - `ELSIF` a quantidade aguardando for moderada (ex.: entre `6` e `15` pessoas ou espera até `45 min`) $\rightarrow$ Classificar situação como `'MODERADA / ATENÇÃO'` (Faixa Média).
    - `ELSE` (acima do limite operacional) $\rightarrow$ Classificar situação como `'CRÍTICA / SUPERLOTADA'` e recomendar redirecionamento do cidadão para outra unidade compatível.

#### C. Estrutura de Repetição `FOR`, `WHILE` ou `LOOP` (`Requisito 04`)
- **Objetivo Técnico:** Processar registros de atendimentos ou unidades utilizando `FOR`, `WHILE` ou `LOOP`.
- **Aplicação Sugerida no Nexa:**
  - Percorrer um conjunto de unidades de saúde ou filas operacionais para recalcular o tempo estimado de espera com base nos atendimentos com status `'AGUARDANDO'`, contabilizando totais acumulados (ex.: total de cidadãos aguardando na rede e média de espera) e exibindo o processamento registro a registro.

#### D. Cursor Explícito (`Requisito 05`)
- **Objetivo Técnico:** Declarar e manipular um cursor explícito (`CURSOR ... IS`, `OPEN`, `FETCH`, `CLOSE`) para percorrer registros relacionados ao atendimento e apresentar os resultados.
- **Aplicação Sugerida no Nexa:**
  - Criar um cursor explícito que faça `JOIN` entre **Unidade de Saúde**, **Serviço**, **Fila/Oferta** e **Atendimentos** para listar o painel detalhado dos atendimentos em andamento/aguardando ou o comparativo de unidades compatíveis com determinado serviço, apresentando cada linha formatada via `DBMS_OUTPUT`.

#### E. Dois Procedimentos Armazenados (`Requisito 06`)
- **Objetivo Técnico:** Implementar 2 procedimentos armazenados (`CREATE OR REPLACE PROCEDURE`), sendo **um de operação** e **outro de consulta/processamento**, ambos relacionados ao Nexa.
- **Aplicação Sugerida no Nexa:**
  1. **Procedimento 1 — Operação (DML / Transacional):**
     - *Exemplo:* `PRC_REGISTRAR_ATUALIZAR_ATENDIMENTO` ou `PRC_ATUALIZAR_STATUS_FILA` — Recebe parâmetros (como ID do atendimento ou dados de chegada na fila, novo status e unidade/serviço), valida a existência do registro, insere um novo atendimento ou atualiza o status do atendimento (ex.: de `'AGUARDANDO'` para `'EM_ATENDIMENTO'` ou `'FINALIZADO'`), atualiza o contador operacional da fila correspondente, realiza `COMMIT` e informa o resultado via `DBMS_OUTPUT` (com tratamento de exceções `EXCEPTION`).
  2. **Procedimento 2 — Consulta / Processamento:**
     - *Exemplo:* `PRC_CONSULTAR_UNIDADES_SERVICO` ou `PRC_CONSOLIDAR_SITUACAO_FILAS` — Recebe como parâmetro o código/nome de um serviço desejado (ou unidade), percorre as unidades compatíveis calculando a quantidade de pessoas aguardando, aplica a classificação da situação operacional da fila e a faixa estimada de espera, e exibe um relatório consolidado para apoiar a decisão do cidadão.

---

## 11. Sugestão de Organização dos Scripts SQL

Para atender ao entregável de **Scripts `.sql` organizados** e facilitar tanto a correção quanto a apresentação presencial, recomenda-se organizar o repositório na seguinte estrutura:

```text
oracle-database-nexa/
├── REQUISITOS.md                      # Este documento de referência oficial
├── README.md                          # Documentação exigida (Problema, Regras, Instruções, Resultados)
├── identificacao_grupo.txt            # Arquivo .txt com nomes e RMs dos integrantes
├── sql/
│   ├── 01_ddl_criacao_tabelas.sql     # DROP/CREATE TABLE, PKs, FKs, Constraints e Sequences
│   ├── 02_dml_carga_dados_teste.sql   # INSERTs com no mínimo 10 registros por tabela + COMMIT
│   ├── 03_plsql_blocos_cursor.sql     # Bloco anônimo (SELECT INTO), Decisão (IF/ELSIF/ELSE), Repetição e Cursor explícito
│   └── 04_plsql_procedimentos.sql     # Criação dos 2 Procedures (Operação e Consulta/Processamento) + chamadas de teste
└── evidencias/                        # Capturas de tela das execuções (blocos, cursor, procedures)
```

> [!TIP]
> Caso o grupo prefira entregar um único script consolidado além dos scripts modulares, pode-se manter também um arquivo mestre (ex.: `script_completo_nexa.sql`) contendo as seções claramente comentadas na mesma ordem lógica: **1. Criação das Tabelas**, **2. Carga das Tabelas** e **3. Códigos PL/SQL Organizados**.

---

## 12. Checklist de Implementação

Utilize este checklist durante o desenvolvimento para garantir que todos os itens obrigatórios da FIAP foram implementados:

- [ ] **Modelo Relacional (Requisito 01):** Foram criadas ao menos **4 tabelas relacionadas** no Oracle Database com chaves primárias (`PK`) e chaves estrangeiras (`FK`) consistentes com o contexto do Nexa?
- [ ] **Carga de Teste (Requisito 01):** Cada uma das tabelas possui no mínimo **10 linhas de dados de teste** inseridas e confirmadas (`COMMIT`)?
- [ ] **Bloco Anônimo (Requisito 02):** Há bloco anônimo PL/SQL utilizando variáveis declaradas, cláusula `SELECT INTO` e saída verificável com `DBMS_OUTPUT.PUT_LINE` (`SET SERVEROUTPUT ON`)?
- [ ] **Estrutura de Decisão (Requisito 03):** Há estrutura `IF / ELSIF / ELSE` implementando uma regra de negócio claramente justificada para o Nexa?
- [ ] **Estrutura de Repetição (Requisito 04):** Há estrutura `FOR`, `WHILE` ou `LOOP` realizando processamento funcional de registros do projeto?
- [ ] **Cursor Explícito (Requisito 05):** Há declaração e uso de cursor explícito percorrendo e apresentando dados das tabelas do Nexa?
- [ ] **Procedimento Armazenado de Operação (Requisito 06 - Parte 1):** Foi criada uma `PROCEDURE` de operação (inserção/atualização/manutenção operacional) executável e sem erros de compilação?
- [ ] **Procedimento Armazenado de Consulta/Processamento (Requisito 06 - Parte 2):** Foi criada uma `PROCEDURE` de consulta/processamento executável e sem erros de compilação?

---

## 13. Checklist de Validação, Documentação e Evidências

Antes de gerar o pacote final de submissão no Portal do Aluno e realizar a apresentação presencial (23 a 27/11), valide todos os itens abaixo para evitar perda de pontos ou nota zero:

### Validação Técnica dos Scripts (Prevenção contra penalidades de até `[_30 ]` pts)
- [ ] Todos os scripts `.sql` foram executados do início ao fim em uma sessão limpa do Oracle SQL Developer / Oracle Database sem apresentar erros (`ORA-*` / `PLS-*`)?
- [ ] O comando `SET SERVEROUTPUT ON;` está incluído no topo dos scripts PL/SQL para garantir a exibição do `DBMS_OUTPUT`?
- [ ] Os blocos `SELECT INTO` e as procedures possuem tratamento adequado ou massa de teste compatível para não falharem com `NO_DATA_FOUND` ou `TOO_MANY_ROWS` durante a avaliação?

### Validação de Evidências e Documentação (Prevenção contra penalidades de até `[_3 0 ]` pts)
- [ ] O arquivo `README.md` (ou `PDF`) contém:
  - [ ] Descrição clara do **Problema** (contexto CitizenTech / Nexa)?
  - [ ] Explicação das **Regras de negócio** implementadas em PL/SQL?
  - [ ] **Instruções de execução** passo a passo dos scripts?
  - [ ] Demonstração dos **Resultados** obtidos?
- [ ] As **Evidências** incluem capturas de tela legíveis:
  - [ ] Da execução dos blocos anônimos (com `SELECT INTO`, decisão e repetição) e saída no `DBMS_OUTPUT`?
  - [ ] Da execução do cursor explícito e saída no `DBMS_OUTPUT`?
  - [ ] Da compilação e execução dos **dois procedimentos armazenados** (`EXEC` / `BEGIN ... END;`) e seus resultados?

### Validação Administrativa e de Submissão (Prevenção contra Nota ZERO ou penalidade de até `[_1 0 _]` pts)
- [ ] O projeto mantém relação direta e explícita com o tema **CitizenTech** (Nexa)?
- [ ] O arquivo `.txt` de identificação do grupo (com nomes completos, RMs e turma) está incluído no pacote final?
- [ ] O arquivo compactado não está corrompido nem incompleto?
- [ ] O envio será realizado dentro do prazo oficial e exclusivamente pelo **Portal do Aluno**?

### Preparação para Apresentação Presencial (23 a 27/11 — 30 pts)
- [ ] O grupo está preparado para apresentar o contexto e regras de negócio (`[_5 _]` pts)?
- [ ] O ambiente está pronto para executar ao vivo o bloco anônimo e a decisão (`[_5 _]` pts)?
- [ ] O ambiente está pronto para demonstrar a estrutura de repetição (`[_5 _]` pts)?
- [ ] O grupo sabe executar e explicar o funcionamento do cursor explícito (`[_5 _]` pts)?
- [ ] O ambiente está pronto para executar os dois procedimentos armazenados (`[_5 _]` pts)?
- [ ] Todos os integrantes dominam o código PL/SQL para responder às perguntas técnicas (`[_5 _]` pts)?
