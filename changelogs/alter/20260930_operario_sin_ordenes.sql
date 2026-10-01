-- =======================
--  EL OPERARIO NO VE LA PANTALLA DE ÓRDENES
--  Su trabajo le llega asignado a MI TRABAJO; el listado de órdenes no es suyo.
--  Hasta ahora el menú lo escondía a mano, pero el permiso seguía puesto: con el
--  menú armado por permisos, ORDENES:READ se lo volvería a mostrar.
--  La única pantalla que usaba ORDENES:READ es el listado de órdenes, así que
--  sacarlo no le quita nada de lo que hace.
-- =======================

DELETE FROM ROLES_PERMISOS rp
USING ROLES r, PERMISOS p
WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID
  AND r.ROL_NOMBRE = 'OPERARIO'
  AND p.PRM_CLAVE = 'ORDENES:READ';
