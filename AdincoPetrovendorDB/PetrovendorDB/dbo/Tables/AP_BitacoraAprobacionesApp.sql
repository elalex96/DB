CREATE TABLE AP_BitacoraAprobacionesApp(
	[Id] [int] primary key IDENTITY(1,1) NOT NULL,
	[IdTarea] [int] NULL,
	[IdTipoPedido] [int] NULL,
	[IdEstatus] [int] NULL,
	[Fecha] [datetime] NULL,
	[App] nvarchar(200) NULL,
)