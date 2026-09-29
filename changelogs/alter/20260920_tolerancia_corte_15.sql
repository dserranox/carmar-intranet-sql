-- Criterio de tolerancia del control de longitud definido por planta:
-- 0% hacia abajo y 1,5% hacia arriba. Queda como valor por defecto y se
-- aplica a las sábanas ya cargadas que todavía tienen el valor inicial.
ALTER TABLE SABANAS_CORTE ALTER COLUMN SAB_TOLERANCIA_SUP SET DEFAULT 1.500;

UPDATE SABANAS_CORTE
   SET SAB_TOLERANCIA_SUP = 1.500,
       AUD_USR_UPD = 'auto',
       AUD_FECHA_UPD = CURRENT_TIMESTAMP
 WHERE SAB_TOLERANCIA_SUP = 0.200
   AND SAB_ESTADO <> 'FINALIZADA';
