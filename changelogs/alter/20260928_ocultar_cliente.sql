-- =======================
--  EL CLIENTE NO SE MUESTRA EN PLANTA
--  Ni los operarios, en ninguno de sus roles, ni el jefe de producción deben
--  ver para qué cliente se fabrica: solo el código y el nombre del producto.
--  Como para dar de alta una orden hay que elegir un cliente, el jefe de
--  producción deja de crear órdenes y productos; planifica y asigna.
-- =======================

DELETE FROM ROLES_PERMISOS rp
USING ROLES r, PERMISOS p
WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID
  AND r.ROL_NOMBRE = 'OPERARIO'
  AND p.PRM_CLAVE = 'CLIENTES:READ';

DELETE FROM ROLES_PERMISOS rp
USING ROLES r, PERMISOS p
WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID
  AND r.ROL_NOMBRE = 'CALIDAD'
  AND p.PRM_CLAVE = 'CLIENTES:READ';

DELETE FROM ROLES_PERMISOS rp
USING ROLES r, PERMISOS p
WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID
  AND r.ROL_NOMBRE = 'JEFE_PRODUCCION'
  AND p.PRM_CLAVE IN ('CLIENTES:READ', 'ORDENES:WRITE', 'PRODUCTOS:WRITE');
