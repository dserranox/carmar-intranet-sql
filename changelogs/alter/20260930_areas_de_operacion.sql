--liquibase formatted sql

--changeset carmar:20260930_areas_operacion_columna
-- El area es la sub-pantalla de TAREAS donde cae cada operacion.
-- Se guarda en la base para poder reasignar operaciones sin tocar codigo.
ALTER TABLE OPERACIONES ADD COLUMN OPE_AREA VARCHAR(30);

--changeset carmar:20260930_areas_operacion_valores
UPDATE OPERACIONES SET OPE_AREA = 'CORTE_CABLE'     WHERE OPE_NOMBRE_CORTO IN ('CAC');
UPDATE OPERACIONES SET OPE_AREA = 'CORTE_CORRUGADO' WHERE OPE_NOMBRE_CORTO IN ('CACo', 'CAE', 'CAT');
UPDATE OPERACIONES SET OPE_AREA = 'ARMADO'          WHERE OPE_NOMBRE_CORTO IN ('EU', 'ES', 'Mo', 'CR', 'CRAS', 'MA', 'EM', 'RT');
UPDATE OPERACIONES SET OPE_AREA = 'CALIDAD'         WHERE OPE_NOMBRE_CORTO IN ('CF', 'RC', 'CT', 'CV', 'CD');
UPDATE OPERACIONES SET OPE_AREA = 'PICKING'         WHERE OPE_NOMBRE_CORTO IN ('PK');
-- Lo que no tenga area cae en la pestaña "Otras" hasta que se le asigne una.

--changeset carmar:20260930_areas_operacion_recepcion_despacho
-- Recepcion de materiales y despacho todavia no tienen operacion definida.
-- Se crean para que la tarea exista desde el dia uno y el area no quede vacia.
INSERT INTO OPERACIONES (OPE_NOMBRE, OPE_NOMBRE_CORTO, OPE_DESCRIPCION, OPE_GRUPO, OPE_ORDEN, OPE_AREA)
SELECT 'Recepcion de materiales', 'RM', 'Ingreso y verificacion de material recibido', 'Deposito', 19, 'RECEPCION'
WHERE NOT EXISTS (SELECT 1 FROM OPERACIONES WHERE OPE_NOMBRE_CORTO = 'RM');

INSERT INTO OPERACIONES (OPE_NOMBRE, OPE_NOMBRE_CORTO, OPE_DESCRIPCION, OPE_GRUPO, OPE_ORDEN, OPE_AREA)
SELECT 'Despacho', 'DE', 'Preparacion y salida del pedido', 'Deposito', 20, 'DESPACHO'
WHERE NOT EXISTS (SELECT 1 FROM OPERACIONES WHERE OPE_NOMBRE_CORTO = 'DE');
