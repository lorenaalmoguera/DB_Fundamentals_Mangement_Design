CONNECT SYSTEM/bdadmin;

CREATE USER EXAM1516_Part2_ModelA IDENTIFIED BY EXAM1516_Part2_ModelA;

GRANT CONNECT, RESOURCE TO EXAM1516_Part2_ModelA;

CONNECT EXAM1516_Part2_ModelA/EXAM1516_Part2_ModelA;

CREATE TABLE ALUMNO(
    numexpediente NUMBER,
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    apellido2 VARCHAR2(50),
    CONSTRAINT alu_num_pk PRIMARY KEY(numexpediente)
);

CREATE TABLE ASIGNATURA(
    codigo VARCHAR2(50),
    nombre VARCHAR2(50),
    creditos NUMBER(2),
    tipo VARCHAR2(50),
    CONSTRAINT asi_cod_pk PRIMARY KEY(codigo),
    CONSTRAINT asi_tip_ch CHECK (tipo IN('OBLIGATORIA', 'OPTATIVA', 'LIBRE'))
);

CREATE TABLE MATRICULAR(
    codigoalumno NUMBER,
    codigoasignatura VARCHAR2(50),
    convocatoria VARCHAR2(50),
    nota NUMBER(4,2),
    CONSTRAINT mat_codigoal_codigoas_conv_pk PRIMARY KEY(codigoalumno, codigoasignatura, convocatoria),
    CONSTRAINT mat_codigoal_alu_fk FOREIGN KEY(codigoalumno) REFERENCES ALUMNO,
    CONSTRAINT mat_codigoas_asi_fk FOREIGN KEY(codigoasignatura) REFERENCES ASIGNATURA
);

-- insertar datos

INSERT INTO ALUMNO VALUES (1001, 'Lorena', 'Almoguera', 'Romero');
INSERT INTO ALUMNO VALUES (1002, 'Carlos', 'Gómez', 'Pérez');
INSERT INTO ALUMNO VALUES (1003, 'María', 'López', 'Sánchez');
INSERT INTO ALUMNO VALUES (1004, 'David', 'Martín', 'Ruiz');

INSERT INTO ASIGNATURA VALUES ('ASG101', 'Bases de Datos', 6, 'OBLIGATORIA');
INSERT INTO ASIGNATURA VALUES ('ASG102', 'Programación I', 6, 'OBLIGATORIA');
INSERT INTO ASIGNATURA VALUES ('ASG201', 'Inteligencia Artificial', 4, 'OPTATIVA');
INSERT INTO ASIGNATURA VALUES ('ASG202', 'Psicología Social', 3, 'LIBRE');
-- Nuevas asignaturas de tipo OPTATIVA
INSERT INTO ASIGNATURA VALUES ('ASG203', 'Ciberseguridad', 4, 'OPTATIVA');
INSERT INTO ASIGNATURA VALUES ('ASG204', 'Desarrollo Web', 5, 'OPTATIVA');


-- Lorena
INSERT INTO MATRICULAR VALUES (1001, 'ASG101', 'ORDINARIA', 8.50);
INSERT INTO MATRICULAR VALUES (1001, 'ASG102', 'ORDINARIA', 7.75);
INSERT INTO MATRICULAR VALUES (1001, 'ASG201', 'ORDINARIA', 9.00);

-- Carlos
INSERT INTO MATRICULAR VALUES (1002, 'ASG101', 'ORDINARIA', 5.25);
INSERT INTO MATRICULAR VALUES (1002, 'ASG102', 'ORDINARIA', 6.00);
INSERT INTO MATRICULAR VALUES (1002, 'ASG202', 'ORDINARIA', 7.50);

-- María
INSERT INTO MATRICULAR VALUES (1003, 'ASG101', 'ORDINARIA', 4.00); -- suspenso
INSERT INTO MATRICULAR VALUES (1003, 'ASG101', 'EXTRAORDINARIA', 6.50); -- aprobada en segunda
INSERT INTO MATRICULAR VALUES (1003, 'ASG201', 'ORDINARIA', 8.25);

-- David
INSERT INTO MATRICULAR VALUES (1004, 'ASG102', 'ORDINARIA', 9.25);
INSERT INTO MATRICULAR VALUES (1004, 'ASG202', 'ORDINARIA', 6.00);



-- procedure

CREATE OR REPLACE PROCEDURE ACTAS_ASIGNATURA_CONVOCATORIA (input_asignatura VARCHAR2, input_convocatoria VARCHAR2)
AS
    var_cod_asi VARCHAR2(50);
    var_nom_asi VARCHAR2(50);
    var_conv  VARCHAR2(50);
    var_hay_datos NUMBER;
    var_hay_asignatura NUMBER;
    tasa_aprobados NUMBER := 0;
    tasa_presentados NUMBER := 0;
    tasa_exito NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO var_hay_asignatura
    FROM ASIGNATURA
    WHERE codigo = input_asignatura;

    IF var_hay_asignatura = 0 THEN
        RAISE_APPLICATION_ERROR(-2001,'La asignatura ' || input_asignatura || ' no existe.');
    END IF;

    SELECT COUNT(*) INTO var_hay_datos
    FROM MATRICULAR
    WHERE codigoasignatura = input_asignatura AND convocatoria = input_convocatoria;

    IF var_hay_datos = 0 THEN  
        RAISE_APPLICATION_ERROR(-2002, 'No hay alumnos matriculados en la convocatoria ' || input_convocatoria || ' de la asignatura ' || input_asignatura);
    END IF;

    SELECT DISTINCT mat.codigoasignatura, asi.nombre, mat.convocatoria
    INTO var_cod_asi, var_nom_asi, var_conv
    FROM MATRICULAR mat
    JOIN ASIGNATURA asi ON asi.codigo = mat.codigoasignatura
    WHERE mat.codigoasignatura = input_asignatura AND mat.convocatoria = input_convocatoria;

    DBMS_OUTPUT.PUT_LINE('ASIGNATURA: ' || var_cod_asi || ' ' || var_nom_asi);
    DBMS_OUTPUT.PUT_LINE('CONVOCATORIA: ' || var_conv);
    DBMS_OUTPUT.PUT_LINE('ALUMNOS');
    DBMS_OUTPUT.PUT_LINE('-----------------------------');

    FOR alumnos IN(
        SELECT alu.apellido1, alu.apellido2, alu.nombre, mat.nota
        FROM MATRICULAR mat
        JOIN ALUMNO alu ON alu.numexpediente = mat.codigoalumno
        WHERE mat.codigoasignatura = input_asignatura AND mat.convocatoria = input_convocatoria
        ORDER BY alu.apellido1, alu.apellido2, alu.nombre
    )LOOP
        DBMS_OUTPUT.PUT_LINE(alumnos.apellido1 || ' ' || alumnos.apellido2 || ', ' || alumnos.nombre || ' ' || alumnos.nota);
        tasa_presentados := tasa_presentados + 1;
        IF alumnos.nota > 5 THEN
            tasa_aprobados := tasa_aprobados + 1;
        END IF;
    END LOOP;

    tasa_exito := (tasa_aprobados / tasa_presentados) * 100;

    DBMS_OUTPUT.PUT_LINE('Tasa de exito: ' || tasa_exito);
END;
/

BEGIN
    ACTAS_ASIGNATURA_CONVOCATORIA('ASG101', 'ORDINARIA');
END;
/

CONNECT SYSTEM/bdadmin;

CREATE USER monica IDENTIFIED BY mon;

GRANT CREATE SESSION TO monica;

GRANT CREATE VIEW TO EXAM1516_Part2_ModelA;

CONNECT EXAM1516_Part2_ModelA/EXAM1516_Part2_ModelA;

-- 1. Creamos una vista para obtener el número total de alumnos
-- matriculados en asignaturas OPTATIVAS, agrupados por asignatura y convocatoria.

CREATE OR REPLACE VIEW numero_total_alumnos_optativas AS
SELECT 
    m.codigoasignatura,
    m.convocatoria,
    COUNT(DISTINCT m.codigoalumno) AS total_matriculados
FROM 
    MATRICULAR m
JOIN 
    ASIGNATURA a ON m.codigoasignatura = a.codigo
WHERE 
    a.tipo = 'OPTATIVA'
GROUP BY 
    m.codigoasignatura, m.convocatoria;

CONNECT SYSTEM/bdadmin;
 
GRANT SELECT ON EXAM1516_Part2_ModelA.numero_total_alumons TO monica;

CONNECT monica/mon;

SELECT * FROM EXAM1516_Part2_ModelA.numero_total_alumons;