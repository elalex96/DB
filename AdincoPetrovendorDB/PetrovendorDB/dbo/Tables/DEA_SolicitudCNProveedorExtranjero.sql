CREATE TABLE [dbo].[DEA_SolicitudCNProveedorExtranjero](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdProveedor] [int] NULL,
	[IdContrato] [int] NULL,
	[Activo] [bit] NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
	[ModificadoEl] [datetime] NULL
)
