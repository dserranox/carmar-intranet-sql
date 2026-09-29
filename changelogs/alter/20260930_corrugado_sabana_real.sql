--liquibase formatted sql

--changeset carmar:20260930_corrugado_diametro_texto
-- El diametro del corrugado se nombra en pulgadas ("1/2", "3/4"), no en milimetros.
-- Se guarda tal cual lo escribe la sabana, y aparte en mm para poder dibujarlo
-- a escala y agrupar los controles.
ALTER TABLE SABANAS_CORTE_DET ADD COLUMN SCD_DIAMETRO_TXT VARCHAR(20);

--changeset carmar:20260930_corrugado_cantidades
-- Un renglon de corrugado no es un corte: es un lote.
--   SCD_CANT_POR_PRODUCTO = cuantos tramos de este largo lleva un producto
--   SCD_CANTIDAD          = cuantas piezas hay que cortar en total
ALTER TABLE SABANAS_CORTE_DET ADD COLUMN SCD_CANT_POR_PRODUCTO INT;
