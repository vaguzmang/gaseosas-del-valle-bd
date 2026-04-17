-- =========================================================
-- Proyecto: Gaseosas del Valle S.A.
-- Archivo: qa_simulacion_validacion.sql
-- Objetivo: validar de forma funcional y estructural que
-- los entregables cubren la rubrica del proyecto.
--
-- Orden sugerido antes de ejecutar este script:
-- 1) SOURCE database.sql;
-- 2) SOURCE functions.sql;
-- 3) SOURCE triggers.sql;
-- 4) SOURCE sample_data.sql;
-- 5) SOURCE views_and_queries.sql;
-- 6) SOURCE qa_simulacion_validacion.sql;
-- =========================================================

USE gaseosas_del_valle;

SELECT '===== 1) VALIDACION DE OBJETOS REQUERIDOS =====' AS seccion;

SELECT
  'tablas_requeridas' AS prueba,
  CASE
    WHEN COUNT(*) = 6 THEN 'OK'
    ELSE CONCAT('FALLA - tablas encontradas: ', COUNT(*))
  END AS resultado
FROM information_schema.tables
WHERE table_schema = 'gaseosas_del_valle'
  AND table_name IN (
    'sedes', 'clientes', 'productos', 'pedidos', 'detalle_pedido', 'auditoria_precios'
  )
  AND table_type = 'BASE TABLE';

SELECT
  'funciones_requeridas' AS prueba,
  CASE
    WHEN COUNT(*) = 2 THEN 'OK'
    ELSE CONCAT('FALLA - funciones encontradas: ', COUNT(*))
  END AS resultado
FROM information_schema.routines
WHERE routine_schema = 'gaseosas_del_valle'
  AND routine_type = 'FUNCTION'
  AND routine_name IN ('fn_calcular_total_con_iva', 'fn_validar_stock');

SELECT
  'triggers_requeridos' AS prueba,
  CASE
    WHEN COUNT(*) >= 2 THEN CONCAT('OK - encontrados ', COUNT(*), ' triggers')
    ELSE CONCAT('FALLA - triggers encontrados: ', COUNT(*))
  END AS resultado
FROM information_schema.triggers
WHERE trigger_schema = 'gaseosas_del_valle'
  AND trigger_name IN ('tr_actualizar_stock', 'tr_auditar_cambio_precio', 'tr_validar_stock_detalle');

SELECT
  'vistas_requeridas' AS prueba,
  CASE
    WHEN COUNT(*) = 3 THEN 'OK'
    ELSE CONCAT('FALLA - vistas encontradas: ', COUNT(*))
  END AS resultado
FROM information_schema.views
WHERE table_schema = 'gaseosas_del_valle'
  AND table_name IN (
    'vista_resumen_pedidos_por_sede',
    'vista_productos_bajo_stock',
    'vista_clientes_activos'
  );

SELECT '===== 2) VALIDACION DE RELACIONES Y ESTRUCTURA =====' AS seccion;

SELECT
  'claves_foraneas' AS prueba,
  CASE
    WHEN COUNT(*) = 5 THEN 'OK'
    ELSE CONCAT('FALLA - FKs encontradas: ', COUNT(*))
  END AS resultado
FROM information_schema.referential_constraints
WHERE constraint_schema = 'gaseosas_del_valle';

SELECT
  'pk_compuesta_detalle_pedido' AS prueba,
  CASE
    WHEN COUNT(*) = 2 THEN 'OK'
    ELSE CONCAT('FALLA - columnas en PK: ', COUNT(*))
  END AS resultado
FROM information_schema.key_column_usage
WHERE table_schema = 'gaseosas_del_valle'
  AND table_name = 'detalle_pedido'
  AND constraint_name = 'PRIMARY';

SELECT '===== 3) VALIDACION DE CARGA DE DATOS DE PRUEBA =====' AS seccion;

SELECT 'sedes_cargadas' AS prueba,
       CASE WHEN COUNT(*) = 3 THEN 'OK' ELSE CONCAT('FALLA - total: ', COUNT(*)) END AS resultado
FROM sedes;

SELECT 'clientes_cargados' AS prueba,
       CASE WHEN COUNT(*) = 6 THEN 'OK' ELSE CONCAT('FALLA - total: ', COUNT(*)) END AS resultado
FROM clientes;

SELECT 'productos_cargados' AS prueba,
       CASE WHEN COUNT(*) = 8 THEN 'OK' ELSE CONCAT('FALLA - total: ', COUNT(*)) END AS resultado
FROM productos;

SELECT 'pedidos_cargados' AS prueba,
       CASE WHEN COUNT(*) = 5 THEN 'OK' ELSE CONCAT('FALLA - total: ', COUNT(*)) END AS resultado
FROM pedidos;

SELECT 'detalles_cargados' AS prueba,
       CASE WHEN COUNT(*) = 11 THEN 'OK' ELSE CONCAT('FALLA - total: ', COUNT(*)) END AS resultado
FROM detalle_pedido;

SELECT 'auditoria_generada' AS prueba,
       CASE WHEN COUNT(*) >= 1 THEN CONCAT('OK - registros: ', COUNT(*)) ELSE 'FALLA - no hay auditoria' END AS resultado
FROM auditoria_precios;

SELECT '===== 4) VALIDACION DE FUNCIONES =====' AS seccion;

SELECT
  'fn_calcular_total_con_iva_pedido_1' AS prueba,
  CASE
    WHEN fn_calcular_total_con_iva(1) = 55930.00 THEN 'OK'
    ELSE CONCAT('FALLA - valor obtenido: ', fn_calcular_total_con_iva(1))
  END AS resultado;

SELECT
  'fn_validar_stock_ok' AS prueba,
  CASE
    WHEN fn_validar_stock(1, 10) LIKE 'Stock suficiente%' THEN fn_validar_stock(1, 10)
    ELSE CONCAT('FALLA - mensaje: ', fn_validar_stock(1, 10))
  END AS resultado;

SELECT
  'fn_validar_stock_insuficiente' AS prueba,
  CASE
    WHEN fn_validar_stock(8, 100) LIKE 'Stock insuficiente%' THEN fn_validar_stock(8, 100)
    ELSE CONCAT('FALLA - mensaje: ', fn_validar_stock(8, 100))
  END AS resultado;

SELECT '===== 5) VALIDACION DE RESULTADOS DE NEGOCIO =====' AS seccion;

SELECT
  'totales_pedidos_correctos' AS prueba,
  CASE
    WHEN COUNT(*) = 5 THEN 'OK'
    ELSE CONCAT('FALLA - pedidos correctos: ', COUNT(*), ' de 5')
  END AS resultado
FROM (
    SELECT id_pedido, total_sin_iva, total_con_iva
    FROM pedidos
    WHERE (id_pedido = 1 AND total_sin_iva = 47000.00 AND total_con_iva = 55930.00)
       OR (id_pedido = 2 AND total_sin_iva = 50500.00 AND total_con_iva = 60095.00)
       OR (id_pedido = 3 AND total_sin_iva = 37600.00 AND total_con_iva = 44744.00)
       OR (id_pedido = 4 AND total_sin_iva = 71400.00 AND total_con_iva = 84966.00)
       OR (id_pedido = 5 AND total_sin_iva = 59500.00 AND total_con_iva = 70805.00)
) t;

SELECT
  'stock_actual_correcto' AS prueba,
  CASE
    WHEN COUNT(*) = 8 THEN 'OK'
    ELSE CONCAT('FALLA - productos correctos: ', COUNT(*), ' de 8')
  END AS resultado
FROM (
    SELECT id_producto, stock_actual
    FROM productos
    WHERE (id_producto = 1 AND stock_actual = 98)
       OR (id_producto = 2 AND stock_actual = 82)
       OR (id_producto = 3 AND stock_actual = 32)
       OR (id_producto = 4 AND stock_actual = 20)
       OR (id_producto = 5 AND stock_actual = 124)
       OR (id_producto = 6 AND stock_actual = 53)
       OR (id_producto = 7 AND stock_actual = 31)
       OR (id_producto = 8 AND stock_actual = 14)
) t;

SELECT
  'auditoria_cambio_precio_producto_1' AS prueba,
  CASE
    WHEN COUNT(*) >= 1 THEN 'OK'
    ELSE 'FALLA - no se encontro auditoria del producto 1'
  END AS resultado
FROM auditoria_precios
WHERE id_producto = 1
  AND precio_anterior = 3500.00
  AND precio_nuevo = 3800.00;

SELECT '===== 6) VALIDACION DE VISTAS =====' AS seccion;

SELECT
  'vista_productos_bajo_stock' AS prueba,
  CASE
    WHEN COUNT(*) = 2 THEN 'OK'
    ELSE CONCAT('FALLA - filas obtenidas: ', COUNT(*))
  END AS resultado
FROM vista_productos_bajo_stock;

SELECT
  'vista_clientes_activos' AS prueba,
  CASE
    WHEN COUNT(*) = 4 THEN 'OK'
    ELSE CONCAT('FALLA - filas obtenidas: ', COUNT(*))
  END AS resultado
FROM vista_clientes_activos;

SELECT
  'vista_resumen_pedidos_por_sede' AS prueba,
  CASE
    WHEN COUNT(*) = 3 THEN 'OK'
    ELSE CONCAT('FALLA - filas obtenidas: ', COUNT(*))
  END AS resultado
FROM vista_resumen_pedidos_por_sede;

SELECT '===== 7) VALIDACION DE CONSULTAS REQUERIDAS =====' AS seccion;

SELECT
  'consulta_between' AS prueba,
  CASE
    WHEN COUNT(*) = 5 THEN 'OK'
    ELSE CONCAT('FALLA - filas obtenidas: ', COUNT(*))
  END AS resultado
FROM pedidos
WHERE DATE(fecha_pedido) BETWEEN '2026-04-01' AND '2026-04-30';

SELECT
  'consulta_like' AS prueba,
  CASE
    WHEN COUNT(*) = 2 THEN 'OK'
    ELSE CONCAT('FALLA - filas obtenidas: ', COUNT(*))
  END AS resultado
FROM clientes
WHERE nombre_completo LIKE '%tienda%';

SELECT
  'consulta_in' AS prueba,
  CASE
    WHEN COUNT(*) = 7 THEN 'OK'
    ELSE CONCAT('FALLA - filas obtenidas: ', COUNT(*))
  END AS resultado
FROM productos
WHERE categoria IN ('Gaseosa', 'Agua', 'Energizante');

SELECT
  'cliente_mayor_numero_pedidos' AS prueba,
  CASE
    WHEN COUNT(*) = 1 AND MAX(nombre_completo) = 'Supertienda Girón' THEN 'OK'
    ELSE CONCAT('FALLA - resultado distinto: ', COALESCE(MAX(nombre_completo), 'sin datos'))
  END AS resultado
FROM (
    SELECT c.nombre_completo, COUNT(p.id_pedido) AS total_pedidos
    FROM clientes c
    JOIN pedidos p ON p.id_cliente = c.id_cliente
    GROUP BY c.id_cliente, c.nombre_completo
    HAVING COUNT(p.id_pedido) = (
        SELECT MAX(t.total_pedidos)
        FROM (
            SELECT COUNT(*) AS total_pedidos
            FROM pedidos
            GROUP BY id_cliente
        ) t
    )
) x;

SELECT
  'producto_mas_vendido' AS prueba,
  CASE
    WHEN MAX(nombre) = 'Agua sin gas 600 ml' AND MAX(unidades_vendidas) = 26 THEN 'OK'
    ELSE CONCAT('FALLA - resultado distinto: ', MAX(nombre), ' / ', MAX(unidades_vendidas))
  END AS resultado
FROM (
    SELECT pr.nombre, SUM(dp.cantidad) AS unidades_vendidas
    FROM detalle_pedido dp
    JOIN productos pr ON pr.id_producto = dp.id_producto
    GROUP BY pr.id_producto, pr.nombre
    ORDER BY unidades_vendidas DESC
    LIMIT 1
) y;

SELECT '===== 8) PRUEBAS NEGATIVAS CONTROLADAS =====' AS seccion;
SELECT 'Estas pruebas deben ejecutarse una por una porque deben lanzar error intencionalmente.' AS nota;

SELECT 'NEGATIVA_1_STOCK_INSUFICIENTE' AS caso,
       'INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad) VALUES (1, 8, 999);' AS sentencia,
       'Resultado esperado: ERROR con mensaje Stock insuficiente...' AS esperado;

SELECT 'NEGATIVA_2_CANTIDAD_INVALIDA' AS caso,
       'INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad) VALUES (1, 2, 0);' AS sentencia,
       'Resultado esperado: ERROR con mensaje La cantidad del detalle debe ser mayor que cero' AS esperado;

SELECT 'NEGATIVA_3_PRODUCTO_INEXISTENTE' AS caso,
       'INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad) VALUES (1, 999, 1);' AS sentencia,
       'Resultado esperado: ERROR por FK o Producto no encontrado' AS esperado;

SELECT '===== 9) CHECK FINAL DE CONSISTENCIA =====' AS seccion;

SELECT
  'sin_stock_negativo' AS prueba,
  CASE
    WHEN COUNT(*) = 0 THEN 'OK'
    ELSE CONCAT('FALLA - productos con stock negativo: ', COUNT(*))
  END AS resultado
FROM productos
WHERE stock_actual < 0;

SELECT
  'sin_pedidos_huerfanos' AS prueba,
  CASE
    WHEN COUNT(*) = 0 THEN 'OK'
    ELSE CONCAT('FALLA - pedidos huerfanos: ', COUNT(*))
  END AS resultado
FROM pedidos p
LEFT JOIN clientes c ON c.id_cliente = p.id_cliente
LEFT JOIN sedes s ON s.id_sede = p.id_sede
WHERE c.id_cliente IS NULL OR s.id_sede IS NULL;

SELECT
  'sin_detalles_huerfanos' AS prueba,
  CASE
    WHEN COUNT(*) = 0 THEN 'OK'
    ELSE CONCAT('FALLA - detalles huerfanos: ', COUNT(*))
  END AS resultado
FROM detalle_pedido d
LEFT JOIN pedidos p ON p.id_pedido = d.id_pedido
LEFT JOIN productos pr ON pr.id_producto = d.id_producto
WHERE p.id_pedido IS NULL OR pr.id_producto IS NULL;
