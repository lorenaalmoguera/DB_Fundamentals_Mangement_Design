CONNECT system/bdadmin;

CREATE USER motivacion1 IDENTIFIED BY motivacion1;

GRANT RESOURCE, CONNECT TO motivacion1;

CONNECT motivacion1/motivacion1;

CREATE TABLE MENOR (
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    fechanac DATE,
    CONSTRAINT men_dni_pk PRIMARY KEY (dni)
);

CREATE TABLE ABOGADO (
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    ncolegido VARCHAR2(50) CONSTRAINT abo_nco_nn NOT NULL,
    CONSTRAINT abo_dni_pk PRIMARY KEY (dni),
    CONSTRAINT abo_nco_uq UNIQUE (ncolegido)
);

CREATE TABLE EXPEDIENTE (
    numero NUMBER(3),
    dnimenor VARCHAR2(9),
    delito VARCHAR2(50),
    fechaapertura DATE,
    sentencia VARCHAR2(2),
    dniabogado VARCHAR2(9) CONSTRAINT exp_dnia_nn NOT NULL,
    CONSTRAINT exp_num_dnim_pk PRIMARY KEY(numero, dnimenor),
    CONSTRAINT exp_dnim_men_fk FOREIGN KEY(dnimenor) REFERENCES MENOR,
    CONSTRAINT exp_dnia_abo_fk FOREIGN KEY(dniabogado) REFERENCES ABOGADO,
    CONSTRAINT exp_sen_ch CHECK (sentencia IN ('C', 'I'))
);

-- 2 

CONNECT SYSTEM/bdadmin;

GRANT CREATE VIEW TO motivacion1;

CREATE USER usermot IDENTIFIED BY usermot;

CONNECT motivacion1/motivacion1;

CREATE VIEW inocente_anyo AS
    SELECT numero, dnimenor, delito, fechaapertura
    FROM EXPEDIENTE
    WHERE sentencia = 'I' AND EXTRACT(YEAR FROM fechaapertura) = EXTRACT(YEAR FROM SYSDATE)
    WITH CHECK OPTION CONSTRAINT ino_fec_ch;

CONNECT SYSTEM/bdadmin;

GRANT SELECT ON motivacion1.inocente_anyo TO usermot;
GRANT UPDATE ON motivacion1.inocente_anyo TO usermot;

CONNECT motivacion1/motivacion1;

INSERT INTO MENOR(dni, nombre, apellido1, fechanac) VALUES ('48796558B', 'Lorena', 'Almoguera', TO_DATE('2000-04-02', 'YYYY-MM-DD'));
INSERT INTO ABOGADO(dni, nombre, apellido1, ncolegido) VALUES ('1111111A', 'Alfredo', 'Pasta', TO_DATE ('1980-02-10', 'YYYY-MM-DD'));
INSERT INTO EXPEDIENTE(numero, dnimenor, delito, fechaapertura, sentencia, dniabogado) VALUES (123, '48796558B', 'cagar en publico', TO_DATE('2025-03-11', 'YYYY-MM-DD'), 'I', '1111111A');

CONNECT SYSTEM/bdadmin;

GRANT CREATE SESSION TO usermot;
CONNECT usermot/usermot;

SELECT * FROM motivacion1.inocente_anyo;

UPDATE motivacion1.inocente_anyo
SET fechaapertura = TO_DATE('2025-05-11', 'YYYY-MM-DD')
WHERE numero = 123;

CONNECT motivacion1/motivacion1;

CREATE OR REPLACE PROCEDURE LISTADO_EXPEDIENTES (vardnimen VARCHAR2) AS
    -- variables aquí
    totalculpable NUMBER := 0;
    totalinocente NUMBER := 0;
    var_dnimenor VARCHAR2(9);
    var_nombremenor VARCHAR2(50);
    var_apellidomenor VARCHAR2(50);
    var_existe NUMBER := 0;
BEGIN

    SELECT COUNT(*)
    INTO var_existe
    FROM MENOR
    WHERE UPPER(dni) = UPPER(vardnimen);
    
    IF var_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El menor ' || vardnimen || ' no se encuentra en la base de datos');
    END IF;

    SELECT DISTINCT exp.dnimenor, men.nombre, men.apellido1
    INTO var_dnimenor, var_nombremenor, var_apellidomenor
    FROM EXPEDIENTE exp
    JOIN MENOR men ON men.dni = exp.dnimenor
    WHERE UPPER(exp.dnimenor) = UPPER(var_dnimenor);

    DBMS_OUTPUT.PUT_LINE('MENOR: ' || var_dnimenor || ' ' || var_nombremenor || ' ' || var_apellidomenor);
    DBMS_OUTPUT.PUT_LINE('-------------------------------');

    FOR datos IN (
        SELECT exp.fechaapertura, exp.numero, exp.delito, exp.sentencia, abo.nombre, abo.apellido1
        FROM EXPEDIENTE exp
        JOIN ABOGADO abo ON abo.dni = exp.dniabogado
        WHERE upper(exp.dnimenor) = upper(vardnimen)
    )LOOP
        DBMS_OUTPUT.PUT_LINE(datos.fechaapertura || ' ' || datos.numero || ' ' || datos.delito || ' ' || datos.sentencia || ' ' || datos.nombre || ' ' || datos.apellido1);

        IF datos.sentencia = 'I' THEN
            totalinocente := totalinocente + 1;
        ELSE
            totalculpable := totalculpable + 1;
        END IF;
    END LOOP;

        DBMS_OUTPUT.PUT_LINE('N. Exp. Culpable: ' || totalculpable);
        DBMS_OUTPUT.PUT_LINE('N. Exp. Inocente: ' || totalinocente);
END;
/

BEGIN
    LISTADO_EXPEDIENTES('48796558B');
END;
/
