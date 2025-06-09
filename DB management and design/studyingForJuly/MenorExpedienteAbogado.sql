CONNECT SYSTEM/bdadmin;

CREATE USER expabogado IDENTIFIED BY evalfinal;

GRANT RESOURCE, CONNECT TO expabogado;

CONNECT expabogado/evalfinal;

CREATE TABLE MENOR(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    fechanac DATE,
    CONSTRAINT men_dni_pk PRIMARY KEY(dni)
);

CREATE TABLE ABOGADO(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    ncolegiado VARCHAR2(9) CONSTRAINT abo_nco_nn NOT NULL,
    CONSTRAINT abo_dni_pk PRIMARY KEY(dni),
    CONSTRAINT abo_nco_uq UNIQUE(ncolegiado)
);

CREATE TABLE EXPEDIENTE(
    numero VARCHAR2(5),
    dnimenor VARCHAR2(9),
    delito VARCHAR2(50),
    fechaapertura DATE DEFAULT SYSDATE,
    sentencia VARCHAR2(1),
    dniabogado VARCHAR2(9) CONSTRAINT exp_dnia_nn NOT NULL,
    CONSTRAINT exp_num_dnim_pk PRIMARY KEY(numero, dnimenor),
    CONSTRAINT exp_dnim_men_fk FOREIGN KEY(dnimenor) REFERENCES MENOR,
    CONSTRAINT exp_dnia_abo_fk FOREIGN KEY(dniabogado) REFERENCES ABOGADO,
    CONSTRAINT exp_sen_ch CHECK (sentencia IN('C','I') OR sentencia IS NULL)
);

CREATE OR REPLACE PROCEDURE LISTADO_EXPEDIENTES (input_dni VARCHAR2)
AS
    var_dnimenor VARCHAR2(9);
    var_nombremenor VARCHAR2(50);
    var_apellidomenor VARCHAR2(50);
    var_total NUMBER := 0;
    var_existe NUMBER;
BEGIN

    SELECT COUNT(*)
    INTO var_existe
    FROM MENOR
    WHERE dni = input_dni;

    IF var_existe < 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El menor con el dni ' || input_dni || ' no existe.');
    END IF;

    SELECT dni, nombre, apellido1
    INTO var_dnimenor, var_nombremenor, var_apellidomenor
    FROM MENOR
    WHERE dni = input_dni;


    DBMS_OUTPUT.PUT_LINE('Menor: ' || var_dnimenor || ' ' || var_nombremenor || ' ' || var_apellidomenor);
    DBMS_OUTPUT.PUT_LINE('--------------------------------');

    FOR menores IN(
        SELECT exp.fechaapertura, exp.numero, exp.delito, exp.sentencia, abo.nombre, abo.apellido1
        FROM EXPEDIENTE exp
        JOIN abogado abo ON abo.dni = exp.dniabogado
        WHERE exp.dnimenor = input_dni
    )LOOP
        DBMS_OUTPUT.PUT_LINE(menores.fechaapertura || ' ' || menores.numero || ' ' || menores.delito || ' ' || menores.sentencia || ' ' || menores.nombre || ' ' || menores.apellido1);
        var_total := var_total + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total expedientes: ' || var_total);
END;
/


CREATE OR REPLACE TRIGGER COMPROBAR_EDAD
BEFORE INSERT ON MENOR
FOR EACH ROW
DECLARE 
fecha DATE;
BEGIN

    fecha := SYSDATE;


     IF MONTHS_BETWEEN(fecha, :NEW.fechanac)/12 > 18 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La persona con el DNI ' || :NEW.dni || ' no es menor de edad');
    END IF;
END;
/

CONNECT SYSTEM/bdadmin;

CREATE USER admin IDENTIFIED BY tutelar;

GRANT CREATE VIEW TO expabogado;
GRANT CREATE SESSION TO admin;

CONNECT expabogado/evalfinal;

CREATE OR REPLACE VIEW vista_exp_inocentes AS
SELECT numero, dnimenor, delito, fechaapertura
FROM expediente
WHERE sentencia = 'I';

CONNECT system/bdadmin;

GRANT SELECT, UPDATE (numero, dnimenor, delito, fechaapertura) ON expabogado.vista_exp_inocentes TO admin;

CONNECT admin/tutelar;

UPDATE expabogado.vista_exp_inocentes
SET delito = 'Amenaza leve'
WHERE numero = 'E002' AND dnimenor = 'M001';

SELECT * FROM expabogado.vista_exp_inocentes;