SET SERVEROUTPUT ON SIZE UNLIMITED;
SET VERIFY OFF;

-- GLOBAL SOLUTION 2026 - CITIZENTECH (NEXA)
-- =====================================================================
-- 1. DROP TABLES
drop table tb_cidadao_unidade_saude cascade constraints;
drop table tb_atendimento cascade constraints;
drop table tb_colaborador cascade constraints;
drop table tb_paciente cascade constraints;
drop table tb_cidadao cascade constraints;
drop table tb_unidade_saude cascade constraints;
drop table tb_localizacao cascade constraints;
drop table tb_municipio cascade constraints;
drop table tb_estado cascade constraints;

-- 2. DROP SEQUENCES
drop sequence seq_atendimento;
drop sequence seq_colaborador;
drop sequence seq_paciente;
drop sequence seq_cidadao;
drop sequence seq_unidade_saude;
drop sequence seq_localizacao;
drop sequence seq_municipio;
drop sequence seq_estado;

-- 3. CREATE SEQUENCES
create sequence seq_estado start with 1 increment by 1 nocache nocycle;
create sequence seq_municipio start with 1 increment by 1 cache 100 nocycle;
create sequence seq_localizacao start with 1 increment by 1 cache 1000 nocycle;
create sequence seq_unidade_saude start with 1 increment by 1 cache 1000 nocycle;
create sequence seq_paciente start with 1 increment by 1 nocache nocycle;
create sequence seq_cidadao start with 1 increment by 1 nocache nocycle;
create sequence seq_colaborador start with 1 increment by 1 nocache nocycle;
create sequence seq_atendimento start with 1 increment by 1 nocache nocycle;

-- 4. CRIAÇÃO DAS TABELAS (3ª FORMA NORMAL - 3FN)
-- =====================================================================

-- 4.1. TABELA DE ESTADOS (UF - IBGE)
create table tb_estado (
   id        number(19) default on null seq_estado.nextval not null,
   codigo_uf varchar2(10),
   sigla     varchar2(2) not null unique,
   nome      varchar2(100) not null,
   constraint pk_tb_estado primary key ( id )
);

-- 4.2. TABELA DE MUNICÍPIOS (IBGE)
create table tb_municipio (
   id                    number(19) default on null seq_municipio.nextval not null,
   codigo_municipio_ibge varchar2(20),
   nome                  varchar2(120) not null,
   id_estado             number(19) not null,
   constraint pk_tb_municipio primary key ( id ),
   constraint fk_municipio_estado foreign key ( id_estado ) references tb_estado ( id )
);

-- 4.3. TABELA DE LOCALIZAÇÕES (ENDEREÇOS E COORDENADAS WGS84)
create table tb_localizacao (
   id           number(19) default on null seq_localizacao.nextval not null,
   cep          varchar2(15),
   logradouro   varchar2(120),
   numero       varchar2(120),
   bairro       varchar2(120),
   id_municipio number(19) not null,
   latitude     number(10,7) not null check ( latitude between - 90 and 90 ),
   longitude    number(10,7) not null check ( longitude between - 180 and 180 ),
   constraint pk_tb_localizacao primary key ( id ),
   constraint fk_localizacao_municipio foreign key ( id_municipio ) references tb_municipio ( id )
);

-- 4.4. TABELA DE UNIDADES DE SAÚDE (CNES / SUS)
create table tb_unidade_saude (
   id             number(19) default on null seq_unidade_saude.nextval not null,
   nome           varchar2(255) not null,
   id_localizacao number(19) unique,
   tempo_espera   number(10,2) default 0.0,
   tipo_unidade   varchar2(60),
   constraint pk_tb_unidade_saude primary key ( id ),
   constraint fk_unidade_localizacao foreign key ( id_localizacao ) references tb_localizacao ( id )
);

-- 4.5. TABELA DE PACIENTES
create table tb_paciente (
   id   number(19) default on null seq_paciente.nextval not null,
   cpf  varchar2(11) not null unique,
   nome varchar2(150) not null,
   constraint pk_tb_paciente primary key ( id )
);

-- 4.6. TABELA DE CIDADÃOS
create table tb_cidadao (
   id                 number(19) default on null seq_cidadao.nextval not null,
   nome               varchar2(150) not null,
   email              varchar2(150) not null unique,
   senha              varchar2(255) not null,
   aceite_localizacao timestamp,
   constraint pk_tb_cidadao primary key ( id )
);

-- 4.7. TABELA DE COLABORADORES (PROFISSIONAIS DE SAÚDE)
create table tb_colaborador (
   id         number(19) default on null seq_colaborador.nextval not null,
   nome       varchar2(150) not null,
   cargo      varchar2(100),
   email      varchar2(150) not null unique,
   senha      varchar2(255) not null,
   id_unidade number(19),
   constraint pk_tb_colaborador primary key ( id ),
   constraint fk_colaborador_unidade foreign key ( id_unidade ) references tb_unidade_saude ( id )
);

-- 4.8. TABELA DE ATENDIMENTOS (FILA EM TEMPO REAL)
create table tb_atendimento (
   id                 number(19) default on null seq_atendimento.nextval not null,
   id_unidade_saude   number(19) not null,
   id_paciente        number(19) not null,
   id_colaborador     number(19),
   status_atendimento varchar2(30) default 'AGUARDANDO' not null check ( status_atendimento in ( 'AGUARDANDO', 'CHAMADO', 'FINALIZADO' ) ),
   data_hora_chegada  timestamp default current_timestamp not null,
   data_hora_chamada  timestamp,
   data_hora_fim      timestamp,
   senha              varchar2(10),
   servico            varchar2(30) default 'CLINICO_GERAL' not null check ( servico in ( 'CLINICO_GERAL', 'TRIAGEM', 'VACINACAO', 'PEDIATRIA', 'ODONTOLOGIA' ) ),
   constraint pk_tb_atendimento primary key ( id ),
   constraint fk_atendimento_unidade foreign key ( id_unidade_saude ) references tb_unidade_saude ( id ),
   constraint fk_atendimento_paciente foreign key ( id_paciente ) references tb_paciente ( id ),
   constraint fk_atendimento_colaborador foreign key ( id_colaborador ) references tb_colaborador ( id )
);

-- 4.9. TABELA DE UNIDADES DE SAÚDE FAVORITAS DE UM CIDADÃO
create table tb_cidadao_unidade_saude (
   id_cidadao       number(19) not null,
   id_unidade_saude number(19) not null,
   constraint pk_tb_cidadao_unidade primary key ( id_cidadao, id_unidade_saude ),
   constraint fk_cus_cidadao foreign key ( id_cidadao ) references tb_cidadao ( id ) on delete cascade,
   constraint fk_cus_unidade foreign key ( id_unidade_saude ) references tb_unidade_saude ( id ) on delete cascade
);

-- 5. ÍNDICES DE PERFORMANCE
-- =====================================================================
create index idx_localizacao_latitude_longitude on tb_localizacao ( latitude, longitude );
create index idx_atendimento_fila on tb_atendimento ( id_unidade_saude, servico, status_atendimento, data_hora_chegada );
create index idx_municipio_estado on tb_municipio ( id_estado );
create index idx_colaborador_unidade on tb_colaborador ( id_unidade );
create index idx_atendimento_paciente on tb_atendimento ( id_paciente );
create index idx_atendimento_colaborador on tb_atendimento ( id_colaborador );

-- 6. Inserts nas tabelas
----------------------------
-- 6.1 Inserts de Estados
insert into tb_estado ( codigo_uf, sigla, nome ) values ( 35, 'SP', 'São Paulo' );
insert into tb_estado ( codigo_uf, sigla, nome ) values ( 33, 'RJ', 'Rio de Janeiro' );
insert into tb_estado ( codigo_uf, sigla, nome ) values ( 31, 'MG', 'Minas Gerais' );
insert into tb_estado ( codigo_uf, sigla, nome ) values ( 26, 'PE', 'Pernambuco' );
insert into tb_estado ( codigo_uf, sigla, nome ) values ( 41, 'PR', 'Paraná' );
insert into tb_estado ( codigo_uf, sigla, nome ) values ( 29, 'BA', 'Bahia' );
insert into tb_estado ( codigo_uf, sigla, nome ) values ( 25, 'PB', 'Paraíba' );
insert into tb_estado ( codigo_uf, sigla, nome ) values ( 13, 'AM', 'Amazonas' );
insert into tb_estado ( codigo_uf, sigla, nome ) values ( 43, 'RS', 'Rio Grande do Sul' );
insert into tb_estado ( codigo_uf, sigla, nome ) values ( 51, 'MT', 'Mato Grosso' );

-- 6.2 Inserts de municípios
insert into tb_municipio ( codigo_municipio_ibge, nome, id_estado ) values ( '3550308', 'São Paulo', 1 );
insert into tb_municipio ( codigo_municipio_ibge, nome, id_estado ) values ( '3304557', 'Rio de Janeiro', 2 );
insert into tb_municipio ( codigo_municipio_ibge, nome, id_estado ) values ( '3106200', 'Belo Horizonte', 3 );
insert into tb_municipio ( codigo_municipio_ibge, nome, id_estado ) values ( '2611606', 'Recife', 4 );
insert into tb_municipio ( codigo_municipio_ibge, nome, id_estado ) values ( '4106902', 'Curitiba', 5 );
insert into tb_municipio ( codigo_municipio_ibge, nome, id_estado ) values ( '2927408', 'Salvador', 6 );
insert into tb_municipio ( codigo_municipio_ibge, nome, id_estado ) values ( '2507507', 'João Pessoa', 7 );
insert into tb_municipio ( codigo_municipio_ibge, nome, id_estado ) values ( '1302603', 'Manaus', 8 );
insert into tb_municipio ( codigo_municipio_ibge, nome, id_estado ) values ( '4314902', 'Porto Alegre', 9 );
insert into tb_municipio ( codigo_municipio_ibge, nome, id_estado ) values ( '5103403', 'Cuiabá', 10 );

-- 6.3. Inserts de localizações
insert into tb_localizacao ( cep, logradouro, numero, bairro, id_municipio, latitude, longitude ) values ( '03978180', 'Rua Batista Fergusio', '1016', 'V Cardoso Franco', 1, - 23.6212831, - 46.5091024 );
insert into tb_localizacao ( cep, logradouro, numero, bairro, id_municipio, latitude, longitude ) values ( '04211000', 'Rua Xavier de Almeida', '427', 'São Paulo', 1, - 23.589789, - 46.607978 );
insert into tb_localizacao ( cep, logradouro, numero, bairro, id_municipio, latitude, longitude ) values ( '22210030', 'Praia do Flamengo', '66', 'Flamengo', 2, - 22.926789, - 43.173781 );
insert into tb_localizacao ( cep, logradouro, numero, bairro, id_municipio, latitude, longitude ) values ( '30160035', 'Rua Espírito Santo', '1607', 'Lourdes', 3, - 19.9328887, - 43.9409544 );
insert into tb_localizacao ( cep, logradouro, numero, bairro, id_municipio, latitude, longitude ) values ( '50740900', 'Av Professor Moraes Rego', '1235', 'Cidade Universitária', 4, - 8.0475018039, - 34.9461364746 );
insert into tb_localizacao ( cep, logradouro, numero, bairro, id_municipio, latitude, longitude ) values ( '80730150', 'Augusto Stellfeld', '1908', 'Bigorrilho', 5, - 25.4340727867, - 49.2917661457 );
insert into tb_localizacao ( cep, logradouro, numero, bairro, id_municipio, latitude, longitude ) values ( '40411900', 'Rua Barão de Cotegipe', '1153', 'Roma', 6, - 12.9373315901, - 38.5067474842 );
insert into tb_localizacao ( cep, logradouro, numero, bairro, id_municipio, latitude, longitude ) values ( '58040090', 'Rua General Bento da Gama', '396', 'Torre', 7, - 7.1228958, - 34.8719017 );
insert into tb_localizacao ( cep, logradouro, numero, bairro, id_municipio, latitude, longitude ) values ( '69050010', 'Djalma Batista', '1719', 'Chapada', 8, - 3.0914355, - 60.0242362 );
insert into tb_localizacao ( cep, logradouro, numero, bairro, id_municipio, latitude, longitude ) values ( '90570001', 'Rua Felix da Cunha', '737', 'Floresta', 9, - 30.019132, - 51.202592 );

-- 6.4. Inserts de Unidades de Saúde
insert into tb_unidade_saude ( nome, id_localizacao, tipo_unidade ) values ( 'AMA Humberto Gastao Bodra', 1, 'CENTRO_DE_SAUDE_UNIDADE_BASICA' );
insert into tb_unidade_saude ( nome, id_localizacao, tipo_unidade ) values ( 'Artfono', 2, 'CONSULTORIO_ISOLADO' );
insert into tb_unidade_saude ( nome, id_localizacao, tipo_unidade ) values ( 'Consultorio CidyaCare', 3, 'CONSULTORIO_ISOLADO' );
insert into tb_unidade_saude ( nome, id_localizacao, tipo_unidade ) values ( 'Nucleo Mineiro de Cirurgia Toracica Ltda', 4, 'COOPERATIVA_DE_TRABALHADORES_NA_SAUDE' );
insert into tb_unidade_saude ( nome, id_localizacao, tipo_unidade ) values ( 'Hospital das Clinicas', 5, 'HOSPITAL_GERAL' );
insert into tb_unidade_saude ( nome, id_localizacao, tipo_unidade ) values ( 'Hospital Universitario Evangelico Mackenzie', 6, 'HOSPITAL_GERAL' );
insert into tb_unidade_saude ( nome, id_localizacao, tipo_unidade ) values ( 'Hospital Estadual da Mulher', 7, 'HOSPITAL_GERAL' );
insert into tb_unidade_saude ( nome, id_localizacao, tipo_unidade ) values ( 'Unimed Joao Pessoa Cooperativa de Trabalho Medico Filial', 8, 'HOME_CARE' );
insert into tb_unidade_saude ( nome, id_localizacao, tipo_unidade ) values ( 'Endoclinic', 9, 'POLICLINICA' );
insert into tb_unidade_saude ( nome, id_localizacao, tipo_unidade ) values ( 'AuxiliaSaude', 10, 'CONSULTORIO_ISOLADO' );

-- 6.5. Inserts de pacientes
insert into tb_paciente (cpf, nome) values ('00000000007', 'Thaciano do Santos');
insert into tb_paciente (cpf, nome) values ('00000000006', 'Ronielson');
insert into tb_paciente (cpf, nome) values ('00000000003', 'Gonzalo Escobar');
insert into tb_paciente (cpf, nome) values ('11122233304', 'Mariana Oliveira');
insert into tb_paciente (cpf, nome) values ('22233344405', 'Carlos Eduardo Lima');
insert into tb_paciente (cpf, nome) values ('33344455506', 'Fernanda Rocha');
insert into tb_paciente (cpf, nome) values ('44455566607', 'Joao Pedro Martins');
insert into tb_paciente (cpf, nome) values ('55566677708', 'Patricia Gomes');
insert into tb_paciente (cpf, nome) values ('66677788809', 'Rafael Almeida');
insert into tb_paciente (cpf, nome) values ('77788899910', 'Camila Souza');
insert into tb_paciente (cpf, nome) values ('88899911111', 'Bruno Henrique');
insert into tb_paciente (cpf, nome) values ('99911122212', 'Juliana Costa');
insert into tb_paciente (cpf, nome) values ('12345678913', 'Mateus Ferreira');

-- 6.6. Inserts de cidadãos (Usuários do APP)
insert into tb_cidadao ( nome, email, senha ) values ( 'Luiz Silva Souza', 'luiz@bd.com', 'Lz#8472A' );
insert into tb_cidadao ( nome, email, senha ) values ( 'Maria Oliveira Santos', 'maria@bd.com', 'Mx!2917K' );
insert into tb_cidadao ( nome, email, senha ) values ( 'Joao Pereira Lima', 'joao@bd.com', 'Jp@6358N' );
insert into tb_cidadao ( nome, email, senha ) values ( 'Ana Carolina Souza', 'ana@bd.com', 'Ac$4721P' );
insert into tb_cidadao ( nome, email, senha ) values ( 'Carlos Henrique Alves', 'carlos@bd.com', 'Ch*9084Q' );
insert into tb_cidadao ( nome, email, senha ) values ( 'Fernanda Rocha Martins', 'fernanda@bd.com', 'Fr!1562M' );
insert into tb_cidadao ( nome, email, senha ) values ( 'Ricardo Gomes Ferreira', 'ricardo@bd.com', 'Rg#7831T' );
insert into tb_cidadao ( nome, email, senha ) values ( 'Patricia Ribeiro Costa', 'patricia@bd.com', 'Pr@4295X' );
insert into tb_cidadao ( nome, email, senha ) values ( 'Bruno Teixeira Silva', 'bruno@bd.com', 'Bt$6147L' );
insert into tb_cidadao ( nome, email, senha ) values ( 'Camila Mendes Araujo', 'camila@bd.com', 'Cm*8523R' );

-- 6.7. Inserts de colaboradores (profissionais da saúde)
insert into tb_colaborador ( nome, cargo, email, senha, id_unidade ) values ( 'Colaborador Teste Silva', 'Médico', 'teste@bd.com', 'Tt*2363R', 1 );
insert into tb_colaborador ( nome, cargo, email, senha, id_unidade ) values ( 'Eduardo Martins', 'Médico', 'eduardo@cbd.com', 'Em#4832P', 1 );
insert into tb_colaborador ( nome, cargo, email, senha, id_unidade ) values ( 'Mariana Oliveira', 'Enfermeira', 'mariana@cbd.com', 'Mo@7315K', 2 );
insert into tb_colaborador ( nome, cargo, email, senha, id_unidade ) values ( 'Rafael Lima', 'Médico', 'rafael@cbd.com', 'Rl*2947M', 3 );
insert into tb_colaborador ( nome, cargo, email, senha, id_unidade ) values ( 'Patricia Souza', 'Dentista', 'patricia@cbd.com', 'Ps!6852R', 4 );
insert into tb_colaborador ( nome, cargo, email, senha, id_unidade ) values ( 'Lucas Ferreira', 'Enfermeiro', 'lucas@cbd.com', 'Lf@9184T', 5 );
insert into tb_colaborador ( nome, cargo, email, senha, id_unidade ) values ( 'Fernanda Costa', 'Médica Pediatra', 'fernanda@cbd.com', 'Fc#5273L', 6 );
insert into tb_colaborador ( nome, cargo, email, senha, id_unidade ) values ( 'Gustavo Almeida', 'Médico', 'gustavo@cbd.com', 'Ga*1704Q', 7 );
insert into tb_colaborador ( nome, cargo, email, senha, id_unidade ) values ( 'Camila Ribeiro', 'Enfermeira', 'camila@cbd.com', 'Cr!8031N', 8 );
insert into tb_colaborador ( nome, cargo, email, senha, id_unidade ) values ( 'Bruno Santos', 'Dentista', 'bruno@cbd.com', 'Bs@6492X', 9 );
insert into tb_colaborador ( nome, cargo, email, senha, id_unidade ) values ( 'Amanda Rocha', 'Médica Pediatra', 'amanda@cbd.com', 'Ar#3528B', 10 );

-- 6.8. Inserts de atendimentos 
insert into tb_atendimento ( id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico ) values ( 1, 1, 1, 'FINALIZADO', current_timestamp - interval '40' minute, current_timestamp - interval '35' minute, current_timestamp - interval '20' minute, 'CLI-001', 'CLINICO_GERAL' );
insert into tb_atendimento ( id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico ) values ( 2, 2, 2, 'FINALIZADO', current_timestamp - interval '30' minute, current_timestamp - interval '25' minute, current_timestamp - interval '10' minute, 'TRI-001', 'TRIAGEM' );
insert into tb_atendimento ( id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico ) values ( 3, 3, 3, 'CHAMADO', current_timestamp - interval '20' minute, current_timestamp - interval '5' minute, null, 'CLI-002', 'CLINICO_GERAL' );
insert into tb_atendimento ( id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico ) values ( 4, 4, 4, 'FINALIZADO', current_timestamp - interval '60' minute, current_timestamp - interval '55' minute, current_timestamp - interval '40' minute, 'ODO-001', 'ODONTOLOGIA' );
insert into tb_atendimento ( id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico ) values ( 5, 5, 5, 'AGUARDANDO', current_timestamp - interval '15' minute, null, null, 'VAC-001', 'VACINACAO' );
insert into tb_atendimento ( id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico ) values ( 6, 6, 6, 'CHAMADO', current_timestamp - interval '18' minute, current_timestamp - interval '3' minute, null, 'PED-001', 'PEDIATRIA' );
insert into tb_atendimento ( id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico ) values ( 7, 7, 7, 'FINALIZADO', current_timestamp - interval '50' minute, current_timestamp - interval '45' minute, current_timestamp - interval '30' minute, 'CLI-003', 'CLINICO_GERAL' );
insert into tb_atendimento ( id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico ) values ( 8, 8, 8, 'AGUARDANDO', current_timestamp - interval '10' minute, null, null, 'TRI-002', 'TRIAGEM' );
insert into tb_atendimento ( id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico ) values ( 9, 9, 9, 'CHAMADO', current_timestamp - interval '12' minute, current_timestamp - interval '1' minute, null, 'ODO-002', 'ODONTOLOGIA' );
insert into tb_atendimento ( id_unidade_saude, id_paciente, id_colaborador, status_atendimento, data_hora_chegada, data_hora_chamada, data_hora_fim, senha, servico ) values ( 10, 10, 10, 'FINALIZADO', current_timestamp - interval '35' minute, current_timestamp - interval '30' minute, current_timestamp - interval '5' minute, 'PED-002', 'PEDIATRIA' );

-- 6.9. Inserts de unidades de atendimento favoritas dos cidadãos
insert into tb_cidadao_unidade_saude ( id_cidadao, id_unidade_saude ) values ( 1, 2 );
insert into tb_cidadao_unidade_saude ( id_cidadao, id_unidade_saude ) values ( 1, 5 );
insert into tb_cidadao_unidade_saude ( id_cidadao, id_unidade_saude ) values ( 2, 1 );
insert into tb_cidadao_unidade_saude ( id_cidadao, id_unidade_saude ) values ( 2, 3 );
insert into tb_cidadao_unidade_saude ( id_cidadao, id_unidade_saude ) values ( 3, 4 );
insert into tb_cidadao_unidade_saude ( id_cidadao, id_unidade_saude ) values ( 4, 6 );
insert into tb_cidadao_unidade_saude ( id_cidadao, id_unidade_saude ) values ( 5, 2 );
insert into tb_cidadao_unidade_saude ( id_cidadao, id_unidade_saude ) values ( 5, 8 );
insert into tb_cidadao_unidade_saude ( id_cidadao, id_unidade_saude ) values ( 7, 10 );
insert into tb_cidadao_unidade_saude ( id_cidadao, id_unidade_saude ) values ( 10, 1 );

commit;

-- 7. Bloco anônimo PL/SQL e Estrutura de Decisão ( no caso para fila de atendimentos)
declare
   -- 1. Variáveis locais ancoradas (%TYPE)
   v_id_atendimento      tb_atendimento.id%type := 1; -- ID para teste de consulta
   v_paciente_nome       tb_paciente.nome%type;
   v_paciente_cpf        tb_paciente.cpf%type;
   v_unidade_id          tb_unidade_saude.id%type;
   v_unidade_nome        tb_unidade_saude.nome%type;
   v_tipo_unidade        tb_unidade_saude.tipo_unidade%type;
   v_colaborador_nome    tb_colaborador.nome%type;
   v_colaborador_cargo   tb_colaborador.cargo%type;
   v_senha               tb_atendimento.senha%type;
   v_servico             tb_atendimento.servico%type;
   v_status              tb_atendimento.status_atendimento%type;
   v_minutos_espera      number;

   -- Variáveis de regra de negócio (Decisão)
   v_classificacao_risco varchar2(60);
   v_sla_maximo_minutos  number;
   v_status_sla          varchar2(40);
   v_total_favoritas     number := 0;
begin
   -- 2. Execução da consulta direta com SELECT ... INTO e junções relacionais
   select p.nome,
          p.cpf,
          u.id,
          u.nome,
          u.tipo_unidade,
          nvl(c.nome, 'Não atribuído'),
          nvl(c.cargo, 'Plantão Geral'),
          a.senha,
          a.servico,
          a.status_atendimento,
          round((cast(nvl(a.data_hora_chamada, current_timestamp) as date) - cast(a.data_hora_chegada as date)) * 24 * 60)
     into v_paciente_nome,
          v_paciente_cpf,
          v_unidade_id,
          v_unidade_nome,
          v_tipo_unidade,
          v_colaborador_nome,
          v_colaborador_cargo,
          v_senha,
          v_servico,
          v_status,
          v_minutos_espera
     from tb_atendimento a
     join tb_paciente p on a.id_paciente = p.id
     join tb_unidade_saude u on a.id_unidade_saude = u.id
     left join tb_colaborador c on a.id_colaborador = c.id
    where a.id = v_id_atendimento;

   -- 3. Estrutura Condicional (IF / ELSIF / ELSE) implementando regra real CitizenTech
   if v_servico = 'TRIAGEM' then
      v_classificacao_risco := 'EMERGÊNCIA / CRÍTICO (VERMELHO)';
      v_sla_maximo_minutos := 10;
   elsif v_servico = 'PEDIATRIA' then
      v_classificacao_risco := 'PRIORITÁRIO - PEDIATRIA (AMARELO)';
      v_sla_maximo_minutos := 20;
   elsif v_servico = 'CLINICO_GERAL' and v_minutos_espera > 30 then
      v_classificacao_risco := 'URGÊNCIA MODERADA - TEMPO ELEVADO (LARANJA)';
      v_sla_maximo_minutos := 30;
   elsif v_servico = 'CLINICO_GERAL' then
      v_classificacao_risco := 'CONSULTA CLÍNICA REGULAR (VERDE)';
      v_sla_maximo_minutos := 45;
   elsif v_servico in ( 'VACINACAO', 'ODONTOLOGIA' ) then
      v_classificacao_risco := 'PROCEDIMENTO ELETIVO (AZUL)';
      v_sla_maximo_minutos := 60;
   else
      v_classificacao_risco := 'ATENDIMENTO GERAL NÃO CLASSIFICADO';
      v_sla_maximo_minutos := 60;
   end if;

   -- Avaliação do cumprimento do SLA
   if v_minutos_espera > v_sla_maximo_minutos then
      v_status_sla := 'SLA VIOLADO (TEMPO EXCESSIVO)';
   else
      v_status_sla := 'DENTRO DA META OPERACIONAL';
   end if;

   -- Verifica se a unidade é favorita de cidadãos cadastrados
   select count(*) into v_total_favoritas from tb_cidadao_unidade_saude where id_unidade_saude = v_unidade_id;

   -- 4. Saída formatada no console via DBMS_OUTPUT.PUT_LINE
   dbms_output.put_line('================================================================');
   dbms_output.put_line('           NEXA - AUDITORIA DE ATENDIMENTO E PROTOCOLO SLA');
   dbms_output.put_line('================================================================');
   dbms_output.put_line('ID Atendimento:   ' || v_id_atendimento);
   dbms_output.put_line('Paciente:         ' || v_paciente_nome || ' (CPF: ' || v_paciente_cpf || ')');
   dbms_output.put_line('Unidade de Saúde: ' || v_unidade_nome || ' [' || v_tipo_unidade || ']');
   dbms_output.put_line('Cidadãos que Favoritaram esta Unidade: ' || v_total_favoritas);
   dbms_output.put_line('Profissional:     ' || v_colaborador_nome || ' (' || v_colaborador_cargo || ')');
   dbms_output.put_line('----------------------------------------------------------------');
   dbms_output.put_line('Senha Gerada:     ' || v_senha || ' | Especialidade: ' || v_servico);
   dbms_output.put_line('Status da Fila:   ' || v_status);
   dbms_output.put_line('Tempo de Espera:  ' || v_minutos_espera || ' minuto(s)');
   dbms_output.put_line('Classificação:    ' || v_classificacao_risco);
   dbms_output.put_line('SLA Máximo Alvo:  ' || v_sla_maximo_minutos || ' minutos');
   dbms_output.put_line('Parecer Operação: ' || v_status_sla);
   dbms_output.put_line('================================================================');

   -- 5. Tratamento de Exceções
exception
   when no_data_found then
      dbms_output.put_line('ERRO: Nenhum atendimento localizado com o ID ' || v_id_atendimento);
   when too_many_rows then
      dbms_output.put_line('ERRO: Inconsistência relacional — mais de um registro retornado para a mesma chave.');
   when others then
      dbms_output.put_line('ERRO INESPERADO [' || sqlcode || ']: ' || sqlerrm);
end;
/

-- 8. Cursor explícito filtrando apenas uma unidade (ex: ID 1)
   DECLARE
      CURSOR c_fila_espera IS
         SELECT a.senha, p.nome AS paciente, a.servico,
                     ROUND((CAST(CURRENT_TIMESTAMP AS DATE) - CAST(a.data_hora_chegada AS DATE)) * 24 * 60) AS minutos_espera
         FROM tb_atendimento a
         JOIN tb_paciente p ON a.id_paciente = p.id
         WHERE a.id_unidade_saude = 8922
            AND a.status_atendimento = 'AGUARDANDO'
         ORDER BY a.data_hora_chegada ASC;

      v_senha    tb_atendimento.senha%TYPE;
      v_paciente tb_paciente.nome%TYPE;
      v_servico  tb_atendimento.servico%TYPE;
      v_minutos  NUMBER;
      v_total    NUMBER := 0;
   BEGIN
         DBMS_OUTPUT.PUT_LINE('--- FILA DE ESPERA: PA MUN SAO MATEUS II  ---');

         OPEN c_fila_espera;
         LOOP
            FETCH c_fila_espera INTO v_senha, v_paciente, v_servico, v_minutos;
            EXIT WHEN c_fila_espera%NOTFOUND;

            v_total := v_total + 1;
            DBMS_OUTPUT.PUT_LINE(v_total || 'º da Fila | Senha: ' || v_senha || ' | Paciente: ' || v_paciente || ' |
            Espera: ' || v_minutos || ' min');
         END LOOP;
         CLOSE c_fila_espera;

      DBMS_OUTPUT.PUT_LINE('Total de pacientes aguardando nesta UBS: ' || v_total);
   END;
   /

-- 9. Procedures

-- 9.1. PRC_BUSCAR_UNIDADES_PROXIMAS (POR GEOLOCALIZAÇÃO / HAVERSINE)
-- =====================================================================
-- Entrada: Latitude, Longitude, Raio máximo em km (default 5km), Limite de resultados (default 10)
-- Saída: SYS_REFCURSOR contendo dados da unidade, endereço e distância em km
-- Utiliza Bounding Box dinâmico ativando o índice idx_localizacao_latitude_longitude
create or replace procedure pr_buscar_unidades_proximas (
   p_latitude  in number,
   p_longitude in number,
   p_raio_km   in number default 5.0,
   p_limite    in number default 10,
   p_resultado out sys_refcursor
) as
   v_raio_km   number := nvl(p_raio_km, 5.0);
   v_limite    number := nvl(p_limite, 10);
   -- 1 grau de latitude equivale a aprox. 111.045 km na Terra
   v_delta_lat number := v_raio_km / 111.0;
   v_delta_lon number;
   c_pi        constant number := 3.141592653589793;
   c_rad       constant number := c_pi / 180.0;
begin
   -- Variação de longitude ajustada pelo cosseno da latitude
   v_delta_lon := v_raio_km / ( 111.0 * cos(p_latitude * c_rad) );

   open p_resultado for
      with calculo as (
         select u.id as id_unidade,
                u.nome as nome_unidade,
                u.tipo_unidade,
                u.tempo_espera,
                l.cep,
                l.logradouro,
                l.numero,
                l.bairro,
                m.nome as municipio,
                e.sigla as uf,
                l.latitude,
                l.longitude,
                round(
                   6371.0 * 2 * atan2(
                      sqrt(power(sin((l.latitude - p_latitude) * c_rad / 2), 2) + cos(p_latitude * c_rad) * cos(l.latitude * c_rad) * power(sin((l.longitude - p_longitude) * c_rad / 2), 2)),
                      sqrt(1 - (power(sin((l.latitude - p_latitude) * c_rad / 2), 2) + cos(p_latitude * c_rad) * cos(l.latitude * c_rad) * power(sin((l.longitude - p_longitude) * c_rad / 2), 2)))
                   ),
                   3
                ) as distancia_km
           from tb_localizacao l
           join tb_unidade_saude u on u.id_localizacao = l.id
           join tb_municipio m on l.id_municipio = m.id
           join tb_estado e on m.id_estado = e.id
          -- Bounding Box para forçar o uso do índice B-Tree (latitude, longitude)
          where l.latitude between ( p_latitude - v_delta_lat ) and ( p_latitude + v_delta_lat )
            and l.longitude between ( p_longitude - abs(v_delta_lon) ) and ( p_longitude + abs(v_delta_lon) )
      )
      select * from calculo where distancia_km <= v_raio_km order by distancia_km asc fetch first v_limite rows only;
end pr_buscar_unidades_proximas;
/

-- 9.2. PRC_REALIZAR_CHECKIN (REGISTRO DE ATENDIMENTO / GERAÇÃO DE SENHA)
-- =====================================================================
-- Entrada: CPF do paciente, ID da unidade de saúde, Tipo de serviço ('CLINICO_GERAL', 'TRIAGEM', etc.)
-- Saída: VARCHAR2 contendo a senha sequencial formatada (ex: 'CLI-001', 'PED-012')
-- Valida o CPF do paciente, define o prefixo do serviço e insere o atendimento com status 'AGUARDANDO'
   CREATE OR REPLACE PROCEDURE prc_realizar_checkin (
      p_cpf_paciente   IN  VARCHAR2,
      p_id_unidade     IN  NUMBER,
      p_servico        IN  VARCHAR2, -- 'CLINICO_GERAL', 'PEDIATRIA', etc.
      p_senha_gerada   OUT VARCHAR2
   ) IS
      v_id_paciente    tb_paciente.id%TYPE;
      v_proximo_num    NUMBER;
      v_prefixo        VARCHAR2(5);
   BEGIN
      SELECT id INTO v_id_paciente
      FROM tb_paciente
      WHERE cpf = p_cpf_paciente;

      IF p_servico = 'CLINICO_GERAL' THEN v_prefixo := 'CLI';
      ELSIF p_servico = 'TRIAGEM'     THEN v_prefixo := 'TRI';
      ELSIF p_servico = 'PEDIATRIA'   THEN v_prefixo := 'PED';
      ELSIF p_servico = 'VACINACAO'   THEN v_prefixo := 'VAC';
      ELSIF p_servico = 'ODONTOLOGIA'   THEN v_prefixo := 'ODO';
      ELSE v_prefixo := 'GER';
      END IF;

      -- 3. Conta quantos atendimentos já existem para gerar a próxima senha sequencial
      SELECT COUNT(*) + 1 INTO v_proximo_num
      FROM tb_atendimento
      WHERE id_unidade_saude = p_id_unidade AND servico = p_servico;

      p_senha_gerada := v_prefixo || '-' || LPAD(v_proximo_num, 3, '0');

      INSERT INTO tb_atendimento (
         id_unidade_saude, id_paciente, status_atendimento,
         data_hora_chegada, senha, servico
      ) VALUES (
         p_id_unidade, v_id_paciente, 'AGUARDANDO', CURRENT_TIMESTAMP, p_senha_gerada, p_servico
        );

      COMMIT;
      DBMS_OUTPUT.PUT_LINE('Check-in realizado! Senha gerada: ' || p_senha_gerada);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Paciente com CPF ' || p_cpf_paciente || ' não encontrado.');
      WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('ERRO ao realizar check-in: ' || SQLERRM);
   END prc_realizar_checkin;
   /

-- 10. Teste da procedure de Unidades mais próximas da minha casa:
   DECLARE
        v_cursor  SYS_REFCURSOR;
        v_id      tb_unidade_saude.id%TYPE;
        v_nome    tb_unidade_saude.nome%TYPE;
        v_tipo    tb_unidade_saude.tipo_unidade%TYPE;
        v_espera  tb_unidade_saude.tempo_espera%TYPE;
        v_cep     tb_localizacao.cep%TYPE;
        v_logr    tb_localizacao.logradouro%TYPE;
        v_num     tb_localizacao.numero%TYPE;
        v_bairro  tb_localizacao.bairro%TYPE;
        v_mun     tb_municipio.nome%TYPE;
        v_uf      tb_estado.sigla%TYPE;
        v_lat     tb_localizacao.latitude%TYPE;
        v_lon     tb_localizacao.longitude%TYPE;
        v_dist    NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- BUSCA HAVERSINE (RAIO 5 KM) ---');
        pr_buscar_unidades_proximas(-23.619035, -46.507267, 5.0, 5, v_cursor);
        LOOP
            FETCH v_cursor INTO v_id, v_nome, v_tipo, v_espera, v_cep, v_logr, v_num, v_bairro, v_mun, v_uf, v_lat,
            v_lon, v_dist;
            EXIT WHEN v_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('[' || v_dist || ' km] ' || v_nome || ' (' || v_bairro || ' - ' || v_mun || '/' ||
            v_uf || ')');
        END LOOP;
        CLOSE v_cursor;
    END;
    /

-- 11. Teste da procedure de CheckIn, na unidade 8922:
   DECLARE
      v_senha_gerada VARCHAR2(20);
   BEGIN
      prc_realizar_checkin(
         p_cpf_paciente => '00000000007',
         p_id_unidade   => 8922,
         p_servico      => 'CLINICO_GERAL',
         p_senha_gerada => v_senha_gerada
      );
      DBMS_OUTPUT.PUT_LINE('Senha gerada pelo Check-in: ' || v_senha_gerada);
   END;
   /

-- 12. Verificar quantidade de registros da base, em cada tabela:
   SELECT 'TB_ESTADO' TABELA, COUNT(*) TOTAL FROM TB_ESTADO
   UNION ALL
   SELECT 'TB_MUNICIPIO', COUNT(*) FROM TB_MUNICIPIO
   UNION ALL
   SELECT 'TB_LOCALIZACAO', COUNT(*) FROM TB_LOCALIZACAO
   UNION ALL
   SELECT 'TB_UNIDADE_SAUDE', COUNT(*) FROM TB_UNIDADE_SAUDE
   UNION ALL
   SELECT 'TB_PACIENTE', COUNT(*) FROM TB_PACIENTE
   UNION ALL
   SELECT 'TB_CIDADAO', COUNT(*) FROM TB_CIDADAO
   UNION ALL
   SELECT 'TB_COLABORADOR', COUNT(*) FROM TB_COLABORADOR
   UNION ALL
   SELECT 'TB_ATENDIMENTO', COUNT(*) FROM TB_ATENDIMENTO
   UNION ALL
   SELECT 'TB_CIDADAO_UNIDADE_SAUDE', COUNT(*) FROM TB_CIDADAO_UNIDADE_SAUDE;

-- 13. SELECT de verificação final das tabelas
   select * from tb_estado;
   select * from tb_municipio;
   select * from tb_localizacao;
   select * from tb_unidade_saude;
   select * from tb_paciente;
   select * from tb_cidadao;
   select * from tb_colaborador;
   select * from tb_atendimento;
   select * from tb_cidadao_unidade_saude;