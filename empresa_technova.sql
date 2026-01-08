-- ==============================================
-- 01 PROYECTO SQL - GESTIÓN DE BASE DE DATOS EMPRESARIAL
-- ==============================================


/* ============================================================
   1) DDL - DEFINICIÓN DE DATOS
   ============================================================ */

/* Crear una base de datos llamada "empresa_technova" */
CREATE DATABASE IF NOT EXISTS empresa_technova;
USE empresa_technova;

/* Crear una tabla de "empleados" con los campos "id", "nombre", "edad" y "salario" */
CREATE TABLE empleados (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50),
  edad INT,
  salario DECIMAL(10,2)
);



/* Añadir una nueva columna "direccion" a la tabla "empleados" */
ALTER TABLE empleados ADD COLUMN direccion VARCHAR(100);



/* Crear una tabla de "departamentos" con los campos "id_dep", "nombre" y "id_empleado" */
CREATE TABLE departamentos (
  id_dep INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50),
  id_empleado INT,
  FOREIGN KEY (id_empleado) REFERENCES empleados(id) ON DELETE CASCADE
);






/* ============================================================
   2) DML - MANIPULACIÓN DE DATOS
   ============================================================ */

/* Insertar tres empleados y dos departamentos */
INSERT INTO empleados (nombre, edad, salario, direccion) VALUES
 ('Patricia',36, 1490, 'Calle Gran Canaria 32'),
 ('Marta',29, 1670, 'Calle Tenerife 67'),
 ('Geetika',57, 1900, 'Calle La Gomera 4');


INSERT INTO departamentos (nombre, id_empleado) VALUES
 ('Recursos Humanos', 3),
 ('Marketing', 2),
 ('Ventas', 1);



/* Modifica el salario de un empleado */
UPDATE empleados
SET salario = 2500
WHERE id = 2;



/* Elimina a los empleados con salario menor a 1500 */
DELETE FROM empleados
WHERE salario < 1500;






/* ============================================================
   3) DQL - CONSULTA DE DATOS
   ============================================================ */

/* Muestra a todos los empleados */
SELECT * FROM empleados;



/* Muestra el nombre y salario de los empleados mayores de 30 años, ordenados por salario descendente */
SELECT nombre, salario FROM empleados
WHERE edad > 30
ORDER BY salario DESC;



/* Muestra el número de empleados agrupados por edad */
SELECT edad, COUNT(*) AS Cantidad_de_empleados
FROM empleados
GROUP BY edad;



/* Muestra la edad y el salario medio de los empleados, filtrando por salario medio mayor a 1800 */
SELECT edad, AVG(salario) AS Salario_medio
FROM empleados
GROUP BY edad
HAVING AVG(salario) > 1800;



/* Muestra el nombre del empleado junto con el nombre de su departamento */
SELECT e.nombre, d.nombre AS Departamento
FROM empleados e
JOIN departamentos d ON e.id = d.id_empleado;






/* ============================================================
   4) DCL - CONTROL DE ACCESO (BÁSICO)
   ============================================================ */

/* Crear un usuario llamado "usuario1" (ajusta la contraseña en producción) */
CREATE USER IF NOT EXISTS 'usuario1'@'%' IDENTIFIED BY '12345';



/* Concede al "usuario1" los permisos de SELECT e INSERT sobre la tabla "empleados" */
GRANT SELECT, INSERT ON empleados TO 'usuario1'@'%'; 



/* Revoca el permiso de INSERT del "usuario1", manteniendo el de SELECT */
REVOKE INSERT ON empleados FROM 'usuario1'@'%';






/* ============================================================
   5) TCL - CONTROL DE TRANSACCIONES
   ============================================================ */

/* Inicia una transacción*/
START TRANSACTION;



/* Inserta un nuevo empleado */
INSERT INTO empleados (nombre, edad, salario, direccion) VALUES
 ('Xavier', 32, 1550, 'Calle La Palma 81');



/* Crea un "SAVEPOINT" */
SAVEPOINT punto1;



/* Actualiza el salario de este nuevo empleado */
UPDATE empleados
SET salario = 15500
WHERE id = 4;



/* Revierte los cambios hasta el "SAVEPOINT" */
ROLLBACK TO SAVEPOINT punto1;



/* Confirma los cambios finales de la transacción */
COMMIT;






/* ============================================================
   6) VISTAS - VIEWS
   ============================================================ */

/* Crear una vista llamada "vista_empleados_activos" que muestre "id", "nombre", "edad", "salario" y "nombre del departamente". Además, debe excluir a los empleados con salario menor a 1500 */
CREATE VIEW vista_empleados_activos AS
SELECT e.id, e.nombre, e.edad, e.salario, d.nombre AS Departamento
FROM empleados e
JOIN departamentos d ON e.id = d.id_empleado
WHERE e.salario >= 1500;



/* Crear una vista llamada "vista_resumen_salarios" que muestre "edad", "total_empleados" y "salario_medio" */
CREATE VIEW vista_resumen_salarios AS
SELECT edad, COUNT(*) AS Total_empleados, AVG(salario) AS Salario_medio
FROM empleados
GROUP BY edad;



/* Realiza consultas sobre estas vistas creadas anteriormente */

/* Consulta 1 - Muestra todos los empleados activos, ordenados por salario descendente */
SELECT * FROM vista_empleados_activos
ORDER BY salario DESC;


/* Consulta 2 - Muestra la edad y el salario medio de los empleados con salario medio mayor a 2000 */
SELECT edad, Salario_medio FROM vista_resumen_salarios
WHERE Salario_medio > 2000;






/* ============================================================
   7) DCL - ROLES Y PERMISOS (AVANZADO)
   ============================================================ */

/* Crear dos roles: "rol_consulta" y "rol_editor_empleados" */
CREATE ROLE IF NOT EXISTS rol_consulta;


CREATE ROLE IF NOT EXISTS rol_editor_empleados;



/* Asignar permisos a los roles creados */

/* Permisos para "rol_consulta" - SELECT */
GRANT SELECT ON vista_empleados_activos TO rol_consulta;

GRANT SELECT ON vista_resumen_salarios TO rol_consulta;

GRANT SELECT ON empleados TO rol_consulta;

GRANT SELECT ON departamentos TO rol_consulta;

/* También se podría usar: GRANT SELECT ON empresa_technova.* TO rol_consulta; */


/* Permisos para "rol_editor_empleados" - SELECT, INSERT, UPDATE */
GRANT SELECT, INSERT, UPDATE ON empleados TO rol_editor_empleados;



/* Asigna el rol "rol_consulta" al "usuario1" */
GRANT rol_consulta TO 'usuario1'@'%';  


/* Crea un nuevo usuario "usuario2" y asigna el rol "rol_editor_empleados" (ajusta la contraseña) */
CREATE USER IF NOT EXISTS 'usuario2'@'%' IDENTIFIED BY '12345';

GRANT rol_editor_empleados TO 'usuario2'@'%';



/* Muestra los permisos asignados a ambos usuarios */
SHOW GRANTS FOR 'usuario1'@'%';

SHOW GRANTS FOR 'usuario2'@'%'; 



/* Revoca los roles asignados a ambos usuarios */
REVOKE rol_editor_empleados FROM 'usuario2'@'%';

REVOKE rol_consulta FROM 'usuario1'@'%';



/* Revoca de los roles, cualquier permisos asignado sobre las vistas y tablas */
REVOKE SELECT, INSERT, UPDATE ON empleados FROM rol_editor_empleados;

REVOKE SELECT ON vista_empleados_activos FROM rol_consulta;

REVOKE SELECT ON vista_resumen_salarios FROM rol_consulta;

REVOKE SELECT ON empleados FROM rol_consulta;

REVOKE SELECT ON departamentos FROM rol_consulta;

/* También se podría usar: REVOKE SELECT ON empresa_technova.* FROM rol_consulta; */


/* Elimina los roles creados */
DROP ROLE rol_consulta;

DROP ROLE rol_editor_empleados;






/* ============================================================
   8) TRIGGERS
   ============================================================ */

/* Crear una tabla "empleados_salario_log" con los campos: "id_log", "id_empleado", "salario_anterior", "salario_nuevo", "fecha_cambio" y "usuario_bd" */
CREATE TABLE empleados_salario_log (
  id_log INT PRIMARY KEY AUTO_INCREMENT,
  id_empleado INT,
  salario_anterior DECIMAL(10,2),
  salario_nuevo DECIMAL(10,2),
  fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  usuario_bd VARCHAR(50)
);



/* Crear un "TRIGGER AFTER UPDATE" sobre la tabla "empleados" e insertar un registro en empleados_salario_log con id_empleado, salario_anterior, salario_nuevo, fecha_cambio y usuario_bd */
DELIMITER //
CREATE TRIGGER tr_auditoria_salario
AFTER UPDATE ON empleados
FOR EACH ROW
BEGIN
  IF OLD.salario <> NEW.salario THEN
  INSERT INTO empleados_salario_log (id_empleado, salario_anterior, salario_nuevo, fecha_cambio, usuario_bd)
    VALUES (OLD.id, OLD.salario, NEW.salario, CURRENT_TIMESTAMP(), USER());
  END IF;
END;
//
DELIMITER ;



/*Realizar un UPDATE de salario sobre algún empleado y verificar que el trigger ha insertado el registro en la tabla de log */
UPDATE empleados 
SET salario = 2500 
WHERE id = 2;



/* Crear un "TRIGGER BEFORE INSERT" sobre la tabla "empleados" */

/* Verificar que el salario del nuevo empleado sea como mínimo 1000. Si no se cumple, lanzar un error que impida la inserción */
DELIMITER //
CREATE TRIGGER tr_salario_minimo
BEFORE INSERT ON empleados
FOR EACH ROW
BEGIN
  IF NEW.salario < 1000 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'No se permite insertar empleados con salario menor a 1000.';
  END IF;
END;
//
DELIMITER ;


/* Otra forma sería:
DELIMITER //
CREATE TRIGGER tr_salario_minimo
BEFORE INSERT ON empleados
FOR EACH ROW
BEGIN
  IF NEW.salario < 1000 THEN
    SET NEW.salario = 1000;
  END IF;
END;
//
DELIMITER ;
*/



/* Prueba el trigger intentando insertar un empleado con salario de 800 (debe fallar por validación) */
INSERT INTO empleados (nombre, edad, salario) VALUES ('Juan', 30, 800);



/* Crear la tabla para empleados borrados y un trigger BEFORE DELETE que copie los datos */
CREATE TABLE IF NOT EXISTS empleados_borrados (
  id_borrado INT PRIMARY KEY AUTO_INCREMENT,
  id_empleado INT,
  nombre VARCHAR(100),
  edad INT,
  salario DECIMAL(10,2),
  fecha_borrado TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER tr_empleado_eliminado
BEFORE DELETE ON empleados
FOR EACH ROW
BEGIN
  INSERT INTO empleados_borrados (id_empleado, nombre, edad, salario, fecha_borrado)
    VALUES (OLD.id, OLD.nombre, OLD.edad, OLD.salario, CURRENT_TIMESTAMP());
END;
//
DELIMITER ;



/* Eliminar un empleado y comprobar qué aparece en "empleados_borrados" */
DELETE FROM empleados WHERE id = 3;

SELECT * FROM empleados_borrados;




/* ============================================================
   9) ÍNDICES
   ============================================================ */

/* Crear un índice llamado "idx_empleados_edad" sobre la columna "edad" de la tabla "empleados" */

/* Realizar una consulta que agrupe por edad y observar el plan de ejecución antes y después de crear el índice */
SELECT edad, COUNT(*) FROM empleados 
GROUP BY edad;


CREATE INDEX idx_empleados_edad ON empleados (edad);


SELECT edad, COUNT(*) FROM empleados 
GROUP BY edad;



/* Crear un índice llamado "idx_empleados_salario" sobre las columnas "salario" de la tabla "empleados" */

/* Realizar varias consultas que filtren por rangos de salario y observar la mejora */
SELECT * FROM empleados 
WHERE salario BETWEEN 1000 AND 2000;


CREATE INDEX idx_empleados_salario ON empleados (salario);


SELECT * FROM empleados 
WHERE salario BETWEEN 1000 AND 2000;



/* Crear un índice único llamado "idx_departamentos_nombre_unique" sobre la columna "nombre" de la tabla "departamentos" */
CREATE UNIQUE INDEX idx_departamentos_nombre_unique ON departamentos (nombre);



/* Intentar insertar un departamento con un nombre ya existente y comprobar que el SGBD no lo permite */
INSERT INTO departamentos (nombre) VALUES ('Marketing');



/* Crear un índice compuesto llamado "idx_empleados_edad_salario" sobre las columnas "edad" y "salario" de la tabla "empleados" */

/* Realizar una consulta que filtre por edad y ordene por salario para comprobar el uso del índice*/
SELECT * FROM empleados 
WHERE edad > 25 
ORDER BY salario;


CREATE INDEX idx_empleados_edad_salario ON empleados (edad, salario);


SELECT * FROM empleados 
WHERE edad > 25 
ORDER BY salario;



-- ==============================================
-- FIN PROYECTO SQL - GESTIÓN DE BASES DE DATOS EMPRESARIAL --
-- ==============================================   