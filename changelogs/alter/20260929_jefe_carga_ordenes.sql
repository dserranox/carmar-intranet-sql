-- =======================
--  EL JEFE DE PRODUCCIÓN VUELVE A CARGAR ÓRDENES
--  La carga sin cliente: el cliente dejó de ser obligatorio y se lo asigna el
--  administrador después. Sigue sin ver para qué cliente se fabrica, que era
--  el motivo por el que se le había sacado el permiso.
-- =======================
INSERT INTO ROLES_PERMISOS (RP_ROL_ID, RP_PRM_ID)
SELECT r.ROL_ID, p.PRM_ID
FROM ROLES r, PERMISOS p
WHERE r.ROL_NOMBRE = 'JEFE_PRODUCCION'
  AND p.PRM_CLAVE IN ('ORDENES:WRITE', 'PRODUCTOS:WRITE')
  AND NOT EXISTS (
    SELECT 1 FROM ROLES_PERMISOS rp WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID);
