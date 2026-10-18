-- liquibase formatted sql

-- =======================
--  POSICIÓN EN EL ORIGEN Y EN EL DESTINO
--
--  La sábana de corte cambió de formato: donde antes había una sola columna de
--  origen y una de destino, ahora hay dos de cada lado.
--
--  La primera dice **a qué va el cable**: un conector (C1, C3, C10) o una
--  soldadura (S1, S7). La segunda dice **en qué lugar de eso va**: el número de
--  cavidad del conector (1, 2, 3…) o, cuando es una soldadura, de qué lado
--  entra (IZQ, DER).
--
--  Van en columnas separadas y no pegadas en una sola porque son dos datos
--  distintos: el conector es el mismo para muchos cables y la posición es la
--  que cambia. Texto y no número: "IZQ" y "DER" también son posiciones.
-- =======================

-- changeset carmar:20261018_posicion_en_sabana
ALTER TABLE SABANAS_CORTE_DET
  ADD COLUMN IF NOT EXISTS SCD_POSICION_A VARCHAR(32);

ALTER TABLE SABANAS_CORTE_DET
  ADD COLUMN IF NOT EXISTS SCD_POSICION_B VARCHAR(32);

COMMENT ON COLUMN SABANAS_CORTE_DET.SCD_POSICION_A IS
  'Posición en el origen: cavidad del conector (1, 2, 3...) o lado de la soldadura (IZQ, DER)';

COMMENT ON COLUMN SABANAS_CORTE_DET.SCD_POSICION_B IS
  'Posición en el destino: cavidad del conector (1, 2, 3...) o lado de la soldadura (IZQ, DER)';
