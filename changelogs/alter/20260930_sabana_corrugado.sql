--liquibase formatted sql

--changeset carmar:20260930_sabana_tipo
-- La sabana de corrugado usa la misma estructura que la de cable: cambia lo
-- que se corta, no el circuito (importar, asignar, cortar, controlar, suspender).
ALTER TABLE SABANAS_CORTE ADD COLUMN SAB_TIPO VARCHAR(20) NOT NULL DEFAULT 'CABLE';
CREATE INDEX IF NOT EXISTS ix_sab_tipo ON SABANAS_CORTE(SAB_TIPO, SAB_ESTADO);

--changeset carmar:20260930_corrugado_columnas
-- Datos propios del corrugado. No hay gap ni pelado: solo largo, diametro,
-- tipo (abierto o cerrado) y el programa de la maquina.
ALTER TABLE SABANAS_CORTE_DET ADD COLUMN SCD_DIAMETRO NUMERIC(6,2);
ALTER TABLE SABANAS_CORTE_DET ADD COLUMN SCD_TIPO_CORRUGADO VARCHAR(10);
ALTER TABLE SABANAS_CORTE_DET ADD COLUMN SCD_PROGRAMA VARCHAR(64);
