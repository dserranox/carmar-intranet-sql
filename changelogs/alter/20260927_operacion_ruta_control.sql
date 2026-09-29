-- =======================
--  LA RUTA DE CONTROL TAMBIÉN ES TRABAJO
--  El responsable de calidad además produce, así que la recorrida tiene que
--  quedarle cargada como una tarea suya, con su tiempo, igual que cualquier
--  otra operación. Para eso se agrega la operación RC.
-- =======================
INSERT INTO OPERACIONES (OPE_NOMBRE, OPE_NOMBRE_CORTO, OPE_DESCRIPCION, OPE_GRUPO, OPE_ORDEN)
SELECT 'Ruta de control', 'RC', 'Recorrida de control de calidad por la planta', 'Calidad', 14
WHERE NOT EXISTS (SELECT 1 FROM OPERACIONES WHERE OPE_NOMBRE_CORTO = 'RC');

-- Una recorrida no pertenece a una sola orden: repasa varias. Por eso la tarea
-- de tipo RC se guarda sin orden, y la pantalla muestra "—" en el plan.
ALTER TABLE TAREAS ALTER COLUMN TAR_ORD_ID DROP NOT NULL;

-- Tarea que generó la recorrida, para poder ir de una a la otra.
ALTER TABLE RUTAS_CALIDAD ADD COLUMN IF NOT EXISTS RCA_TAR_ID BIGINT
  REFERENCES TAREAS(TAR_ID) ON UPDATE CASCADE ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS ix_rca_tarea ON RUTAS_CALIDAD(RCA_TAR_ID);
