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