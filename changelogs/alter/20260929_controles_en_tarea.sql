-- =======================
--  CONTROLES DENTRO DE UNA TAREA
--  Hasta ahora un control de calidad solo podía nacer de un corte de la sábana.
--  Ahora el operario también los hace mientras produce: un control de tracción
--  antes de crimpear, un control visual durante el montaje. Esos controles no
--  cuelgan de un corte, sino de la tarea y la orden.
-- =======================

-- El corte deja de ser obligatorio: un control puede venir de una tarea.
ALTER TABLE CONTROLES_CALIDAD ALTER COLUMN CCA_SCD_ID DROP NOT NULL;

-- SABANA = nació de un corte; TAREA = lo hizo el operario mientras producía.
ALTER TABLE CONTROLES_CALIDAD ADD COLUMN IF NOT EXISTS CCA_ORIGEN VARCHAR(20) NOT NULL DEFAULT 'SABANA';

ALTER TABLE CONTROLES_CALIDAD ADD COLUMN IF NOT EXISTS CCA_TAR_ID BIGINT
  REFERENCES TAREAS(TAR_ID) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE CONTROLES_CALIDAD ADD COLUMN IF NOT EXISTS CCA_ORD_ID BIGINT
  REFERENCES ORDENES(ORD_ID) ON UPDATE CASCADE ON DELETE SET NULL;

-- Se guardan copiados para que el registro siga leyéndose aunque cambie la orden.
ALTER TABLE CONTROLES_CALIDAD ADD COLUMN IF NOT EXISTS CCA_NRO_PLAN VARCHAR(64);
ALTER TABLE CONTROLES_CALIDAD ADD COLUMN IF NOT EXISTS CCA_CODIGO VARCHAR(64);
ALTER TABLE CONTROLES_CALIDAD ADD COLUMN IF NOT EXISTS CCA_PUESTO VARCHAR(64);

CREATE INDEX IF NOT EXISTS ix_cca_tarea  ON CONTROLES_CALIDAD(CCA_TAR_ID);
CREATE INDEX IF NOT EXISTS ix_cca_orden  ON CONTROLES_CALIDAD(CCA_ORD_ID);
CREATE INDEX IF NOT EXISTS ix_cca_origen ON CONTROLES_CALIDAD(CCA_ORIGEN);

-- Los que ya estaban vienen todos de una sábana: se les completa el rastro.
UPDATE CONTROLES_CALIDAD c
SET CCA_NRO_PLAN = d.SCD_NRO_PLAN, CCA_CODIGO = d.SCD_CODIGO
FROM SABANAS_CORTE_DET d
WHERE d.SCD_ID = c.CCA_SCD_ID AND c.CCA_NRO_PLAN IS NULL;

COMMENT ON COLUMN CONTROLES_CALIDAD.CCA_ORIGEN IS
  'SABANA = control obligatorio de un corte; TAREA = control que hizo el operario mientras producía.';
