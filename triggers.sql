-- =============================================
-- Proyecto: Gaseosas del Valle S.A.
-- Archivo: triggers.sql
-- Descripción: triggers para validación, stock,
-- totales del pedido y auditoría de precios.
-- =============================================

USE gaseosas_del_valle;

DROP TRIGGER IF EXISTS tr_validar_stock_detalle;
DROP TRIGGER IF EXISTS tr_actualizar_stock;
DROP TRIGGER IF EXISTS tr_auditar_cambio_precio;

DELIMITER $$

CREATE TRIGGER tr_validar_stock_detalle
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    DECLARE v_stock_actual INT DEFAULT NULL;
    DECLARE v_precio DECIMAL(10,2) DEFAULT NULL;
    DECLARE v_mensaje VARCHAR(255) DEFAULT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_stock_actual = NULL, v_precio = NULL;

    IF NEW.cantidad IS NULL OR NEW.cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cantidad del detalle debe ser mayor que cero';
    END IF;

    SELECT stock_actual, precio
      INTO v_stock_actual, v_precio
      FROM productos
     WHERE id_producto = NEW.id_producto
     FOR UPDATE;

    IF v_stock_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Producto no encontrado';
    END IF;

    IF v_stock_actual < NEW.cantidad THEN
        SET v_mensaje = fn_validar_stock(NEW.id_producto, NEW.cantidad);
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = v_mensaje;
    END IF;

    SET NEW.subtotal = ROUND(NEW.cantidad * v_precio, 2);
END$$

CREATE TRIGGER tr_actualizar_stock
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE productos
       SET stock_actual = stock_actual - NEW.cantidad
     WHERE id_producto = NEW.id_producto;

    UPDATE pedidos
       SET total_sin_iva = (
                SELECT COALESCE(SUM(subtotal), 0.00)
                  FROM detalle_pedido
                 WHERE id_pedido = NEW.id_pedido
           ),
           total_con_iva = fn_calcular_total_con_iva(NEW.id_pedido)
     WHERE id_pedido = NEW.id_pedido;
END$$

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

DELIMITER ;
