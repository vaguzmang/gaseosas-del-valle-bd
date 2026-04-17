-- =============================================
-- Proyecto: Gaseosas del Valle S.A.
-- Archivo: sample_data.sql
-- Descripción: datos de prueba para evidencias
-- =============================================

USE gaseosas_del_valle;

-- =========================
-- Sedes
-- =========================
INSERT INTO sedes (nombre_sede, ubicacion, capacidad_almacenamiento, encargado)
VALUES
('Girón Centro', 'Girón - Centro', 1200, 'Laura Peña'),
('Bucaramanga Norte', 'Bucaramanga - Cabecera', 1500, 'Jhon Arias'),
('Piedecuesta Sur', 'Piedecuesta - Centro', 1000, 'Diana Cáceres');

-- =========================
-- Clientes
-- =========================
INSERT INTO clientes (nombre_completo, identificacion, direccion, telefono, correo_electronico)
VALUES
('Supertienda Girón', '900100001', 'Cra 10 # 20-30, Girón', '3001112233', 'compras@supertiendagiron.com'),
('Minimercado San Juan', '900100002', 'Calle 15 # 8-19, Girón', '3001112244', 'ventas@sjuan.com'),
('Distribuciones La 27', '900100003', 'Av. 27 # 45-12, Bucaramanga', '3001112255', 'contacto@la27.com'),
('Tienda El Puente', '900100004', 'Calle 8 # 4-10, Piedecuesta', '3001112266', 'tienda@elpuente.com'),
('Autoservicio La Cumbre', '900100005', 'Cra 5 # 18-55, Bucaramanga', '3001112277', 'pedidos@lacumbre.com'),
('Kiosco Portal', '900100006', 'Transv. 3 # 7-40, Girón', '3001112288', 'portal@kiosco.com');

-- =========================
-- Productos
-- =========================
INSERT INTO productos (nombre, categoria, precio, volumen_ml, stock_actual, stock_minimo)
VALUES
('Cola 400 ml', 'Gaseosa', 3500.00, 400, 120, 25),
('Cola 1500 ml', 'Gaseosa', 6500.00, 1500, 90, 20),
('Naranja 400 ml', 'Gaseosa', 3200.00, 400, 40, 15),
('Lima Limón 300 ml', 'Gaseosa', 2800.00, 300, 25, 20),
('Agua sin gas 600 ml', 'Agua', 2000.00, 600, 150, 30),
('Agua con gas 600 ml', 'Agua', 2200.00, 600, 60, 20),
('Energizante 250 ml', 'Energizante', 4500.00, 250, 35, 10),
('Té frío limón 500 ml', 'Té', 3000.00, 500, 18, 20);

-- =========================
-- Pedidos
-- =========================
INSERT INTO pedidos (fecha_pedido, id_cliente, id_sede)
VALUES
('2026-04-01 09:10:00', 1, 1),
('2026-04-03 14:30:00', 2, 1),
('2026-04-05 11:00:00', 3, 2),
('2026-04-07 16:45:00', 1, 3),
('2026-04-10 08:20:00', 4, 2);

-- =========================
-- Detalle de pedidos
-- Nota: los triggers calculan subtotal,
-- descuentan stock y actualizan totales.
-- =========================
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad)
VALUES
(1, 1, 10),
(1, 5, 6),
(2, 2, 5),
(2, 7, 4),
(3, 3, 8),
(3, 8, 4),
(4, 1, 12),
(4, 4, 5),
(4, 6, 7),
(5, 5, 20),
(5, 2, 3);

-- =========================
-- Cambio de precio para probar auditoría
-- =========================
UPDATE productos
   SET precio = 3800.00
 WHERE id_producto = 1;
