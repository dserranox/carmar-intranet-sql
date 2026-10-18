-- liquibase formatted sql

-- =======================
--  PERMISOS DE BASE PARA LOS USUARIOS DE LA APLICACIÓN
--
--  Producción tiene tres usuarios separados, y está bien que así sea:
--    carmarliquibase  dueño de las tablas, el único que migra
--    carmarapp        el de la aplicación: lee y escribe datos, no toca estructura
--    carmarconsulta   sólo lectura
--
--  El problema: los changelogs crean tablas pero nunca otorgaron privilegios, así
--  que cada tabla nueva nacía inaccesible para la aplicación. Se descubrió en
--  producción el 18/10/2026: asignar trabajo fallaba con "permission denied for
--  table asignaciones", porque las 19 tablas creadas en el despliegue anterior
--  habían quedado sin permisos.
--
--  Esto hace dos cosas: repara lo que ya existe y, con ALTER DEFAULT PRIVILEGES,
--  deja arreglado el futuro — toda tabla que cree el dueño de ahora en más nace
--  con los permisos puestos.
--
--  Los entornos de desarrollo usan un único usuario y no tienen estos roles, así
--  que cada bloque se saltea solo si el rol no existe. Es idempotente: se puede
--  correr las veces que haga falta.
-- =======================

-- El bloque va entero: splitStatements:false evita que Liquibase lo corte en los
-- punto y coma de adentro.
-- changeset carmar:20261018_permisos_tablas_existentes splitStatements:false
DO $$
DECLARE
  duenio text := current_user;
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'carmarapp') THEN
    EXECUTE 'GRANT USAGE ON SCHEMA public TO carmarapp';
    EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO carmarapp';
    EXECUTE 'GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO carmarapp';
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA public '
                || 'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO carmarapp', duenio);
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA public '
                || 'GRANT USAGE, SELECT ON SEQUENCES TO carmarapp', duenio);
    RAISE NOTICE 'Permisos otorgados a carmarapp';
  ELSE
    RAISE NOTICE 'No existe el rol carmarapp: se saltea (entorno de un solo usuario)';
  END IF;

  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'carmarconsulta') THEN
    EXECUTE 'GRANT USAGE ON SCHEMA public TO carmarconsulta';
    EXECUTE 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO carmarconsulta';
    EXECUTE 'GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO carmarconsulta';
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA public '
                || 'GRANT SELECT ON TABLES TO carmarconsulta', duenio);
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA public '
                || 'GRANT SELECT ON SEQUENCES TO carmarconsulta', duenio);
    RAISE NOTICE 'Permisos otorgados a carmarconsulta';
  ELSE
    RAISE NOTICE 'No existe el rol carmarconsulta: se saltea';
  END IF;
END
$$;
