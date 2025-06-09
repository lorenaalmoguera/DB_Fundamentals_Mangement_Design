CONNECT SYSTEM/bdadmin;

CREATE USER ord2425 IDENTIFIED BY examen;

GRANT CONNECT, RESOURCE TO ord2425;

CONNECT ord2425/examen;

CREATE TABLE PRUEBA(
    codigo VARCHAR2(50),
    nombre VARCHAR2(50),
    CONSTRAINT pru_cod_pk PRIMARY KEY(codigo)
);

CREATE TABLE CENTRO(
    codigo VARCHAR2(50),
    nombre VARCHAR2(50),
    localidad VARCHAR2(50),
    CONSTRAINT cen_cod_pk PRIMARY KEY(codigo)
);

CREATE TABLE DEPORTISTA(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    localidad VARCHAR2(50),
    telefono VARCHAR2(9),
    iddep VARCHAR2(9) CONSTRAINT dep_idd_uq UNIQUE,
    CONSTRAINT dep_dni_pk PRIMARY KEY(dni)
);

CREATE TABLE CELEBRAR(
    codigo VARCHAR2(50),
    centro VARCHAR2(50),
    dia DATE,
    precio NUMBER(5,2),
    CONSTRAINT cel_cod_cen_dia_pk PRIMARY KEY(codigo, centro, dia),
    CONSTRAINT cel_pre_ch CHECK (precio >= 0 AND precio <= 120),
    CONSTRAINT cel_cod_pru_fk FOREIGN KEY(codigo) REFERENCES PRUEBA,
    CONSTRAINT cel_cen_cen_fk FOREIGN KEY(centro) REFERENCES CENTRO
);


CREATE TABLE PARTICIPAR(
    dni VARCHAR2(9),
    codigo VARCHAR2(50),
    centro VARCHAR2(50),
    fecha DATE,
    posicion NUMBER(3),
    CONSTRAINT par_dni_cod_cen_fec_pk PRIMARY KEY(dni, codigo, centro, fecha),
    CONSTRAINT par_dni_dep_fk FOREIGN KEY(dni) REFERENCES DEPORTISTA,
    CONSTRAINT par_cod_cen_fec_cel_fk FOREIGN KEY(codigo, centro, fecha) REFERENCES CELEBRAR(codigo, centro, dia),
    CONSTRAINT par_pos_ch CHECK(posicion > 0)
);

-- esta era mi solución que estaba bien encaminada pero no del todo bien...
CREATE OR REPLACE PROCEDURE INSVRITOS_PRUEBACENTRO (
    codigoprueba VARCHAR2, codigocentro VARCHAR2, diaprueba DATE
)AS
    nombreprueba VARCHAR2(50);
    nombrecentro VARCHAR2(50);
    checkprueba VARCHAR2(50);
    checkcentro VARCHAR2(50);
    checkfecha DATE;
    fechaprueba DATE;
    total NUMBER := 0;
BEGIN
    SELECT DISTINCT prueba.nombre, centro.nombre, participar.fecha, prueba.codigo, centro.codigo, participar.fecha
    INTO nombreprueba, nombrecentro, fechaprueba, checkprueba, checkcentro, checkfecha
    FROM PARTICIPAR participar
    JOIN CELEBRAR c ON c.codigo = participar.codigo AND c.centro = participar.centro AND c.dia = participar.fecha
    JOIN CENTRO centro ON centro.codigo = c.centro
    JOIN PRUEBA prueba ON prueba.codigo = participar.codigo
    WHERE prueba.codigo = codigoprueba AND centro.codigo = codigocentro AND participar.fecha = diaprueba;

    IF checkprueba IS NULL AND checkcentro IS NULL AND checkfecha IS NULL THEN
       RAISE_APPLICATION_ERROR(-20004, 'No existe la prueba en el centro en el dia indicado'); 
    ELSIF checkprueba IS NULL AND checkcentro IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'No existe la prueba ni el centro');
    ELSIF checkprueba IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'No existe la prueba');
    ELSIF checkcentro IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003, 'No existe el centro');
    END IF;

    DBMS_OUTPUT.PUT_LINE('PRUEBA: ' || nombreprueba);
    DBMS_OUTPUT.PUT_LINE('CENTRO: ' || nombrecentro);
    DBMS_OUTPUT.PUT_LINE('DIA: ' || fechaprueba);
    DBMS_OUTPUT.PUT_LINE('PARTICIPANTES');
    DBMS_OUTPUT.PUT_LINE('------------------------------');

    FOR participantes IN (
        SELECT dep.apellido1, dep.nombre, participar.posicion, c.precio
        FROM PARTICIPAR participar
        JOIN CELEBRAR c ON c.codigo = participar.codigo AND c.centro = participar.centro AND c.dia = participar.fecha
        JOIN CENTRO centro ON centro.codigo = c.centro
        JOIN PRUEBA prueba ON prueba.codigo = participar.codigo
        JOIN DEPORTISTA dep ON dep.dni = participar.dni
        WHERE prueba.codigo = codigoprueba AND centro.codigo = codigocentro AND participar.fecha = diaprueba
    )LOOP
       DBMS_OUTPUT.PUT_LINE(participantes.apellido1 || ' ' || participantes.nombre || ' ' || participantes.posicion);
       total := total + participantes.precio; 
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total importe inscripciones: ' || total);

END;
/
-- solucion de chagpt:

CREATE OR REPLACE PROCEDURE INSVRITOS_PRUEBACENTRO (
    codigoprueba VARCHAR2,
    codigocentro VARCHAR2,
    diaprueba DATE
) AS
    nombreprueba   VARCHAR2(50);
    nombrecentro   VARCHAR2(50);
    fechaprueba    DATE;
    total          NUMBER := 0;

    v_existe_prueba   NUMBER := 0;
    v_existe_centro   NUMBER := 0;
    v_existe_celebrar NUMBER := 0;
BEGIN
    -- Comprobaciones por separado
    SELECT COUNT(*) INTO v_existe_prueba FROM PRUEBA WHERE codigo = codigoprueba;
    SELECT COUNT(*) INTO v_existe_centro FROM CENTRO WHERE codigo = codigocentro;
    SELECT COUNT(*) INTO v_existe_celebrar
    FROM CELEBRAR
    WHERE codigo = codigoprueba AND centro = codigocentro AND dia = diaprueba;

    -- IFs con lógica clara
    IF v_existe_celebrar > 0 THEN
        -- Recuperar nombres reales para mostrar
        SELECT DISTINCT p.nombre, c.nombre, cel.dia
        INTO nombreprueba, nombrecentro, fechaprueba
        FROM CELEBRAR cel
        JOIN PRUEBA p ON p.codigo = cel.codigo
        JOIN CENTRO c ON c.codigo = cel.centro
        WHERE cel.codigo = codigoprueba AND cel.centro = codigocentro AND cel.dia = diaprueba;

        DBMS_OUTPUT.PUT_LINE('PRUEBA: ' || nombreprueba);
        DBMS_OUTPUT.PUT_LINE('CENTRO: ' || nombrecentro);
        DBMS_OUTPUT.PUT_LINE('DIA: ' || fechaprueba);
        DBMS_OUTPUT.PUT_LINE('PARTICIPANTES');
        DBMS_OUTPUT.PUT_LINE('------------------------------');

        FOR participantes IN (
            SELECT dep.apellido1, dep.nombre, par.posicion, cel.precio
            FROM PARTICIPAR par
            JOIN CELEBRAR cel ON cel.codigo = par.codigo AND cel.centro = par.centro AND cel.dia = par.fecha
            JOIN DEPORTISTA dep ON dep.dni = par.dni
            WHERE par.codigo = codigoprueba AND par.centro = codigocentro AND par.fecha = diaprueba
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(participantes.apellido1 || ' ' || participantes.nombre || ' ' || participantes.posicion);
            total := total + participantes.precio;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('Total importe inscripciones: ' || total);

    ELSIF v_existe_prueba = 0 AND v_existe_centro = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '❌ No existe ni la prueba ni el centro');
    ELSIF v_existe_prueba = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '❌ No existe la prueba');
    ELSIF v_existe_centro = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, '❌ No existe el centro');
    ELSE
        RAISE_APPLICATION_ERROR(-20004, '⚠️ Existen prueba y centro, pero no se celebra en esa fecha');
    END IF;
END;
/


SET SERVER OUTPUT ON;

-- TODO OK
BEGIN
    INSVRITOS_PRUEBACENTRO('P001', 'C001', TO_DATE('2024-05-01','YYYY-MM-DD'));
END;
/

-- ❌ No existe el centro.
BEGIN
    INSVRITOS_PRUEBACENTRO('P001', 'XXX', TO_DATE('2024-05-01','YYYY-MM-DD'));
END;
/

-- ❌ No existe la prueba.

BEGIN
    INSVRITOS_PRUEBACENTRO('ZZZ', 'C001', TO_DATE('2024-05-01','YYYY-MM-DD'));
END;
/

-- ❌ No existe ni la prueba ni el centro.

BEGIN
    INSVRITOS_PRUEBACENTRO('XXX', 'ZZZ', TO_DATE('2024-05-01','YYYY-MM-DD'));
END;
/

BEGIN
    INSVRITOS_PRUEBACENTRO('P001', 'C001', TO_DATE('2030-01-01','YYYY-MM-DD'));
END;
/
-- SOLO MAL FECHA

CREATE OR REPLACE TRIGGER trig_localidad
BEFORE INSERT ON PARTICIPAR
FOR EACH ROW
DECLARE
    localidaddni VARCHAR2(50);
    localidadcentro VARCHAR2(50);
BEGIN
    SELECT c.localidad
    INTO localidadcentro
    FROM Celebrar cel
    JOIN Centro c ON c.codigo = cel.centro
    WHERE cel.codigo = :NEW.codigo
      AND cel.centro = :NEW.centro
      AND cel.dia = :NEW.fecha;

    SELECT dep.localidad
    INTO localidaddni
    FROM DEPORTISTA dep
    WHERE dep.dni = :NEW.dni;

    IF localidadcentro = localidaddni THEN
        RAISE_APPLICATION_ERROR(-20005, 'La localidad del deportista ' || :NEW.dni || ' no puede coincidir con la localidad en la que se realza la prueba');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Se ha insertado con exito');
    END IF;
END;
/