CONNECT SYSTEM/bdadmin;

CREATE USER enero_2014_2015_Parte_2A IDENTIFIED BY enero_2014_2015_Parte_2A;
GRANT CONNECT, RESOURCE TO enero_2014_2015_Parte_2A;
CONNECT enero_2014_2015_Parte_2A/enero_2014_2015_Parte_2A;

CREATE TABLE TORNEO(
    codigo VARCHAR2(50),
    nombre VARCHAR2(50),
    fechainicio DATE,
    descripcion VARCHAR2(50),
    CONSTRAINT tor_cod_pk PRIMARY KEY(codigo)
);

CREATE TABLE SOCIO(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    apellido2 VARCHAR2(50),
    telefono NUMBER(9),
    email VARCHAR2(50),
    sexo VARCHAR2(50),
    CONSTRAINT soc_dni_pk PRIMARY KEY(dni)
);

CREATE TABLE PATROCINADOR(
    cif VARCHAR2(50),
    nombre VARCHAR2(50),
    telefono NUMBER(9),
    email VARCHAR2(50),
    CONSTRAINT pat_cif_pk PRIMARY KEY (cif)
);

CREATE TABLE PARTICIPAR (
    codtorneo VARCHAR2(50),
    socio1 VARCHAR2(9),
    socio2 VARCHAR2(9) CONSTRAINT par_cod_socio2_nn NOT NULL,
    posicion NUMBER,
    CONSTRAINT par_cod_socio1_pk PRIMARY KEY(codtorneo, socio1),
    CONSTRAINT par_cod_tor_fk FOREIGN KEY(codtorneo) REFERENCES TORNEO,
    CONSTRAINT par_socio1_soc_fk FOREIGN KEY (socio1) REFERENCES SOCIO,
    CONSTRAINT par_socio2_soc_fk FOREIGN KEY (socio2) REFERENCES SOCIO,
    CONSTRAINT par_cod_socio2_uq UNIQUE(codtorneo, socio2)
);

CREATE TABLE FINANCIAR(
    cifpatrocinador VARCHAR2(50),
    codtorneo VARCHAR2(50),
    importe NUMBER(7,2),
    CONSTRAINT fin_cif_cod_pk PRIMARY KEY(cifpatrocinador, codtorneo),
    CONSTRAINT fin_cif_pat_fk FOREIGN KEY(cifpatrocinador) REFERENCES PATROCINADOR,
    CONSTRAINT fin_cod_tor_fk FOREIGN KEY(codtorneo) REFERENCES TORNEO
);


-- INSERTS


INSERT INTO TORNEO VALUES ('T001', 'Open Invierno', TO_DATE('2025-01-10', 'YYYY-MM-DD'), 'Torneo regional');
INSERT INTO TORNEO VALUES ('T002', 'Primavera Cup', TO_DATE('2025-03-21', 'YYYY-MM-DD'), 'Edición de primavera');
INSERT INTO TORNEO VALUES ('T003', 'Verano Masters', TO_DATE('2025-06-15', 'YYYY-MM-DD'), 'Final nacional');


INSERT INTO SOCIO VALUES ('12345678A', 'Lorena', 'Almoguera', 'Romero', 612345678, 'lorena@email.com', 'F');
INSERT INTO SOCIO VALUES ('23456789B', 'Carlos', 'Gómez', 'Pérez', 622334455, 'carlos@email.com', 'M');
INSERT INTO SOCIO VALUES ('34567890C', 'María', 'López', 'Sánchez', 633112233, 'maria@email.com', 'F');
INSERT INTO SOCIO VALUES ('45678901D', 'David', 'Martín', 'Ruiz', 644223344, 'david@email.com', 'M');


INSERT INTO PATROCINADOR VALUES ('PATR01', 'Coca-Cola', 911223344, 'sponsor1@cocacola.com');
INSERT INTO PATROCINADOR VALUES ('PATR02', 'Nike', 922334455, 'sponsor2@nike.com');
INSERT INTO PATROCINADOR VALUES ('PATR03', 'Adidas', 933445566, 'sponsor3@adidas.com');


-- Torneo T001
INSERT INTO PARTICIPAR VALUES ('T001', '12345678A', '23456789B', 1);
INSERT INTO PARTICIPAR VALUES ('T001', '34567890C', '45678901D', 2);

-- Torneo T002
INSERT INTO PARTICIPAR VALUES ('T002', '12345678A', '34567890C', 3);
INSERT INTO PARTICIPAR VALUES ('T002', '23456789B', '45678901D', 1);


INSERT INTO FINANCIAR VALUES ('PATR01', 'T001', 1500.00);
INSERT INTO FINANCIAR VALUES ('PATR02', 'T002', 2000.00);
INSERT INTO FINANCIAR VALUES ('PATR03', 'T003', 2500.00);
INSERT INTO FINANCIAR VALUES ('PATR01', 'T003', 1800.00);


-- EJERCICO 1


CONNECT SYSTEM/bdadmin;

CREATE USER vertorneos IDENTIFIED BY ver;

GRANT CREATE SESSION TO vertorneos;

GRANT CREATE VIEW TO enero_2014_2015_Parte_2A;

CONNECT enero_2014_2015_Parte_2A/enero_2014_2015_Parte_2A;

CREATE OR REPLACE VIEW DATOSTORNEO AS
SELECT torn.fechainicio, torn.nombre AS Nombre_Torneo, fin.importe, pat.nombre AS Nombre_Patrocinador, pat.telefono
FROM FINANCIAR fin
JOIN TORNEO torn ON torn.codigo = fin.codtorneo
JOIN PATROCINADOR pat ON pat.cif = pat.cif
ORDER BY torn.fechainicio, fin.importe;

CONNECT SYSTEM/bdadmin;

GRANT SELECT ON enero_2014_2015_Parte_2A.DATOSTORNEO TO vertorneos;



CONNECT vertorneos/ver;

SELECT * FROM enero_2014_2015_Parte_2A.DATOSTORNEO;

-- CREATE PROCEDURE

CONNECT enero_2014_2015_Parte_2A/enero_2014_2015_Parte_2A;


SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE PARTICIPANTES (input_torneo VARCHAR2) 
AS
    var_torneo VARCHAR2(50);
    var_total_parejas NUMBER := 0;
    var_hay_torneo NUMBER;
BEGIN
    SELECT COUNT(*) INTO var_hay_torneo
    FROM PARTICIPAR
    WHERE codtorneo = input_torneo;

    IF var_hay_torneo = 0 THEN
        DBMS_OUTPUT.PUT_LINE('El torneo ' || input_torneo || ' no se encuentra en la base de datos');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Torneo: ' || input_torneo);
        DBMS_OUTPUT.PUT_LINE('------------------------------------');

    FOR parejas IN(
        SELECT socio1, socio2, posicion
        FROM PARTICIPAR
        WHERE codtorneo = input_torneo
    )LOOP

        DBMS_OUTPUT.PUT_LINE(parejas.socio1 || ' ' || parejas.socio2 || ' ' || parejas.posicion);
        var_total_parejas := var_total_parejas + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total parejas: ' || var_total_parejas);
END;
/

BEGIN
    PARTICIPANTES('T002');
END;
/
