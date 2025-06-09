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

CREATE USER aramisfuster IDENTIFIED BY bruja;
GRANT CONNECT, RESOURCE, CREATE VIEW TO aramisfuster;

CONNECT aramisfuster/bruja;

CREATE TABLE CLASE(
    codigo VARCHAR2(50),
    nombre VARCHAR2(50),
    CONSTRAINT cla_cod_pk PRIMARY KEY(codigo)
);

CREATE TABLE MONITOR(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellidos VARCHAR2(100),
    telefono VARCHAR2(9),
    CONSTRAINT mon_dni_pk PRIMARY KEY(dni)
);

CREATE TABLE SALA(
    codigo VARCHAR2(50),
    nombre VARCHAR2(50),
    ubicacion VARCHAR2(50),
    CONSTRAINT sal_cod_pk PRIMARY KEY(codigo)
);

CREATE TABLE IMPARTIR(
    codmonitor VARCHAR2(50),
    codclase VARCHAR2(50) CONSTRAINT imp_ccl_nn NOT NULL,
    codsala VARCHAR2(50) CONSTRAINT imp_csa_nn NOT NULL,
    diasemana VARCHAR2(50),
    CONSTRAINT imp_cmo_ccl_pk PRIMARY KEY(codmonitor, codclase),
    CONSTRAINT imp_cmo_mon_fk FOREIGN KEY(codmonitor) REFERENCES MONITOR,
    CONSTRAINT imp_ccl_cla_fk FOREIGN KEY(codclase) REFERENCES CLASE,
    CONSTRAINT imp_ccl_uq UNIQUE (codclase),
    CONSTRAINT imp_csa_uq UNIQUE (codsala),
    CONSTRAINT imp_csa_sal_fk FOREIGN KEY(codsala) REFERENCES SALA
);

CREATE OR REPLACE PROCEDURE CLASES_MONITOR (
    input_monitor VARCHAR2
) AS
    v_nomMonitor VARCHAR2(50);
    v_apellMonitor VARCHAR2(100);
BEGIN

    SELECT nombre, apellidos
    INTO v_nomMonitor, v_apellMonitor
    FROM MONITOR
    WHERE dni = input_monitor;

    DBMS_OUTPUT.PUT_LINE('MONITOR: ' || v_nomMonitor || ' ' || v_apellMonitor);
    DBMS_OUTPUT.PUT_LINE('CLASES QUE IMPARTE');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------');

    FOR clases IN(
        SELECT c.nombre, s.nombre AS nombresala, i.diasemana
        FROM IMPARTIR i
        JOIN CLASE c ON c.codigo = i.codclase
        JOIN SALA s ON s.codigo = i.codsala
        WHERE i.codmonitor = input_monitor
    )LOOP

        DBMS_OUTPUT.PUT_LINE(clases.nombre || ' ' || clases.nombresala || ' ' || clases.diasemana);
    END LOOP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('El monitor ' || input_monitor || ' no existe.');
END;
/


CREATE PROCEDURE TOTAL_MONITORES_CLASE (
    input_clase VARCHAR2
) AS
    var_total NUMBER := 0;
BEGIN
    FOR monitores IN (
        SELECT i.codmonitor
        FROM IMPARTIR i
        WHERE i.codclase = input_clase
    )LOOP
        var_total := var_total + 1;
    END LOOP;

        DBMS_OUTPUT.PUT_LINE(var_total);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('0');
END;
/
   

CONNECT system/bdadmin;

CREATE USER antonio2 IDENTIFIED BY toni2;
GRANT CREATE SESSION TO antonio2;


CONNECT aramisfuster/bruja;

CREATE OR REPLACE VIEW vistasmonitor AS
SELECT *
FROM IMPARTIR
WHERE codmonitor = '11222333A';


GRANT SELECT, UPDATE ON vistasmonitor TO antonio2;

CREATE OR REPLACE TRIGGER vistasmonitor_trg_antonio INSTEAD OF UPDATE ON vistasmonitor
FOR EACH ROW
BEGIN
    IF :OLD.codmonitor != :NEW.codmonitor THEN
        RAISE_APPLICATION_ERROR(-20002, 'No se permite modificar el DNI del monitor');
    END IF;

    UPDATE IMPARTIR
    SET codclase = :NEW.codclase, codsala = :NEW.codsala, diasemana = :NEW.diasemana
    WHERE :OLD.codmonitor = '11222333A';
END;
/