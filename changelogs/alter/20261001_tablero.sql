-- =======================
--  TABLERO DE COMANDOS
--  Un permiso propio para la pantalla de indicadores: la mira quien conduce la
--  planta, no quien la opera. Como cualquier otra pantalla, después se reparte
--  desde la pantalla de roles.
-- =======================

INSERT INTO PERMISOS (PRM_CLAVE, PRM_DESCRIPCION) VALUES
  ('TABLERO:READ', 'Ver el tablero de comandos con los indicadores de la planta')
ON CONFLICT (PRM_CLAVE) DO NOTHING;

INSERT INTO ROLES_PERMISOS (RP_ROL_ID, RP_PRM_ID)
SELECT r.ROL_ID, p.PRM_ID
FROM ROLES r, PERMISOS p
WHERE r.ROL_NOMBRE IN ('ADMIN', 'JEFE_PRODUCCION', 'CONSULTA')
  AND p.PRM_CLAVE = 'TABLERO:READ'
  AND NOT EXISTS (
    SELECT 1 FROM ROLES_PERMISOS rp
    WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID);
