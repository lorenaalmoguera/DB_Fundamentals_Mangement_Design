CONNECT SYSTEM/bdadmin;

CREATE USER EXAMENB_ALMOGUERALORENA1516 IDENTIFIED BY EXAMENB_ALMOGUERALORENA1516;

GRANT CONNECT, RESOURCE TO EXAMENB_ALMOGUERALORENA1516;

CONNECT EXAMENB_ALMOGUERALORENA1516/EXAMENB_ALMOGUERALORENA1516;

CREATE TABLE LIBRO (
    codigo VARCHAR2(50),
    titulo VARCHAR2(50),
    precio NUMBER(5,2),
    nejemplares NUMBER,
    anopublicacion NUMBER(4),
    CONSTRAINT lib_cod_pk PRIMARY KEY (codigo),
    CONSTRAINT lib_pre_ch CHECK(precio > 0)
);

CREATE TABLE TEMA (
    codigo VARCHAR2(50),
    nombre VARCHAR2(50),
    CONSTRAINT tem_cod_pk PRIMARY KEY (codigo)
);

CREATE TABLE TRATAR (
    codigolibro VARCHAR2(50),
    codigotema VARCHAR2(50),
    CONSTRAINT tra_codigol_codigot_pk PRIMARY KEY(codigolibro, codigotema),
    CONSTRAINT tra_codgol_lib_fk FOREIGN KEY(codigolibro) REFERENCES LIBRO,
    CONSTRAINT tra_codigo2_tem_fk FOREIGN KEY (codigotema) REFERENCES TEMA  
);

-- INSERT LIBRO

INSERT INTO LIBRO VALUES ('L001', 'El Quijote', 19.99, 50, 2004);
INSERT INTO LIBRO VALUES ('L002', 'Cien Años de Soledad', 24.50, 35, 2006);
INSERT INTO LIBRO VALUES ('L003', 'La Sombra del Viento', 18.75, 40, 2001);
INSERT INTO LIBRO VALUES ('L004', '1984', 15.20, 20, 1949);
INSERT INTO LIBRO VALUES ('L005', 'Sapiens', 22.95, 60, 2011);
INSERT INTO LIBRO VALUES ('L006', 'El Principito', 10.50, 0, 1943);
INSERT INTO LIBRO VALUES ('L007', 'Rayuela', 17.95, 0, 1963);
INSERT INTO LIBRO VALUES ('L008', 'Fahrenheit 451', 14.40, 0, 1953);


-- INSERT TEMA

INSERT INTO TEMA VALUES ('T001', 'Literatura Clásica');
INSERT INTO TEMA VALUES ('T002', 'Realismo Mágico');
INSERT INTO TEMA VALUES ('T003', 'Historia');
INSERT INTO TEMA VALUES ('T004', 'Ciencia Ficción');
INSERT INTO TEMA VALUES ('T005', 'Ensayo');

-- INSERT TRATAR

INSERT INTO TRATAR VALUES ('L001', 'T001');
INSERT INTO TRATAR VALUES ('L002', 'T002'); 
INSERT INTO TRATAR VALUES ('L003', 'T001'); 
INSERT INTO TRATAR VALUES ('L004', 'T004'); 
INSERT INTO TRATAR VALUES ('L005', 'T003'); 
INSERT INTO TRATAR VALUES ('L005', 'T005'); 


CONNECT SYSTEM/bdadmin;

GRANT CREATE VIEW TO EXAMENB_ALMOGUERALORENA1516;

CREATE USER ALEJANDRO IDENTIFIED BY ALEJANDRO;

GRANT CREATE SESSION TO ALEJANDRO;

CONNECT EXAMENB_ALMOGUERALORENA1516/EXAMENB_ALMOGUERALORENA1516;

CREATE OR REPLACE VIEW vista_ej_nodisp AS
SELECT codigo, titulo, precio, nejemplares, anopublicacion
FROM LIBRO
WHERE nejemplares = 0;

CONNECT SYSTEM/bdadmin;

GRANT SELECT, UPDATE ON EXAMENB_ALMOGUERALORENA1516.vista_ej_nodisp TO ALEJANDRO;

CONNECT ALEJANDRO/ALEJANDRO;

SELECT * 
FROM EXAMENB_ALMOGUERALORENA1516.vista_ej_nodisp;

UPDATE EXAMENB_ALMOGUERALORENA1516.vista_ej_nodisp
SET precio = 69, titulo = 'Yolanda', nejemplares = 10
WHERE codigo ='L008';
