-- Las secuencias de IDs quedaron atrás del contenido real de las tablas (pasa cuando
-- los datos se cargan con IDs explícitos, por ejemplo al restaurar un backup). Eso hace
-- que el primer INSERT nuevo falle con "duplicate key value violates unique constraint".
-- Se reposicionan al máximo ID existente. Es idempotente: se puede volver a correr.
SELECT setval(pg_get_serial_sequence('clientes', 'cli_id'), COALESCE((SELECT MAX(cli_id) FROM clientes), 1), (SELECT COUNT(*) > 0 FROM clientes));
SELECT setval(pg_get_serial_sequence('productos', 'prd_id'), COALESCE((SELECT MAX(prd_id) FROM productos), 1), (SELECT COUNT(*) > 0 FROM productos));
SELECT setval(pg_get_serial_sequence('ordenes', 'ord_id'), COALESCE((SELECT MAX(ord_id) FROM ordenes), 1), (SELECT COUNT(*) > 0 FROM ordenes));
SELECT setval(pg_get_serial_sequence('situaciones', 'sit_id'), COALESCE((SELECT MAX(sit_id) FROM situaciones), 1), (SELECT COUNT(*) > 0 FROM situaciones));
SELECT setval(pg_get_serial_sequence('operaciones', 'ope_id'), COALESCE((SELECT MAX(ope_id) FROM operaciones), 1), (SELECT COUNT(*) > 0 FROM operaciones));
SELECT setval(pg_get_serial_sequence('usuarios', 'usr_id'), COALESCE((SELECT MAX(usr_id) FROM usuarios), 1), (SELECT COUNT(*) > 0 FROM usuarios));
SELECT setval(pg_get_serial_sequence('roles', 'rol_id'), COALESCE((SELECT MAX(rol_id) FROM roles), 1), (SELECT COUNT(*) > 0 FROM roles));
SELECT setval(pg_get_serial_sequence('permisos', 'prm_id'), COALESCE((SELECT MAX(prm_id) FROM permisos), 1), (SELECT COUNT(*) > 0 FROM permisos));
SELECT setval(pg_get_serial_sequence('tareas', 'tar_id'), COALESCE((SELECT MAX(tar_id) FROM tareas), 1), (SELECT COUNT(*) > 0 FROM tareas));
SELECT setval(pg_get_serial_sequence('producto_documentos', 'pdo_id'), COALESCE((SELECT MAX(pdo_id) FROM producto_documentos), 1), (SELECT COUNT(*) > 0 FROM producto_documentos));
