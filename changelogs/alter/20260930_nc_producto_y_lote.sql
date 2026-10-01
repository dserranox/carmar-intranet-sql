-- =======================
--  PRODUCTO Y LOTE EN LA NO CONFORMIDAD
--  Hasta ahora la trazabilidad solo se llenaba sola, cuando la NC nacía de un KO.
--  La que abre calidad por su cuenta quedaba sin producto y sin lote, que es
--  justo lo que hace falta para encontrar el material después.
-- =======================

ALTER TABLE NO_CONFORMIDADES
  ADD COLUMN IF NOT EXISTS NCF_LOTE VARCHAR(64);

COMMENT ON COLUMN NO_CONFORMIDADES.NCF_LOTE IS
  'Lote sobre el que se detectó el desvío, como lo identifica planta';
