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