---     • Clave principal: tab_col_pk
---     • Clave ajena: tab_col_tabdestino_fk
---     • Valores no nulos: tab_col_nn
---     • Valores únicos: tab_col_uq
---     • Comprobación de condiciones: tab_col_ch
---     tab: 3 primeros caracteres de la tabla donde se define la restricción.
---•    col: 3 primeros caracteres de la columna que forma parte de la restricción. En
---     el caso de que haya más de una columna se indicará de la siguiente forma
---     col1_col2_... donde col1 y col2 son los tres primeros caracteres de dos
---     columnas que forman parte de la restricción
---•    tabdestino: 3 primeros caracteres de la tabla a la que hace referencia la clave ajena

CREATE TABLE ALUMNO (
    numexpediente INT,
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    apellido2 VARCHAR2(50),
    fecha_nacimiento DATE,
    CONSTRAINT alu_num_pk PRIMARY KEY (numexpediente)
);

CREATE TABLE ASIGNATURA (
    codigo INT,
    nombre VARCHAR2(50),
    creditos NUMBER(2,1),
    tipo VARCHAR2(50),
    CONSTRAINT asi_cod_pk PRIMARY KEY (codigo),
    CONSTRAINT asi_tip_ch CHECK (tipo IN('OBLIGATORIA', 'OPTATIVA', 'LIBRE')),
    CONSTRAINT asi_cre_ch CHECK (creditos > 0 AND creditos < 100)
);

CREATE TABLE MATRICULAR (
    codigoalumno INT,
    codigoasignatura INT,
    convocatoria VARCHAR2(50),
    nota NUMBER(2,1),
    CONSTRAINT mat_cal_cas_con_pk PRIMARY KEY(codigoalumno, codigoasignatura, convocatoria),
    CONSTRAINT mat_cal_alu_fk FOREIGN KEY(codigoalumno) REFERENCES ALUMNO(numexpediente),
    CONSTRAINT mal_cas_asi_fk FOREIGN KEY(codigoasignatura) REFERENCES ASIGNATURA(codigo)
);

CONNECT system/bdadmin

CREATE USER admin1 IDENTIFIED BY admin
  DEFAULT TABLESPACE users;

GRANT CREATE SESSION TO admin1;

CONNECT ord1819/ene1819

CREATE OR REPLACE VIEW v_mat_optativa_cnt AS
SELECT  a.codigo             AS codigo_asig,
        m.convocatoria,
        COUNT(*)             AS num_alumnos
FROM      asignatura   a
JOIN      matricular   m ON a.codigo = m.codigoasignatura
WHERE     a.tipo = 'OPTATIVA'
GROUP BY  a.codigo, m.convocatoria
ORDER BY  a.codigo, m.convocatoria;

GRANT SELECT ON v_mat_optativa_cnt TO admin1;


CONNECT admin1/admin
CREATE SYNONYM mat_opt_cnt FOR ord1819.v_mat_optativa_cnt;


SELECT codigo_asig,
       convocatoria,
       num_alumnos
FROM   mat_opt_cnt
ORDER  BY num_alumnos DESC;

CREATE OR REPLACE PROCEDURE ACTAS_ASIGNATURA_CONVOCATORIA(
    asignatura_input NUMBER,
    convocatoria_input VARCHAR2
) AS
    var_codigoasi NUMBER;
    var_nombreasi VARCHAR2(50);
    var_convocatoria VARCHAR2(50);
    var_total NUMBER := 0;
    var_presentados NUMBER := 0;
    var_tasa NUMBER(5,2);
BEGIN
    BEGIN
        SELECT m.codigoasignatura, asi.nombre, m.convocatoria
        INTO var_codigoasi, var_nombreasi, var_convocatoria
        FROM MATRICULAR m
        INNER JOIN ASIGNATURA asi ON asi.codigo = m.codigoasignatura
        WHERE m.codigoasignatura = asignatura_input
          AND m.convocatoria = convocatoria_input;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO EXISTE MATRÍCULA CON CÓDIGO DE ASIGNATURA ' || asignatura_input || ' Y CONVOCATORIA ' || convocatoria_input);
            RETURN;
    END;

    DBMS_OUTPUT.PUT_LINE('ASIGNATURA: ' || var_codigoasi || ' ' || var_nombreasi);
    DBMS_OUTPUT.PUT_LINE('CONVOCATORIA: ' || var_convocatoria);
    DBMS_OUTPUT.PUT_LINE('ALUMNOS');
    DBMS_OUTPUT.PUT_LINE('------------------------------------');

    FOR alumnos IN (
        SELECT alu.apellido1, alu.apellido2, alu.nombre, m.nota
        FROM MATRICULAR m
        JOIN ALUMNO alu ON alu.numexpediente = m.codigoalumno
        WHERE m.codigoasignatura = var_codigoasi
          AND m.convocatoria = var_convocatoria
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(alumnos.apellido1 || ' ' || alumnos.apellido2 || ', ' || alumnos.nombre || ' Nota: ' || alumnos.nota);
        var_presentados := var_presentados + 1;
        IF alumnos.nota >= 5 THEN
            var_total := var_total + 1;
        END IF;
    END LOOP;

    IF var_presentados = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No hay alumnos matriculados en la convocatoria ' || var_convocatoria || ' de la asignatura ' || var_codigoasi || '.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Total aprobados: ' || var_total);
    DBMS_OUTPUT.PUT_LINE('Total presentados: ' || var_presentados);
    var_tasa := (var_total / var_presentados) * 100;
    DBMS_OUTPUT.PUT_LINE('Tasa de éxito: ' || TO_CHAR(var_tasa, '90.00') || '%');
END;
/

CREATE OR REPLACE TRIGGER MAYOR_EDAD
BEFORE INSERT OR UPDATE ON ALUMNO
FOR EACH ROW
DECLARE
    -- Variable to store the current year
    current_year NUMBER;
BEGIN
    -- Get the current year using the SYSDATE function
    current_year := EXTRACT(YEAR FROM SYSDATE);

    -- Check if the student's birth year makes them under 18
    IF EXTRACT(YEAR FROM :NEW.fecha_nacimiento) > (current_year - 18) THEN
        -- Raise an error if the student is under 18
        RAISE_APPLICATION_ERROR(
            -20002,
            'El alumno con expediente ' || :NEW.numexpediente || ' es menor de edad.'
        );
    END IF;
END;
/
