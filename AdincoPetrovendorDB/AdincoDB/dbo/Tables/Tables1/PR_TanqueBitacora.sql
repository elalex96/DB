
CREATE TABLE [dbo].[PR_TanqueBitacora](
	[Id] INT IDENTITY(1,1) primary KEY,
	[Accion] [varchar](300) NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[TanqueId] [int] NULL,
	[Clave] [varchar](20) NOT NULL,
	[Nombre] [varchar](200) NOT NULL,
	[Descripcion] [nvarchar](2000) NOT NULL,
	[Estatus] [tinyint] NOT NULL,
	[Estacion] [int] NULL,
	[Capacidad] [decimal](24, 8) NOT NULL,
	[Producto] [int] NOT NULL,
	[Diametro] [decimal](24, 8) NOT NULL,
	[Altura] [decimal](24, 8) NOT NULL,
	[Constante] [decimal](24, 8) NOT NULL,
	[PctNoBombeable] [decimal](8, 4) NOT NULL,
	[VolNoBombeable] [decimal](24, 8) NOT NULL,
	[PctMaximo] [decimal](8, 4) NOT NULL,
	[VolMaximo] [decimal](24, 8) NOT NULL,
	[PorcentajeAgua] [float] NULL,
	[ProductoAlmacenado] [varchar](250) NULL,
	[IdTipoTanque] [int] NULL,
	[MedicionManual] [bit] NULL,
	[PuntoEntregaID] [int] NULL,
	Activo BIT)


ALTER TABLE [dbo].[PR_TanqueBitacora] ADD  FOREIGN KEY([Estacion])
REFERENCES [dbo].[PR_Estacion] ([Id])
GO
ALTER TABLE [dbo].[PR_TanqueBitacora] ADD FOREIGN KEY(CreadoPor)
REFERENCES [dbo].[AP_USUARIO] ([UsuarioID]);
GO