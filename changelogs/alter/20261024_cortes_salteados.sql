-- liquibase formatted sql

-- =======================
--  CORTES SALTEADOS Y LA SÁBANA DE PENDIENTES
--
--  El visor obligaba a hacer la sábana en orden estricto. Si faltaba el caño de
--  una medida, el operario quedaba trabado: o cortaba algo que no tenía, o
--  abandonaba la sábana entera.
--
--  Ahora un corte se puede saltear indicando por qué. El salteado no se pierde
--  ni se da por hecho: queda en estado SALTEADO, y al llegar al final el visor
--  los vuelve a ofrecer. Si todavía no se pueden hacer, la sábana se cierra
--  igual y los salteados se mudan a una SÁBANA DE PENDIENTES —una por tipo— que
--  se asigna como cualquier otra cuando llega el material.
--
--  Lo importante: el corte se muda de sábana pero **se lleva su orden**. El
--  tiempo de cortarlo se sigue imputando al plan original, no a la sábana de
--  pendientes, que es solo el vehículo para hacerlos.
--
--  ESTADOS DEL CORTE: PENDIENTE | SALTEADO | HECHO
-- =======================

-- changeset carmar:20261024_corte_salteado
ALTER TABLE SABANAS_CORTE_DET
  ADD COLUMN IF NOT EXISTS SCD_SUBTIPO_SALTEO VARCHAR(30);

ALTER TABLE SABANAS_CORTE_DET
  ADD COLUMN IF NOT EXISTS SCD_MOTIVO_SALTEO VARCHAR(300);

ALTER TABLE SABANAS_CORTE_DET
  ADD COLUMN IF NOT EXISTS SCD_FECHA_SALTEO TIMESTAMP;

ALTER TABLE SABANAS_CORTE_DET
  ADD COLUMN IF NOT EXISTS SCD_USR_SALTEO_ID BIGINT;

-- De qué sábana venía, para saber de dónde salió una vez mudado.
ALTER TABLE SABANAS_CORTE_DET
  ADD COLUMN IF NOT EXISTS SCD_SAB_ORIGEN_ID BIGINT;

-- changeset carmar:20261024_corte_salteado_fks
ALTER TABLE SABANAS_CORTE_DET
  ADD CONSTRAINT sabanas_corte_det_scd_usr_salteo_id_fkey
  FOREIGN KEY (SCD_USR_SALTEO_ID) REFERENCES USUARIOS (USR_ID);

ALTER TABLE SABANAS_CORTE_DET
  ADD CONSTRAINT sabanas_corte_det_scd_sab_origen_id_fkey
  FOREIGN KEY (SCD_SAB_ORIGEN_ID) REFERENCES SABANAS_CORTE (SAB_ID);

-- changeset carmar:20261024_sabana_de_pendientes
-- La sábana que junta lo que quedó sin cortar. Hay una por tipo y no se borra:
-- se vacía sola a medida que se hacen los cortes.
ALTER TABLE SABANAS_CORTE
  ADD COLUMN IF NOT EXISTS SAB_ES_PENDIENTES BOOLEAN NOT NULL DEFAULT FALSE;

-- changeset carmar:20261024_cortes_salteados_comentarios
COMMENT ON COLUMN SABANAS_CORTE_DET.SCD_ESTADO IS
  'PENDIENTE | SALTEADO (se dejó para después, con motivo) | HECHO';

COMMENT ON COLUMN SABANAS_CORTE_DET.SCD_SUBTIPO_SALTEO IS
  'FALTA_MATERIAL | MAQUINA | OTRA_MAQUINA | OTRO';

COMMENT ON COLUMN SABANAS_CORTE.SAB_ES_PENDIENTES IS
  'La sábana que junta los cortes salteados de las demás. Una por tipo.';
