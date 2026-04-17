-- =============================================
-- Proyecto: Gaseosas del Valle S.A.
-- Archivo: functions.sql
-- Descripción: funciones personalizadas
-- =============================================

USE gaseosas_del_valle;

DROP FUNCTION IF EXISTS fn_calcular_total_con_iva;
DROP FUNCTION IF EXISTS fn_validar_stock;

DELIMITER $$

CREATE FUNCTION fn_calcular_total_con_iva(p_id_pedido INT)
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

CREATE FUNCTION fn_validar_stock(p_id_producto INT, p_cantidad INT)
RETURNS VARCHAR(255)
READS SQL DATA
BEGIN
    DECLARE v_stock_actual INT DEFAULT NULL;
    DECLARE v_nombre_producto VARCHAR(120) DEFAULT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_stock_actual = NULL, v_nombre_producto = NULL;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        RETURN 'Cantidad inválida';
    END IF;

    SELECT stock_actual, nombre
      INTO v_stock_actual, v_nombre_producto
      FROM productos
     WHERE id_producto = p_id_producto
     LIMIT 1;

    IF v_stock_actual IS NULL THEN
        RETURN 'Producto no encontrado';
    END IF;

    IF v_stock_actual >= p_cantidad THEN
        RETURN CONCAT(
            'Stock suficiente. Disponible: ',
            v_stock_actual,
            ' unidades de ',
            v_nombre_producto
        );
    END IF;

    RETURN CONCAT(
        'Stock insuficiente. Disponible: ',
        v_stock_actual,
        ' unidades de ',
        v_nombre_producto
    );
END$$

DELIMITER ;
