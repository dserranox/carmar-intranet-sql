-- =======================
--  QUIÉN DEFINE LOS CRITERIOS DE CALIDAD
--  Las fuerzas de tracción las definen calidad, jefatura y administración.
--  Leerlos lo puede hacer cualquiera que los necesite: el operario tiene que
--  saber contra qué se mide antes de tirar.
--  Va en un permiso propio y no en CALIDAD:WRITE porque el jefe de producción
--  define criterios pero sigue sin cargar controles.
-- =======================

INSERT INTO PERMISOS (PRM_CLAVE, PRM_DESCRIPCION) VALUES
  ('CRITERIOS:WRITE', 'Definir los criterios de calidad: fuerzas de tracción y tolerancias')
ON CONFLICT (PRM_CLAVE) DO NOTHING;

INSERT INTO ROLES_PERMISOS (RP_ROL_ID, RP_PRM_ID)
SELECT r.ROL_ID, p.PRM_ID
FROM ROLES r, PERMISOS p
WHERE r.ROL_NOMBRE IN ('ADMIN', 'CALIDAD', 'JEFE_PRODUCCION')
  AND p.PRM_CLAVE = 'CRITERIOS:WRITE'
  AND NOT EXISTS (
    SELECT 1 FROM ROLES_PERMISOS rp
    WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID);
