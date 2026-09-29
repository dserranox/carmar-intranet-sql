-- No toda actividad se hace en una máquina numerada: montaje, control o empalme
-- se hacen en un puesto de trabajo. El número de máquina pasa a ser opcional y se
-- agrega el puesto, que viene de la asignación y queda en el historial de la tarea.
ALTER TABLE TAREAS ALTER COLUMN TAR_NRO_MAQUINA DROP NOT NULL;
ALTER TABLE TAREAS ADD COLUMN IF NOT EXISTS TAR_PUESTO VARCHAR(64);

COMMENT ON COLUMN TAREAS.TAR_NRO_MAQUINA IS 'Máquina, cuando la actividad se hace en una máquina numerada';
COMMENT ON COLUMN TAREAS.TAR_PUESTO IS 'Puesto de trabajo, como lo indicó la asignación';
