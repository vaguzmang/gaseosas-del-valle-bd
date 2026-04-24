

--Registre en una tabla auditoria_precios los campos:
--id_producto, precio_anterior, precio_nuevo, fecha_modificacion.
--Solo se debe registrar si el precio realmente cambio .


USE gaseosas_del_valle;

CREATE TABLE auditoria_precios (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    precio_anterior decimal(10,2) NOT NULL,
    precio_nuevo decimal(10,2) NOT NULL,
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
 );

--Crear una funcion MySQL llamada calcular_promedio_pedidos_cliente que:
--Reciba como para metro el ID de un cliente.
--Retorne el promedio del total (sin IVA) de todos los pedidos realizados por ese cliente.
--Si el cliente no tiene pedidos, retorne 0.


USE gaseosas_del_valle;

DROP FUNCTION IF EXISTS fn_calcular_promedio_pedidos_cliente;


DELIMITER $$

CREATE FUNCTION fn_calcular_promedio_pedidos_cliente;(c_id_cliente INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_total_sin_iva DECIMAL(12,2) DEFAULT 0.00;

    SELECT COALESCE(SUM(subtotal), 0.00)
      INTO v_total_sin_iva
      FROM detalle_pedido
     WHERE id_pedido = p_id_pedido;

    RETURN ROUND(v_total_sin_iva * 1.19, 2);
END$$

--Crear una vista llamada vista_resumen_sedes que:
--Muestre por cada sede:
--Nombre de la sede
--Cantidad total de pedidos despachados
--Valor total vendido (sin IVA)
--Promedio de valor por pedido
--La vista debe usar JOIN entre pedidos y sedes, y agrupar correctamente los
resultados.


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


--Realizar una consulta con subconsulta que:
--Muestre el nombre del producto, categorí a y stock
--Solo incluya los productos cuyo precio sea mayor al promedio general de precios de todos
--los productos.
--Crear un trigger llamado auditar_cambio_precio que:
--Se ejecute despues de un UPDATE en la tabla de productos.


USE gaseosas_del_valle;


DROP TRIGGER IF EXISTS tr_auditar_cambio_precio;

DELIMITER $$

CREATE TRIGGER tr_auditar_cambio_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO auditoria_precios (
            id_producto,
            precio_anterior,
            precio_nuevo,
            fecha_cambio,
            usuario_bd
        )
        VALUES (
            NEW.id_producto,
            OLD.precio,
            NEW.precio,
            NOW(),
            CURRENT_USER()
        );
    END IF;
END$$

DELIMITER;

