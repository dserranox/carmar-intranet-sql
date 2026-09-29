-- =======================
--  EL RELOJ LO LLEVA LA TAREA
--  Hasta ahora el tiempo de una tarea era fin menos inicio, así que una pausa
--  segu%ía sumando tiempo de producción. Ahora la tarea acumula sus segundos
--  productivos y, por separado, los de pausa: se puede saber cuánto lleva un
--  lote con pausas y sin pausas.
--  Además la tarea se puede suspender: se termina el día sin finalizarla y al
--  otro día se retoma donde quedó, sin que la noche cuente como trabajo.
-- =======================

-- EN_CURSO | PAUSADA | SUSPENDIDA | TERMINADA
ALTER TABLE TAREAS ADD COLUMN IF NOT EXISTS TAR_ESTADO VARCHAR(20);

-- Cuándo arrancó el tramo que está corriendo ahora. Null si no corre.
ALTER TABLE TAREAS ADD COLUMN IF NOT EXISTS TAR_ULTIMO_INICIO TIMESTAMP;

-- Cuándo empezó la pausa o la suspensión que está abierta.
ALTER TABLE TAREAS ADD COLUMN IF NOT EXISTS TAR_FECHA_PAUSA TIMESTAMP;
ALTER TABLE TAREAS ADD COLUMN IF NOT EXISTS TAR_SUBTIPO_PAUSA VARCHAR(30);
ALTER TABLE TAREAS ADD COLUMN IF NOT EXISTS TAR_MOTIVO_PAUSA VARCHAR(500);

COMMENT ON COLUMN TAREAS.TAR_SEGUNDOS_EFECTIVOS IS
  'Segundos realmente trabajados: no incluye pausas ni el tiempo entre suspensión y retoma.';
COMMENT ON COLUMN TAREAS.TAR_SEGUNDOS_PAUSA IS
  'Segundos de pausa operativa acumulados en la tarea.';

-- Las tareas que ya existen: las cerradas quedan terminadas, las abiertas en curso.
UPDATE TAREAS SET TAR_ESTADO = 'TERMINADA' WHERE TAR_ESTADO IS NULL AND TAR_FECHA_FIN IS NOT NULL;
UPDATE TAREAS SET TAR_ESTADO = 'EN_CURSO', TAR_ULTIMO_INICIO = TAR_FECHA_INICIO
  WHERE TAR_ESTADO IS NULL AND TAR_FECHA_FIN IS NULL;

-- A las cerradas sin tiempo efectivo se les toma la diferencia, que es lo que
-- venía valiendo hasta ahora.
UPDATE TAREAS
SET TAR_SEGUNDOS_EFECTIVOS = GREATEST(0, EXTRACT(EPOCH FROM (TAR_FECHA_FIN - TAR_FECHA_INICIO))::int)
WHERE TAR_SEGUNDOS_EFECTIVOS IS NULL AND TAR_FECHA_FIN IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_tar_estado ON TAREAS(TAR_ESTADO);
