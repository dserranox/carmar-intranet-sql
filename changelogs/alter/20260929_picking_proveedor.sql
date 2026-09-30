--liquibase formatted sql

--changeset carmar:20260929_picking_codigo_proveedor
-- La sabana de picking ahora trae el codigo con el que el proveedor identifica
-- la pieza. Se guarda aparte del codigo interno: al buscar en el almacen a
-- veces lo unico que esta impreso en la bolsa es el del proveedor.
ALTER TABLE PICKINGS_DET ADD COLUMN PKD_CODIGO_PROVEEDOR VARCHAR(64);
CREATE INDEX IF NOT EXISTS ix_pkd_proveedor ON PICKINGS_DET(PKD_CODIGO_PROVEEDOR);
