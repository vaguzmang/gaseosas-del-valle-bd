-- =============================================
-- Proyecto: Gaseosas del Valle S.A.
-- Archivo: views_and_queries.sql
-- Descripción: vistas requeridas y consultas SQL
-- =============================================

USE gaseosas_del_valle;

DROP VIEW IF EXISTS vista_resumen_pedidos_por_sede;
DROP VIEW IF EXISTS vista_productos_bajo_stock;
DROP VIEW IF EXISTS vista_clientes_activos;

-- =============================================
-- VISTAS
-- =============================================

CREATE VIEW vista_resumen_pedidos_por_sede AS
SELECT
    s.id_sede,
    s.nombre_sede,
    s.ubicacion,
    COUNT(p.id_pedido) AS cantidad_pedidos,
    COALESCE(SUM(p.total_sin_iva), 0.00) AS ventas_sin_iva,
    COALESCE(SUM(p.total_con_iva), 0.00) AS ventas_con_iva
FROM sedes s
LEFT JOIN pedidos p
       ON p.id_sede = s.id_sede
GROUP BY s.id_sede, s.nombre_sede, s.ubicacion;

CREATE VIEW vista_productos_bajo_stock AS
SELECT
    id_producto,
    nombre,
    categoria,
    precio,
    volumen_ml,
    stock_actual,
    stock_minimo
FROM productos
WHERE stock_actual <= stock_minimo;

CREATE VIEW vista_clientes_activos AS
SELECT
    c.id_cliente,
    c.nombre_completo,
    c.identificacion,
    c.telefono,
    c.correo_electronico,
    COUNT(p.id_pedido) AS cantidad_pedidos,
    MAX(p.fecha_pedido) AS ultimo_pedido
FROM clientes c
INNER JOIN pedidos p
        ON p.id_cliente = c.id_cliente
GROUP BY
    c.id_cliente,
    c.nombre_completo,
    c.identificacion,
    c.telefono,
    c.correo_electronico;

-- =============================================
-- CONSULTAS REQUERIDAS
-- =============================================

-- 1. Consultar los productos con stock por debajo del mínimo.
SELECT *
FROM vista_productos_bajo_stock
ORDER BY stock_actual ASC, nombre ASC;

-- 2. Consultar los pedidos realizados entre dos fechas (BETWEEN).
SELECT
    p.id_pedido,
    p.fecha_pedido,
    c.nombre_completo AS cliente,
    s.nombre_sede,
    p.total_sin_iva,
    p.total_con_iva
FROM pedidos p
INNER JOIN clientes c ON c.id_cliente = p.id_cliente
INNER JOIN sedes s ON s.id_sede = p.id_sede
WHERE DATE(p.fecha_pedido) BETWEEN '2026-04-01' AND '2026-04-30'
ORDER BY p.fecha_pedido ASC;

-- 3. Listar los productos más vendidos (JOIN + GROUP BY).
SELECT
    pr.id_producto,
    pr.nombre,
    pr.categoria,
    SUM(dp.cantidad) AS unidades_vendidas,
    SUM(dp.subtotal) AS total_vendido_sin_iva
FROM detalle_pedido dp
INNER JOIN productos pr ON pr.id_producto = dp.id_producto
GROUP BY pr.id_producto, pr.nombre, pr.categoria
ORDER BY unidades_vendidas DESC, total_vendido_sin_iva DESC;

-- 4. Mostrar clientes y la cantidad de pedidos realizados.
SELECT
    c.id_cliente,
    c.nombre_completo,
    COUNT(p.id_pedido) AS cantidad_pedidos
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre_completo
ORDER BY cantidad_pedidos DESC, c.nombre_completo ASC;

-- 5. Buscar clientes por nombre parcial usando LIKE.
SELECT
    id_cliente,
    nombre_completo,
    identificacion,
    telefono,
    correo_electronico
FROM clientes
WHERE nombre_completo LIKE '%tienda%'
ORDER BY nombre_completo ASC;

-- 6. Consultar productos de ciertas categorías usando IN.
SELECT
    id_producto,
    nombre,
    categoria,
    precio,
    stock_actual
FROM productos
WHERE categoria IN ('Gaseosa', 'Agua', 'Energizante')
ORDER BY categoria ASC, nombre ASC;

-- 7. Mostrar el cliente con mayor número de pedidos (subconsulta).
SELECT
    c.id_cliente,
    c.nombre_completo,
    t.total_pedidos
FROM clientes c
INNER JOIN (
    SELECT id_cliente, COUNT(*) AS total_pedidos
    FROM pedidos
    GROUP BY id_cliente
) t ON t.id_cliente = c.id_cliente
WHERE t.total_pedidos = (
    SELECT MAX(sub.total_pedidos)
    FROM (
        SELECT COUNT(*) AS total_pedidos
        FROM pedidos
        GROUP BY id_cliente
    ) sub
);

-- 8. Consultar pedidos y sus totales agrupados por sede.
SELECT
    s.id_sede,
    s.nombre_sede,
    COUNT(p.id_pedido) AS cantidad_pedidos,
    COALESCE(SUM(p.total_sin_iva), 0.00) AS total_sin_iva_acumulado,
    COALESCE(SUM(p.total_con_iva), 0.00) AS total_con_iva_acumulado
FROM sedes s
LEFT JOIN pedidos p ON p.id_sede = s.id_sede
GROUP BY s.id_sede, s.nombre_sede
ORDER BY total_con_iva_acumulado DESC;

-- =============================================
-- CONSULTAS EXTRA DE APOYO
-- =============================================

-- Validar stock desde la función.
SELECT fn_validar_stock(1, 10) AS validacion_stock;

-- Obtener total con IVA de un pedido específico.
SELECT fn_calcular_total_con_iva(1) AS total_con_iva_pedido_1;

-- Ver pedidos resumidos por sede usando la vista.
SELECT *
FROM vista_resumen_pedidos_por_sede
ORDER BY ventas_con_iva DESC;

-- Ver clientes activos.
SELECT *
FROM vista_clientes_activos
ORDER BY cantidad_pedidos DESC, ultimo_pedido DESC;
