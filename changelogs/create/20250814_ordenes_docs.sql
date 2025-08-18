-- Orden de borrado por dependencias
DROP TABLE IF EXISTS ORDENES_DOCUMENTOS CASCADE;


-- =======================
--  ORDENES_DOCUMENTOS
-- =======================
CREATE TABLE IF NOT EXISTS ORDENES_DOCUMENTOS (
  ODO_ID BIGSERIAL PRIMARY KEY,
  ODO_NOMBRE VARCHAR(255) NOT NULL,
  ODO_DRIVE_URL VARCHAR(1024) NOT NULL,
  ODO_ORD_ID BIGINT NOT NULL
);

ALTER TABLE ORDENES_DOCUMENTOS
  ADD CONSTRAINT fk_ordenes_documento_orden
    FOREIGN KEY (ODO_ORD_ID) REFERENCES ORDENES(ORD_ID) ON UPDATE CASCADE ON DELETE SET NULL;

-- =======================
--  DATOS PRUEBAS
-- =======================
INSERT INTO ORDENES_DOCUMENTOS(ODO_NOMBRE,ODO_DRIVE_URL,ODO_ORD_ID) VALUES 
    ('VIGENTE - REV1 - C8309 - ARNES LUCES DE TRASLADO GEOSPOT.pdf','https://drive.google.com/file/d/1AggRe3Y8IZxdamRFlStW4YRqfgi4t73y/view?usp=drive_link', 2),
    ('cba-sticker.pdf','https://drive.google.com/file/d/12cqDdwtc-eSScPrzXtoicLjIbEpqJAVM/view?usp=drive_link', 2)
ON CONFLICT DO NOTHING;