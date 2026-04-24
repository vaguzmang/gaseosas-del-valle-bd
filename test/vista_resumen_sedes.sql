USE gaseosas_del_valle;

DROP VIEW IF EXISTS vista_resumen_sedes;

CREATE VIEW vista_resumen_sedes AS
SELECT
    s.nombre_sede,
    s.id_pedido,
    s.id_sede,
    COUNT(p.id_pedido) AS cantidad_pedidos,
    COALESCE(SUM(p.total_sin_iva), 0.00) AS ventas_sin_iva,
FROM sedes s
LEFT JOIN pedidos p
       ON p.id_sede = s.id_sede
GROUP BY s.id_sede, s.id_sede;