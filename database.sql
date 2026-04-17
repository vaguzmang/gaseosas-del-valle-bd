-- =============================================
-- Proyecto: Gaseosas del Valle S.A.
-- Archivo: database.sql
-- Descripción: creación de base de datos, tablas,
-- restricciones, índices y relaciones.
-- Motor recomendado: MySQL 8.0+
-- =============================================

DROP DATABASE IF EXISTS gaseosas_del_valle;
CREATE DATABASE gaseosas_del_valle
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE gaseosas_del_valle;

-- =========================
-- Tabla: sedes
-- =========================
CREATE TABLE sedes (
    id_sede INT AUTO_INCREMENT PRIMARY KEY,
    nombre_sede VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(150) NOT NULL,
    capacidad_almacenamiento INT NOT NULL,
    encargado VARCHAR(100) NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_sedes_nombre UNIQUE (nombre_sede),
    CONSTRAINT chk_sedes_capacidad CHECK (capacidad_almacenamiento > 0)
) ENGINE=InnoDB;

-- =========================
-- Tabla: clientes
-- =========================
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(120) NOT NULL,
    identificacion VARCHAR(20) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    correo_electronico VARCHAR(120),
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT uq_clientes_identificacion UNIQUE (identificacion),
    CONSTRAINT uq_clientes_correo UNIQUE (correo_electronico)
) ENGINE=InnoDB;

-- =========================
-- Tabla: productos
-- =========================
CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    categoria VARCHAR(60) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    volumen_ml INT NOT NULL,
    stock_actual INT NOT NULL,
    stock_minimo INT NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_productos_precio CHECK (precio > 0),
    CONSTRAINT chk_productos_volumen CHECK (volumen_ml > 0),
    CONSTRAINT chk_productos_stock_actual CHECK (stock_actual >= 0),
    CONSTRAINT chk_productos_stock_minimo CHECK (stock_minimo >= 0)
) ENGINE=InnoDB;

-- =========================
-- Tabla: pedidos
-- =========================
CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    fecha_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente INT NOT NULL,
    id_sede INT NOT NULL,
    total_sin_iva DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_con_iva DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_pedidos_cliente
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_pedidos_sede
        FOREIGN KEY (id_sede) REFERENCES sedes(id_sede)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =========================
-- Tabla: detalle_pedido
-- =========================
CREATE TABLE detalle_pedido (
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (id_pedido, id_producto),
    CONSTRAINT fk_detalle_pedido_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_detalle_pedido_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_detalle_pedido_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_pedido_subtotal CHECK (subtotal >= 0)
) ENGINE=InnoDB;

-- =========================
-- Tabla: auditoria_precios
-- =========================
CREATE TABLE auditoria_precios (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    CONSTRAINT fk_auditoria_precios_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =========================
-- Índices recomendados
-- =========================
CREATE INDEX idx_productos_categoria ON productos (categoria);
CREATE INDEX idx_productos_stock ON productos (stock_actual, stock_minimo);
CREATE INDEX idx_clientes_nombre ON clientes (nombre_completo);
CREATE INDEX idx_pedidos_fecha ON pedidos (fecha_pedido);
CREATE INDEX idx_pedidos_cliente ON pedidos (id_cliente);
CREATE INDEX idx_pedidos_sede ON pedidos (id_sede);
CREATE INDEX idx_detalle_producto ON detalle_pedido (id_producto);
CREATE INDEX idx_auditoria_producto_fecha ON auditoria_precios (id_producto, fecha_cambio);
