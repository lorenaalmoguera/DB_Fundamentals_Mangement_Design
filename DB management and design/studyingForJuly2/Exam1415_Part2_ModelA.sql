CONNECT SYSTEM/bdadmin;

CREATE USER exam1415_Part2_ModelA IDENTIFIED BY exam1415_Part2_ModelA;

GRANT CONNECT, RESOURCE TO exam1415_Part2_ModelA;

CONNECT exam1415_Part2_ModelA/exam1415_Part2_ModelA;

--- CREACIÓN DE TABLAS

CREATE TABLE MENOR (
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    telefono NUMBER (9),
    fechanac DATE,
    CONSTRAINT men_dni_pk PRIMARY KEY (dni)
);

CREATE TABLE JUZGADO(
    codigo VARCHAR2(50),
    direccion VARCHAR2(100),
    CONSTRAINT juz_cod_pk PRIMARY KEY (codigo)
);

CREATE TABLE ABOGADO(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    telefono NUMBER(9),
    ncolegiado VARCHAR2(9) CONSTRAINT abo_nco_nn NOT NULL,
    CONSTRAINT abo_dni_pk PRIMARY KEY(dni),
    CONSTRAINT abo_nco_uq UNIQUE (ncolegiado)
);

CREATE TABLE EXPEDIENTE(
    numero NUMBER,
    dnimenor VARCHAR2(9),
    delito VARCHAR2(50),
    fecha DATE,
    sentencia VARCHAR2(2),
    codigojuzgado VARCHAR2(50),
    dniabogado VARCHAR2(9) CONSTRAINT exp_cod_nn NOT NULL,
    CONSTRAINT exp_num_dnim_pk PRIMARY KEY(numero, dnimenor),
    CONSTRAINT exp_dnim_men_fk FOREIGN KEY(dnimenor) REFERENCES MENOR,
    CONSTRAINT exp_cod_juz_fk FOREIGN KEY (codigojuzgado) REFERENCES JUZGADO,
    CONSTRAINT exp_dnia_abo_fk FOREIGN KEY(dniabogado) REFERENCES ABOGADO
);

-- insertar datos

INSERT INTO MENOR(dni, nombre, apellido1, telefono, fechanac) VALUES('48796558B', 'LORENA', 'ALMOGUERA', 659639436, '02-04-2000');
INSERT INTO MENOR(dni, nombre, apellido1, telefono, fechanac) VALUES('12345678A', 'ALEJANDRO', 'COVES', 123456789, '11-07-2003');
INSERT INTO JUZGADO(codigo, direccion) VALUES('mijuzgado', 'calle tus muertos 23');
INSERT INTO ABOGADO(dni, nombre, apellido1, telefono, ncolegiado) VALUES('12344478B', 'YOLANDA', 'MARHUENDA', 123456777, 'TETA123');
INSERT INTO EXPEDIENTE(numero, dnimenor, delito, fecha, sentencia, codigojuzgado, dniabogado) VALUES(1, '48796558B', 'ser sexy', '12-06-2025', 'I', 'mijuzgado', '12344478B');
INSERT INTO EXPEDIENTE(numero, dnimenor, delito, fecha, sentencia, codigojuzgado, dniabogado) VALUES(1, '12345678A', 'ser listo', '12-06-2025', 'I', 'mijuzgado', '12344478B');


-- ejercicio expedientes pendientes por fecha

SET SERVEROUTPUT ON;
clear screen;

CREATE OR REPLACE PROCEDURE EXPEDIENTES_PENDIENTES (input_fecha DATE) AS
    var_fecha DATE;
    var_hay_fechas NUMBER;
    var_total_expedientes NUMBER := 0;
BEGIN

    SELECT DISTINCT COUNT(*)
    INTO var_hay_fechas
    FROM EXPEDIENTE
    WHERE fecha < input_fecha;

    IF var_hay_fechas = 0 THEN
        RAISE_APPLICATION_ERROR(-2001, 'Todos los expedientes anteriores a ' || input_fecha || 'han sido resueltos.');
    END IF;

    SELECT DISTINCT fecha
    INTO var_fecha
    FROM EXPEDIENTE
    WHERE fecha < input_fecha;

    DBMS_OUTPUT.PUT_LINE('EXPEDIENTES PENDIENTES ' || var_fecha);

    FOR expedientes IN (
        SELECT exp.fecha, exp.dnimenor, exp.numero, men.nombre, men.apellido1
        FROM EXPEDIENTE exp
        JOIN MENOR men ON men.dni = exp.dnimenor
        WHERE exp.fecha < input_fecha
    )LOOP

        DBMS_OUTPUT.PUT_LINE(expedientes.fecha || ' ' || expedientes.dnimenor || ' ' || expedientes.numero || ' ' || expedientes.nombre || ' ' || expedientes.apellido1);
        var_total_expedientes := var_total_expedientes + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total expedientes: ' || var_total_expedientes);

END;
/
BEGIN
    EXPEDIENTES_PENDIENTES('13-06-2025');
END;
/

--- EJERCICIO2

CONNECT SYSTEM/bdadmin;

CREATE USER juzgado1 IDENTIFIED BY JUZ1;
GRANT CREATE SESSION TO juzgado1;

GRANT CREATE VIEW TO exam1415_Part2_ModelA;

CONNECT exam1415_Part2_ModelA/exam1415_Part2_ModelA;

CREATE OR REPLACE VIEW EXPEDIENTES_JUZ1 AS
SELECT fecha, numero, dnimenor, sentencia
FROM EXPEDIENTE
ORDER BY fecha;

CONNECT SYSTEM/bdadmin;

GRANT SELECT ON exam1415_Part2_ModelA.EXPEDIENTES_JUZ1 TO juzgado1;

CONNECT juzgado1/JUZ1;

SELECT * FROM exam1415_Part2_ModelA.EXPEDIENTES_JUZ1;
