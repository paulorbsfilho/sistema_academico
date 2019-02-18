------------------------------------------------------------------------------------------------------------------------

--                                                 BANCO E TABELAS

------------------------------------------------------------------------------------------------------------------------

DROP SCHEMA public CASCADE;

CREATE SCHEMA public;

CREATE TABLE ALUNOS
(
  IDALUNO SERIAL PRIMARY KEY NOT NULL,
  NOME    VARCHAR(30),
  SEXO    VARCHAR(1),
  EMAIL   VARCHAR(50),
  CPF     VARCHAR(15)
);


CREATE TABLE TELEFONES
(
  IDTELEFONE SERIAL PRIMARY KEY NOT NULL,
  TIPO       VARCHAR(3),
  NUMERO     VARCHAR(10),
  ID_ALUNO   INT,
  FOREIGN KEY (ID_ALUNO)
  REFERENCES ALUNOS (IDALUNO)
);


CREATE TABLE ENDERECOS
(
  IDENDERECO SERIAL PRIMARY KEY NOT NULL,
  RUA        VARCHAR(30),
  BAIRRO     VARCHAR(30),
  CIDADE     VARCHAR(30),
  ESTADO     CHAR(2),
  ID_ALUNO   INT,
  FOREIGN KEY (ID_ALUNO)
  REFERENCES ALUNOS (IDALUNO)
);


CREATE TABLE CURSOS
(
  IDCURSO SERIAL PRIMARY KEY NOT NULL,
  NOME    VARCHAR(30)
);


CREATE TABLE PROFESSORES
(
  IDPROFESSOR SERIAL PRIMARY KEY NOT NULL,
  NOME        VARCHAR(30),
  SEXO        VARCHAR(1),
  EMAIL       VARCHAR(50),
  CPF         VARCHAR(15)
);


CREATE TABLE DISCIPLINAS
(
  IDDISCIPLINA SERIAL PRIMARY KEY NOT NULL,
  NOME         VARCHAR(50),
  ID_CURSO     INT,
  FOREIGN KEY (ID_CURSO) REFERENCES CURSOS (IDCURSO),
  PREREQUISITO INT,
  FOREIGN KEY (PREREQUISITO)
  REFERENCES DISCIPLINAS (IDDISCIPLINA),
  ID_PROFESSOR INT,
  FOREIGN KEY (ID_PROFESSOR) REFERENCES PROFESSORES (IDPROFESSOR),
  NUM_B        INT
);


CREATE TABLE BLOCOS
(
  IDBLOCO   SERIAL PRIMARY KEY NOT NULL,
  NUM_BLOCO INT,
  ID_CURSO  INT,
  FOREIGN KEY (ID_CURSO)
  REFERENCES CURSOS (IDCURSO)
);


CREATE TABLE SALAS
(
  IDSALA SERIAL PRIMARY KEY NOT NULL,
  NOME   VARCHAR(30),
  STATUS VARCHAR(1)
);

CREATE TABLE BOLETIM
(
  IDBOLETIM     SERIAL PRIMARY KEY NOT NULL,
  ID_ALUNO      INT,
  FOREIGN KEY (ID_ALUNO) REFERENCES ALUNOS (IDALUNO),
  ID_DISCIPLINA INT,
  FOREIGN KEY (ID_DISCIPLINA) REFERENCES DISCIPLINAS (IDDISCIPLINA),
  NOTA          FLOAT
);

------------------------------------------------------------------------------------------------------------------------

--                                              TABELAS ASSOCIATIVAS

------------------------------------------------------------------------------------------------------------------------


CREATE TABLE MATRICULA
(
  IDMATRICULA SERIAL PRIMARY KEY,
  BLOCO_ATUAL INT DEFAULT 0,
  ID_ALUNO    INT,
  FOREIGN KEY (ID_ALUNO)
  REFERENCES ALUNOS (IDALUNO),
  ID_CURSO    INT,
  FOREIGN KEY (ID_CURSO)
  REFERENCES CURSOS (IDCURSO)
);


CREATE TABLE TURMAS
(
  IDTURMA       SERIAL PRIMARY KEY,
  MATRICULA     INT,
  FOREIGN KEY (MATRICULA)
  REFERENCES MATRICULA (IDMATRICULA),
  ID_DISCIPLINA INT,
  FOREIGN KEY (ID_DISCIPLINA)
  REFERENCES DISCIPLINAS (IDDISCIPLINA),
  ID_SALA       INT,
  FOREIGN KEY (ID_SALA)
  REFERENCES SALAS (IDSALA)
);

------------------------------------------------------------------------------------------------------------------------

--                                                      FUNÇÕES

------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION cadastrarAluno(NOME_A VARCHAR(30), SEXO_A varchar(1), EMAIL_A VARCHAR(50), CPF_A VARCHAR(15))
  RETURNS VOID AS
$$
BEGIN
  IF NOME_A IS NULL OR NOME_A LIKE ''
  THEN
    RAISE EXCEPTION 'O NOME DO ALUNO NÃO PODE SER NULO OU VAZIO!';
  ELSEIF SEXO_A IS NULL OR SEXO_A LIKE ''
    THEN
      RAISE EXCEPTION 'O SEXO DO ALUNO NÃO PODE SER NULO OU VAZIO!';
  ELSEIF EMAIL_A IS NULL OR EMAIL_A LIKE ''
    THEN
      RAISE EXCEPTION 'O EMAIL DO ALUNO NÃO PODE SER NULO OU VAZIO!';
  ELSEIF NOT (SEXO_A ILIKE 'M' OR SEXO_A ILIKE 'F')
    THEN
      RAISE EXCEPTION 'O SEXO DO ALUNO É INVÁLIDO!';
  ELSEIF CPF_A IS NULL OR CPF_A LIKE ''
    THEN
      RAISE EXCEPTION 'O CPF DO ALUNO NÃO PODE SER NULO OU VAZIO!';
  ELSE
    INSERT INTO ALUNOS VALUES (DEFAULT, NOME_A, SEXO_A, EMAIL_A, CPF_A);
    RAISE NOTICE 'ALUNO CADASTRADO COM SUCESSO!';
  END IF;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION cadastrarCurso(NOME_C VARCHAR(30))
  RETURNS VOID AS
$$
BEGIN
  IF NOME_C IS NULL OR NOME_C LIKE ''
  THEN
    RAISE EXCEPTION 'O NOME DO CURSO NÃO PODE SER NULO OU VAZIO!';
  ELSE
    INSERT INTO CURSOS VALUES (DEFAULT, NOME_C);
    RAISE NOTICE 'CURSO CADASTRADO COM SUCESSO!';
  END IF;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION cadastrarProfessor(NOME_P VARCHAR(30), SEXO_P VARCHAR(1), EMAIL_P VARCHAR(50),
                                              CPF_P  VARCHAR(15))
  RETURNS VOID AS
$$
BEGIN
  IF NOME_P IS NULL OR NOME_P LIKE ''
  THEN
    RAISE EXCEPTION 'O NOME DO PROFESSOR NÃO PODE SER NULO OU VAZIO!';
  ELSEIF SEXO_P IS NULL OR SEXO_P LIKE ''
    THEN
      RAISE EXCEPTION 'O SEXO DO PROFESSOR NÃO PODE SER NULO OU VAZIO!';
  ELSEIF EMAIL_P IS NULL OR EMAIL_P LIKE ''
    THEN
      RAISE EXCEPTION 'O EMAIL DO PROFESSOR NÃO PODE SER NULO OU VAZIO!';
  ELSEIF CPF_P IS NULL OR CPF_P LIKE ''
    THEN
      RAISE EXCEPTION 'O CPF DO PROFESSOR NÃO PODE SER NULO OU VAZIO!';
  ELSE
    INSERT INTO PROFESSORES VALUES (DEFAULT, NOME_P, SEXO_P, EMAIL_P, CPF_P);
    RAISE NOTICE 'PROFESSOR CADASTRADO COM SUCESSO!';
  END IF;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION cadastrarDisciplina(NOME_D VARCHAR(30), CURSO VARCHAR(30), PREREQUISITO_D VARCHAR(30),
                                               NOME_P VARCHAR(30), N_BLOCO INT)
  RETURNS VOID AS
$$
DECLARE
  ID_PREREQ    INT;
  ID_PROF      INT;
  VAR_ID_CURSO INT;
BEGIN
  SELECT IDCURSO INTO VAR_ID_CURSO FROM CURSOS C WHERE CURSO = C.NOME;
  SELECT IDPROFESSOR INTO ID_PROF FROM PROFESSORES P WHERE NOME_P LIKE P.NOME;
  SELECT PREREQUISITO INTO ID_PREREQ FROM DISCIPLINAS D WHERE D.NOME = PREREQUISITO_D;
  IF NOME_D IS NULL OR NOME_D LIKE ''
  THEN
    RAISE EXCEPTION 'O NOME DA DISCIPLINA NÃO PODE SER NULO OU VAZIO!';
  ELSEIF NOME_P IS NULL OR NOME_P LIKE ''
    THEN
      RAISE EXCEPTION 'O NOME DO PROFESSOR NÃO PODE SER NULO OU VAZIO!';
  ELSEIF N_BLOCO IS NULL
    THEN
      RAISE EXCEPTION 'O ID DO BLOCO NÃO PODE SER NULO OU VAZIO!';
  ELSEIF CURSO IS NULL OR CURSO LIKE ''
    THEN
      RAISE EXCEPTION 'O NOME DO CURSO NÃO PODE SER NULO OU VAZIO!';
  ELSEIF VAR_ID_CURSO IS NULL OR VAR_ID_CURSO = 0
    THEN
      RAISE EXCEPTION 'O ID DO CURSO NÃO PODE SER NULO';
  ELSEIF ID_PROF IS NULL
    THEN
      RAISE EXCEPTION 'O ID DO PROFESSOR NAO PODE SER NULO';
  ELSE
    IF PREREQUISITO_D IS NULL OR PREREQUISITO_D LIKE ''
    THEN
      INSERT INTO DISCIPLINAS VALUES (DEFAULT, NOME_D, VAR_ID_CURSO, ID_PREREQ, ID_PROF, N_BLOCO);
      RAISE NOTICE 'DISCIPLINA CADASTRADA COM SUCESSO!';
    ELSE
      INSERT INTO DISCIPLINAS VALUES (DEFAULT, NOME_D, VAR_ID_CURSO, ID_PREREQ, ID_PROF, N_BLOCO);
      RAISE NOTICE 'DISCIPLINA CADASTRADA COM SUCESSO!';
    END IF;
  END IF;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION cadastrarBloco(N_BLOCO INT, NOMECURSO_B VARCHAR(30))
  RETURNS VOID AS
$$
DECLARE VAR_IDCURSO INT;
BEGIN
  SELECT IDCURSO INTO VAR_IDCURSO FROM CURSOS C WHERE NOMECURSO_B = C.NOME;
  IF NOMECURSO_B IS NULL OR NOMECURSO_B LIKE ''
  THEN
    RAISE EXCEPTION 'VOCÊ DEVE INFORMAR O NOME DE UM CURSO PARA ASSOCIAR AO BLOCO!';
  ELSEIF N_BLOCO IS NULL
    THEN
      RAISE EXCEPTION 'VOCÊ DEVE INFORMAR O NOME DO PARA ASSOCIAR AO BLOCO!';
  ELSE
    INSERT INTO BLOCOS VALUES (DEFAULT, N_BLOCO, VAR_IDCURSO);
  END IF;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION matricularNoCurso(ALUNO VARCHAR(30), CURSO VARCHAR(30))
  RETURNS VOID AS
$$
DECLARE
  VAR_ALUNO INT;
  VAR_CURSO INT;
BEGIN
  SELECT IDALUNO INTO VAR_ALUNO FROM ALUNOS A WHERE ALUNO = A.NOME;
  SELECT IDCURSO INTO VAR_CURSO FROM CURSOS C WHERE CURSO = C.NOME;
  IF ALUNO IS NULL
  THEN
    RAISE EXCEPTION 'O ID DO ALUNO NÃO PODE SER NULO!';
  ELSEIF CURSO IS NULL
    THEN
      RAISE EXCEPTION 'O ID DO CURSO NÃO PODE SER NULO!';
  ELSE
    INSERT INTO MATRICULA VALUES (DEFAULT, DEFAULT, VAR_ALUNO, VAR_CURSO);
    RAISE NOTICE 'ALUNO MATRICULADO COM SUCESSO!';
  END IF;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION cadastrarSala()
  RETURNS TRIGGER AS
$$
DECLARE
  IDSALA_S VARCHAR(30);
BEGIN
  SELECT NOME FROM SALAS INTO IDSALA_S;
  IF NEW.NOME IS NULL OR NEW.NOME LIKE ''
  THEN
    RAISE EXCEPTION 'O NOME DA SALA NÃO PODE SER NULO OU VAZIO!';
  ELSIF IDSALA_S = NEW.NOME
    THEN
      RAISE EXCEPTION 'JÁ EXISTE UMA SALA COM ESTE NOME!';
  ELSE
    RAISE NOTICE 'SALA CADASTRADA COM SUCESSO!';
  END IF;
  RETURN NEW;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION matriculaAutomatica()
  RETURNS TRIGGER AS
$BODY$
DECLARE
  --cursor
  reg RECORD;
  DISC INT;
  VAR_SALA INT;
BEGIN
  SELECT D1.IDDISCIPLINA INTO DISC FROM DISCIPLINAS D1 WHERE D1.NUM_B = 1;
  --realiza um loop em todos os telefones da tabela
  FOR reg in
  SELECT D2.IDDISCIPLINA FROM DISCIPLINAS D2 WHERE D2.NUM_B = 1
  LOOP
    SELECT S.ID_SALA INTO VAR_SALA FROM SALAS_LIVRES S;
    INSERT INTO TURMAS VALUES (DEFAULT, NEW.IDMATRICULA, REG.IDDISCIPLINA, VAR_SALA);
    UPDATE SALAS SET STATUS = 'O' WHERE IDSALA = VAR_SALA;
    RETURN NEW;
  END LOOP;
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION lancarNotas(ALUNOB VARCHAR(30), DISCIPLINAB VARCHAR(30), NOTAB FLOAT)
  RETURNS VOID AS
$$
DECLARE
  VAR_ALUNO INT;
  VAR_DISC  INT;
BEGIN
  SELECT IDALUNO INTO VAR_ALUNO FROM ALUNOS WHERE ALUNOB = ALUNOS.NOME;
  SELECT IDDISCIPLINA INTO VAR_DISC FROM DISCIPLINAS WHERE DISCIPLINAB = DISCIPLINAS.NOME;
  IF ALUNOB IS NULL OR ALUNOB LIKE ''
  THEN
    RAISE EXCEPTION 'O NOME DO ALUNO NÃO PODE SER NULO OU VAZIO!';
  ELSIF DISCIPLINAB IS NULL OR DISCIPLINAB LIKE ''
    THEN
      RAISE EXCEPTION 'O NOME DA DISCIPLINA NAO PODE SER NULO OU VAZIO!';
  ELSEIF NOTAB < 0.0
    THEN
      RAISE EXCEPTION 'A NOTA NAO PODE SER MENOR QUE ZERO!';
  ELSE
    INSERT INTO BOLETIM VALUES (DEFAULT, VAR_ALUNO, VAR_DISC, NOTAB);
    RAISE NOTICE 'A NOTA FOI LANCADA COM SUCESSO';
  END IF;
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION INSERIR(TABELA TEXT, VALORES TEXT)
  RETURNS VOID AS
$$
DECLARE
  STR TEXT;
BEGIN
  IF ($2 NOT ILIKE '%DEFAULT%')
  THEN
    STR := 'INSERT INTO ' || $1 || ' VALUES (DEFAULT,' || $2 || ');';
  ELSE
    STR := 'INSERT INTO ' || $1 || ' VALUES (' || $2 || ');';
  END IF;
END;
$$
LANGUAGE PLPGSQL;

CREATE or REPLACE FUNCTION ATUALIZAR(TABELA TEXT, COLUNAS TEXT, CONDICAO TEXT)
  RETURNS VOID AS
$$
DECLARE
  TMP  TEXT;
  STR  TEXT := 'UPDATE ' || $1 || ' SET ' || $2 || ' WHERE ''' || $3 || ''';';
  STR2 TEXT := 'UPDATE ' || $1 || ' SET ' || $2 || ' WHERE ''' || $3 || ''';';
BEGIN
  SELECT TABELA INTO TMP;
  IF ($3 = '')
  THEN
    EXECUTE STR;
  ELSE
    EXECUTE STR2;
  END IF;
END;
$$
LANGUAGE PLPGSQL;

CREATE or REPLACE FUNCTION DELETAR(TABELA TEXT, VALOR TEXT)
  RETURNS VOID AS
$$
DECLARE
  STR TEXT := 'DELETE FROM ' || $1 || ' WHERE NOME = ''' || $2 || ''';';
BEGIN
  EXECUTE STR;
END;
$$
LANGUAGE PLPGSQL;

-- CREATE OR REPLACE FUNCTION matriculaAprovados()
--   RETURNS TRIGGER AS
-- $$
-- DECLARE
--   BOLETIM_ALUNO RECORD;
-- BEGIN
--   SELECT NOTA INTO NOTA FROM BOLETIM WHERE NEW.;
--   FOR R IN DISCIPLINAS_INICIAIS LOOP
--   INSERT INTO TURMAS(NEW.MATRICULA, ID_DISCIPLINA, ID_SALA);
--
-- end loop;
--   RETURN NEW;
-- END;
-- $$
-- LANGUAGE PLPGSQL;

------------------------------------------------------------------------------------------------------------------------

--                                                   TRIGGERS

------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER TGR_feedBackOperacao
  BEFORE INSERT
  ON SALAS
  FOR EACH ROW
EXECUTE PROCEDURE cadastrarSala();

CREATE TRIGGER TGR_matriculaAutomatica
  AFTER INSERT OR
  UPDATE
  ON MATRICULA
  FOR EACH ROW
EXECUTE PROCEDURE matriculaAutomatica();

------------------------------------------------------------------------------------------------------------------------

--                                                       VIEWS

------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE VIEW ALUNOS_ORDEM_ALFABETICA AS
  SELECT NOME, EMAIL, CPF
  FROM ALUNOS
  ORDER BY NOME;


CREATE OR REPLACE VIEW TELEFONES_ALUNOS AS
  SELECT A.NOME, T.TIPO, T.NUMERO
  FROM ALUNOS A
         INNER JOIN TELEFONES T ON A.IDALUNO = T.ID_ALUNO;


CREATE OR REPLACE VIEW PROFESSORES_ORDEM_ALFABETICA AS
  SELECT NOME, EMAIL, CPF
  FROM PROFESSORES
  ORDER BY NOME;


CREATE OR REPLACE VIEW PROFESSORES_DISCIPLINAS AS
  SELECT P.NOME
  FROM PROFESSORES P
         INNER JOIN DISCIPLINAS D on P.IDPROFESSOR = D.ID_PROFESSOR
  ORDER BY P.NOME;


CREATE OR REPLACE VIEW DISCIPLINAS_ORDEM_ALFABETICA AS
  SELECT NOME
  FROM DISCIPLINAS
  ORDER BY NOME;


CREATE OR REPLACE VIEW DISCIPLINAS_CURSO AS
  SELECT C.NOME AS CURSO, D.NOME AS DISCIPLINA
  FROM CURSOS C
         INNER JOIN DISCIPLINAS D ON C.IDCURSO = D.ID_CURSO;


CREATE OR REPLACE VIEW SALAS_DE_AULA AS
  SELECT NOME
  FROM SALAS
  ORDER BY NOME;


CREATE OR REPLACE VIEW ALUNOS_TURMA AS
  SELECT A.NOME
  FROM ALUNOS A
         INNER JOIN MATRICULA M ON A.IDALUNO = M.ID_ALUNO
         INNER JOIN TURMAS T ON M.IDMATRICULA = T.MATRICULA;


CREATE OR REPLACE VIEW SALAS_LIVRES AS
  SELECT MIN(IDSALA) AS ID_SALA FROM SALAS S WHERE STATUS LIKE 'L';




------------------------------------------------------------------------------------------------------------------------

--                                                      INSERTS

------------------------------------------------------------------------------------------------------------------------

SELECT cadastrarAluno('PAULO', 'M', 'PAULO@GMAIL.CM', '054.923.83-90');
SELECT cadastrarAluno('JEFF', 'M', 'JEFF@GMAIL.COM', '051.923.83-90');
SELECT cadastrarAluno('BILL', 'M', 'BILL@GMAIL.COM', '051.923.831-90');
SELECT cadastrarAluno('MLKDD', 'M', 'MLKDD@GMAIL.COM', '021.923.831-90');
SELECT cadastrarAluno('TIJOLINHO', 'M', 'TIJOLINHO@GMAIL.COM', '022.923.831-90');
SELECT cadastrarAluno('GIL', 'M', 'GIL@GMAIL.COM', '022.933.831-90');


SELECT cadastrarCurso('ADS');
SELECT cadastrarCurso('ADM');
SELECT cadastrarCurso('GEOPROCESSAMENTO');


SELECT cadastrarProfessor('RICARDO', 'M ', 'RICARDO@IFPI.EDU.COM', '2345678910');
SELECT cadastrarProfessor('ERICK', 'M', 'ERICK@IFPI.EDU.COM', '134578910');
SELECT cadastrarProfessor('FATIMA', 'M', 'FATIMA@IFPI.EDU.COM', '1345678910');
SELECT cadastrarProfessor('LOSSIAN', 'M', 'LOSSIAN@IFPI.EDU.COM', '1234578910');
SELECT cadastrarProfessor('GRU', 'M', 'GRU@IFPI.EDU.COM', '123478910');
SELECT cadastrarProfessor('INARA', 'F', 'INARA@IFPI.EDU.COM', '122552353535');
SELECT cadastrarProfessor('FABIO', 'M', 'FABIO@IFPI.EDU.COM', '1345781220');
SELECT cadastrarProfessor('NEY', 'M', 'NEY@IFPI.EDU.COM', '134578120');
SELECT cadastrarProfessor('MARTINS', 'M', 'MARTINS@IFPI.EDU.COM', '13457810');
SELECT cadastrarProfessor('ELY', 'M', 'ELY@IFPI.EDU.COM', '134781220');
SELECT cadastrarProfessor('THIAGO', 'M', 'THIAGO@IFPI.EDU.COM', '12345678910');


SELECT cadastrarDisciplina('INTRODUCAO A COMPUTACAO', 'ADS', NULL, 'RICARDO', 1);
SELECT cadastrarDisciplina('ALGORITMOS', 'ADS', NULL, 'ERICK', 1);
SELECT cadastrarDisciplina('INGLES INSTRUMENTAL', 'ADS', NULL, 'FATIMA', 1);
SELECT cadastrarDisciplina('MATEMATICA', 'ADS', NULL, 'LOSSIAN', 1);
SELECT cadastrarDisciplina('PORTUGUES', 'ADS', NULL, 'GRU', 1);
SELECT cadastrarDisciplina('INTRODUCAO A ADMINISTRACAO', 'ADS', NULL, 'INARA', 1);
SELECT cadastrarDisciplina('ESTRUTURA DE DADOS', 'ADS', 'ALGORITMOS', 'FABIO', 2);
SELECT cadastrarDisciplina('ARQUITETURA DE COMPUTADORES', 'ADS', 'INTRODUCAO A COMPUTACAO', 'NEY', 2);
SELECT cadastrarDisciplina('ORGANIZACAO DE SISTEMAS E METODOS', 'ADS', 'INTRODUCAO A ADMINISTRACAO', 'MARTINS', 2);
SELECT cadastrarDisciplina('PROGRAMACAO ORIENTADA A OBJETOS', 'ADS', 'ALGORITMOS', 'ELY', 2);
SELECT cadastrarDisciplina('INTRODUCAO A BANCO DE DADOS', 'ADS', 'ESTRTURA DE DADOS', 'THIAGO', 3);


SELECT cadastrarBloco(1, 'ADS');
SELECT cadastrarBloco(1, 'ADS');
SELECT cadastrarBloco(1, 'ADS');
SELECT cadastrarBloco(1, 'ADS');
SELECT cadastrarBloco(1, 'ADS');
SELECT cadastrarBloco(1, 'ADS');
SELECT cadastrarBloco(2, 'ADS');
SELECT cadastrarBloco(2, 'ADS');
SELECT cadastrarBloco(2, 'ADS');
SELECT cadastrarBloco(2, 'ADS');
SELECT cadastrarBloco(3, 'ADS');


INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-01', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-02', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-03', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-04', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-05', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-06', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-07', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-08', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-09', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-10', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-12', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-13', 'L');
INSERT INTO SALAS (NOME, STATUS) VALUES ('B2-14', 'L');



SELECT matricularNoCurso('PAULO', 'ADS');
SELECT matricularNoCurso('JEFF', 'ADS');
SELECT matricularNoCurso('BILL', 'ADS');
SELECT matricularNoCurso('MLKDD', 'ADS');
SELECT matricularNoCurso('TIJOLINHO', 'ADS');
SELECT matricularNoCurso('MATEUS', 'ADS');


SELECT lancarNotas('PAULO', 'INTRODUCAO A COMPUTACAO', 7.0);
SELECT lancarNotas('JEFF', 'INTRODUCAO A COMPUTACAO', 7.0);
SELECT lancarNotas('BILL', 'INTRODUCAO A COMPUTACAO', 7.0);
SELECT lancarNotas('TIJOLINHO', 'INTRODUCAO A COMPUTACAO', 7.0);
SELECT lancarNotas('GIL', 'INTRODUCAO A COMPUTACAO', 7.0);
SELECT lancarNotas('MLKDD', 'INTRODUCAO A COMPUTACAO', 7.0);
SELECT lancarNotas('PAULO', 'ALGORITMOS', 7.0);
SELECT lancarNotas('JEFF', 'ALGORITMOS', 7.0);
SELECT lancarNotas('BILL', 'ALGORITMOS', 7.0);
SELECT lancarNotas('TIJOLINHO', 'ALGORITMOS', 7.0);
SELECT lancarNotas('GIL', 'ALGORITMOS', 7.0);
SELECT lancarNotas('MLKDD', 'ALGORITMOS', 7.0);
SELECT lancarNotas('PAULO', 'INGLES INSTRUMENTAL', 7.0);
SELECT lancarNotas('JEFF', 'INGLES INSTRUMENTAL', 7.0);
SELECT lancarNotas('BILL', 'INGLES INSTRUMENTAL', 7.0);
SELECT lancarNotas('TIJOLINHO', 'INGLES INSTRUMENTAL', 7.0);
SELECT lancarNotas('GIL', 'INGLES INSTRUMENTAL', 7.0);
SELECT lancarNotas('MLKDD', 'INGLES INSTRUMENTAL', 7.0);
SELECT lancarNotas('PAULO', 'MATEMATICA', 7.0);
SELECT lancarNotas('JEFF', 'MATEMATICA', 7.0);
SELECT lancarNotas('BILL', 'MATEMATICA', 7.0);
SELECT lancarNotas('TIJOLINHO', 'MATEMATICA', 7.0);
SELECT lancarNotas('GIL', 'MATEMATICA', 7.0);
SELECT lancarNotas('MLKDD', 'MATEMATICA', 7.0);
SELECT lancarNotas('PAULO', 'PORTUGUES', 7.0);
SELECT lancarNotas('JEFF', 'PORTUGUES', 7.0);
SELECT lancarNotas('BILL', 'PORTUGUES', 7.0);
SELECT lancarNotas('TIJOLINHO', 'PORTUGUES', 7.0);
SELECT lancarNotas('GIL', 'PORTUGUES', 7.0);
SELECT lancarNotas('MLKDD', 'PORTUGUES', 7.0);
SELECT lancarNotas('PAULO', 'INTRODUCAO A ADMINISTRACAO', 7.0);
SELECT lancarNotas('JEFF', 'INTRODUCAO A ADMINISTRACAO', 7.0);
SELECT lancarNotas('BILL', 'INTRODUCAO A ADMINISTRACAO', 7.0);
SELECT lancarNotas('TIJOLINHO', 'INTRODUCAO A ADMINISTRACAO', 7.0);
SELECT lancarNotas('GIL', 'INTRODUCAO A ADMINISTRACAO', 7.0);
SELECT lancarNotas('MLKDD', 'INTRODUCAO A ADMINISTRACAO', 7.0);

-- MOSTRAR BOLETIM (APENAS UMA NOTA) INDIVIDUAL;
-- MOSTRAR CURSOS;
-- MOSTRAR DISCIPLINAS DE UM CURSO;
-- MOSTRAR PROFESSOR DE UMA DISCIPLINA;
-- MOSTRAR HORÁRIO INDIVIDUAL;

-- MATRICULAR ALUNOS NOVOS NO PRIMEIRO BLOCO DE UM CURSO;
-- MATRICULAR ALUNOS APROVADOS NO BLOCO SEGUINTE DE UM CURSO;

SELECT * FROM TURMAS
