CONNECT SYSTEM/bdadmin;

CREATE USER nuevoUser IDENTIFIED BY nuevoUser1;

GRANT RESOURCE, CONNECT TO nuevoUser;

CONNECT nuevoUser/nuevoUser1;

CREATE TABLE EMPLEADO (
    dni VARCHAR2(50),
    nombre VARCHAR2(50) CONSTRAINT emp_nom_nn NOT NULL,
    apellido1 VARCHAR2(50) CONSTRAINT emp_ap1_nn NOT NULL,
    apellido2 VARCHAR2(50),
    Fecha_Nto DATE,
    CONSTRAINT emp_dni_pk PRIMARY KEY (dni),
    CONSTRAINT emp_nom_apellido1_apellido2_uq UNIQUE (nombre, apellido1, apellido2)
);

CREATE TABLE PROYECTO (
    codigo VARCHAR2(50),
    nombre VARCHAR2(50) CONSTRAINT pro_nom_nn NOT NULL,
    tipo VARCHAR2(50),
    CONSTRAINT pro_cod_pk PRIMARY KEY (codigo)
);

CREATE TABLE PARTICIPAR (
    codigo VARCHAR2(50),
    dni VARCHAR2(50),
    fase VARCHAR2(50),
    n_horas NUMBER,
    CONSTRAINT par_cod_dni_fas_pk PRIMARY KEY (codigo, dni, fase),
    CONSTRAINT par_dni_emp_fk FOREIGN KEY (dni) REFERENCES EMPLEADO,
    CONSTRAINT par_cod_pro_fk FOREIGN KEY (codigo) REFERENCES PROYECTO
);

CONNECT SYSTEM/bdadmin;

CREATE USER administrador IDENTIFIED BY administrador1;

GRANT CREATE VIEW TO nuevoUser;

CONNECT nuevoUser/nuevoUser1;

CREATE OR REPLACE VIEW vista_total_emp  AS
SELECT DISTINCT COUNT(dni) AS total_empleados, codigo, fase
FROM PARTICIPAR
GROUP BY codigo, fase
ORDER BY codigo;

CONNECT system/bdadmin;

GRANT CREATE SESSION TO administrador;

GRANT SELECT ON nuevoUser.vista_total_emp TO administrador;

CONNECT administrador/administrador1;

SELECT * FROM nuevoUser.vista_total_emp;

CONNECT nuevoUser/nuevoUser1;

CREATE OR REPLACE PROCEDURE CERTIFICADO_PROYECTOS_FASE (
    input_codigo VARCHAR2,
    input_fase VARCHAR2
)AS
    var_nombre_proyecto VARCHAR2(50);
    var_fase VARCHAR2(50);
    var_total_activos NUMBER := 0;
    var_participando NUMBER := 0;
    var_tasa NUMBER := 0;
    var_proyecto_chck NUMBER;
    var_emp_fas_chck NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO var_proyecto_chck
    FROM PROYECTO
    WHERE codigo = codigo;

    SELECT COUNT(dni)
    INTO var_emp_fas_chck
    FROM PARTICIPAR
    WHERE codigo = input_codigo AND fase = input_fase;

    IF var_proyecto_chck = 0 THEN
        DBMS_OUTPUT.PUT_LINE('El proyecto ' || input_codigo || ' no existe.');
    END IF;

    IF var_emp_fas_chck = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No hay empleados participantes en la fase ' || input_fase || ' del proyecto ' || input_codigo || '.');
    END IF;

    SELECT proy.nombre, par.fase
    INTO var_nombre_proyecto, var_fase
    FROM PARTICIPAR par
    JOIN PROYECTO proy ON proy.codigo = par.codigo
    WHERE par.codigo = input_codigo AND par.fase = input_fase;

    DBMS_OUTPUT.PUT_LINE('PROYECTO: ' || var_nombre_proyecto);
    DBMS_OUTPUT.PUT_LINE('FASE: ' || var_fase);
    DBMS_OUTPUT.PUT_LINE('EMPLEADOS');
    DBMS_OUTPUT.PUT_LINE('-------------------------');

    FOR empleados_in_proyecto IN(
        SELECT emp.apellido1, emp.apellido2, emp.nombre, par.n_horas
        FROM PARTICIPAR par
        JOIN EMPLEADO emp ON emp.dni = par.dni
        WHERE par.codigo = input_codigo AND par.fase = input_fase
    )LOOP
        DBMS_OUTPUT.PUT_LINE(empleados_in_proyecto.apellido1 || ' ' || empleados_in_proyecto.apellido2 || ', ' || empleados_in_proyecto.nombre || ' ' || empleados_in_proyecto.n_horas);

        IF empleados_in_proyecto.n_horas >= 1 THEN
            var_total_activos := var_total_activos + 1;
        END IF;

        var_participando := var_participando + 1;
    END LOOP;

    var_tasa := (var_total_activos / var_participando)*100;

    DBMS_OUTPUT.PUT_LINE('Total activos: ' || var_total_activos);
    DBMS_OUTPUT.PUT_LINE('Total participando: ' || var_participando);
    DBMS_OUTPUT.PUT_LINE('Tasa: ' || var_tasa);
END;
/


CREATE OR REPLACE TRIGGER CONTROL_EDAD
BEFORE INSERT OR UPDATE ON EMPLEADO
FOR EACH ROW
DECLARE
    anio_actual NUMBER := EXTRACT(YEAR FROM SYSDATE);
    anio_nacimiento NUMBER := EXTRACT(YEAR FROM :NEW.Fecha_Nto);
    edad NUMBER;
BEGIN
    edad := anio_actual - anio_nacimiento;

    IF edad < 18 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El empleado con DNI ' || :NEW.dni || ' no cumple el mínimo de edad.');
    ELSIF edad > 32 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El empleado con DNI ' || :NEW.dni || ' no cumple el máximo de edad.');
    END IF;
END;
/
