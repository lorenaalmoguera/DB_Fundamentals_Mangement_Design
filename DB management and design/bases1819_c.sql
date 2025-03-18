CONNECT system/bdadmin;

CREATE USER bases1819_c IDENTIFIED BY bases1819_c;

GRANT CONNECT, RESOURCE TO bases1819_c;

CONNECT bases1819_c/bases1819_c;

/*1.- Crea un usuario llamado puntuable2 y contraseña examen y conéctate desde este usuario. Crea
las tablas según el diseño lógico que se indica (nombres de tablas, campos, claves,…). Todos los
campos tienen como tipo de datos VARCHAR2(10), excepto los campos que se indique un tipo de
datos particular. Las claves ajenas se crean con la opción por defecto.*/

-- Crear la tabla B
CREATE TABLE B (
    b1 VARCHAR2(10),
    b2 DATE,
    b3 VARCHAR2(10),
    CONSTRAINT b_b_pk PRIMARY KEY (b1, b2)
);

-- Crear la tabla D
CREATE TABLE D (
    d1 VARCHAR2(10),
    d2 VARCHAR2(10) CONSTRAINT d_d2_uq UNIQUE,
    d3 DATE,
    CONSTRAINT d_d1_pk PRIMARY KEY (d1),
    CONSTRAINT d_b_fk FOREIGN KEY (d2, d3) REFERENCES B (b1, b2) ON DELETE CASCADE
);

-- Agregar índice único compuesto en D
ALTER TABLE D ADD CONSTRAINT d_d1d2_uq UNIQUE (d1, d2);

-- Crear la tabla C
CREATE TABLE C (
    c1 VARCHAR2(10),
    c2 VARCHAR2(1) DEFAULT 'N',
    c3 VARCHAR2(10),
    c4 VARCHAR2(10),
    CONSTRAINT c_c1_pk PRIMARY KEY (c1)
);

-- Crear la tabla A
CREATE TABLE A (
    a1 VARCHAR2(10),
    a2 VARCHAR2(10) CONSTRAINT a_a2_nn NOT NULL,
    a3 VARCHAR2(10) CONSTRAINT a_a3_nn NOT NULL,
    CONSTRAINT a_a1a2_pk PRIMARY KEY (a1, a3),
    CONSTRAINT a_d_fk FOREIGN KEY (a1, a2) REFERENCES D (d1, d2),
    CONSTRAINT a_c_fk FOREIGN KEY (a3) REFERENCES B (b1),
    CONSTRAINT a_a2_uq UNIQUE (a2)
);


ALTER TABLE B ADD CONSTRAINT b_b1_uq UNIQUE (b1);



/*2.- Deshabilita temporalmente la clave ajena a3  C y comprueba que se encuentra deshabilitada
consultando la información en la tabla del sistema adecuada. Muestra solamente los campos
necesarios para saber si está habilitada o no esta restricción. Vuelve a habilitar la restricción.*/

ALTER TABLE A DISABLE CONSTRAINT a_c_fk;

SELECT CONSTRAINT_NAME, STATUS
FROM user_constraints
WHERE TABLE_NAME = 'A' AND CONSTRAINT_NAME = 'a_c_fk';

/*3.- El campo c4 solamente debe admitir números comprendidos entre 1 y 10. Modifica la base de
datos sin eliminar ninguna tabla para incluir esta restricción. Asigna nombre a la restricción
siguiendo la nomenclatura. */

ALTER TABLE C ADD CONSTRAINT c_c4_chk CHECK(c4 < 11 AND c4 > 0);

/*4.- Instrucción que obtenga exclusivamente el nombre de los campos que forman la clave principal
de la tabla A y en qué orden están incluidos en la clave principal. Para realizar este apartado no
puedes utilizar en la instrucción como dato el nombre de la restricción que es clave principal en A,
sino que hay que obtenerlo.*/

SELECT column_name, position
FROM user_cons_columns
WHERE constraint_name = (
    SELECT constraint_name
    FROM user_constraints
    WHERE table_name = 'A' AND constraint_type = 'P'
)
ORDER BY position;

/*5.- Realiza las siguientes acciones:
5.1.- Inserta tres registros en la tabla B y seis registros en D de forma que haya un registro en D
que no haga referencia a ningún registro de B y haya tres registros de D que tengan en el campo
d3 el valor de la fecha de hoy. Muestra todos los datos de las dos tablas.
5.2.- Actualiza los registros de D para que aquellos que tienen la fecha de hoy no tengan asignado
ningún valor en el campo d3 y vuelve a mostrar todos los registros de la tabla D.
5.3.- Elimina los registros de D que no tengan asignado ningún valor en el campo d3.
*/


/*5.1-*/
INSERT INTO B (B1,B2,B3) VALUES ('HOLA', '17/01/2025', 'A_UNO');
INSERT INTO B (B1,B2,B3) VALUES ('ADIOS', '17/01/2025', 'A_DOS');
INSERT INTO B (B1,B2,B3) VALUES ('BUENAS', '17/01/2025', 'A_TRES');
INSERT INTO D (D1,D2,D3) VALUES ('HOLA', '17/01/2025', 'E_UNO');
INSERT INTO B (b1, b2, b3) VALUES ('E_UNO', TO_DATE('17/01/2025', 'DD/MM/YYYY'), 'SomeValue');
INSERT INTO D (d1, d2, d3) 
VALUES ('HOLA', 'E_UNO', TO_DATE('17/01/2025', 'DD/MM/YYYY'));

INSERT INTO D (D1,D2,D3) VALUES ('ADIOS', 'HOLA', TO_DATE('17/01/2025', 'DD/MM/YYYY'));
INSERT INTO D (D1,D2,D3) VALUES ('BUENAS','ADIOS', TO_DATE('17/01/2025','DD/MM/YYYY'));
INSERT INTO D (D1,D2,D3) VALUES ('AAAAA','BUENAS', TO_DATE('17/01/2025', 'DD/MM/YYYY'));

INSERT INTO B (B1, B2, B3) VALUES ('EXTRA1', TO_DATE('18/01/2025', 'DD/MM/YYYY'), 'EXTRA_V1');
INSERT INTO B (B1, B2, B3) VALUES ('EXTRA2', TO_DATE('19/01/2025', 'DD/MM/YYYY'), 'EXTRA_V2');
INSERT INTO B (B1, B2, B3) VALUES ('EXTRA3', TO_DATE('20/01/2025', 'DD/MM/YYYY'), 'EXTRA_V3');

INSERT INTO D (D1, D2, D3) VALUES ('D_EXTRA1', 'EXTRA1', TO_DATE('18/01/2025', 'DD/MM/YYYY'));
INSERT INTO D (D1, D2, D3) VALUES ('D_EXTRA2', 'EXTRA2', TO_DATE('19/01/2025', 'DD/MM/YYYY'));
INSERT INTO D (D1, D2, D3) VALUES ('D_EXTRA3', 'EXTRA3', TO_DATE('20/01/2025', 'DD/MM/YYYY'));


SELECT * FROM A;
SELECT * FROM B;
SELECT * FROM C;
SELECT * FROM D;

/*5.2-*/
UPDATE D
SET D3 = NULL
WHERE TRUNC(D3) = TRUNC(SYSDATE);

SELECT * FROM D;

/*5.3-*/
DELETE FROM D
WHERE D3 IS NULL;

SELECT * FROM D;