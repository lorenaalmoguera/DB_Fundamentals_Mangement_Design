CONNECT SYSTEM/bdadmin;
CREATE USER BDGB1617 IDENTIFIED BY BDGB1617;
GRANT CONNECT, RESOURCE, CREATE VIEW TO BDGB1617;
CONNECT BDGB1617/BDGB1617;

DROP TABLE CLASE CASCADE CONSTRAINTS;
DROP TABLE MONITOR CASCADE CONSTRAINTS;
DROP TABLE SALA CASCADE CONSTRAINTS;
DROP TABLE IMPARTIR CASCADE CONSTRAINTS;

        /*'SELECT constraint_name, constraint_type, table_name
        FROM user_constraints
        WHERE table_name = 'TABLE_NAME';'*/


CREATE TABLE CLASE(
    codigo VARCHAR2(50),
    nombre VARCHAR2(50),
    CONSTRAINT cla_cod_pk PRIMARY KEY (codigo)
);

CREATE TABLE MONITOR(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellidos VARCHAR2(50),
    telefono NUMBER(9),
    CONSTRAINT mon_dni_pk PRIMARY KEY (dni)
);

CREATE TABLE SALA(
    codigo VARCHAR2(50),
    nombre VARCHAR2(50),
    ubicacion VARCHAR2(50),
    CONSTRAINT sal_cod_pk PRIMARY KEY (codigo)
);

CREATE TABLE IMPARTIR(
    codmonitor VARCHAR2(50),
    codclase VARCHAR2(50) CONSTRAINT imp_ccl_uq UNIQUE,
    codsala VARCHAR2(50) CONSTRAINT imp_csa_uq UNIQUE,
    diassemana NUMBER,
    CONSTRAINT imp_mc_pk PRIMARY KEY (codmonitor, codclase),
    CONSTRAINT imp_ccl_nn CHECK(codclase IS NOT NULL),
    CONSTRAINT imp_csa_nn CHECK(codsala IS NOT NULL),
    CONSTRAINT imp_mon_fk FOREIGN KEY(codmonitor) REFERENCES MONITOR,
    CONSTRAINT imp_cla_fk FOREIGN KEY(codclase) REFERENCES CLASE,
    CONSTRAINT imp_sal_fk FOREIGN KEY(codsala) REFERENCES SALA
);


/*VALORES PARA INSERTAR*/

INSERT INTO MONITOR (dni, nombre, apellidos, telefono) VALUES ('12345678A', 'Juan', 'Pérez García', 600123456);
INSERT INTO MONITOR (dni, nombre, apellidos, telefono) VALUES ('87654321B', 'Ana', 'López Martínez', 611654321);
INSERT INTO MONITOR (dni, nombre, apellidos, telefono) VALUES ('45678901C', 'Carlos', 'Hernández Sánchez', 622987654);

INSERT INTO CLASE (codigo, nombre) VALUES ('C1', 'Yoga');
INSERT INTO CLASE (codigo, nombre) VALUES ('C2', 'Pilates');
INSERT INTO CLASE (codigo, nombre) VALUES ('C3', 'Spinning');
INSERT INTO CLASE (codigo, nombre) VALUES ('C4', 'Zumba');

INSERT INTO SALA (codigo, nombre, ubicacion) VALUES ('S1', 'Principal', 'Planta Baja');
INSERT INTO SALA (codigo, nombre, ubicacion) VALUES ('S2', 'Secundaria', 'Primer Piso');
INSERT INTO SALA (codigo, nombre, ubicacion) VALUES ('S3', 'Terciaria', 'Segundo Piso');

INSERT INTO IMPARTIR (codmonitor, codclase, codsala, diassemana) 
VALUES ('12345678A', 'C1', 'S1', 2);

INSERT INTO IMPARTIR (codmonitor, codclase, codsala, diassemana) 
VALUES ('12345678A', 'C2', 'S2', 3);

INSERT INTO IMPARTIR (codmonitor, codclase, codsala, diassemana) 
VALUES ('87654321B', 'C3', 'S3', 1);

INSERT INTO IMPARTIR (codmonitor, codclase, codsala, diassemana) 
VALUES ('45678901C', 'C4', 'S1', 4);

/*SELECTS*/

SELECT * FROM CLASE;

SELECT * FROM MONITOR;

SELECT * FROM SALA;

SELECT * FROM IMPARTIR;

/*
1.- Crea un procedimiento llamado CLASES_MONITOR que reciba como argumento el código de
un monitor y muestre las clases que imparte, en qué sala y los días de la semana. El listado estará
ordenado ascendentemente por el nombre de la clase. Incluye también una instrucción para llamar
al procedimiento. 
*/

CREATE OR REPLACE PROCEDURE CLASES_MONITOR (input_dni VARCHAR2) AS
    nombre_V VARCHAR2(9);
    apellidos_V VARCHAR2(50);
BEGIN
    SELECT nombre, apellidos INTO nombre_V, apellidos_V
    FROM MONITOR
    WHERE dni = input_dni;
    
    DBMS_OUTPUT.PUT_LINE('MONITOR: ' || nombre_V || apellidos_V);
    DBMS_OUTPUT.PUT_LINE('CLASES QUE IMPARTE');
    DBMS_OUTPUT.PUT_LINE('---------------------------------');

    FOR impartir IN (
        SELECT c.nombre AS clase_nombre, s.nombre AS sala_nombre, i.diassemana AS diasem
        FROM IMPARTIR i
        JOIN CLASE c ON c.codigo = i.codclase
        JOIN SALA s ON s.codigo = i.codsala
        WHERE i.codmonitor = input_dni
        ORDER BY c.nombre
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(impartir.clase_nombre || impartir.sala_nombre || impartir.diasem);
    END LOOP;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('El monitor ' || input_dni || ' no existe.');
        RETURN;
    END;
/

SET SERVEROUTPUT ON;

BEGIN
    CLASES_MONITOR('12345678A'); 
    END;
/

/*2.- Crea una función llamada TOTAL_MONITORES_CLASE que reciba como argumento el código
de una clase (independientemente de que esté escrito en mayúsculas o minúsculas) y devuelva el
número total de monitores distintos que imparten dicha clase. Incluye una instrucción para ejecutar
la función.*/

CREATE OR REPLACE PROCEDURE TOTAL_MONITORES_CLASE (input_codigo VARCHAR2) AS
    codigo_V VARCHAR2(50);
    count_total NUMBER := 0;
BEGIN
    SELECT codigo INTO codigo_V
    FROM CLASE
    WHERE codigo = input_codigo;

    DBMS_OUTPUT.PUT_LINE('MONITORS TOTALES');
    FOR monitores IN (
        SELECT codmonitor
        FROM IMPARTIR
        WHERE codclase=codigo_V
    ) LOOP
        count_total := count_total+1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(count_total);

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('NO EXISTEN DATOS');
    RETURN;
    END;
/


-- Eliminar las restricciones
ALTER TABLE IMPARTIR DROP CONSTRAINT imp_ccl_uq;
ALTER TABLE IMPARTIR DROP CONSTRAINT imp_csa_uq;

-- Ahora puedes insertar registros con los mismos valores de `codclase` y `codsala`
INSERT INTO IMPARTIR (codmonitor, codclase, codsala, diassemana)
VALUES ('78901234E', 'C1', 'S2', 5);

INSERT INTO IMPARTIR (codmonitor, codclase, codsala, diassemana)
VALUES ('89012345F', 'C1', 'S3', 2);

INSERT INTO IMPARTIR (codmonitor, codclase, codsala, diassemana)
VALUES ('90123456G', 'C1', 'S1', 3);


BEGIN 
    TOTAL_MONITORES_CLASE('C1');
END;
/

/*3.- Crea un usuario llamado antonio con contraseña toni que tenga permisos para ver la
información referente a las clases que imparte el monitor con dni 11222333A. Se mostrarán los
códigos del monitor, de la clase, de la sala y los días de la semana. Además el usuario puede
modificar esta información siempre y cuando no asigne un valor de monitor distinto del 11222333A.
Introduce en el fichero todas las instrucciones necesarias para realizar el ejercicio, la explicación
entre comentarios de los pasos que llevas a cabo y un ejemplo con las instrucciones necesarias
para que el usuario consulte y modifique estos datos. El usuario no tendrá más permisos que los
necesarios para realizar el ejercicio. */


CREATE USER ANTONIO IDENTIFIED BY TONYI;

GRANT CONNECT, CREATE VIEW TO ANTONIO;

CONNECT ANTONIO/TONYI;

CREATE OR REPLACE VIEW MONITORVIEW AS
    SELECT codmonitor, codclase, codsala, diassemana
    FROM IMPARTIR
    WHERE codmonitor = '11222333A';



GRANT SELECT ON MONITORVIEW TO ANTONIO;

GRANT UPDATE ON MONITORVIEW TO ANTONIO;

CREATE OR REPLACE TRIGGER trg_restrict_monitor_update
BEFORE UPDATE OF CODMONITOR ON IMPARTIR
FOR EACH ROW
WHEN(NEW.codmonitor != '11222333A')
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'No se puede asignar datos a un monitor quie sea distinto a: 11222333A');
END;
/

UPDATE IMPARTIR
SET codmonitor = '12232435A';
