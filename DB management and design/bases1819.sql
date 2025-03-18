
connect system/bdadmin;
CREATE USER dgbd1819 IDENTIFIED BY dgbd1819;
GRANT CONNECT, RESOURCE TO dgbd1819;

connect dgbd1819/dgbd1819

/*EJERCICIO 1*/
CREATE TABLE ALUMNO(
    numexpediente NUMBER,
    nombre VARCHAR2(20),
    apellido1 VARCHAR2(20),
    apellido2 VARCHAR2(20),
    fechanacimiento DATE,
    CONSTRAINT alu_num_pk PRIMARY KEY (numexpediente)
);

CREATE TABLE ASIGNATURA(
    codigo NUMBER,
    nombre VARCHAR2(20),
    creditos NUMBER(4,1),
    tipo VARCHAR2(20),
    CONSTRAINT asi_cod_pk PRIMARY KEY (codigo),
    CONSTRAINT asi_cre_chk CHECK(creditos < 100 AND creditos > 0),
    CONSTRAINT asi_tip_chk CHECK(tipo IN('OBLIGATORIA', 'OPTATIVA', 'LIBRE'))
);

CREATE TABLE MATRICULAR(
    codigoalumno NUMBER,
    codigoasignatura NUMBER,
    convocatoria VARCHAR2(20),
    nota NUMBER,
    CONSTRAINT mat_cal_cas_con_pk PRIMARY KEY (codigoalumno, codigoasignatura, convocatoria),
    CONSTRAINT mat_asi_fk FOREIGN KEY (codigoasignatura) REFERENCES ASIGNATURA,
    CONSTRAINT mat_alu_fk FOREIGN KEY (codigoalumno) REFERENCES ALUMNO
);

INSERT INTO ALUMNO (numexpediente, nombre, apellido1, apellido2, fechanacimiento)
VALUES (1, 'Juan', 'Pérez', 'García', TO_DATE('2000-05-15', 'YYYY-MM-DD'));

INSERT INTO ALUMNO (numexpediente, nombre, apellido1, apellido2, fechanacimiento)
VALUES (2, 'María', 'López', 'Martínez', TO_DATE('1999-08-10', 'YYYY-MM-DD'));

INSERT INTO ALUMNO (numexpediente, nombre, apellido1, apellido2, fechanacimiento)
VALUES (3, 'Carlos', 'Sánchez', 'Rodríguez', TO_DATE('2002-12-22', 'YYYY-MM-DD'));


INSERT INTO ASIGNATURA (codigo, nombre, creditos, tipo)
VALUES (101, 'Matemáticas', 6.0, 'OBLIGATORIA');

INSERT INTO ASIGNATURA (codigo, nombre, creditos, tipo)
VALUES (102, 'Física', 5.5, 'OPTATIVA');

INSERT INTO ASIGNATURA (codigo, nombre, creditos, tipo)
VALUES (103, 'Química', 4.0, 'OPTATIVA');

INSERT INTO ASIGNATURA (codigo, nombre, creditos, tipo)
VALUES (104, 'Historia', 3.0, 'LIBRE');


INSERT INTO MATRICULAR (codigoalumno, codigoasignatura, convocatoria, nota)
VALUES (1, 101, '2023-01', 8.5);

INSERT INTO MATRICULAR (codigoalumno, codigoasignatura, convocatoria, nota)
VALUES (2, 102, '2023-01', 7.0);

INSERT INTO MATRICULAR (codigoalumno, codigoasignatura, convocatoria, nota)
VALUES (3, 102, '2023-01', 6.0);

INSERT INTO MATRICULAR (codigoalumno, codigoasignatura, convocatoria, nota)
VALUES (1, 103, '2023-02', 5.5);

INSERT INTO MATRICULAR (codigoalumno, codigoasignatura, convocatoria, nota)
VALUES (2, 103, '2023-02', 9.0);



/*EJERCICIO2

2.- Crea un usuario llamado admin1 con contraseña admin que pueda únicamente ver el número total de
alumnos matriculados por asignatura y convocatoria de las asignaturas optativas (mostrando los tres datos),
ordenados por asignatura. Introduce en el fichero todas las instrucciones necesarias para realizar el apartado,
la explicación entre comentarios de los pasos que llevas a cabo y un ejemplo con las instrucciones necesarias
para que el usuario consulte estos datos ordenados por el número de alumnos de mayor a menor. El usuario
no tendrá más permisos que los necesarios para realizar este apartado.

    visualizar numero total de matriculados por asignatura y convocatoria.

*/
connect system/bdadmin;
CREATE admin1819/admin1819;
GRANT CONNECT TO ADMIN1819;

CREATE OR REPLACE VIEW matriculas_optativas AS 
    SELECT m.codigoasignatura, m.convocatoria
    FROM MATRICULAR m
    JOIN ASIGNATURA a ON m.codigoasignatura = a.codigo
    WHERE a.tipo = 'OPTATIVA'
GROUP BY m.codigoasignatura, m.convocatoria;

GRANT SELECT ON dgbd1819.matriculas_optativas TO admin1819;

SELECT * FROM matriculas_optativas ORDER BY codigoasignatura;

/*EJERCICIO3
3.- Crea un procedimiento llamado ACTAS_ASIGNATURA_CONVOCATORIA que reciba como argumentos
los códigos de una asignatura y de una convocatoria y muestre las notas de los alumnos matriculados en
dicha asignatura y convocatoria ordenados ascendentemente en primer lugar por los apellidos y luego por el
nombre. Al final del listado se imprimirá la tasa de éxito de la convocatoria, que se calcula como nº alumnos
aprobados / nº alumnos presentados * 100. En el caso de que no se haya presentado ningún alumno el valor
de la tasa de éxito es el carácter: -.
*/

CREATE OR REPLACE PROCEDURE ACTAS_ASIGNATURA_CONVOCATORIA (
    in_codasi IN NUMBER,
    in_conv IN VARCHAR2
) AS
    nombre_asignatura VARCHAR2(50); -- Almacena el nombre de la asignatura
    total_presentados NUMBER := 0;  -- Contador de alumnos presentados
    total_aprobados NUMBER := 0;    -- Contador de alumnos aprobados
    tasa_exito VARCHAR2(10);        -- Tasa de éxito como texto
BEGIN
    -- Verificar si la asignatura existe
    BEGIN
        SELECT nombre INTO nombre_asignatura
        FROM ASIGNATURA
        WHERE codigo = in_codasi;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('LA ASIGNATURA CON CÓDIGO: ' || in_codasi || ' NO EXISTE.');
            RETURN;
    END;

    -- Encabezado de la salida
    DBMS_OUTPUT.PUT_LINE('ASIGNATURA: ' || in_codasi || ' - ' || nombre_asignatura);
    DBMS_OUTPUT.PUT_LINE('CONVOCATORIA: ' || in_conv);
    DBMS_OUTPUT.PUT_LINE('ALUMNOS');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------');

    -- Consultar los alumnos matriculados
    FOR alumno IN (
        SELECT a.apellido1, a.apellido2, a.nombre, m.nota
        FROM MATRICULAR m
        JOIN ALUMNO a ON m.codigoalumno = a.numexpediente
        WHERE m.codigoasignatura = in_codasi AND m.convocatoria = in_conv
        ORDER BY a.apellido1, a.apellido2, a.nombre
    ) LOOP
        -- Mostrar información del alumno
        DBMS_OUTPUT.PUT_LINE(
            alumno.apellido1 || ' ' || alumno.apellido2 || ', ' || alumno.nombre || ' - NOTA: ' || alumno.nota
        );

        -- Incrementar contadores
        total_presentados := total_presentados + 1;
        IF alumno.nota >= 5 THEN
            total_aprobados := total_aprobados + 1;
        END IF;
    END LOOP;

    -- Calcular la tasa de éxito
    IF total_presentados > 0 THEN
        tasa_exito := TO_CHAR((total_aprobados / total_presentados) * 100, '90.00') || '%';
    ELSE
        tasa_exito := '-';
    END IF;

    -- Mostrar totales
    DBMS_OUTPUT.PUT_LINE('TOTAL DE PRESENTADOS: ' || total_presentados);
    DBMS_OUTPUT.PUT_LINE('TOTAL DE APROBADOS: ' || total_aprobados);
    DBMS_OUTPUT.PUT_LINE('TASA DE ÉXITO: ' || tasa_exito);

EXCEPTION
    -- Manejar errores generales
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('HA OCURRIDO UN ERROR INESPERADO. REVISA LOS DATOS DE ENTRADA.');
END;
/


    SET SERVEROUTPUT ON;

    BEGIN
        ACTAS_ASIGNATURA_CONVOCATORIA(102, '2023-01'); -- Sustituye con códigos válidos de prueba
    END;
    /


/*4.- Crea un disparador llamado MAYOR_EDAD que controle que solamente se pueda tener en la base de
datos a alumnos con 18 años o más, considerando que la edad se cumple dentro del año que el ordenador
tenga configurado como la fecha hoy (la fecha de hoy hay que obtenerla por medio de alguna función). Así,
por ejemplo si el año actual es 2019, no se permitirá tener alumnos cuya fecha de nacimiento sea posterior al
año 2001. Si el año actual fuera el 2020, serían los alumnos con fecha de nacimiento posterior al 2002. En el
caso de que no tener la edad mínima se emitirá el mensaje: El alumno con expediente X es menor de
edad. (donde X es el número de expediente).
*/

CREATE OR REPLACE TRIGGER MAYOR_EDAD
BEFORE INSERT ON ALUMNO
FOR EACH ROW
DECLARE
    edad NUMBER;
BEGIN

SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, :NEW.fechanacimiento) / 12) INTO edad FROM DUAL;

IF edad <= 18 THEN
    RAISE_APPLICATION_ERROR(-20001, 'NO SE PUEDEN INSERTAR USUARIOS MENORES DE EDAD.');
END IF;
END;
/

INSERT INTO ALUMNO (numexpediente, nombre, fechanacimiento)
VALUES (1, 'Juan Pérez', TO_DATE('2010-05-15', 'YYYY-MM-DD'));
