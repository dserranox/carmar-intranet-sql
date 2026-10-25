-- liquibase formatted sql

-- =======================
--  RECORRIDAS: PAUSA Y LOS DATOS QUE PIDEN LOS INDICADORES
--
--  1) PAUSA. Hasta ahora una recorrida se cerraba o se suspendía, y suspender
--     la daba por perdida. En el descanso, o cuando al responsable de calidad
--     lo llaman para otra cosa, lo que hace falta es pararla y seguir después.
--
--     La pausa cierra la tarea que estaba corriendo —así el operario queda
--     libre para hacer otra cosa, que es lo que se pidió— y deja la recorrida
--     en PAUSADA. Al retomarla se abre una tarea nueva. Como el tiempo queda
--     repartido entre varias tareas, la recorrida guarda lo acumulado para
--     poder mostrar cuánto llevó en total.
--
--  2) LOS DATOS DE CADA ORDEN CONTROLADA. Para que los indicadores salgan
--     solos hacen falta la cantidad controlada y, cuando algo sale mal, la
--     causa, la acción inmediata y quién la hizo.
--
--     Van en el control de cada orden y no en la recorrida entera: una
--     recorrida toca varias órdenes y el problema es de una.
-- =======================

-- changeset carmar:20261024_ruta_pausa
ALTER TABLE RUTAS_CALIDAD
  ADD COLUMN IF NOT EXISTS RCA_SEGUNDOS_ACUMULADOS INTEGER NOT NULL DEFAULT 0;

COMMENT ON COLUMN RUTAS_CALIDAD.RCA_ESTADO IS
  'EN_CURSO | PAUSADA (parada, se retoma después) | CERRADA | SUSPENDIDA';

COMMENT ON COLUMN RUTAS_CALIDAD.RCA_SEGUNDOS_ACUMULADOS IS
  'Lo que llevaba trabajado en los tramos anteriores a la pausa';

-- changeset carmar:20261024_ruta_datos_del_control
ALTER TABLE RUTAS_CALIDAD_CONTROLES
  ADD COLUMN IF NOT EXISTS RCC_CANTIDAD_CONTROLADA INTEGER;

ALTER TABLE RUTAS_CALIDAD_CONTROLES
  ADD COLUMN IF NOT EXISTS RCC_CANTIDAD_NC INTEGER;

ALTER TABLE RUTAS_CALIDAD_CONTROLES
  ADD COLUMN IF NOT EXISTS RCC_CAUSA VARCHAR(500);

ALTER TABLE RUTAS_CALIDAD_CONTROLES
  ADD COLUMN IF NOT EXISTS RCC_ACCION_INMEDIATA VARCHAR(500);

ALTER TABLE RUTAS_CALIDAD_CONTROLES
  ADD COLUMN IF NOT EXISTS RCC_ACCION_POR VARCHAR(64);

-- changeset carmar:20261024_ruta_datos_comentarios
COMMENT ON COLUMN RUTAS_CALIDAD_CONTROLES.RCC_CANTIDAD_CONTROLADA IS
  'Cuántas piezas se miraron en esta orden';

COMMENT ON COLUMN RUTAS_CALIDAD_CONTROLES.RCC_CANTIDAD_NC IS
  'De las miradas, cuántas salieron no conformes';

COMMENT ON COLUMN RUTAS_CALIDAD_CONTROLES.RCC_ACCION_POR IS
  'Quién hizo la acción inmediata de corrección';
