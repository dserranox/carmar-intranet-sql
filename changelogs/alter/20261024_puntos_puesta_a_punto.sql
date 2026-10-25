-- liquibase formatted sql

-- =======================
--  PUESTA A PUNTO JUNTO A LOS PUNTOS DE CONTROL
--
--  Los puntos de control son la lista que el responsable de calidad recorre en
--  cada orden. Las puestas a punto que hace él mismo —ajustar una máquina,
--  cambiar un útil, calibrar— no tenían dónde anotarse: había que inventar un
--  proceso para registrarlas.
--
--  En vez de una tabla nueva, los puntos pasan a tener tipo. La recorrida sigue
--  siendo una sola y las puestas a punto se marcan igual que un control, pero
--  quedan separadas para poder contarlas aparte.
-- =======================

-- changeset carmar:20261024_punto_control_tipo
ALTER TABLE PUNTOS_CONTROL
  ADD COLUMN IF NOT EXISTS PCO_TIPO VARCHAR(20) NOT NULL DEFAULT 'CONTROL';

COMMENT ON COLUMN PUNTOS_CONTROL.PCO_TIPO IS
  'CONTROL (se verifica) | PUESTA_A_PUNTO (se hace sobre la máquina o el puesto)';
