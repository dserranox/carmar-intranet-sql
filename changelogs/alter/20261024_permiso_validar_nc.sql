-- liquibase formatted sql

-- =======================
--  QUIÉN VALIDA UNA NO CONFORMIDAD
--
--  Cualquiera puede reportar una no conformidad, pero decidir si realmente lo
--  es —y si por lo tanto cuenta en los indicadores— es de calidad, del jefe de
--  producción y del administrador.
--
--  Va en un permiso propio y no en CALIDAD:WRITE porque el jefe de producción
--  valida no conformidades pero no carga controles de calidad.
--
--  El mismo permiso habilita anular una NC ya validada que estaba mal cargada
--  o repetida: es la misma decisión, en otro momento.
-- =======================

-- changeset carmar:20261024_permiso_validar_nc
INSERT INTO PERMISOS (PRM_CLAVE, PRM_DESCRIPCION) VALUES
  ('NC:VALIDAR', 'Validar, rechazar o anular una no conformidad')
ON CONFLICT (PRM_CLAVE) DO NOTHING;

INSERT INTO ROLES_PERMISOS (RP_ROL_ID, RP_PRM_ID)
SELECT r.ROL_ID, p.PRM_ID
FROM ROLES r, PERMISOS p
WHERE r.ROL_NOMBRE IN ('ADMIN', 'CALIDAD', 'JEFE_PRODUCCION')
  AND p.PRM_CLAVE = 'NC:VALIDAR'
  AND NOT EXISTS (
    SELECT 1 FROM ROLES_PERMISOS rp
    WHERE rp.RP_ROL_ID = r.ROL_ID AND rp.RP_PRM_ID = p.PRM_ID);
