-- =======================
--  QUÉ ACTIVIDADES SE PUEDEN ASIGNAR A MANO
--  Hay actividades que la app genera sola y no tiene sentido repartir desde el
--  cuadro de asignar: la ruta de control nace cuando calidad arranca la recorrida,
--  los tres controles nacen dentro de la tarea que se está haciendo, y el picking
--  nace al cargar el Excel del plan.
--  Recepción y despacho quedan asignables: esas sí las hace alguien a mano.
-- =======================

ALTER TABLE OPERACIONES
  ADD COLUMN IF NOT EXISTS OPE_ASIGNABLE BOOLEAN NOT NULL DEFAULT TRUE;

COMMENT ON COLUMN OPERACIONES.OPE_ASIGNABLE IS
  'Si aparece en el cuadro de asignar trabajo; las que genera la app sola, no';

UPDATE OPERACIONES
   SET OPE_ASIGNABLE = FALSE
 WHERE UPPER(OPE_NOMBRE_CORTO) IN ('RC', 'CT', 'CV', 'CD', 'PK');
