-- GLOBAL SOLUTION 2026 - CITIZENTECH (NEXA)
-- Script Oracle Database (100% Sincronizado com o Spring Boot)
-- =====================================================================
-- 1. DROP TABLES
DROP TABLE tb_atendimento CASCADE CONSTRAINTS;
DROP TABLE tb_colaborador CASCADE CONSTRAINTS;
DROP TABLE tb_paciente CASCADE CONSTRAINTS;
DROP TABLE tb_cidadao CASCADE CONSTRAINTS;
DROP TABLE tb_unidade_saude CASCADE CONSTRAINTS;
DROP TABLE tb_localizacao CASCADE CONSTRAINTS;
DROP TABLE tb_municipio CASCADE CONSTRAINTS;
DROP TABLE tb_estado CASCADE CONSTRAINTS;

-- 2. DROP SEQUENCES
DROP SEQUENCE seq_atendimento;
DROP SEQUENCE seq_colaborador;
DROP SEQUENCE seq_paciente;
DROP SEQUENCE seq_cidadao;
DROP SEQUENCE seq_unidade_saude;
DROP SEQUENCE seq_localizacao;
DROP SEQUENCE seq_municipio;
DROP SEQUENCE seq_estado;

-- 3. CREATE SEQUENCES
CREATE SEQUENCE seq_estado START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_municipio START WITH 1 INCREMENT BY 1 CACHE 100 NOCYCLE;
CREATE SEQUENCE seq_localizacao START WITH 1 INCREMENT BY 1 CACHE 1000 NOCYCLE;
CREATE SEQUENCE seq_unidade_saude START WITH 1 INCREMENT BY 1 CACHE 1000 NOCYCLE;
CREATE SEQUENCE seq_paciente START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_cidadao START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_colaborador START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_atendimento START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 4. CRIAÇÃO DAS TABELAS (3ª FORMA NORMAL - 3FN)
-- =====================================================================

-- 4.1. TABELA DE ESTADOS (UF - IBGE)
CREATE TABLE tb_estado (
    id          NUMBER(19) DEFAULT ON NULL seq_estado.NEXTVAL NOT NULL,
    codigo_uf   VARCHAR2(10),
    sigla       VARCHAR2(2) NOT NULL UNIQUE,
    nome        VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_tb_estado PRIMARY KEY (id)
);

-- 4.2. TABELA DE MUNICÍPIOS (IBGE)
CREATE TABLE tb_municipio (
    id                      NUMBER(19) DEFAULT ON NULL seq_municipio.NEXTVAL NOT NULL,
    codigo_municipio_ibge   VARCHAR2(20),
    nome                    VARCHAR2(120) NOT NULL,
    id_estado               NUMBER(19) NOT NULL,
    CONSTRAINT pk_tb_municipio PRIMARY KEY (id),
    CONSTRAINT fk_municipio_estado FOREIGN KEY (id_estado)
        REFERENCES tb_estado (id)
);

-- 4.3. TABELA DE LOCALIZAÇÕES (ENDEREÇOS E COORDENADAS WGS84)
CREATE TABLE tb_localizacao (
    id              NUMBER(19) DEFAULT ON NULL seq_localizacao.NEXTVAL NOT NULL,
    cep             VARCHAR2(15),
    logradouro      VARCHAR2(120),
    numero          VARCHAR2(120),
    bairro          VARCHAR2(120),
    id_municipio    NUMBER(19) NOT NULL,
    latitude        NUMBER(10, 7) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude       NUMBER(10, 7) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT pk_tb_localizacao PRIMARY KEY (id),
    CONSTRAINT fk_localizacao_municipio FOREIGN KEY (id_municipio)
        REFERENCES tb_municipio (id)
);

-- 4.4. TABELA DE UNIDADES DE SAÚDE (CNES / SUS)
CREATE TABLE tb_unidade_saude (
    id              NUMBER(19) DEFAULT ON NULL seq_unidade_saude.NEXTVAL NOT NULL,
    nome            VARCHAR2(255) NOT NULL,
    id_localizacao  NUMBER(19) UNIQUE,
    tempo_espera    NUMBER(10, 2) DEFAULT 0.0,
    tipo_unidade    VARCHAR2(60),
    CONSTRAINT pk_tb_unidade_saude PRIMARY KEY (id),
    CONSTRAINT fk_unidade_localizacao FOREIGN KEY (id_localizacao)
        REFERENCES tb_localizacao (id)
);

-- 4.5. TABELA DE PACIENTES (CIDADÃOS)
CREATE TABLE tb_paciente (
    id      NUMBER(19) DEFAULT ON NULL seq_paciente.NEXTVAL NOT NULL,
    cpf     VARCHAR2(15) NOT NULL UNIQUE,
    nome    VARCHAR2(150) NOT NULL,
    CONSTRAINT pk_tb_paciente PRIMARY KEY (id)
);

CREATE TABLE tb_cidadao(
     id                  NUMBER(19) DEFAULT ON NULL seq_cidadao.NEXTVAL NOT NULL,
     nome                VARCHAR2(150) NOT NULL,
     email               VARCHAR2(150) NOT NULL UNIQUE,
     senha               VARCHAR2(255) NOT NULL,
     aceite_localizacao  TIMESTAMP,
     CONSTRAINT pk_tb_cidadao PRIMARY KEY (id)
);

-- 4.6. TABELA DE COLABORADORES (PROFISSIONAIS DE SAÚDE)
CREATE TABLE tb_colaborador (
    id          NUMBER(19) DEFAULT ON NULL seq_colaborador.NEXTVAL NOT NULL,
    nome        VARCHAR2(150) NOT NULL,
    cargo       VARCHAR2(100),
    email       VARCHAR2(150) NOT NULL UNIQUE,
    senha       VARCHAR2(255) NOT NULL,
    id_unidade  NUMBER(19),
    CONSTRAINT pk_tb_colaborador PRIMARY KEY (id),
    CONSTRAINT fk_colaborador_unidade FOREIGN KEY (id_unidade)
        REFERENCES tb_unidade_saude (id)
);

-- 4.7. TABELA DE ATENDIMENTOS (FILA EM TEMPO REAL)
CREATE TABLE tb_atendimento (
    id                  NUMBER(19) DEFAULT ON NULL seq_atendimento.NEXTVAL NOT NULL,
    id_unidade_saude    NUMBER(19) NOT NULL,
    id_paciente         NUMBER(19) NOT NULL,
    id_colaborador      NUMBER(19),
    status_atendimento  VARCHAR2(30) DEFAULT 'AGUARDANDO' NOT NULL CHECK (status_atendimento IN ('AGUARDANDO', 'CHAMADO', 'FINALIZADO')),
    data_hora_chegada   TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_hora_chamada   TIMESTAMP,
    data_hora_fim       TIMESTAMP,
    senha               VARCHAR2(10),
    servico        VARCHAR2(30) DEFAULT 'CLINICO_GERAL' NOT NULL CHECK (servico IN ('CLINICO_GERAL', 'TRIAGEM', 'VACINACAO', 'PEDIATRIA', 'ODONTOLOGIA')),
    CONSTRAINT pk_tb_atendimento PRIMARY KEY (id),
    CONSTRAINT fk_atendimento_unidade FOREIGN KEY (id_unidade_saude)
        REFERENCES tb_unidade_saude (id),
    CONSTRAINT fk_atendimento_paciente FOREIGN KEY (id_paciente)
        REFERENCES tb_paciente (id),
    CONSTRAINT fk_atendimento_colaborador FOREIGN KEY (id_colaborador)
        REFERENCES tb_colaborador (id)
);

CREATE TABLE tb_cidadao_unidade_saude(
    id_cidadao NUMBER (19),
    id_unidade_saude NUMBER (19)
    --mais ou menos isso
)

-- 5. ÍNDICES DE PERFORMANCE
-- =====================================================================
CREATE INDEX idx_localizacao_lat_lon ON tb_localizacao (latitude, longitude);
CREATE INDEX idx_atendimento_fila_fifo ON tb_atendimento (id_unidade_saude, servico, status_atendimento, data_hora_chegada);