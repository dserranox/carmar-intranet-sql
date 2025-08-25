-- Orden de borrado por dependencias
DROP TABLE IF EXISTS OPERACIONES CASCADE;


-- =======================
--  OPERACIONES
-- =======================
CREATE TABLE IF NOT EXISTS OPERACIONES (
  OPE_ID BIGSERIAL PRIMARY KEY,
  OPE_NOMBRE VARCHAR(255) NOT NULL,
  OPE_NOMBRE_CORTO VARCHAR(10) NOT NULL,
  OPE_DESCRIPCION VARCHAR(255),
  OPE_GRUPO VARCHAR(100),
  OPE_ORDEN INT NOT NULL
);


-- =======================
--  DATOS PRUEBAS
-- =======================
INSERT INTO OPERACIONES(OPE_NOMBRE,OPE_NOMBRE_CORTO,OPE_DESCRIPCION,OPE_GRUPO,OPE_ORDEN) VALUES 
    ('CORTE MANUAL CABLE','CMC', 'Corte manual de cacble', 'CORTE MANUAL', 1),
    ('CORTE MANUAL CORRUGADO','CMCo', 'Corte manual Corrugado', 'CORTE MANUAL', 2),
    ('CORTE MANUAL ESPAGUETI','CME', 'Corte Manual Espagueti', 'CORTE MANUAL', 3),
    ('CORTE MANUAL TERMOC.','CMT', 'Corte Manual termoc.', 'CORTE MANUAL', 4),
    ('CORTE AUTO. CABLE','CAC', 'Corte Auto. Cable', 'CORTE AUTO.', 5),
    ('CORTE AUTO. CORRUGADO','CACo', 'Corte automatico Corrugado', 'CORTE AUTO.', 6),
    ('CORTE AUTO. ESPAGUETI','CAE', 'Corte Auto. espagueti', 'CORTE AUTO.', 7),
    ('CORTE AUTO. TERMO.','CAT', 'Corte Auto. Termo.', 'CORTE AUTO.', 8),
    ('ARMADO','AR', 'Armado', 'ARMADO', 9),
    ('SPLICING','ES', 'Empalme Splicing', 'EMPALME', 10),
    ('AUTO. C/SELLO','CRAS', 'Cripeado Automatico con sello', 'CRIPEADO AUTOMATICO', 11),
    ('OPERACION ESPECIAL','OE', 'Todo proceso que no sea: corte, armado, empalme, crimpeado, ficchado, terrminación y control.', 'OPERACION ESPECIAL', 12)
ON CONFLICT DO NOTHING;