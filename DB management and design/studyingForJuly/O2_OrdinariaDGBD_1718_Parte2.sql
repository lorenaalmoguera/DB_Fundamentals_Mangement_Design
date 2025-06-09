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

CREATE USER LORENITA IDENTIFIED BY lorenita;
GRANT CONNECT, RESOURCE TO LORENITA;
CONNECT LORENITA/lorenita;

CREATE TABLE ABOGADO(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    ncolegiado VARCHAR2(50) CONSTRAINT abo_nco_nn NOT NULL,
    CONSTRAINT abo_dni_pk PRIMARY KEY (dni),
    CONSTRAINT abo_nco_uq UNIQUE (ncolegiado)
);


CREATE TABLE MENOR(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    fechanac DATE,
    CONSTRAINT men_dni_pk PRIMARY KEY(dni)
);

CREATE TABLE EXPEDIENTE(
    numero NUMBER,
    dnimenor VARCHAR2(9),
    delito VARCHAR2(50),
    fechaapertura DATE DEFAULT SYSDATE,
    sentencia VARCHAR2(1),
    dniabogado VARCHAR2(9) CONSTRAINT exp_dna_nn NOT NULL,
    CONSTRAINT exp_num_dni_pk PRIMARY KEY(numero, dnimenor),
    CONSTRAINT exp_dnm_men_fk FOREIGN KEY(dnimenor) REFERENCES MENOR,
    CONSTRAINT exp_dna_abo_fk FOREIGN KEY(dniabogado) REFERENCES ABOGADO,
    CONSTRAINT men_sen_ch CHECK (sentencia IN ('I','C',''))
);

CONNECT system/bdadmin;

CREATE USER inocente IDENTIFIED BY tutelar;
GRANT CREATE SESSION TO inocente;
GRANT CREATE VIEW TO LORENITA;


CONNECT LORENITA/lorenita;

CREATE OR REPLACE VIEW expedientes AS
SELECT e.numero, e.dnimenor, e.delito, e.fechaapertura
FROM EXPEDIENTE e
WHERE e.sentencia = 'I';

GRANT SELECT, UPDATE (fechaapertura) ON expedientes TO inocente;

CREATE OR REPLACE TRIGGER exp_trigger_fecha INSTEAD OF UPDATE ON expedientes
FOR EACH ROW
BEGIN
    IF EXTRACT(YEAR FROM :OLD.fechaapertura) != EXTRACT (YEAR FROM :NEW.fechaapertura) THEN 
        RAISE_APPLICATION_ERROR(-20001, 'No se permite modificar el año de la fecha del expediente');
    END IF

    UPDATE EXPEDIENTE
    SET fechaapertura = :NEW.fechaapertura
    WHERE numero = :OLD.numero AND dnimenor = :OLD.numero
END;
/

GRANT SELECT, UPDATE ON expedientes TO inocente;


CREATE OR REPLACE PROCEDURE LISTADO_EXPEDIENTES (
    input_dni VARCHAR2
) AS
    var_dni VARCHAR2(9);    
    var_nombre VARCHAR2(50);
    var_apellido VARCHAR2(50);
    var_culpable NUMBER := 0;
    var_inocente NUMBER := 0;
BEGIN
    BEGIN
        SELECT m.dni, m.nombre, m.apellido1
        INTO var_dni, var_nombre, var_apellido
        FROM MENOR m
        WHERE m.dni = input_dni;

        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('El menor ' || input_dni || ' no se encuentra en la base de datos.');
            RETURN;
    END;
 
    DBMS_OUTPUT.PUT_LINE('MENOR: ' || var_dni || ' ' || var_nombre || ' ' || var_apellido);
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');

    FOR expedientes IN(
        SELECT e.fechaapertura, e.numero, e.delito, e.sentencia, a.nombre, a.apellido1
        FROM EXPEDIENTE e
        JOIN ABOGADO a ON a.dni = e.dniabogado
        WHERE e.dnimenor = var_dni
        ORDER BY e.fechaapertura DESC
    )LOOP
        
        DBMS_OUTPUT.PUT_LINE(expedientes.fechaapertura || ' ' || expedientes.numero || ' ' || expedientes.delito || ' ' || expedientes.sentencia || ' ' || expedientes.nombre || ' ' || expedientes.apellido1);

        IF expedientes.sentencia = 'I' THEN
            var_inocente := var_inocente + 1;
        END IF;

        IF expedientes.sentencia = 'C' THEN
            var_culpable := var_culpable + 1;
        END IF;

    END LOOP;

    DBMS_OUTPUT.PUT_LINE('N.Exp. Culpable: ' || var_culpable);
    DBMS_OUTPUT.PUT_LINE('N.Exp. Inocente: ' || var_inocente);

END;
/

SET SERVEROUTPUT ON;

BEGIN
    LISTADO_EXPEDIENTES('48796558B');
END;
/


CREATE OR REPLACE PROCEDURE LISTADO_ALEJANDRO (p_dni VARCHAR2) AS
    v_nom     VARCHAR2(50);
    v_ape     VARCHAR2(50);

    v_culp    NUMBER := 0;
    v_inoc    NUMBER := 0;
    v_dnix    VARCHAR2(20) := UPPER(p_dni);
BEGIN
    SELECT nombre, apellido1
      INTO v_nom, v_ape
      FROM MENOR
     WHERE UPPER(dni) = v_dnix;

    DBMS_OUTPUT.PUT_LINE('MENOR: ' || v_dnix || ' ' || v_nom || ' ' || v_ape);

    FOR exp_rec IN (
        SELECT e.fechaapertura, e.numero, e.delito, e.sentencia, a.nombre, a.apellido1
        FROM EXPEDIENTE e
        JOIN ABOGADO a ON a.dni = e.dniabogado
        WHERE UPPER(e.dnimenor) = v_dnix
        ORDER BY e.fechaapertura DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            exp_rec.fechaapertura || ' ' ||
            exp_rec.numero || ' ' ||
            exp_rec.delito || ' ' ||
            exp_rec.sentencia || ' ' ||
            exp_rec.nombre || ' ' ||
            exp_rec.apellido1
        );

        IF exp_rec.sentencia = 'I' THEN
            v_inoc := v_inoc + 1;
        END IF;

        IF exp_rec.sentencia = 'C' THEN
            v_culp := v_culp + 1;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('N.Exp. Culpable: ' || v_culp);
    DBMS_OUTPUT.PUT_LINE('N.Exp. Inocente: ' || v_inoc);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('El menor ' || p_dni ||
                             ' no se encuentra en la base de datos.');
END;
/

BEGIN
    LISTADO_ALEJANDRO('48796558B');
END;
/
