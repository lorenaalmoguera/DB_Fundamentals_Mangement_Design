CONNECT SYSTEM/bdadmin;

CREATE USER PADEL IDENTIFIED BY padel;

GRANT CONNECT, RESOURCE, CREATE VIEW TO PADEL;

CONNECT PADEL/padel;

CREATE TABLE PISTA(
    codigo VARCHAR2(50),
    estado VARCHAR2(50),
    observaciones VARCHAR2(50),
    CONSTRAINT pis_cod_pk PRIMARY KEY(codigo),
    CONSTRAINT pis_est_ch CHECK(estado IN('bien','mal','decente'))
);

CREATE TABLE NIVEL(
    numero NUMBER,
    nombre VARCHAR2(50),
    descripcion VARCHAR2(50),
    CONSTRAINT niv_num_pk PRIMARY KEY(numero)
);

CREATE TABLE MONITOR(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    apellido2 VARCHAR2(50),
    telefono NUMBER(9),
    CONSTRAINT mon_dni_pk PRIMARY KEY(dni)
);

CREATE TABLE TIENDA(
    cif VARCHAR2(9),
    nombre VARCHAR2(50),
    email VARCHAR2(20),
    telefono NUMBER(9),
    CONSTRAINT tie_cif_pk PRIMARY KEY(cif)
);

CREATE TABLE ASIGNAR(
    dnimonitor VARCHAR2(9),
    ciftienda VARCHAR2(9),
    descuento NUMBER(2,2),
    CONSTRAINT asi_dni_cif_pk PRIMARY KEY(dnimonitor, ciftienda),
    CONSTRAINT asi_dni_mon_fk FOREIGN KEY(dnimonitor) REFERENCES MONITOR,
    CONSTRAINT asi_cif_tie_fk FOREIGN KEY(ciftienda) REFERENCES TIENDA
);

CREATE TABLE CURSO(
    numero NUMBER,
    nnivel NUMBER,
    pista VARCHAR2(50),
    dnimon VARCHAR2(9) CONSTRAINT cur_mon_nn NOT NULL,
    fechaini DATE,
    horario VARCHAR2(50),
    numhoras NUMBER(3,2),
    precio NUMBER(3,2),
    CONSTRAINT cur_num_nni_pk PRIMARY KEY(numero, nnivel),
    CONSTRAINT cur_nni_niv_fk FOREIGN KEY(nnivel) REFERENCES NIVEL,
    CONSTRAINT cur_dni_mon_fk FOREIGN KEY(dnimon) REFERENCES MONITOR
);

CREATE TABLE ALUMNO(
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellido1 VARCHAR2(50),
    apellido2 VARCHAR2(50),
    telefono NUMBER(9),
    email VARCHAR2(50),
    sexo VARCHAR2(2),
    CONSTRAINT alu_dni_pk PRIMARY KEY(dni),
    CONSTRAINT alu_sex_ch CHECK (sexo IN('M','F','NB'))
);

CREATE TABLE COMPRAR(
    dalu VARCHAR2(9),
    cif VARCHAR2(9),
    dmon VARCHAR2(9),
    fecha DATE,
    importeinicial NUMBER(3,2),
    importefinal NUMBER (3,2),
    CONSTRAINT com_dal_cif_dmo_fec_pk PRIMARY KEY(dalu,cif,dmon,fecha),
    CONSTRAINT com_dal_alu_fk FOREIGN KEY(dalu) REFERENCES ALUMNO,
    CONSTRAINT com_cif_dmo_asi_fk FOREIGN KEY(cif, dmon) REFERENCES ASIGNAR(ciftienda, dnimonitor),
    CONSTRAINT com_iin_ifi_ch CHECK (importeinicial >= importefinal)
);

CREATE TABLE TORNEO(
    codigo VARCHAR2(50),
    nombre VARCHAR2(50),
    fechainicio DATE,
    descripcion VARCHAR2(50),
    CONSTRAINT tor_cod_pk PRIMARY KEY(codigo)
);

CREATE TABLE PATROCINADOR(
    cif VARCHAR2(9),
    nombre VARCHAR2(50),
    email VARCHAR2(50),
    telefono VARCHAR2(50),
    CONSTRAINT pat_cif_pk PRIMARY KEY(cif)
);

CREATE TABLE FINANCIAR(
    torneo VARCHAR2(50),
    patrocinador VARCHAR2(9),
    importe NUMBER(3,2),
    CONSTRAINT fin_tor_pat_pk PRIMARY KEY(torneo, patrocinador),
    CONSTRAINT fin_tor_tor_fk FOREIGN KEY(torneo) REFERENCES TORNEO,
    CONSTRAINT fin_pat_pat_fk FOREIGN KEY(patrocinador) REFERENCES PATROCINADOR
);

CREATE TABLE PARTICIPAR(
    alu1 VARCHAR2(9),
    alu2 VARCHAR2(9),
    codigo VARCHAR2(50),
    posicion NUMBER(3),
    CONSTRAINT par_al1_cod_pk PRIMARY KEY(alu1, codigo),
    CONSTRAINT par_al2_cod_uq UNIQUE(alu2, codigo),
    CONSTRAINT par_al1_alu_fk FOREIGN KEY(alu1) REFERENCES ALUMNO,
    CONSTRAINT par_al2_alu_fk FOREIGN KEY(alu2) REFERENCES ALUMNO,
    CONSTRAINT par_cod_tor_fk FOREIGN KEY(codigo) REFERENCES TORNEO 
);

CREATE OR REPLACE PROCEDURE QUIEN_PARTICPA (codigotorneo VARCHAR2) AS
    alumno1 VARCHAR2(50);
    alumno2 VARCHAR2(50);
    mitorneo VARCHAR2(50);
    numpareja NUMBER := 0;
BEGIN
    SELECT DISTINCT t.nombre
    INTO  mitorneo
    FROM PARTICIPAR p
    JOIN TORNEO t ON t.codigo = p.codigo
    WHERE p.codigo = codigotorneo;

    DBMS_OUTPUT.PUT_LINE('Participan en el torneo ' || mitorneo || ' son: ');

    FOR participantes IN (
        SELECT alu1.nombre AS alumno1, alu2.nombre AS alumno2
        FROM PARTICIPAR p
        JOIN ALUMNO alu1 ON alu1.dni = p.alu1
        JOIN ALUMNO alu2 ON alu2.dni = p.alu2
        WHERE p.codigo = codigotorneo
    ) LOOP
        numpareja := numpareja + 1;
        DBMS_OUTPUT.PUT_LINE('PAREJA ' || numpareja || ' ESTÁ FORMADA POR: ' || participantes.alumno1 || ' y ' || participantes.alumno2 || '.');
        
    
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('EXISTEN UN TOTAL DE ' || numpareja || ' PAREJAS');

    IF numpareja = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'NO EXISTEN PARTICIPANTES');
    END IF;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO EXITE ESE TORNEO');
END;
/