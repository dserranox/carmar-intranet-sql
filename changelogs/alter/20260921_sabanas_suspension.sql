-- Una sábana puede llevar más de un día, o el operario puede ser derivado a otra
-- tarea en el medio. Se agrega el estado SUSPENDIDA (sobre SAB_ESTADO, que ya es
-- texto libre) con el momento y el motivo, para poder retomarla donde quedó.
ALTER TABLE SABANAS_CORTE ADD COLUMN IF NOT EXISTS SAB_FECHA_SUSPENSION TIMESTAMP;
ALTER TABLE SABANAS_CORTE ADD COLUMN IF NOT EXISTS SAB_SUBTIPO_SUSPENSION VARCHAR(30);
ALTER TABLE SABANAS_CORTE ADD COLUMN IF NOT EXISTS SAB_MOTIVO_SUSPENSION VARCHAR(500);

COMMENT ON COLUMN SABANAS_CORTE.SAB_ESTADO IS
  'PENDIENTE | EN_PROCESO | SUSPENDIDA | FINALIZADA';
COMMENT ON COLUMN SABANAS_CORTE.SAB_SUBTIPO_SUSPENSION IS
  'FIN_JORNADA | OTRA_TAREA | OTROS';

-- El corte que quedó a medio hacer conserva el tiempo ya medido, así al retomar
-- el cronómetro sigue desde ahí en lugar de arrancar de cero.
COMMENT ON COLUMN SABANAS_CORTE_DET.SCD_SEGUNDOS IS
  'Tiempo de corte acumulado; se guarda también al suspender, con el corte todavía PENDIENTE';

-- EVENTOS_CORTE pasa a registrar además el tipo SUSPENSION (segundos 0: no es
-- tiempo de máquina, es la marca de cuándo y por qué se dejó la sábana).
COMMENT ON COLUMN EVENTOS_CORTE.EVC_TIPO IS 'SETUP | PAUSA | SUSPENSION';
COMMENT ON COLUMN EVENTOS_CORTE.EVC_SUBTIPO IS
  'SETUP: CAMBIO_BOBINA | CAMBIO_TERMINAL | CAMBIO_BOBINA_TERMINAL; '
  'PAUSA: CONSULTA_TECNICA | CONSULTA_CALIDAD | FALTA_MATERIAL | MANTENIMIENTO | DESCANSO | OTROS; '
  'SUSPENSION: FIN_JORNADA | OTRA_TAREA | OTROS';
