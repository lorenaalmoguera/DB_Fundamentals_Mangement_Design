
CONNECT SYSTEM/bdadmin;
CLEAR SCREEN;

CREATE USER ORD1819_ALMOGUERALORENA IDENTIFIED BY ORD1819_ALMOGUERALORENA;

GRANT CONNECT, RESOURCE TO ORD1819_ALMOGUERALORENA;

CONNECT ORD1819_ALMOGUERALORENA/ORD1819_ALMOGUERALORENA;

CREATE TABLE ALUMNO(
    numexpediente NUMBER,
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    apellido2 VARCHAR2(50),
    fechanacimiento DATE,
    CONSTRAINT alu_num_pk PRIMARY KEY (numexpediente)
);

CREATE TABLE ASIGNATURA(
    codigo NUMBER,
    nombre VARCHAR2(50),
    creditos NUMBER(4,1),
    tipo VARCHAR2(50),
    CONSTRAINT asi_cod_pk PRIMARY KEY (codigo),
    CONSTRAINT asi_cre_ch CHECK (creditos > 0 AND creditos < 100),
    CONSTRAINT asi_tip_ch CHECK (tipo IN ('OBLIGATORIA', 'OPTATIVA', 'LIBRE'))
);

CREATE TABLE MATRICULAR(
    codigoalumno NUMBER,
    codigoasignatura NUMBER,
    convocatoria VARCHAR2(50),
    nota NUMBER (4,2),
    CONSTRAINT mat_codal_codas_pk PRIMARY KEY(codigoalumno, codigoasignatura),
    CONSTRAINT mat_codal_alu_fk FOREIGN KEY(codigoalumno) REFERENCES ALUMNO,
    CONSTRAINT mat_codas_asi_fk FOREIGN KEY (codigoasignatura) REFERENCES ASIGNATURA
);

-- insertar datos

INSERT INTO ALUMNO VALUES (1001, 'Carlos', 'Pérez', 'García', DATE '2001-05-10');
INSERT INTO ALUMNO VALUES (1002, 'Lucía', 'Sánchez', 'López', DATE '2002-07-15');
INSERT INTO ALUMNO VALUES (1003, 'Manuel', 'Gómez', 'Ruiz', DATE '2000-11-20');
INSERT INTO ALUMNO VALUES (1004, 'Laura', 'Díaz', 'Fernández', DATE '2001-03-25');
INSERT INTO ALUMNO VALUES (1005, 'Mario', 'Martínez', 'Ortega', DATE '1999-09-05');
INSERT INTO ALUMNO VALUES (1006, 'Andrea', 'Romero', 'Castro', DATE '2002-12-12');
INSERT INTO ALUMNO VALUES (1007, 'Javier', 'Alonso', 'Vega', DATE '2003-01-08');
INSERT INTO ALUMNO VALUES (1008, 'Paula', 'Navarro', 'Iglesias', DATE '2001-06-30');
INSERT INTO ALUMNO VALUES (1009, 'David', 'Molina', 'Serrano', DATE '2000-04-17');
INSERT INTO ALUMNO VALUES (1010, 'Sara', 'Torres', 'Delgado', DATE '2001-10-01');


-- insertar asignaturas
-- Obligatorias
INSERT INTO ASIGNATURA VALUES (1, 'Matemáticas I', 6, 'OBLIGATORIA');
INSERT INTO ASIGNATURA VALUES (2, 'Física', 6, 'OBLIGATORIA');
INSERT INTO ASIGNATURA VALUES (3, 'Química', 6, 'OBLIGATORIA');

-- Optativas
INSERT INTO ASIGNATURA VALUES (10, 'Programación Web', 4.5, 'OPTATIVA');
INSERT INTO ASIGNATURA VALUES (11, 'Inteligencia Artificial', 5, 'OPTATIVA');
INSERT INTO ASIGNATURA VALUES (12, 'Realidad Virtual', 4, 'OPTATIVA');
INSERT INTO ASIGNATURA VALUES (13, 'Diseño Gráfico', 3, 'OPTATIVA');

-- Libres
INSERT INTO ASIGNATURA VALUES (20, 'Taller de Escritura', 2, 'LIBRE');
INSERT INTO ASIGNATURA VALUES (21, 'Ajedrez', 2, 'LIBRE');

-- insertart matriculas
-- Alumnos en obligatorias
INSERT INTO MATRICULAR VALUES (1001, 1, 'Ordinaria', 7.5);
INSERT INTO MATRICULAR VALUES (1001, 2, 'Ordinaria', 6.2);
INSERT INTO MATRICULAR VALUES (1002, 1, 'Ordinaria', 5.0);
INSERT INTO MATRICULAR VALUES (1002, 3, 'Extraordinaria', 6.0);
INSERT INTO MATRICULAR VALUES (1003, 2, 'Ordinaria', 8.0);
INSERT INTO MATRICULAR VALUES (1004, 1, 'Ordinaria', 9.5);

-- Alumnos en optativas
INSERT INTO MATRICULAR VALUES (1001, 10, 'Ordinaria', 8.7);
INSERT INTO MATRICULAR VALUES (1002, 10, 'Extraordinaria', 7.0);
INSERT INTO MATRICULAR VALUES (1003, 11, 'Ordinaria', 6.5);
INSERT INTO MATRICULAR VALUES (1004, 11, 'Extraordinaria', 7.5);
INSERT INTO MATRICULAR VALUES (1005, 12, 'Ordinaria', 9.0);
INSERT INTO MATRICULAR VALUES (1006, 10, 'Ordinaria', 5.5);
INSERT INTO MATRICULAR VALUES (1007, 12, 'Extraordinaria', 6.0);
INSERT INTO MATRICULAR VALUES (1008, 13, 'Ordinaria', 7.8);
INSERT INTO MATRICULAR VALUES (1009, 11, 'Ordinaria', 8.2);
INSERT INTO MATRICULAR VALUES (1010, 10, 'Extraordinaria', 9.3);
INSERT INTO MATRICULAR VALUES (1005, 13, 'Ordinaria', 6.0);
INSERT INTO MATRICULAR VALUES (1006, 13, 'Ordinaria', 5.0);

-- Alumnos en libres
INSERT INTO MATRICULAR VALUES (1001, 21, 'Ordinaria', 6.0);
INSERT INTO MATRICULAR VALUES (1003, 20, 'Ordinaria', 7.0);
INSERT INTO MATRICULAR VALUES (1007, 21, 'Extraordinaria', 8.5);
INSERT INTO MATRICULAR VALUES (1009, 20, 'Ordinaria', 9.0);






CONNECT SYSTEM/bdadmin;

CREATE USER admin1ord1819 IDENTIFIED BY admin1ord1819;

GRANT CREATE SESSION TO admin1ord1819;

GRANT CREATE VIEW TO ORD1819_ALMOGUERALORENA;

CONNECT ORD1819_ALMOGUERALORENA/ORD1819_ALMOGUERALORENA;

CREATE OR REPLACE VIEW visualizar_total_alumnos AS
SELECT COUNT(DISTINCT mat.codigoalumno) AS TOTAL_Matriculados, mat.codigoasignatura, mat.convocatoria
FROM MATRICULAR mat
GROUP BY mat.codigoasignatura, mat.convocatoria
ORDER BY TOTAL_Matriculados DESC, mat.codigoasignatura ASC;

CONNECT SYSTEM/bdadmin;

GRANT SELECT ON ORD1819_ALMOGUERALORENA.visualizar_total_alumnos TO admin1ord1819;

CONNECT admin1ord1819/admin1ord1819;

SET LINESIZE 200
SET PAGESIZE 100

COLUMN total_matriculados FORMAT 999
COLUMN codigoasignatura FORMAT 999
COLUMN convocatoria FORMAT A20

SELECT * FROM ORD1819_ALMOGUERALORENA.visualizar_total_alumnos;

-- ahora el procedure

CONNECT ORD1819_ALMOGUERALORENA/ORD1819_ALMOGUERALORENA;

CREATE OR REPLACE PROCEDURE ACTAS_ASIGNATURA_CONVOCATORIA (input_asi NUMBER, input_conv VARCHAR2) AS
    var_asi NUMBER;
    var_nom VARCHAR2(50);
    var_conv VARCHAR2(50);
    var_aprob NUMBER := 0;
    var_pres NUMBER := 0;
    var_exito NUMBER := 0;
    var_chck_asi NUMBER;
    var_chck_asi_conv NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO var_chck_asi
    FROM ASIGNATURA
    WHERE codigo = input_asi;

    IF var_chck_asi = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La asignatura ' || input_asi || ' no existe.');
    END IF;

    SELECT COUNT(codigoalumno)
    INTO var_chck_asi_conv
    FROM MATRICULAR
    WHERE convocatoria = input_conv AND codigoasignatura = input_asi;

    IF var_chck_asi_conv = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'No hay alumnos matriculados en la convocatoria ' || input_conv || ' de la asignatura ' || input_asi);
    END IF;

    SELECT DISTINCT m.codigoasignatura, asi.nombre, m.convocatoria
    INTO var_asi, var_nom, var_conv
    FROM MATRICULAR m
    JOIN ASIGNATURA asi ON asi.codigo = m.codigoasignatura
    WHERE m.codigoasignatura = input_asi AND m.convocatoria = input_conv;

    DBMS_OUTPUT.PUT_LINE('ASIGNATURA ' || var_asi || ' ' || var_nom);
    DBMS_OUTPUT.PUT_LINE('CONVOCATORIA: ' || var_conv);
    DBMS_OUTPUT.PUT_LINE('-------------------------------');
    
    FOR matriculados IN (
        SELECT alu.apellido1, alu.apellido2, alu.nombre, mat.nota
        FROM MATRICULAR mat
        JOIN ALUMNO alu ON alu.numexpediente = mat.codigoalumno
        WHERE mat.convocatoria = input_conv AND mat.codigoasignatura = input_asi
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(matriculados.apellido1 || ' ' || matriculados.apellido2 || ', ' || matriculados.nombre || ' ' || matriculados.nota);
        var_pres := var_pres + 1;
        IF matriculados.nota >= 5 THEN
            var_aprob := var_aprob + 1;
        END IF;
    END LOOP;

    var_exito := (var_aprob / var_pres) * 100;

    DBMS_OUTPUT.PUT_LINE('Total aprobadios: ' || var_aprob);
    DBMS_OUTPUT.PUT_LINE('Total presentados: ' || var_pres);
    DBMS_OUTPUT.PUT_LINE('Total aprobadios: ' || var_exito);
    
END;
/

SET SERVEROUTPUT ON;

BEGIN
  ACTAS_ASIGNATURA_CONVOCATORIA(999, 'Ordinaria');
END;
/

BEGIN
  ACTAS_ASIGNATURA_CONVOCATORIA(10, 'Futura');
END;
/

BEGIN
  ACTAS_ASIGNATURA_CONVOCATORIA(10, 'Ordinaria');
END;
/

-- # Disparador
CREATE OR REPLACE TRIGGER MAYOR_EDAD
BEFORE INSERT OR UPDATE ON ALUMNO
FOR EACH ROW
DECLARE
    v_edad NUMBER;
BEGIN
    v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, :NEW.fechanacimiento) / 12);

    IF v_edad < 18 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El alumno con expediente ' || :NEW.numexpediente || ' es menor de edad');
    END IF;
END;
/    

-- prueba

INSERT INTO ALUMNO (numexpediente, nombre, apellido1, apellido2, fechanacimiento)
VALUES (3001, 'Juan', 'Peña', 'Soto', ADD_MONTHS(SYSDATE, -12*17));

INSERT INTO ALUMNO (numexpediente, nombre, apellido1, apellido2, fechanacimiento)
VALUES (3002, 'Marta', 'Ruiz', 'Vega', ADD_MONTHS(SYSDATE, -12*20));
