-- =======================
--  EVENTOS DE CORTE
--  Tiempos que no son de corte propiamente dicho: los set up (cambio de bobina
--  o de terminal) y las pausas operativas con su motivo.
-- =======================
CREATE TABLE IF NOT EXISTS EVENTOS_CORTE (
  EVC_ID BIGSERIAL PRIMARY KEY,
  EVC_SAB_ID BIGINT NOT NULL REFERENCES SABANAS_CORTE(SAB_ID) ON UPDATE CASCADE ON DELETE CASCADE,
  -- Corte en el que ocurrió; permite atribuir el tiempo al código/plan correcto.
  EVC_SCD_ID BIGINT REFERENCES SABANAS_CORTE_DET(SCD_ID) ON UPDATE CASCADE ON DELETE SET NULL,
  EVC_TIPO VARCHAR(20) NOT NULL,        -- SETUP | PAUSA
  EVC_SUBTIPO VARCHAR(30) NOT NULL,     -- SETUP:  CAMBIO_BOBINA | CAMBIO_TERMINAL | CAMBIO_BOBINA_TERMINAL
                                        -- PAUSA:  CONSULTA_TECNICA | CONSULTA_CALIDAD | FALTA_MATERIAL | MANTENIMIENTO | OTROS
  EVC_MOTIVO VARCHAR(500),              -- detalle libre; obligatorio cuando el subtipo es OTROS
  EVC_FECHA_INICIO TIMESTAMP NOT NULL,
  EVC_FECHA_FIN TIMESTAMP NOT NULL,
  EVC_SEGUNDOS INT NOT NULL,
  EVC_USR_ID BIGINT NOT NULL REFERENCES USUARIOS(USR_ID) ON UPDATE CASCADE ON DELETE CASCADE,
  aud_usr_ins varchar(250) NOT NULL,
  aud_usr_upd varchar(250) NOT NULL,
  aud_fecha_ins timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aud_fecha_upd timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_evc_sabana ON EVENTOS_CORTE(EVC_SAB_ID);
CREATE INDEX IF NOT EXISTS ix_evc_corte  ON EVENTOS_CORTE(EVC_SCD_ID);
CREATE INDEX IF NOT EXISTS ix_evc_tipo   ON EVENTOS_CORTE(EVC_TIPO, EVC_SUBTIPO);

-- =======================
--  TAREAS: tiempos de set up y de pausa, aparte del tiempo de corte
-- =======================
ALTER TABLE TAREAS ADD COLUMN IF NOT EXISTS TAR_SEGUNDOS_SETUP INT;
ALTER TABLE TAREAS ADD COLUMN IF NOT EXISTS TAR_SEGUNDOS_PAUSA INT;

COMMENT ON COLUMN TAREAS.TAR_SEGUNDOS_EFECTIVOS IS 'Tiempo de corte propiamente dicho, sumado corte por corte';
COMMENT ON COLUMN TAREAS.TAR_SEGUNDOS_SETUP     IS 'Tiempo de cambios de bobina y de terminal';
COMMENT ON COLUMN TAREAS.TAR_SEGUNDOS_PAUSA     IS 'Tiempo de pausas operativas, con el detalle en EVENTOS_CORTE';
