-- La fuerza mínima de tracción pasa a poder definirse por sección (valor general)
-- y, si hace falta, afinarse para un terminal puntual de esa misma sección.
ALTER TABLE TRACCION_MINIMA ADD COLUMN IF NOT EXISTS TRM_TERMINAL VARCHAR(64);
ALTER TABLE TRACCION_MINIMA ADD COLUMN IF NOT EXISTS TRM_OBSERVACIONES VARCHAR(255);

DROP INDEX IF EXISTS uq_trm_seccion;

-- Una sola fila general por sección, y una sola por sección + terminal.
CREATE UNIQUE INDEX IF NOT EXISTS uq_trm_seccion_general
  ON TRACCION_MINIMA(TRM_SECCION) WHERE TRM_TERMINAL IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_trm_seccion_terminal
  ON TRACCION_MINIMA(TRM_SECCION, TRM_TERMINAL) WHERE TRM_TERMINAL IS NOT NULL;

UPDATE TRACCION_MINIMA
   SET TRM_OBSERVACIONES = 'Valor orientativo IEC 60352-2, a ajustar con mediciones de planta'
 WHERE TRM_OBSERVACIONES IS NULL
   AND AUD_USR_INS = 'auto';

-- Permiso para administrar los valores de referencia de calidad.
INSERT INTO PERMISOS (PRM_CLAVE, PRM_DESCRIPCION) VALUES
  ('CALIDAD:WRITE','Definir los valores de referencia de los controles de calidad')
ON CONFLICT DO NOTHING;

INSERT INTO ROLES_PERMISOS (RP_ROL_ID, RP_PRM_ID)
SELECT r.ROL_ID, p.PRM_ID
FROM ROLES r
JOIN PERMISOS p ON p.PRM_CLAVE = 'CALIDAD:WRITE'
WHERE r.ROL_NOMBRE = 'ADMIN'
  AND NOT EXISTS (
    SELECT 1 FROM ROLES_PERMISOS rp
    WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID
  );
