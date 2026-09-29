-- =======================
--  OPERACIONES DE CONTROL Y PICKING
--  Todo lo que se hace sobre una orden tiene que quedar como tarea propia, con
--  su tiempo y su responsable. Para eso faltaban las operaciones de control que
--  el operario hace durante la producción, y la de picking.
-- =======================

-- El "Control" pasa a llamarse "Control final": se conserva el mismo registro
-- para no perder las tareas ya cargadas con esa operación.
UPDATE OPERACIONES
SET OPE_NOMBRE = 'Control final',
    OPE_NOMBRE_CORTO = 'CF',
    OPE_DESCRIPCION = 'Control final del producto terminado'
WHERE OPE_NOMBRE_CORTO = 'CO';

INSERT INTO OPERACIONES (OPE_NOMBRE, OPE_NOMBRE_CORTO, OPE_DESCRIPCION, OPE_GRUPO, OPE_ORDEN)
SELECT 'Control de tracción', 'CT',
       'Ensayo de arrancamiento sobre un cable crimpeado', 'Calidad', 15
WHERE NOT EXISTS (SELECT 1 FROM OPERACIONES WHERE OPE_NOMBRE_CORTO = 'CT');

INSERT INTO OPERACIONES (OPE_NOMBRE, OPE_NOMBRE_CORTO, OPE_DESCRIPCION, OPE_GRUPO, OPE_ORDEN)
SELECT 'Control visual', 'CV',
       'Verificación visual durante el montaje', 'Calidad', 16
WHERE NOT EXISTS (SELECT 1 FROM OPERACIONES WHERE OPE_NOMBRE_CORTO = 'CV');

INSERT INTO OPERACIONES (OPE_NOMBRE, OPE_NOMBRE_CORTO, OPE_DESCRIPCION, OPE_GRUPO, OPE_ORDEN)
SELECT 'Control dimensional', 'CD',
       'Verificación de medidas contra el plano', 'Calidad', 17
WHERE NOT EXISTS (SELECT 1 FROM OPERACIONES WHERE OPE_NOMBRE_CORTO = 'CD');

INSERT INTO OPERACIONES (OPE_NOMBRE, OPE_NOMBRE_CORTO, OPE_DESCRIPCION, OPE_GRUPO, OPE_ORDEN)
SELECT 'Picking de materiales', 'PK',
       'Preparación de los materiales de la orden', 'Depósito', 18
WHERE NOT EXISTS (SELECT 1 FROM OPERACIONES WHERE OPE_NOMBRE_CORTO = 'PK');

-- =======================
--  ORDENES AUTOCREADAS CON EL AÑO A DOS DÍGITOS
--  La importación de sábanas tomaba el "26" del plan como año. Quedaban fuera
--  de la pantalla de Órdenes, que filtra por año completo.
-- =======================
UPDATE ORDENES SET ORD_ANIO = 2000 + ORD_ANIO
WHERE ORD_ANIO IS NOT NULL AND ORD_ANIO BETWEEN 1 AND 99;
