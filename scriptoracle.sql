-- GLOBAL SOLUTION 2026 - CITIZENTECH (NEXA)
-- =====================================================================
-- 1. DROP TABLES
DROP TABLE tb_cidadao_unidade_saude CASCADE CONSTRAINTS;
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
    CONSTRAINT fk_municipio_estado FOREIGN KEY (id_estado) REFERENCES tb_estado (id)
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
    CONSTRAINT fk_localizacao_municipio FOREIGN KEY (id_municipio) REFERENCES tb_municipio (id)
);

-- 4.4. TABELA DE UNIDADES DE SAÚDE (CNES / SUS)
CREATE TABLE tb_unidade_saude (
    id              NUMBER(19) DEFAULT ON NULL seq_unidade_saude.NEXTVAL NOT NULL,
    nome            VARCHAR2(255) NOT NULL,
    id_localizacao  NUMBER(19) UNIQUE,
    tempo_espera    NUMBER(10, 2) DEFAULT 0.0,
    tipo_unidade    VARCHAR2(60),
    CONSTRAINT pk_tb_unidade_saude PRIMARY KEY (id),
    CONSTRAINT fk_unidade_localizacao FOREIGN KEY (id_localizacao) REFERENCES tb_localizacao (id)
);

-- 4.5. TABELA DE PACIENTES
CREATE TABLE tb_paciente (
    id      NUMBER(19) DEFAULT ON NULL seq_paciente.NEXTVAL NOT NULL,
    cpf     VARCHAR2(15) NOT NULL UNIQUE,
    nome    VARCHAR2(150) NOT NULL,
    CONSTRAINT pk_tb_paciente PRIMARY KEY (id)
);

-- 4.6. TABELA DE CIDADÃOS
CREATE TABLE tb_cidadao(
     id                  NUMBER(19) DEFAULT ON NULL seq_cidadao.NEXTVAL NOT NULL,
     nome                VARCHAR2(150) NOT NULL,
     email               VARCHAR2(150) NOT NULL UNIQUE,
     senha               VARCHAR2(255) NOT NULL,
     aceite_localizacao  TIMESTAMP,
     CONSTRAINT pk_tb_cidadao PRIMARY KEY (id)
);

-- 4.7. TABELA DE COLABORADORES (PROFISSIONAIS DE SAÚDE)
CREATE TABLE tb_colaborador (
    id          NUMBER(19) DEFAULT ON NULL seq_colaborador.NEXTVAL NOT NULL,
    nome        VARCHAR2(150) NOT NULL,
    cargo       VARCHAR2(100),
    email       VARCHAR2(150) NOT NULL UNIQUE,
    senha       VARCHAR2(255) NOT NULL,
    id_unidade  NUMBER(19),
    CONSTRAINT pk_tb_colaborador PRIMARY KEY (id),
    CONSTRAINT fk_colaborador_unidade FOREIGN KEY (id_unidade) REFERENCES tb_unidade_saude (id)
);

-- 4.8. TABELA DE ATENDIMENTOS (FILA EM TEMPO REAL)
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
    CONSTRAINT fk_atendimento_unidade FOREIGN KEY (id_unidade_saude) REFERENCES tb_unidade_saude (id),
    CONSTRAINT fk_atendimento_paciente FOREIGN KEY (id_paciente) REFERENCES tb_paciente (id),
    CONSTRAINT fk_atendimento_colaborador FOREIGN KEY (id_colaborador) REFERENCES tb_colaborador (id)
);

-- 4.9. TABELA DE UNIDADES DE SAÚDE FAVORITAS DE UM CIDADÃO
CREATE TABLE tb_cidadao_unidade_saude(
    id_cidadao       NUMBER(19) NOT NULL,
    id_unidade_saude NUMBER(19) NOT NULL,
    CONSTRAINT pk_tb_cidadao_unidade PRIMARY KEY (id_cidadao, id_unidade_saude),
    CONSTRAINT fk_cus_cidadao FOREIGN KEY (id_cidadao) REFERENCES tb_cidadao (id) ON DELETE CASCADE,
    CONSTRAINT fk_cus_unidade FOREIGN KEY (id_unidade_saude) REFERENCES tb_unidade_saude (id) ON DELETE CASCADE
);

-- 5. ÍNDICES DE PERFORMANCE
-- =====================================================================
CREATE INDEX idx_localizacao_latitude_longitude ON tb_localizacao (latitude, longitude);
CREATE INDEX idx_atendimento_fila ON tb_atendimento (id_unidade_saude, servico, status_atendimento, data_hora_chegada);
CREATE INDEX idx_municipio_estado ON tb_municipio (id_estado);
CREATE INDEX idx_colaborador_unidade ON tb_colaborador (id_unidade);
CREATE INDEX idx_atendimento_paciente ON tb_atendimento (id_paciente);
CREATE INDEX idx_atendimento_colaborador ON tb_atendimento (id_colaborador);

-- 6. Inserts nas tabelas
----------------------------
-- 6.1 Inserts de Estados
INSERT INTO tb_estado(codigo_uf, sigla, nome) VALUES (35, 'SP', 'São Paulo');
INSERT INTO tb_estado(codigo_uf, sigla, nome) VALUES (33, 'RJ', 'Rio de Janeiro');
INSERT INTO tb_estado(codigo_uf, sigla, nome) VALUES (31, 'MG', 'Minas Gerais');
INSERT INTO tb_estado(codigo_uf, sigla, nome) VALUES (26, 'PE', 'Pernambuco');
INSERT INTO tb_estado(codigo_uf, sigla, nome) VALUES (41, 'PR', 'Paraná');
INSERT INTO tb_estado(codigo_uf, sigla, nome) VALUES (29, 'BA', 'Bahia');
INSERT INTO tb_estado(codigo_uf, sigla, nome) VALUES (25, 'PB', 'Paraíba');
INSERT INTO tb_estado(codigo_uf, sigla, nome) VALUES (13, 'AM', 'Amazonas');
INSERT INTO tb_estado(codigo_uf, sigla, nome) VALUES (43, 'RS', 'Rio Grande do Sul');
INSERT INTO tb_estado(codigo_uf, sigla, nome) VALUES (51, 'MT', 'Mato Grosso');

-- 6.2 Inserts de municípios
INSERT INTO tb_municipio(codigo_municipio_ibge, nome, id_estado) VALUES ('3550308', 'São Paulo', 1);
INSERT INTO tb_municipio(codigo_municipio_ibge, nome, id_estado) VALUES ('3304557', 'Rio de Janeiro', 2);
INSERT INTO tb_municipio(codigo_municipio_ibge, nome, id_estado) VALUES ('3106200', 'Belo Horizonte', 3);
INSERT INTO tb_municipio(codigo_municipio_ibge, nome, id_estado) VALUES ('2611606', 'Recife', 4);
INSERT INTO tb_municipio(codigo_municipio_ibge, nome, id_estado) VALUES ('4106902', 'Curitiba', 5);
INSERT INTO tb_municipio(codigo_municipio_ibge, nome, id_estado) VALUES ('2927408', 'Salvador', 6);
INSERT INTO tb_municipio(codigo_municipio_ibge, nome, id_estado) VALUES ('2507507', 'João Pessoa', 7);
INSERT INTO tb_municipio(codigo_municipio_ibge, nome, id_estado) VALUES ('1302603', 'Manaus', 8);
INSERT INTO tb_municipio(codigo_municipio_ibge, nome, id_estado) VALUES ('4314902', 'Porto Alegre', 9);
INSERT INTO tb_municipio(codigo_municipio_ibge, nome, id_estado) VALUES ('5103403', 'Cuiabá', 10);

-- 6.3. Inserts de localizações
INSERT INTO tb_localizacao(cep, logradouro, numero, bairro, id_municipio, latitude, longitude) VALUES ('03978180', 'Rua Batista Fergusio', '1016', 'V Cardoso Franco', 1, -23.6212831, -46.5091024);
INSERT INTO tb_localizacao(cep, logradouro, numero, bairro, id_municipio, latitude, longitude) VALUES ('04211000', 'Rua Xavier de Almeida', '427', 'São Paulo', 1, -23.589789, -46.607978);
INSERT INTO tb_localizacao(cep, logradouro, numero, bairro, id_municipio, latitude, longitude) VALUES ('22210030', 'Praia do Flamengo', '66', 'Flamengo', 2, -22.926789, -43.173781);
INSERT INTO tb_localizacao(cep, logradouro, numero, bairro, id_municipio, latitude, longitude) VALUES ('30160035', 'Rua Espírito Santo', '1607', 'Lourdes', 3, -19.9328887, -43.9409544);
INSERT INTO tb_localizacao(cep, logradouro, numero, bairro, id_municipio, latitude, longitude) VALUES ('50740900', 'Av Professor Moraes Rego', '1235', 'Cidade Universitária', 4, -8.0475018039, -34.9461364746);
INSERT INTO tb_localizacao(cep, logradouro, numero, bairro, id_municipio, latitude, longitude) VALUES ('80730150', 'Augusto Stellfeld', '1908', 'Bigorrilho', 5, -25.4340727867, -49.2917661457);
INSERT INTO tb_localizacao(cep, logradouro, numero, bairro, id_municipio, latitude, longitude) VALUES ('40411900', 'Rua Barão de Cotegipe', '1153', 'Roma', 6, -12.9373315901, -38.5067474842);
INSERT INTO tb_localizacao(cep, logradouro, numero, bairro, id_municipio, latitude, longitude) VALUES ('58040090', 'Rua General Bento da Gama', '396', 'Torre', 7, -7.1228958, -34.8719017);
INSERT INTO tb_localizacao(cep, logradouro, numero, bairro, id_municipio, latitude, longitude) VALUES ('69050010', 'Djalma Batista', '1719', 'Chapada', 8, -3.0914355, -60.0242362);
INSERT INTO tb_localizacao(cep, logradouro, numero, bairro, id_municipio, latitude, longitude) VALUES ('90570001', 'Rua Felix da Cunha', '737', 'Floresta', 9, -30.019132, -51.202592);

-- 6.4. Inserts de Unidades de Saúde
INSERT INTO tb_unidade_saude(nome, id_localizacao, tipo_unidade) VALUES ('AMA Humberto Gastao Bodra', 1, 'CENTRO_DE_SAUDE_UNIDADE_BASICA');
INSERT INTO tb_unidade_saude(nome, id_localizacao, tipo_unidade) VALUES ('Artfono', 2, 'CONSULTORIO_ISOLADO');
INSERT INTO tb_unidade_saude(nome, id_localizacao, tipo_unidade) VALUES ('Consultorio CidyaCare', 3, 'CONSULTORIO_ISOLADO');
INSERT INTO tb_unidade_saude(nome, id_localizacao, tipo_unidade) VALUES ('Nucleo Mineiro de Cirurgia Toracica Ltda', 4, 'COOPERATIVA_DE_TRABALHADORES_NA_SAUDE');
INSERT INTO tb_unidade_saude(nome, id_localizacao, tipo_unidade) VALUES ('Hospital das Clinicas', 5, 'HOSPITAL_GERAL');
INSERT INTO tb_unidade_saude(nome, id_localizacao, tipo_unidade) VALUES ('Hospital Universitario Evangelico Mackenzie', 6, 'HOSPITAL_GERAL');
INSERT INTO tb_unidade_saude(nome, id_localizacao, tipo_unidade) VALUES ('Hospital Estadual da Mulher', 7, 'HOSPITAL_GERAL');
INSERT INTO tb_unidade_saude(nome, id_localizacao, tipo_unidade) VALUES ('Unimed Joao Pessoa Cooperativa de Trabalho Medico Filial', 8, 'HOME_CARE');
INSERT INTO tb_unidade_saude(nome, id_localizacao, tipo_unidade) VALUES ('Endoclinic', 9, 'POLICLINICA');
INSERT INTO tb_unidade_saude(nome, id_localizacao, tipo_unidade) VALUES ('AuxiliaSaude', 10, 'CONSULTORIO_ISOLADO');

-- 6.5. Inserts de pacientes
INSERT INTO tb_paciente (cpf, nome) VALUES ('000.000.000.07', 'Thaciano do Santos');
INSERT INTO tb_paciente (cpf, nome) VALUES ('000.000.000.06', 'Ronielson');
INSERT INTO tb_paciente (cpf, nome) VALUES ('000.000.000.03', 'Gonzalo Escobar');
INSERT INTO tb_paciente (cpf, nome) VALUES ('111.222.333.04', 'Mariana Oliveira');
INSERT INTO tb_paciente (cpf, nome) VALUES ('222.333.444.05', 'Carlos Eduardo Lima');
INSERT INTO tb_paciente (cpf, nome) VALUES ('333.444.555.06', 'Fernanda Rocha');
INSERT INTO tb_paciente (cpf, nome) VALUES ('444.555.666.07', 'Joao Pedro Martins');
INSERT INTO tb_paciente (cpf, nome) VALUES ('555.666.777.08', 'Patricia Gomes');
INSERT INTO tb_paciente (cpf, nome) VALUES ('666.777.888.09', 'Rafael Almeida');
INSERT INTO tb_paciente (cpf, nome) VALUES ('777.888.999.10', 'Camila Souza');
INSERT INTO tb_paciente (cpf, nome) VALUES ('888.999.111.11', 'Bruno Henrique');
INSERT INTO tb_paciente (cpf, nome) VALUES ('999.111.222.12', 'Juliana Costa');
INSERT INTO tb_paciente (cpf, nome) VALUES ('123.456.789.13', 'Mateus Ferreira');

-- 6.6. Inserts de cidadãos (Usuários do APP)
INSERT INTO tb_cidadao(nome, email, senha) VALUES ('Luiz Silva Souza', 'luiz@bd.com', 'Lz#8472A');
INSERT INTO tb_cidadao(nome, email, senha) VALUES ('Maria Oliveira Santos', 'maria@bd.com', 'Mx!2917K');
INSERT INTO tb_cidadao(nome, email, senha) VALUES ('Joao Pereira Lima', 'joao@bd.com', 'Jp@6358N');
INSERT INTO tb_cidadao(nome, email, senha) VALUES ('Ana Carolina Souza', 'ana@bd.com', 'Ac$4721P');
INSERT INTO tb_cidadao(nome, email, senha) VALUES ('Carlos Henrique Alves', 'carlos@bd.com', 'Ch*9084Q');
INSERT INTO tb_cidadao(nome, email, senha) VALUES ('Fernanda Rocha Martins', 'fernanda@bd.com', 'Fr!1562M');
INSERT INTO tb_cidadao(nome, email, senha) VALUES ('Ricardo Gomes Ferreira', 'ricardo@bd.com', 'Rg#7831T');
INSERT INTO tb_cidadao(nome, email, senha) VALUES ('Patricia Ribeiro Costa', 'patricia@bd.com', 'Pr@4295X');
INSERT INTO tb_cidadao(nome, email, senha) VALUES ('Bruno Teixeira Silva', 'bruno@bd.com', 'Bt$6147L');
INSERT INTO tb_cidadao(nome, email, senha) VALUES ('Camila Mendes Araujo', 'camila@bd.com', 'Cm*8523R');

-- 6.7. Inserts de colaboradores (profissionais da saúde)
INSERT INTO tb_colaborador(nome, cargo, email, senha, id_unidade) VALUES ('Colaborador Teste Silva', 'Médico',  'teste@bd.com', 'Tt*2363R', 1);
INSERT INTO tb_colaborador(nome, cargo, email, senha, id_unidade) VALUES ('Eduardo Martins', 'Médico', 'eduardo@cbd.com', 'Em#4832P', 1);
INSERT INTO tb_colaborador(nome, cargo, email, senha, id_unidade) VALUES ('Mariana Oliveira', 'Enfermeira', 'mariana@cbd.com', 'Mo@7315K', 2);
INSERT INTO tb_colaborador(nome, cargo, email, senha, id_unidade) VALUES ('Rafael Lima', 'Médico', 'rafael@cbd.com', 'Rl*2947M', 3);
INSERT INTO tb_colaborador(nome, cargo, email, senha, id_unidade) VALUES ('Patricia Souza', 'Dentista', 'patricia@cbd.com', 'Ps!6852R', 4);
INSERT INTO tb_colaborador(nome, cargo, email, senha, id_unidade) VALUES ('Lucas Ferreira', 'Enfermeiro', 'lucas@cbd.com', 'Lf@9184T', 5);
INSERT INTO tb_colaborador(nome, cargo, email, senha, id_unidade) VALUES ('Fernanda Costa', 'Médica Pediatra', 'fernanda@cbd.com', 'Fc#5273L', 6);
INSERT INTO tb_colaborador(nome, cargo, email, senha, id_unidade) VALUES ('Gustavo Almeida', 'Médico', 'gustavo@cbd.com', 'Ga*1704Q', 7);
INSERT INTO tb_colaborador(nome, cargo, email, senha, id_unidade) VALUES ('Camila Ribeiro', 'Enfermeira', 'camila@cbd.com', 'Cr!8031N', 8);
INSERT INTO tb_colaborador(nome, cargo, email, senha, id_unidade) VALUES ('Bruno Santos', 'Dentista', 'bruno@cbd.com', 'Bs@6492X', 9);
INSERT INTO tb_colaborador(nome, cargo, email, senha, id_unidade) VALUES ('Amanda Rocha', 'Médica Pediatra', 'amanda@cbd.com', 'Ar#3528B', 10);

-- 6.8. Inserts de atendimentos 
INSERT INTO tb_atendimento(id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico)
VALUES (1, 1, 1, 'FINALIZADO', CURRENT_TIMESTAMP - INTERVAL '40' MINUTE, CURRENT_TIMESTAMP - INTERVAL '35' MINUTE, CURRENT_TIMESTAMP - INTERVAL '20' MINUTE, 'CLI-001', 'CLINICO_GERAL');
INSERT INTO tb_atendimento(id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico)
VALUES (2, 2, 2, 'FINALIZADO', CURRENT_TIMESTAMP - INTERVAL '30' MINUTE, CURRENT_TIMESTAMP - INTERVAL '25' MINUTE, CURRENT_TIMESTAMP - INTERVAL '10' MINUTE, 'TRI-001', 'TRIAGEM');
INSERT INTO tb_atendimento(id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico)
VALUES (3, 3, 3, 'CHAMADO', CURRENT_TIMESTAMP - INTERVAL '20' MINUTE, CURRENT_TIMESTAMP - INTERVAL '5' MINUTE, NULL, 'CLI-002', 'CLINICO_GERAL');
INSERT INTO tb_atendimento(id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico)
VALUES (4, 4, 4, 'FINALIZADO', CURRENT_TIMESTAMP - INTERVAL '60' MINUTE, CURRENT_TIMESTAMP - INTERVAL '55' MINUTE, CURRENT_TIMESTAMP - INTERVAL '40' MINUTE, 'ODO-001', 'ODONTOLOGIA');
INSERT INTO tb_atendimento(id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico)
VALUES (5, 5, 5, 'AGUARDANDO', CURRENT_TIMESTAMP - INTERVAL '15' MINUTE, NULL, NULL, 'VAC-001', 'VACINACAO');
INSERT INTO tb_atendimento(id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico)
VALUES (6, 6, 6, 'CHAMADO', CURRENT_TIMESTAMP - INTERVAL '18' MINUTE, CURRENT_TIMESTAMP - INTERVAL '3' MINUTE, NULL, 'PED-001', 'PEDIATRIA');
INSERT INTO tb_atendimento(id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico)
VALUES (7, 7, 7, 'FINALIZADO', CURRENT_TIMESTAMP - INTERVAL '50' MINUTE, CURRENT_TIMESTAMP - INTERVAL '45' MINUTE, CURRENT_TIMESTAMP - INTERVAL '30' MINUTE, 'CLI-003', 'CLINICO_GERAL');
INSERT INTO tb_atendimento(id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico)
VALUES (8, 8, 8, 'AGUARDANDO', CURRENT_TIMESTAMP - INTERVAL '10' MINUTE, NULL, NULL, 'TRI-002', 'TRIAGEM');
INSERT INTO tb_atendimento(id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico)
VALUES (9, 9, 9, 'CHAMADO', CURRENT_TIMESTAMP - INTERVAL '12' MINUTE, CURRENT_TIMESTAMP - INTERVAL '1' MINUTE, NULL, 'ODO-002', 'ODONTOLOGIA');
INSERT INTO tb_atendimento(id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico)
VALUES (10, 10, 10, 'FINALIZADO', CURRENT_TIMESTAMP - INTERVAL '35' MINUTE, CURRENT_TIMESTAMP - INTERVAL '30' MINUTE, CURRENT_TIMESTAMP - INTERVAL '5' MINUTE, 'PED-002', 'PEDIATRIA');

-- 6.9. Inserts de unidades de atendimento favoritas dos cidadãos
INSERT INTO tb_cidadao_unidade_saude(id_cidadao, id_unidade_saude) VALUES (1,2);
INSERT INTO tb_cidadao_unidade_saude(id_cidadao, id_unidade_saude) VALUES (1,5);
INSERT INTO tb_cidadao_unidade_saude(id_cidadao, id_unidade_saude) VALUES (2,1);
INSERT INTO tb_cidadao_unidade_saude(id_cidadao, id_unidade_saude) VALUES (2,3);
INSERT INTO tb_cidadao_unidade_saude(id_cidadao, id_unidade_saude) VALUES (3,4);
INSERT INTO tb_cidadao_unidade_saude(id_cidadao, id_unidade_saude) VALUES (4,6);
INSERT INTO tb_cidadao_unidade_saude(id_cidadao, id_unidade_saude) VALUES (5,2);
INSERT INTO tb_cidadao_unidade_saude(id_cidadao, id_unidade_saude) VALUES (5,8);
INSERT INTO tb_cidadao_unidade_saude(id_cidadao, id_unidade_saude) VALUES (7,10);
INSERT INTO tb_cidadao_unidade_saude(id_cidadao, id_unidade_saude) VALUES (10,1);

COMMIT;

-- SELECT de verificação de criação das tabelas
SELECT * FROM tb_estado;
SELECT * FROM tb_municipio;
SELECT * FROM tb_localizacao;
SELECT * FROM tb_unidade_saude;
SELECT * FROM tb_paciente;
SELECT * FROM tb_cidadao;
SELECT * FROM tb_colaborador;
SELECT * FROM tb_atendimento;
SELECT * FROM tb_cidadao_unidade_saude;
/*
SELECT m.nome Municipio , e.nome Estado
FROM 
tb_estado e 
INNER JOIN tb_municipio m
ON e.id = m.id_estado;
*/
