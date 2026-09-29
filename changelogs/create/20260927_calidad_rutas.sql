-- =======================
--  RUTAS DE CONTROL DE CALIDAD
--  El responsable de calidad hace dos recorridas por día. En cada una elige
--  órdenes abiertas y sobre cada una completa una lista de puntos de control
--  (OK / KO / N/A, con observaciones). No es un muestreo al azar: son los
--  puntos que la planta fue aprendiendo a mirar a partir de los problemas.
-- =======================

-- Los puntos que se chequean. Están en tabla y no en el código para poder
-- agregar o sacar sin tocar la aplicación.
CREATE TABLE IF NOT EXISTS PUNTOS_CONTROL (
  PCO_ID BIGSERIAL PRIMARY KEY,
  PCO_NOMBRE VARCHAR(120) NOT NULL UNIQUE,
  PCO_DESCRIPCION VARCHAR(500),
  -- En qué posición aparece en la lista que completa el responsable.
  PCO_ORDEN INT NOT NULL DEFAULT 1,
  PCO_ACTIVO BOOLEAN NOT NULL DEFAULT TRUE,
  aud_usr_ins varchar(250) NOT NULL,
  aud_usr_upd varchar(250) NOT NULL,
  aud_fecha_ins timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aud_fecha_upd timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO PUNTOS_CONTROL (PCO_NOMBRE, PCO_ORDEN, aud_usr_ins, aud_usr_upd) VALUES
  ('CONTROL VISUAL DE CRIMPEADO',        1, 'liquibase', 'liquibase'),
  ('CONTROL VISUAL DE SELLOS',           2, 'liquibase', 'liquibase'),
  ('CONTROL DE MONTAJE DE CONECTORES',   3, 'liquibase', 'liquibase'),
  ('CONTROL DIMENSIONAL',                4, 'liquibase', 'liquibase'),
  ('CONTROL DE IMPRESIONES',             5, 'liquibase', 'liquibase')
ON CONFLICT (PCO_NOMBRE) DO NOTHING;

-- Una recorrida. Por día se esperan dos (RCA_NUMERO 1 y 2), de un responsable.
CREATE TABLE IF NOT EXISTS RUTAS_CALIDAD (
  RCA_ID BIGSERIAL PRIMARY KEY,
  RCA_FECHA DATE NOT NULL DEFAULT CURRENT_DATE,
  RCA_NUMERO INT NOT NULL DEFAULT 1,
  RCA_USR_ID BIGINT NOT NULL REFERENCES USUARIOS(USR_ID) ON UPDATE CASCADE ON DELETE CASCADE,
  RCA_ESTADO VARCHAR(20) NOT NULL DEFAULT 'EN_CURSO',   -- EN_CURSO | CERRADA
  RCA_FECHA_INICIO TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  RCA_FECHA_FIN TIMESTAMP,
  RCA_OBSERVACIONES VARCHAR(1000),
  aud_usr_ins varchar(250) NOT NULL,
  aud_usr_upd varchar(250) NOT NULL,
  aud_fecha_ins timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aud_fecha_upd timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- No puede haber dos veces la misma recorrida del mismo día.
CREATE UNIQUE INDEX IF NOT EXISTS ux_rca_fecha_numero ON RUTAS_CALIDAD(RCA_FECHA, RCA_NUMERO);
CREATE INDEX IF NOT EXISTS ix_rca_estado ON RUTAS_CALIDAD(RCA_ESTADO, RCA_FECHA);

-- Cada orden controlada dentro de una recorrida.
CREATE TABLE IF NOT EXISTS RUTAS_CALIDAD_CONTROLES (
  RCC_ID BIGSERIAL PRIMARY KEY,
  RCC_RCA_ID BIGINT NOT NULL REFERENCES RUTAS_CALIDAD(RCA_ID) ON UPDATE CASCADE ON DELETE CASCADE,
  RCC_ORD_ID BIGINT NOT NULL REFERENCES ORDENES(ORD_ID) ON UPDATE CASCADE ON DELETE CASCADE,
  -- Dónde se tomó la muestra, si el responsable lo quiere dejar anotado.
  RCC_PUESTO VARCHAR(64),
  RCC_OPERARIO VARCHAR(64),
  -- Se calcula a partir de los ítems: KO si alguno dio KO.
  RCC_RESULTADO VARCHAR(10) NOT NULL DEFAULT 'PENDIENTE',  -- PENDIENTE | OK | KO
  RCC_OBSERVACIONES VARCHAR(1000),
  RCC_FECHA TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aud_usr_ins varchar(250) NOT NULL,
  aud_usr_upd varchar(250) NOT NULL,
  aud_fecha_ins timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aud_fecha_upd timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- La misma orden no se controla dos veces en la misma recorrida.
CREATE UNIQUE INDEX IF NOT EXISTS ux_rcc_ruta_orden ON RUTAS_CALIDAD_CONTROLES(RCC_RCA_ID, RCC_ORD_ID);
CREATE INDEX IF NOT EXISTS ix_rcc_orden ON RUTAS_CALIDAD_CONTROLES(RCC_ORD_ID);

-- El resultado de cada punto de control sobre esa orden.
CREATE TABLE IF NOT EXISTS RUTAS_CALIDAD_ITEMS (
  RCI_ID BIGSERIAL PRIMARY KEY,
  RCI_RCC_ID BIGINT NOT NULL REFERENCES RUTAS_CALIDAD_CONTROLES(RCC_ID) ON UPDATE CASCADE ON DELETE CASCADE,
  RCI_PCO_ID BIGINT NOT NULL REFERENCES PUNTOS_CONTROL(PCO_ID) ON UPDATE CASCADE ON DELETE CASCADE,
  RCI_RESULTADO VARCHAR(10) NOT NULL DEFAULT 'PENDIENTE',  -- PENDIENTE | OK | KO | NA
  RCI_OBSERVACIONES VARCHAR(500),
  aud_usr_ins varchar(250) NOT NULL,
  aud_usr_upd varchar(250) NOT NULL,
  aud_fecha_ins timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aud_fecha_upd timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_rci_control_punto ON RUTAS_CALIDAD_ITEMS(RCI_RCC_ID, RCI_PCO_ID);
CREATE INDEX IF NOT EXISTS ix_rci_resultado ON RUTAS_CALIDAD_ITEMS(RCI_RESULTADO);
