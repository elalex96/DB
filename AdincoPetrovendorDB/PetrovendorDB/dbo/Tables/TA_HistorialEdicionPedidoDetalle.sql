CREATE TABLE TA_HistorialEdicionPedidoDetalle (
	IdHistorial INT IDENTITY(1,1),
	Descripcion NVARCHAR(MAX),
	IdPedido INT,
	IdUsuario INT,
	IdContrato INT,
	Fecha DATETIME
);
