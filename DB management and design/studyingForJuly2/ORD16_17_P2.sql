
CONNECT SYSTEM/bdadmin;

CREATE USER estoycansada IDENTIFIED BY JEFE;

GRANT CONNECT, RESOURCE TO estoycansada;

CONNECT estoycansada/JEFE;

CREATE TABLE CLASE(
    codigo VARCHAR2(50),
    nombre VARCHAR2(50),
    CONSTRAINT cla_cod_pk PRIMARY KEY(codigo) 
);

CREATE TABLE MONITOR(
    dni VARCHAR2(50),
    nombre VARCHAR2(50),
    apellidos VARCHAR2(50),
    telefono VARCHAR2(50),
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
    codclase VARCHAR2(50) CONSTRAINT imp_codc_nn NOT NULL,
    codsala VARCHAR2(50) CONSTRAINT imp_cods_nn NOT NULL,
    diassemana DATE,
    CONSTRAINT imp_codm_codc_pk PRIMARY KEY (codmonitor, codclase),
    CONSTRAINT imp_codm_mon_fk FOREIGN KEY(codmonitor) REFERENCES MONITOR,
    CONSTRAINT imp_codc_cla_fk FOREIGN KEY (codclase) REFERENCES CLASE,
    CONSTRAINT imp_cods_sal_fk FOREIGN KEY (codsala) REFERENCES SALA,
    CONSTRAINT imp_codc_cods_uq UNIQUE (codclase, codsala)
);

-- DATOS

-- MONITORES
INSERT INTO MONITOR VALUES ('111A', 'Carlos', 'Sánchez', '600111111');
INSERT INTO MONITOR VALUES ('222B', 'Lucía', 'Pérez', '600222222');
INSERT INTO MONITOR VALUES ('333C', 'Raúl', 'Martínez', '600333333');

-- CLASES
INSERT INTO CLASE VALUES ('CL001', 'Pilates');
INSERT INTO CLASE VALUES ('CL002', 'Zumba');
INSERT INTO CLASE VALUES ('CL003', 'Yoga');

-- SALAS
INSERT INTO SALA VALUES ('S001', 'Sala Verde', 'Planta 1');
INSERT INTO SALA VALUES ('S002', 'Sala Azul', 'Planta 2');

-- IMPARTICIÓN (relaciones válidas)
INSERT INTO IMPARTIR VALUES ('111A', 'CL001', 'S001', TO_DATE('2025-06-17', 'YYYY-MM-DD'));
INSERT INTO IMPARTIR VALUES ('222B', 'CL002', 'S001', TO_DATE('2025-06-18', 'YYYY-MM-DD'));
INSERT INTO IMPARTIR VALUES ('333C', 'CL001', 'S002', TO_DATE('2025-06-19', 'YYYY-MM-DD'));
INSERT INTO IMPARTIR VALUES ('111A', 'CL003', 'S002', TO_DATE('2025-06-20', 'YYYY-MM-DD'));


-- PROCEDURE

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE CLASES_MONITOR (input_monitor VARCHAR2)
AS
    var_monitor VARCHAR2(50);
    var_apellido VARCHAR2(50);
    mon_chck NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO mon_chck
    FROM MONITOR
    WHERE dni = input_monitor;

    IF mon_chck = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El monitor ' || input_monitor || ' no existe.');
    END IF;

    SELECT nombre, apellidos
    INTO var_monitor, var_apellido
    FROM MONITOR
    WHERE dni = input_monitor;

    DBMS_OUTPUT.PUT_LINE('MONITOR: ' || var_monitor || ' ' || var_apellido);
    DBMS_OUTPUT.PUT_LINE('CLASES QUE IMPARTE');
    DBMS_OUTPUT.PUT_LINE('-------------------');

    FOR datos IN(
        SELECT clase.nombre AS clasenombre, sala.nombre AS salanombre, imp.diassemana
        FROM IMPARTIR imp
        JOIN CLASE clase ON clase.codigo = imp.codclase
        JOIN SALA sala ON sala.codigo = imp.codsala
    )LOOP
        DBMS_OUTPUT.PUT_LINE(datos.clasenombre || ' ' || datos.salanombre || ' ' || datos.diassemana);
    END LOOP;
END;
/

-- Ejecución correcta (Carlos imparte CL001 y CL003)
EXEC CLASES_MONITOR('111A');

-- Caso de error: monitor no existe
EXEC CLASES_MONITOR('999X');


-- otro procedure

CREATE OR REPLACE PROCEDURE DEVOLVER_MONITORES (input_clase VARCHAR2)
AS
    var_total_mon NUMBER;
BEGIN
    SELECT DISTINCT COUNT (codmonitor)
    INTO var_total_mon
    FROM IMPARTIR imp
    WHERE imp.codclase = input_clase;

    DBMS_OUTPUT.PUT_LINE('Total monitores distintos: ' || var_total_mon);

END;
/

CONNECT SYSTEM/bdadmin;

GRANT CREATE VIEW TO estoycansada;

CREATE USER antonio IDENTIFIED BY toni;

GRANT CREATE SESSION TO antonio;

CONNECT estoycansada/JEFE;

CREATE OR REPLACE VIEW clasesusuario AS
    SELECT *
    FROM IMPARTIR
    WHERE codmonitor = '11222333A';
END;
/


-- 1. CREAR MONITOR CON DNI 11222333A
INSERT INTO MONITOR VALUES ('11222333A', 'Antonio', 'López', '611223344');

-- 2. CREAR CLASES Y SALAS
INSERT INTO CLASE VALUES ('CL010', 'Body Combat');
INSERT INTO SALA VALUES ('S010', 'Sala Roja', 'Planta Baja');

-- 3. INSERTAR UNA IMPARTICIÓN CON ESE MONITOR
INSERT INTO IMPARTIR VALUES ('11222333A', 'CL010', 'S010', TO_DATE('2025-06-21', 'YYYY-MM-DD'));



CONNECT SYSTEM/bdadmin;

GRANT SELECT ON estoycansada.clasesusuario TO antonio;

CONNECT antonio/toni;