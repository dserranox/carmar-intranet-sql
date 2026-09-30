--liquibase formatted sql

--changeset carmar:20260929_picking_tablas
-- =======================
--  PICKING DE ABASTECIMIENTO
--  Por cada plan que se lanza, logistica prepara un cajon con los materiales
--  de almacen. El cable y el corrugado NO entran: vienen de lead prep, que
--  corre en paralelo. Picking no bloquea ni habilita nada en otros modulos.
-- =======================
CREATE TABLE IF NOT EXISTS PICKINGS (
  PCK_ID BIGSERIAL PRIMARY KEY,
  PCK_NRO_PLAN VARCHAR(64) NOT NULL,
  -- La orden puede no estar cargada todavia: el picking vale igual.
  PCK_ORD_ID BIGINT REFERENCES ORDENES(ORD_ID) ON UPDATE CASCADE ON DELETE SET NULL,
  PCK_PRD_ID BIGINT REFERENCES PRODUCTOS(PRD_ID) ON UPDATE CASCADE ON DELETE SET NULL,
  PCK_CODIGO_PRODUCTO VARCHAR(64) NOT NULL,
  PCK_CANTIDAD_PRODUCIR INT,
  -- PENDIENTE | EN_CURSO | COMPLETO | INCOMPLETO
  PCK_ESTADO VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
  PCK_USR_ID BIGINT REFERENCES USUARIOS(USR_ID) ON UPDATE CASCADE ON DELETE SET NULL,
  PCK_FECHA_INICIO TIMESTAMP,
  PCK_FECHA_FIN TIMESTAMP,
  PCK_SEGUNDOS INT,
  PCK_ARCHIVO VARCHAR(255),
  PCK_OBSERVACIONES VARCHAR(1000),
  aud_usr_ins varchar(250) NOT NULL,
  aud_usr_upd varchar(250),
  aud_fecha_ins timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aud_fecha_upd timestamp
);
-- Un solo picking por plan: si se vuelve a subir, se reemplaza o se rechaza.
CREATE UNIQUE INDEX IF NOT EXISTS uq_pck_plan ON PICKINGS(PCK_NRO_PLAN);
CREATE INDEX IF NOT EXISTS ix_pck_estado ON PICKINGS(PCK_ESTADO);
CREATE INDEX IF NOT EXISTS ix_pck_usuario ON PICKINGS(PCK_USR_ID);

-- Una fila del Excel = un componente a buscar en el almacen.
CREATE TABLE IF NOT EXISTS PICKINGS_DET (
  PKD_ID BIGSERIAL PRIMARY KEY,
  PKD_PCK_ID BIGINT NOT NULL REFERENCES PICKINGS(PCK_ID) ON UPDATE CASCADE ON DELETE CASCADE,
  PKD_NRO_LINEA INT NOT NULL,
  -- Texto libre: todavia no hay maestro de materiales. Cuando lo haya se suma
  -- un PKD_MAT_ID al lado, sin tocar lo que ya esta cargado.
  PKD_CODIGO_PIEZA VARCHAR(64) NOT NULL,
  PKD_DESCRIPCION VARCHAR(255),
  PKD_UM VARCHAR(20),
  -- Tal cual viene: a veces es una ubicacion ("PB B 2.1") y a veces una medida
  -- ("16,4mm - 30mm"). No se interpreta.
  PKD_UBICACION VARCHAR(128),
  PKD_CANT_POR_PRODUCTO NUMERIC(12,3),
  PKD_CANT_TOTAL NUMERIC(12,3) NOT NULL,
  PKD_CANT_RETIRADA NUMERIC(12,3) NOT NULL DEFAULT 0,
  -- PENDIENTE | RETIRADO | PARCIAL | FALTANTE
  PKD_ESTADO VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
  -- SIN_STOCK | NO_ENCONTRADO | OTRO
  PKD_MOTIVO_FALTANTE VARCHAR(30),
  PKD_OBSERVACIONES VARCHAR(500),
  PKD_USR_RETIRO BIGINT REFERENCES USUARIOS(USR_ID) ON UPDATE CASCADE ON DELETE SET NULL,
  PKD_FECHA_RETIRO TIMESTAMP,
  -- Cuando el faltante se entrega despues.
  PKD_USR_ENTREGA BIGINT REFERENCES USUARIOS(USR_ID) ON UPDATE CASCADE ON DELETE SET NULL,
  PKD_FECHA_ENTREGA TIMESTAMP,
  -- Compras ya pidio este codigo.
  PKD_PEDIDO BOOLEAN NOT NULL DEFAULT FALSE,
  PKD_USR_PEDIDO BIGINT REFERENCES USUARIOS(USR_ID) ON UPDATE CASCADE ON DELETE SET NULL,
  PKD_FECHA_PEDIDO TIMESTAMP,
  aud_usr_ins varchar(250) NOT NULL,
  aud_usr_upd varchar(250),
  aud_fecha_ins timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aud_fecha_upd timestamp
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_pkd_linea ON PICKINGS_DET(PKD_PCK_ID, PKD_NRO_LINEA);
CREATE INDEX IF NOT EXISTS ix_pkd_picking ON PICKINGS_DET(PKD_PCK_ID);
CREATE INDEX IF NOT EXISTS ix_pkd_estado  ON PICKINGS_DET(PKD_ESTADO);
CREATE INDEX IF NOT EXISTS ix_pkd_pieza   ON PICKINGS_DET(PKD_CODIGO_PIEZA);

--changeset carmar:20260929_picking_permisos
INSERT INTO PERMISOS (PRM_CLAVE, PRM_DESCRIPCION)
SELECT v.clave, v.descripcion
FROM (VALUES
  ('PICKING:READ',  'Ver los pickings de abastecimiento y los pendientes de compra'),
  ('PICKING:WRITE', 'Preparar el cajon: retirar, marcar faltantes y entregarlos'),
  ('PICKING:ADMIN', 'Importar el Excel, reemplazar un picking y marcar codigos como pedidos')
) AS v(clave, descripcion)
WHERE NOT EXISTS (SELECT 1 FROM PERMISOS p WHERE p.PRM_CLAVE = v.clave);

--changeset carmar:20260929_picking_rol_logistica
-- El operario de logistica prepara los cajones. No produce ni asigna.
INSERT INTO ROLES (ROL_NOMBRE, ROL_DESCRIPCION)
SELECT 'LOGISTICA', 'Abastecimiento: prepara los cajones de materiales de cada plan'
WHERE NOT EXISTS (SELECT 1 FROM ROLES WHERE ROL_NOMBRE = 'LOGISTICA');

INSERT INTO ROLES_PERMISOS (RP_ROL_ID, RP_PRM_ID)
SELECT r.ROL_ID, p.PRM_ID
FROM ROLES r, PERMISOS p
WHERE r.ROL_NOMBRE = 'LOGISTICA'
  AND p.PRM_CLAVE IN ('PRODUCTOS:READ', 'PICKING:READ', 'PICKING:WRITE')
  AND NOT EXISTS (
    SELECT 1 FROM ROLES_PERMISOS rp WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID);

--changeset carmar:20260929_picking_permisos_roles
-- El administrador y el jefe de produccion ven todo y ademas importan.
INSERT INTO ROLES_PERMISOS (RP_ROL_ID, RP_PRM_ID)
SELECT r.ROL_ID, p.PRM_ID
FROM ROLES r, PERMISOS p
WHERE r.ROL_NOMBRE IN ('ADMIN', 'JEFE_PRODUCCION')
  AND p.PRM_CLAVE IN ('PICKING:READ', 'PICKING:WRITE', 'PICKING:ADMIN')
  AND NOT EXISTS (
    SELECT 1 FROM ROLES_PERMISOS rp WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID);

-- Consulta mira, no toca.
INSERT INTO ROLES_PERMISOS (RP_ROL_ID, RP_PRM_ID)
SELECT r.ROL_ID, p.PRM_ID
FROM ROLES r, PERMISOS p
WHERE r.ROL_NOMBRE = 'CONSULTA'
  AND p.PRM_CLAVE = 'PICKING:READ'
  AND NOT EXISTS (
    SELECT 1 FROM ROLES_PERMISOS rp WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID);
