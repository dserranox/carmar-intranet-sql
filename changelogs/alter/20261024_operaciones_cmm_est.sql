-- liquibase formatted sql

-- =======================
--  DOS OPERACIONES NUEVAS: CORTE MANUAL DE MALLA Y ESTAÑADO
--
--  Las dos son de ARMADO y se asignan como el resto del trabajo de línea.
--
--  Ojo con la sigla del estañado: en planta lo llaman ES, pero esa sigla ya
--  está tomada por el empalme splicing, así que entra como EST. Cambiarle la
--  sigla al splicing habría dejado las tareas viejas mostrando otra cosa.
--
--  OPE_ORDEN es solo el orden en que se listan. Cada una se inserta en su
--  grupo —el estañado con los empalmes, el corte de malla con el mallado— y
--  para eso hay que correr un lugar a las que vienen después. El corrimiento
--  está condicionado a que la operación no exista todavía, así que volver a
--  correr esto no mueve nada dos veces.
-- =======================

-- changeset carmar:20261024_operacion_estanado
UPDATE OPERACIONES
   SET OPE_ORDEN = OPE_ORDEN + 1
 WHERE OPE_ORDEN > 6
   AND NOT EXISTS (SELECT 1 FROM OPERACIONES WHERE OPE_NOMBRE_CORTO = 'EST');

INSERT INTO OPERACIONES (OPE_NOMBRE, OPE_NOMBRE_CORTO, OPE_DESCRIPCION, OPE_GRUPO, OPE_ORDEN, OPE_AREA, OPE_ASIGNABLE)
SELECT 'Estañado', 'EST', 'Estañado de puntas de cable', 'Empalme', 7, 'ARMADO', TRUE
 WHERE NOT EXISTS (SELECT 1 FROM OPERACIONES WHERE OPE_NOMBRE_CORTO = 'EST');

-- changeset carmar:20261024_operacion_corte_manual_malla
UPDATE OPERACIONES
   SET OPE_ORDEN = OPE_ORDEN + 1
 WHERE OPE_ORDEN > 11
   AND NOT EXISTS (SELECT 1 FROM OPERACIONES WHERE OPE_NOMBRE_CORTO = 'CMM');

INSERT INTO OPERACIONES (OPE_NOMBRE, OPE_NOMBRE_CORTO, OPE_DESCRIPCION, OPE_GRUPO, OPE_ORDEN, OPE_AREA, OPE_ASIGNABLE)
SELECT 'Corte manual de malla', 'CMM', 'Corte de malla hecho a mano', 'Mallado', 12, 'ARMADO', TRUE
 WHERE NOT EXISTS (SELECT 1 FROM OPERACIONES WHERE OPE_NOMBRE_CORTO = 'CMM');
