# Guia de Arquitetura, Execução e Integração – Banco de Dados (NEXA)
**Global Solution 2026/2 – Tema CitizenTech**  
**Disciplina:** Mastering Relational and Non-Relational Database (FIAP)  
**Projeto Integrado:** NEXA Saúde Pública (Oracle + Spring Boot + .NET)  
**Data da Análise:** 11/11/2026 | **Prazo Final de Entrega:** 19/11/2026 às 23h55  

---

## 1. Visão Geral e Estratégia dos Dados

### 1.1. Separação Inteligente: Script da Entrega vs Carga Massiva (Python)
Sua decisão de engenharia de dados está **perfeita e é a mais recomendada pelo mercado**:

1. **Arquivo Oficial da Entrega (`scriptoracle.sql`):**
   - Contém a infraestrutura DDL completa (9 tabelas em 3FN, sequences e índices).
   - Contém a carga oficial de 10 a 13 registros por tabela (já implementada!).
   - Contém os blocos PL/SQL, Cursores e Procedures.
   - **Tempo de execução:** ~2 segundos.
   - **Objetivo:** Garantir os 70 pontos da avaliação da FIAP sem risco de travar a máquina do professor ou estourar quota do tablespace.

2. **Pipeline de Carga Massiva (Python ETL - CNES/SUS):**
   - **Entrada:** Base bruta do Ministério da Saúde (> 600.000 registros).
   - **Tratamento no Python:**
     - Filtro SUS: apenas estabelecimentos onde `atende_sus == 'Sim'`.
     - Filtro Geo: descarte de registros sem coordenadas ou coordenadas inválidas (`latitude != 0` e `longitude != 0`).
     - Filtro Tipos: enquadramento nos Enums mapeados no Java (`POSTO_DE_SAUDE`, `CENTRO_DE_SAUDE_UNIDADE_BASICA`, `PRONTO_ATENDIMENTO`, `HOSPITAL_GERAL`, etc.).
     - **Volume final filtrado:** ~90.000 registros.
   - **Estratégia de Inserção no Oracle para NÃO travar:**
     - Utilizar a biblioteca oficial `python-oracledb`.
     - Usar `cursor.executemany()` com **batches de 2.000 a 5.000 registros**.
     - Realizar `connection.commit()` a cada lote para não esgotar a área de UNDO/REDO do Oracle.
   - **Objetivo:** Alimentar a API Spring Boot e .NET com dados reais de todo o Brasil para impressionar a banca na apresentação presencial.

---

## 2. Alinhamento de Negócio: Spring Boot ↔ Oracle PL/SQL

Analisamos o código do backend Java em [`AtendimentoServiceImpl.java`](file:///C:/Users/paulo_xeqkecn/Faculdade%20FIAP/GlobalSolution2026/JavaAdvanced/gs-springboot/src/main/java/br/com/gs/springboot/gs_springboot/service/AtendimentoServiceImpl.java) e desenhamos a camada PL/SQL para espelhar **exatamente** as mesmas regras de negócio do Spring Boot. Isso demonstra maturidade arquitetural máxima para os professores da FIAP.

---

## 3. Especificação dos Componentes PL/SQL

### 3.1. Bloco Anônimo + `IF/ELSIF/ELSE` + Tratamento de Exceções (20 Pontos)
- **Objetivo:** Simular a consulta detalhada de um atendimento específico, calculando a **prioridade de triagem e SLA de atendimento** com base no tipo de serviço e no tempo aguardando.
- **Tratamento de Exceções:** Trata explicitamente `NO_DATA_FOUND` (atendimento não localizado) e `TOO_MANY_ROWS`.

#### Código Modelo:
```sql
SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_id_atendimento      tb_atendimento.id%TYPE := 3; -- ID de teste
    v_paciente_nome       tb_paciente.nome%TYPE;
    v_unidade_nome        tb_unidade_saude.nome%TYPE;
    v_senha               tb_atendimento.senha%TYPE;
    v_servico             tb_atendimento.servico%TYPE;
    v_status              tb_atendimento.status_atendimento%TYPE;
    v_minutos_espera      NUMBER;
    v_classificacao_risco VARCHAR2(50);
    v_sla_maximo_minutos  NUMBER;
BEGIN
    -- 1. Consulta com SELECT ... INTO e JOIN
    SELECT p.nome, u.nome, a.senha, a.servico, a.status_atendimento,
           ROUND((NVL(a.data_hora_chamada, CURRENT_TIMESTAMP) - a.data_hora_chegada) * 24 * 60)
    INTO v_paciente_nome, v_unidade_nome, v_senha, v_servico, v_status, v_minutos_espera
    FROM tb_atendimento a
    JOIN tb_paciente p ON a.id_paciente = p.id
    JOIN tb_unidade_saude u ON a.id_unidade_saude = u.id
    WHERE a.id = v_id_atendimento;

    -- 2. Estrutura Condicional com Regra de Negócio CitizenTech (Triagem e SLA)
    IF v_servico = 'TRIAGEM' THEN
        v_classificacao_risco := 'EMERGÊNCIA / CRÍTICO';
        v_sla_maximo_minutos  := 15;
    ELSIF v_servico = 'PEDIATRIA' THEN
        v_classificacao_risco := 'PRIORITÁRIO (CRIANÇAS/LACTANTES)';
        v_sla_maximo_minutos  := 30;
    ELSIF v_servico = 'CLINICO_GERAL' AND v_minutos_espera > 40 THEN
        v_classificacao_risco := 'URGÊNCIA MODERADA (TEMPO ELEVADO)';
        v_sla_maximo_minutos  := 45;
    ELSE
        v_classificacao_risco := 'REGULAR / BAIXA COMPLEXIDADE';
        v_sla_maximo_minutos  := 60;
    END IF;

    -- 3. Saída formatada no console
    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE('     NEXA - PROTOCOLO DE TRIAGEM CIDADÃ');
    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE('Paciente:       ' || v_paciente_nome);
    DBMS_OUTPUT.PUT_LINE('Unidade:        ' || v_unidade_nome);
    DBMS_OUTPUT.PUT_LINE('Senha:          ' || v_senha || ' (' || v_servico || ')');
    DBMS_OUTPUT.PUT_LINE('Status Fila:    ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Tempo Espera:   ' || v_minutos_espera || ' minutos');
    DBMS_OUTPUT.PUT_LINE('Classificação:  ' || v_classificacao_risco);
    DBMS_OUTPUT.PUT_LINE('SLA Alvo:       ' || v_sla_maximo_minutos || ' min');
    
    IF v_minutos_espera > v_sla_maximo_minutos THEN
        DBMS_OUTPUT.PUT_LINE('ALERTA SLA:    ATENDIMENTO FORA DO TEMPO LIMITE!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('STATUS SLA:     DENTRO DA META OPERACIONAL');
    END IF;
    DBMS_OUTPUT.PUT_LINE('==================================================');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERRO: Atendimento ID ' || v_id_atendimento || ' não foi localizado.');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('ERRO: A consulta retornou múltiplos atendimentos para o mesmo identificador.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERRO INESPERADO [' || SQLCODE || ']: ' || SQLERRM);
END;
/
```

---

### 3.2. Estrutura de Repetição + Cursor FOR LOOP (25 Pontos)
- **Objetivo:** O professor validou o uso do `SELECT dentro do LOOP`. Implementa o painel de monitoramento da fila em tempo real, percorrendo todos os atendimentos pendentes nas unidades de saúde e totalizando os dados.

#### Código Modelo:
```sql
DECLARE
    v_total_aguardando NUMBER := 0;
    v_total_chamados   NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('================================================================================');
    DBMS_OUTPUT.PUT_LINE('               NEXA - MONITORAMENTO DE FILAS EM TEMPO REAL');
    DBMS_OUTPUT.PUT_LINE('================================================================================');
    
    -- Cursor FOR LOOP com junção de tabelas
    FOR reg IN (
        SELECT u.nome AS unidade,
               a.senha,
               a.servico,
               p.nome AS paciente,
               a.status_atendimento,
               ROUND((CURRENT_TIMESTAMP - a.data_hora_chegada) * 24 * 60) AS minutos_espera
        FROM tb_atendimento a
        JOIN tb_unidade_saude u ON a.id_unidade_saude = u.id
        JOIN tb_paciente p ON a.id_paciente = p.id
        WHERE a.status_atendimento IN ('AGUARDANDO', 'CHAMADO')
        ORDER BY a.id_unidade_saude, a.data_hora_chegada ASC
    ) LOOP
        -- Atualização dos contadores
        IF reg.status_atendimento = 'AGUARDANDO' THEN
            v_total_aguardando := v_total_aguardando + 1;
        ELSE
            v_total_chamados := v_total_chamados + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            '[' || RPAD(reg.status_atendimento, 10) || '] ' ||
            'Senha: ' || RPAD(reg.senha, 8) || ' | ' ||
            'Serviço: ' || RPAD(reg.servico, 14) || ' | ' ||
            'Espera: ' || LPAD(reg.minutos_espera, 3) || ' min | ' ||
            'Unidade: ' || RPAD(reg.unidade, 32) || ' | ' ||
            'Paciente: ' || reg.paciente
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('RESUMO OPERACIONAL:');
    DBMS_OUTPUT.PUT_LINE('Total de Pacientes Aguardando: ' || v_total_aguardando);
    DBMS_OUTPUT.PUT_LINE('Total de Pacientes em Chamada: ' || v_total_chamados);
    DBMS_OUTPUT.PUT_LINE('Total Ativo na Fila:           ' || (v_total_aguardando + v_total_chamados));
    DBMS_OUTPUT.PUT_LINE('================================================================================');
END;
/
```

---

### 3.3. As Duas Stored Procedures Obrigatórias (15 Pontos)

#### Procedure 1 (Transacional / DML): `prc_chamar_proximo_fila`
- **Espelho no Spring Boot:** Método `chamarProximoDaFila` do [`AtendimentoServiceImpl.java`](file:///C:/Users/paulo_xeqkecn/Faculdade%20FIAP/GlobalSolution2026/JavaAdvanced/gs-springboot/src/main/java/br/com/gs/springboot/gs_springboot/service/AtendimentoServiceImpl.java#L121).
- **O que faz:** Recebe o ID da unidade, o serviço e o ID do médico/colaborador. Localiza o primeiro paciente da fila (`AGUARDANDO`), altera seu status para `'CHAMADO'`, atribui a data/hora e o colaborador responsável, e retorna a senha via parâmetro `OUT`.

```sql
CREATE OR REPLACE PROCEDURE prc_chamar_proximo_fila (
    p_id_unidade     IN  tb_unidade_saude.id%TYPE,
    p_servico        IN  tb_atendimento.servico%TYPE,
    p_id_colaborador IN  tb_colaborador.id%TYPE,
    p_senha_chamada  OUT VARCHAR2
) IS
    v_id_atendimento tb_atendimento.id%TYPE;
BEGIN
    -- Busca o primeiro paciente aguardando por ordem de chegada (FIFO)
    SELECT id, senha
    INTO v_id_atendimento, p_senha_chamada
    FROM (
        SELECT id, senha
        FROM tb_atendimento
        WHERE id_unidade_saude = p_id_unidade
          AND servico = p_servico
          AND status_atendimento = 'AGUARDANDO'
        ORDER BY data_hora_chegada ASC, id ASC
    )
    WHERE ROWNUM = 1;

    -- Atualiza o atendimento para status CHAMADO
    UPDATE tb_atendimento
    SET status_atendimento = 'CHAMADO',
        data_hora_chamada  = CURRENT_TIMESTAMP,
        id_colaborador     = p_id_colaborador
    WHERE id = v_id_atendimento;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SUCESSO: Paciente chamado com a senha ' || p_senha_chamada);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_senha_chamada := NULL;
        DBMS_OUTPUT.PUT_LINE('AVISO: Não há pacientes aguardando para a especialidade ' || p_servico);
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERRO ao chamar próximo da fila: ' || SQLERRM);
        RAISE;
END;
/
```

#### Procedure 2 (Analítica / Lote): `prc_atualizar_tempo_espera_unidades`
- **Espelho no Spring Boot:** Método `atualizarTempoEsperaUnidade` do [`AtendimentoServiceImpl.java`](file:///C:/Users/paulo_xeqkecn/Faculdade%20FIAP/GlobalSolution2026/JavaAdvanced/gs-springboot/src/main/java/br/com/gs/springboot/gs_springboot/service/AtendimentoServiceImpl.java#L111).
- **O que faz:** Percorre todas as unidades de saúde cadastradas, conta em lote quantos pacientes estão aguardando e recalcula o campo `tempo_espera` de cada unidade (`fila * 20 minutos`), gerando um relatório gerencial consolidado no console.

```sql
CREATE OR REPLACE PROCEDURE prc_atualizar_tempo_espera_unidades (
    p_minutos_por_paciente IN NUMBER DEFAULT 20
) IS
    v_pacientes_fila NUMBER;
    v_novo_tempo     NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================================');
    DBMS_OUTPUT.PUT_LINE('       CONSOLIDAÇÃO ANALÍTICA DE TEMPO DE ESPERA DAS UNIDADES');
    DBMS_OUTPUT.PUT_LINE('====================================================================');

    FOR r_unidade IN (SELECT id, nome, tempo_espera FROM tb_unidade_saude ORDER BY id) LOOP
        -- Conta quantos pacientes estão na fila aguardando nesta unidade
        SELECT COUNT(*)
        INTO v_pacientes_fila
        FROM tb_atendimento
        WHERE id_unidade_saude = r_unidade.id
          AND status_atendimento = 'AGUARDANDO';

        -- Calcula a estimativa de tempo
        v_novo_tempo := v_pacientes_fila * p_minutos_por_paciente;

        -- Atualiza a tabela tb_unidade_saude
        UPDATE tb_unidade_saude
        SET tempo_espera = v_novo_tempo
        WHERE id = r_unidade.id;

        DBMS_OUTPUT.PUT_LINE(
            'Unidade [' || r_unidade.id || '] ' || RPAD(r_unidade.nome, 35) ||
            ' | Pacientes: ' || LPAD(v_pacientes_fila, 2) ||
            ' | Tempo Espera: ' || LPAD(v_novo_tempo, 3) || ' min'
        );
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('====================================================================');
    DBMS_OUTPUT.PUT_LINE('Consolidação concluída e persistida com sucesso.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERRO na consolidação de tempo de espera: ' || SQLERRM);
        RAISE;
END;
/
```

---

## 4. O Ecossistema Integrado: Oracle + Java Spring Boot + .NET

```
                ┌────────────────────────────────────────────────┐
                │             ORACLE DATABASE (19c/23c)          │
                │                                                │
                │  tb_estado ─── tb_municipio ─── tb_localizacao │
                │                                        │       │
                │  tb_cidadao ── tb_unidade_saude ───────┘       │
                │       │                │                       │
                │  tb_paciente ──── tb_atendimento ─── tb_colab  │
                └────────────────────────┬───────────────────────┘
                                         │
                   ┌─────────────────────┴─────────────────────┐
                   │                                           │
                   ▼                                           ▼
         [JAVA SPRING BOOT]                           [.NET BACKEND]
    • JPA / Hibernate (ddl-auto: update)        • Entity Framework Core
    • Spring Security + JWT                     • Migrations / Scaffold
    • Fila e Gestão de Espera                   • Serviços de Integração
```

- **Para o Java:** As entidades já estão mapeadas perfeitamente para as 9 tabelas (`tb_...`) com os enums como String.
- **Para o .NET:** Se você for usar Entity Framework Core no .NET, em vez de criar migrations que possam conflitar com o Oracle, a melhor prática é rodar o comando de **Scaffold (Database-First)** apontando para a base Oracle já criada:
  ```bash
  dotnet ef dbcontext scaffold "User Id=RMxxx;Password=xxx;Data Source=oracle.fiap.com.br:1521/ORCL" Oracle.EntityFrameworkCore -o Models
  ```
  Ele gera automaticamente as models C# espelhando o banco exato, sem você precisar escrever uma linha de migration manual!

---

## 5. Cronograma Recomendado para os Próximos Dias

| Data | Ação Principal | Meta do Dia |
| :--- | :--- | :--- |
| **12/11 (Amanhã)** | Subir o `scriptoracle.sql` no banco Oracle da FIAP e testar o Spring Boot conectado. | Validar que o Java inicia sem erro com `ddl-auto: update`. |
| **13/11** | Adicionar os Blocos PL/SQL e as 2 Procedures ao `scriptoracle.sql`. | Rodar e verificar as saídas no `DBMS_OUTPUT`. |
| **14/11** | Executar o script Python de ETL da base CNES (filtrando os 90k) em background. | Base populada com unidades reais de todo o Brasil. |
| **15/11** | Capturar os prints das telas com `DBMS_OUTPUT` para a pasta `/evidencias/`. | Artefatos visuais prontos. |
| **16/11 a 17/11** | Montar o pacote `.zip` final com `identificacao_grupo.txt` e README. | Projeto 100% blindado contra penalidades. |
| **19/11** | **Submissão Final no Portal FIAP até 23h55.** | Entrega concluída com folga. |
