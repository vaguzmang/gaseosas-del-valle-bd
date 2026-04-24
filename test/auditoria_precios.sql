USE gaseosas_del_valle;

CREATE TABLE auditoria_precios (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    precio_anterior decimal(10,2) NOT NULL,
    precio_nuevo decimal(10,2) NOT NULL,
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
 );