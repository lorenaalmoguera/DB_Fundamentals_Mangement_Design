/*

    1.- MONTAR LA BASE DE DATOS ... 3 PUNTOS.

*/

CREATE TABLE ABOGADO(
    dni VARCHAR2(9),
    nombre VARCHAR2(20),
    apellido1 VARCHAR2(20),
    ncolegiado VARCHAR2(20),
    CONSTRAINT abo_dni_pk PRIMARY KEY (dni),
    CONSTRAINT abo_nco_uq  UNIQUE (ncolegiado)
);

CREATE TABLE MENOR(
    dni VARCHAR2(9),
    nombre VARCHAR2(20),
    apellido1 VARCHAR2(20),
    fechanac DATE,
    CONSTRAINT men_dni_pk PRIMARY KEY(dni)
);

CREATE TABLE EXPEDIENTE(
    numero NUMBER(5),
    dnimenor VARCHAR2(9),
    delito VARCHAR2(20) NOT NULL,
    fechaapertura DATE DEFAULT SYSDATE,
    sentencia VARCHAR2(1),
    dniabogado VARCHAR(9) NOT NULL,
    CONSTRAINT exp_num_dni_pk PRIMARY KEY(numero, dnimenor),
    CONSTRAINT exp_men_fk FOREIGN KEY(dnimenor) REFERENCES MENOR,
    CONSTRAINT exp_abo_fk FOREIGN KEY(dniabogado) REFERENCES ABOGADO,
    CONSTRAINT exp_dab_nn CHECK (dniabogado IS NOT NULL),
    CONSTRAINT exp_sen_chk CHECK (sentencia IN ('C', 'I') OR sentencia IS NULL)
);


/*


    2.- - Instrucción que muestre por pantalla el número de restricciones que contiene la base de datos según el
          tipo de restricción: claves principales, ajenas,…

*/


SELECT 
    constraint_type AS tipo_restriccion,
    COUNT(*) AS numero
FROM user_constraints
GROUP BY constraint_type;




/*

3.- Crea un procedimiento llamado LISTADO_EXPEDIENTES que reciba como argumento el dni de un menor
e imprima los expedientes del menor ordenados por la fecha de apertura del expediente. Al final del listado
se imprimirá el número total de expedientes del menor. El formato de salida del procedimiento es:

*/

CREATE OR REPLACE PROCEDURE LISTADO_EXPEDIENTES (dnimenor_input IN VARCHAR2) AS
   nombremenor VARCHAR2(50);
   apellidomenor VARCHAR2(50);
   totalexpedientes NUMBER;
BEGIN
   SELECT nombre, apellido1 INTO nombremenor, apellidomenor
   FROM MENOR
   WHERE dni = UPPER(dnimenor_input);

   DBMS_OUTPUT.PUT_LINE('Menor: ' || dnimenor_input || ' ' || nombremenor || ' ' || apellidomenor);
   DBMS_OUTPUT.PUT_LINE('----------------------------------------------');

   FOR expediente IN (
       SELECT fechaapertura, numero, delito, sentencia, nombre, apellido1
       FROM EXPEDIENTE
       JOIN ABOGADO ON EXPEDIENTE.dniabogado = ABOGADO.dni
       WHERE EXPEDIENTE.dnimenor = UPPER(dnimenor_input)
       ORDER BY fechaapertura
   ) LOOP
       DBMS_OUTPUT.PUT_LINE(expediente.fechaapertura || ' ' || expediente.numero || ' ' || expediente.delito || ' ' ||
                            expediente.sentencia || ' ' || expediente.nombre || ' ' || expediente.apellido1);
   END LOOP;

   SELECT COUNT(*) INTO totalexpedientes
   FROM EXPEDIENTE
   WHERE dnimenor = UPPER(dnimenor_input);

   DBMS_OUTPUT.PUT_LINE('Total expedientes: ' || totalexpedientes);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       DBMS_OUTPUT.PUT_LINE('El menor ' || dnimenor_input || ' no se encuentra en la base de datos.');
END;
/


SET SERVEROUTPUT ON;

BEGIN
    LISTADO_EXPEDIENTES('48796558B'); -- Reemplaza con el DNI del menor que quieras probar
END;
/

INSERT INTO EXPEDIENTE(numero, dnimenor, delito, fechaapertura, sentencia, dniabogado) VALUES ('1', '48796558B', 'Ser maravillosa', '16/01/2025', 'C', '12345678N');

/* 4.- Crea un disparador llamado COMPROBAR_EDAD que no permita dar de alta a menores que han cumplido
los 18 años. En dicho caso se emitirá el mensaje: No se pueda dar de alta al menor porque tiene XX años,
donde XX es la edad del menor y no se dará de alta al menor.
*/

CREATE OR REPLACE TRIGGER COMPROBAR_EDAD
BEFORE INSERT ON MENOR
FOR EACH ROW
DECLARE
    edad NUMBER;
BEGIN
    -- Calcular la edad del menor
    SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, :NEW.fechanac) / 12) INTO edad FROM DUAL;

    -- Comprobar si la edad es mayor o igual a 18 años
    IF edad >= 18 THEN
        -- Generar un error con un mensaje personalizado
        RAISE_APPLICATION_ERROR(-20001, 'No se puede dar de alta al menor porque tiene ' || edad || ' años.');
    END IF;
END;
/


/*5.- Crea un usuario llamado admin con contraseña tutelar. Este usuario solamente podrá consultar y
actualizar los expedientes cuya sentencia sea inocente y en concreto los valores correspondientes al número
de expediente, DNI del menor, delito y fecha de apertura. Realiza una consulta y una actualización desde el
usuario admin. Introduce en el fichero todas las instrucciones necesarias para realizar el ejercicio, la
explicación entre comentarios de los pasos que llevas a cabo. El usuario no tendrá más permisos que los
necesarios para realizar el ejercicio.*/

-- Paso 1: Crear el usuario admin
CREATE USER admin IDENTIFIED BY tutelar;
GRANT CONNECT TO admin;

-- Paso 2: Crear la vista para limitar SELECT a expedientes inocentes
CREATE VIEW expediente_inocentes AS
SELECT numero, dnimenor, delito, fechaapertura
FROM EXPEDIENTE
WHERE sentencia = 'I';

-- Conceder permisos SELECT al usuario admin sobre la vista
GRANT SELECT ON expediente_inocentes TO admin;

-- Paso 3: Crear un disparador para restringir actualizaciones a expedientes inocentes
CREATE TRIGGER admin_update_restriction
BEFORE UPDATE ON EXPEDIENTE
FOR EACH ROW
WHEN (NEW.sentencia != 'I')
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'Solo se pueden actualizar expedientes con sentencia inocente.');
END;
/

-- Conceder permisos de UPDATE en los campos permitidos de la vista
GRANT UPDATE (numero, dnimenor, delito, fechaapertura) ON expediente_inocentes TO admin;

-- Conectarse como admin
CONNECT admin/tutelar;

-- Paso 4: Realizar una consulta desde el usuario admin
SELECT * FROM expediente_inocentes;

-- Paso 5: Realizar una actualización desde el usuario admin
UPDATE expediente_inocentes
SET delito = 'Nuevo Delito'
WHERE numero = 1;


INSERT INTO MENOR (DNI, NOMBRE, APELLIDO1, FECHANAC) VALUES ('33333333N', 'ADRIAN', 'AAA', '20/12/2009');
