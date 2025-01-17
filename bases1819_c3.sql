CONNECT system/bdadmin;

CREATE USER bases1819_c3 IDENTIFIED BY bases1819_c3;

GRANT CONNECT, RESOURCE TO bases1819_c3;

CONNECT bases1819_c3/bases1819_c3;

/*
 Clave principal: tab_col_pk
 Clave ajena: tab_tabdestino_fk
 Valores no nulos: tab_col_nn
 Comprobación de condiciones: tab_col_ch
 Valores únicos: tab_col_uq
*/

/*CREACION DE TABLAS*/
CREATE TABLE MONITOR(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    porcentaje NUMBER(4,2),
    CONSTRAINT mon_dni_pk PRIMARY KEY (dni)
);

CREATE TABLE CURSO(
    codigo NUMBER,
    tipo VARCHAR2(50),
    duracion NUMBER,
    fechaini DATE CONSTRAINT curso_fin_nn NOT NULL,
    fechafin DATE CONSTRAINT curso_ffi_nn NOT NULL,
    preciohora NUMBER,
    dnimon VARCHAR2(9),
    CONSTRAINT cur_cod_pk PRIMARY KEY (codigo),
    CONSTRAINT cur_mon_fk FOREIGN KEY (dnimon) REFERENCES MONITOR,
    CONSTRAINT cur_fei_chk CHECK(fechaini < fechafin)
);

CREATE TABLE CLIENTE(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    fechanac DATE,
    CONSTRAINT cli_dni_pk PRIMARY KEY (dni)
);

CREATE TABLE MATRICULAR(
    codigo NUMBER,
    dni VARCHAR2(9),
    CONSTRAINT mat_cod_pk PRIMARY KEY(codigo, dni),
    CONSTRAINT mat_cur_fk FOREIGN KEY (codigo) REFERENCES CURSO,
    CONSTRAINT mat_dni_fk FOREIGN KEY (dni) REFERENCES CLIENTE
);

/*INSERTANDO VLAORES PARA PROBAR FUNCIONALIDAD*/

INSERT INTO CURSO (codigo, tipo, duracion, fechaini, fechafin, preciohora, dnimon)
VALUES (1, '1', 20, TO_DATE('2025-01-01', 'YYYY-MM-DD'), TO_DATE('2025-01-20', 'YYYY-MM-DD'), 15, 'MONITOR1');

INSERT INTO CURSO (codigo, tipo, duracion, fechaini, fechafin, preciohora, dnimon)
VALUES (2, '2', 15, TO_DATE('2025-02-01', 'YYYY-MM-DD'), TO_DATE('2025-02-15', 'YYYY-MM-DD'), 20, 'MONITOR2');

INSERT INTO CURSO (codigo, tipo, duracion, fechaini, fechafin, preciohora, dnimon)
VALUES (3, '3', 30, TO_DATE('2025-03-01', 'YYYY-MM-DD'), TO_DATE('2025-03-30', 'YYYY-MM-DD'), 25, 'MONITOR3');

INSERT INTO MATRICULAR (codigo, dni)
VALUES (1, 'DNI123456');

INSERT INTO MATRICULAR (codigo, dni)
VALUES (1, 'DNI234567');

INSERT INTO MATRICULAR (codigo, dni)
VALUES (2, 'DNI345678');

INSERT INTO MATRICULAR (codigo, dni)
VALUES (2, 'DNI456789');

INSERT INTO MATRICULAR (codigo, dni)
VALUES (3, 'DNI567890');

INSERT INTO MONITOR (dni, nombre, apellido1, porcentaje)
VALUES ('MONITOR1', 'Juan', 'Pérez', 50.00);

INSERT INTO MONITOR (dni, nombre, apellido1, porcentaje)
VALUES ('MONITOR2', 'Ana', 'Gómez', 60.00);

INSERT INTO MONITOR (dni, nombre, apellido1, porcentaje)
VALUES ('MONITOR3', 'Luis', 'Martínez', 70.00);

INSERT INTO CLIENTE (dni, nombre, apellido1, fechanac)
VALUES ('DNI123456', 'Juan', 'Pérez', TO_DATE('1990-05-15', 'YYYY-MM-DD'));

INSERT INTO CLIENTE (dni, nombre, apellido1, fechanac)
VALUES ('DNI234567', 'Ana', 'García', TO_DATE('1985-08-10', 'YYYY-MM-DD'));

INSERT INTO CLIENTE (dni, nombre, apellido1, fechanac)
VALUES ('DNI345678', 'Luis', 'Martínez', TO_DATE('2000-02-25', 'YYYY-MM-DD'));

INSERT INTO CLIENTE (dni, nombre, apellido1, fechanac)
VALUES ('DNI456789', 'María', 'López', TO_DATE('1995-11-30', 'YYYY-MM-DD'));

INSERT INTO CLIENTE (dni, nombre, apellido1, fechanac)
VALUES ('DNI567890', 'Pedro', 'Gómez', TO_DATE('1998-07-12', 'YYYY-MM-DD'));

INSERT INTO MATRICULAR (codigo, dni)
VALUES (3, 'DNI123456');

INSERT INTO MATRICULAR (codigo, dni)
VALUES (3, 'DNI234567');

INSERT INTO MATRICULAR (codigo, dni)
VALUES (3, 'DNI345678');

INSERT INTO MATRICULAR (codigo, dni)
VALUES (3, 'DNI456789');

INSERT INTO MATRICULAR (codigo, dni)
VALUES (3, 'DNI567890');


SELECT * FROM CURSO;
SELECT * FROM MATRICULAR;
SELECT * FROM MONITOR;



/*1.- Crea una función llamada TIPO_CURSO que reciba como argumento el código de un curso y
devuelva el texto correspondiente al tipo de curso que se trata, de forma que puede tomar los
siguientes valores: 1: TENIS, 2: NATACION y 3: AEROBIC. Por ejemplo, si el tipo de curso es 1 la
función devolverá TENIS.
*/

    SET SERVEROUTPUT ON;
    /

CREATE OR REPLACE PROCEDURE TIPO_CURSO (input_cod NUMBER) AS
    v_found BOOLEAN := FALSE; 
BEGIN

    FOR curso IN (
        SELECT tipo
        FROM CURSO
        WHERE codigo = input_cod
    ) LOOP

        v_found := TRUE;


        IF curso.tipo = '1' THEN
            DBMS_OUTPUT.PUT_LINE('CODIGO: ' || input_cod || ' TIPO: TENIS');
        ELSIF curso.tipo = '2' THEN
            DBMS_OUTPUT.PUT_LINE('CODIGO: ' || input_cod || ' TIPO: NATACION');
        ELSIF curso.tipo = '3' THEN
            DBMS_OUTPUT.PUT_LINE('CODIGO: ' || input_cod || ' TIPO: AEROBIC');
        ELSE
            DBMS_OUTPUT.PUT_LINE('CODIGO: ' || input_cod || ' TIPO: OTRO');
        END IF;
    END LOOP;

    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('NO EXISTEN DATOS PARA EL CODIGO: ' || input_cod);
    END IF;
END;
/

BEGIN
    TIPO_CURSO(1);
END;
/

BEGIN
    TIPO_CURSO(10);
END;
/

/*2.- Crea un procedimiento llamado CLIENTES_CURSO que reciba como argumento el código de
un curso imprima por pantalla el monitor que lo imparte (nombre y apellido) (el nombre y apellido se
mostrará una sola vez) y a continuación los clientes matriculados en el curso (apellido, nombre y
dni, separados por espacios en blanco y un cliente por línea) ordenados alfabéticamente en orden
ascendente según el apellido. Al final del listado se imprimirá el número total de clientes
matriculados en el curso, el importe extra que se lleva el monitor (que depende de su porcentaje) y
el importe que se queda el centro tras aplicar la cantidad extra que percibe el monitor.*/

CREATE OR REPLACE PROCEDURE CLIENTES_CURSO (input_cod NUMBER) AS
    monitor VARCHAR2(9);
    codigo NUMBER;
    v_found BOOLEAN := FALSE;
    v_total NUMBER := 0;
BEGIN
    SELECT m.nombre, m.apellido1
    INTO monitor_nombre, monitor_apellido
    FROM CURSO c
    JOIN MONITOR m ON c.dnimon = m.dni
    WHERE c.codigo = input_cod;
        DBMS_OUTPUT.PUT_LINE('CODIGO CURSO: ' || input_cod || ' MONITOR: ' || monitor || 'DATOS MONITOR... ' || monitor_apellido || ', ' || monitor_nombre);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO EXISTE EL CURSO CON CODIGO: ' || input_cod);
            RETURN;
        END;

    DBMS_OUTPUT.PUT_LINE('ALUMNOS MATRICULADOS...');

    FOR matricular IN (
        SELECT c.apellido1, c.nombre, m.dni
        FROM MATRICULAR m
        JOIN CLIENTE c ON m.dni = c.dni
        WHERE codigo = input_cod
        ORDER BY c.apellido1, c.nombre
    ) LOOP
    v_found:= TRUE;
    v_total:=v_total + 1;
    DBMS_OUTPUT.PUT_LINE('ALUMNO: ' || matricular.dni);

    END LOOP;

    IF v_total = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No hay clientes matriculados en el curso con código ' || input_cod);
        RETURN;
    END IF;

    importe_total := total_alumnos * precio_hora * duracion;
    importe_monitor := (importe_total * porcentaje) / 100;
    importe_centro := importe_total - importe_monitor;


    DBMS_OUTPUT.PUT_LINE('TOTAL DE CLIENTES MATRICULADOS: ' || total_alumnos);
    DBMS_OUTPUT.PUT_LINE('IMPORTE TOTAL DEL CURSO: ' || TO_CHAR(importe_total, 'FM999,999.00') || '€');
    DBMS_OUTPUT.PUT_LINE('IMPORTE EXTRA PARA EL MONITOR: ' || TO_CHAR(importe_monitor, 'FM999,999.00') || '€');
    DBMS_OUTPUT.PUT_LINE('IMPORTE FINAL PARA EL CENTRO: ' || TO_CHAR(importe_centro, 'FM999,999.00') || '€');

END;
/

SET SERVEROUTPUT ON;

BEGIN
    CLIENTES_CURSO(1); 
    END;
/

/*3.- Controla mediante un disparador llamado FECHAS_CURSO que no se puedan tener cursos
cuya fecha de inicio sea posterior a la fecha de finalización. Además de controlar que no se pueda
tener estos cursos, se imprimirá el mensaje “La fecha de inicio fechainicio no puede ser posterior a
la fecha fin del curso fechafin”.*/

CREATE OR REPLACE TRIGGER FECHAS_CURSO
BEFORE INSERT ON CURSO
FOR EACH ROW
DECLARE

BEGIN
    IF :NEW.fechafin < :NEW.fechaini THEN
        RAISE_APPLICATION_ERROR(-20001, 'La fecha de inicio fechainicio no puede ser posterior a la fecha fin del curso fechafin');
    END IF;
END;
/

/*para proabr...*/

INSERT INTO CURSO (codigo, tipo, duracion, fechaini, fechafin, preciohora, dnimon)
VALUES (
    10, -- Código del curso
    '1', -- Tipo del curso
    20, -- Duración en horas
    TO_DATE('2025-12-31', 'YYYY-MM-DD'), -- Fecha de inicio (posterior)
    TO_DATE('2025-01-01', 'YYYY-MM-DD'), -- Fecha de fin (anterior)
    15, -- Precio por hora
    'MONITOR1' -- DNI del monitor
);

/*4.- Supón que hay diferentes usuarios con los que se ha compartido la información de algunas
tablas de la base de datos. Introduce la instrucción SQL para que el usuario puntuable3 pueda saber
el nombre de los usuarios con los que ha compartido la información, qué recursos ha compartido
con cada uno de ellos y qué permisos ha dado a cada uno de los usuarios sobre los recursos.
(1,5 pto
*/

SELECT grantee AS usuario,
       table_name AS recurso,
       privilege AS permiso
FROM all_tab_privs
WHERE grantor = 'bases1819_c3';

/*5. este no lo entiendo muy bien... así que voy a hacer solo los SELECTS

Ventana 1: Ventana 2:
2.- Consultar los datos de los clientes
matriculados en el curso C1.
3.- Matricular a un nuevo cliente en el curso C1.
4.- Confirmar transacción.
1.- Consultar los datos de los clientes
matriculados en el curso C1.
5.- Consultar los datos de los clientes
matriculados en el curso C1.
6.- Confirmar transacción.

*/


/*Consultar los datos de los clientes
matriculados en el curso C1... el problema es que curso debería de ser un VARCHAR 
pero eso la yolanda no lo ha especificado hasta ahora*/
SELECT * FROM CLIENTE c
JOIN MATRICULAR m ON c.dni = m.dni
WHERE m.codigo = '1'; 

INSERT INTO CLIENTE (dni, nombre, apellido1, fechanac) 
VALUES ('12345678N', 'LORENA', 'ALMOGUERA', TO_DATE('2000-04-02', 'YYYY-MM-DD'));
INSERT INTO MATRICULAR (codigo, dni) VALUES ('1', '12345678N');

SELECT * FROM CLIENTE;

SELECT dni FROM MATRICULAR
WHERE codigo = '1';