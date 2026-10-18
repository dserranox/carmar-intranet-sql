-- liquibase formatted sql

-- =======================
--  TAREAS CON TIEMPO NO CONFIABLE
--
--  Una tarea que queda abierta sigue con el reloj corriendo. Al cerrarla, el
--  tiempo registrado no es el que se trabajó: es el que pasó. El caso extremo
--  en producción fue una tarea de montaje abierta desde el 19/06 y cerrada el
--  18/10, que quedó con 2.910 horas para 100 unidades. Las otras siete son
--  tareas que arrancaron un jueves o viernes y se cerraron el lunes.
--
--  No se borran: las unidades se produjeron de verdad y la trazabilidad del
--  lote tiene que quedar. Lo que se marca es que **el tiempo no sirve**, y los
--  indicadores las descartan enteras — con las horas y con las unidades —,
--  porque dejar las unidades sin las horas inflaría el rendimiento.
--
--  El criterio es más de 24 horas de tiempo efectivo **en tareas ya cerradas**.
--  Nadie trabaja un día entero seguido sobre la misma tarea sin cerrarla. A una
--  tarea abierta no se la toca: todavía está corriendo y su tiempo se define
--  cuando el operario la cierre.
-- =======================

-- changeset carmar:20261018_tiempo_no_confiable_columna
ALTER TABLE TAREAS
  ADD COLUMN IF NOT EXISTS TAR_TIEMPO_NO_CONFIABLE BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN TAREAS.TAR_TIEMPO_NO_CONFIABLE IS
  'La tarea quedó abierta y el tiempo registrado no es el trabajado: se excluye de los indicadores';

-- changeset carmar:20261018_tiempo_no_confiable_marcar
UPDATE TAREAS
   SET TAR_TIEMPO_NO_CONFIABLE = TRUE,
       TAR_SEGUNDOS_EFECTIVOS = 0,
       TAR_OBSERVACIONES = CASE
         WHEN TAR_OBSERVACIONES IS NULL OR TAR_OBSERVACIONES = ''
           THEN 'Tiempo no confiable: quedó abierta y el reloj siguió corriendo. Excluida de los indicadores.'
           ELSE TAR_OBSERVACIONES || ' · Tiempo no confiable: quedó abierta y el reloj siguió corriendo. Excluida de los indicadores.'
       END
 WHERE TAR_SEGUNDOS_EFECTIVOS > 86400
   AND TAR_FECHA_FIN IS NOT NULL
   AND TAR_TIEMPO_NO_CONFIABLE = FALSE;
