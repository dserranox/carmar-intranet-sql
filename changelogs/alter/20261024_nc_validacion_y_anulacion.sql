-- liquibase formatted sql

-- =======================
--  LA NO CONFORMIDAD PASA POR CALIDAD ANTES DE CONTAR
--
--  Hasta ahora cualquiera cargaba una NC y esa NC ya era un hecho: contaba en
--  los indicadores y disparaba los avisos. Pero no todo lo que un operario
--  reporta como no conformidad lo es, y una vez cargada no había forma de
--  sacarla sin tocar la base.
--
--  Ahora la NC nace PENDIENTE y recién cuenta cuando la valida calidad, el
--  jefe de producción o el administrador. Si la rechazan queda NO_PROCEDENTE:
--  no se borra, queda a la vista con el motivo. Saber cuántas se rechazan, y
--  de quién vienen, también es información.
--
--  La que abre calidad nace validada: no tiene sentido que se valide a sí misma.
--
--  ANULADA es otra cosa: una NC que ya estaba validada y resultó estar mal
--  cargada, o repetida. No se borra tampoco — el número queda reservado, así
--  nadie se pregunta por qué falta el 47.
--
--  ESTADOS: PENDIENTE | ABIERTA | CERRADA | NO_PROCEDENTE | ANULADA
-- =======================

-- changeset carmar:20261024_nc_estado_mas_largo
-- "NO_PROCEDENTE" no entra en diez caracteres.
ALTER TABLE NO_CONFORMIDADES
  ALTER COLUMN NCF_ESTADO TYPE VARCHAR(20);

-- changeset carmar:20261024_nc_validacion
ALTER TABLE NO_CONFORMIDADES
  ADD COLUMN IF NOT EXISTS NCF_FECHA_VALIDACION TIMESTAMP;

ALTER TABLE NO_CONFORMIDADES
  ADD COLUMN IF NOT EXISTS NCF_USR_VALIDACION_ID BIGINT;

ALTER TABLE NO_CONFORMIDADES
  ADD COLUMN IF NOT EXISTS NCF_MOTIVO_RECHAZO VARCHAR(500);

-- changeset carmar:20261024_nc_validacion_fk
ALTER TABLE NO_CONFORMIDADES
  ADD CONSTRAINT no_conformidades_ncf_usr_validacion_id_fkey
  FOREIGN KEY (NCF_USR_VALIDACION_ID) REFERENCES USUARIOS (USR_ID);

-- changeset carmar:20261024_nc_anulacion
ALTER TABLE NO_CONFORMIDADES
  ADD COLUMN IF NOT EXISTS NCF_FECHA_ANULACION TIMESTAMP;

ALTER TABLE NO_CONFORMIDADES
  ADD COLUMN IF NOT EXISTS NCF_USR_ANULACION_ID BIGINT;

ALTER TABLE NO_CONFORMIDADES
  ADD COLUMN IF NOT EXISTS NCF_MOTIVO_ANULACION VARCHAR(500);

-- changeset carmar:20261024_nc_anulacion_fk
ALTER TABLE NO_CONFORMIDADES
  ADD CONSTRAINT no_conformidades_ncf_usr_anulacion_id_fkey
  FOREIGN KEY (NCF_USR_ANULACION_ID) REFERENCES USUARIOS (USR_ID);

-- changeset carmar:20261024_nc_comentarios
COMMENT ON COLUMN NO_CONFORMIDADES.NCF_ESTADO IS
  'PENDIENTE (esperando validación) | ABIERTA | CERRADA | NO_PROCEDENTE (rechazada) | ANULADA';

COMMENT ON COLUMN NO_CONFORMIDADES.NCF_MOTIVO_RECHAZO IS
  'Por qué no procede, cuando la validación la rechaza';

COMMENT ON COLUMN NO_CONFORMIDADES.NCF_MOTIVO_ANULACION IS
  'Por qué se anuló una NC que ya estaba validada: carga equivocada, duplicada';
