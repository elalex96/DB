CREATE TABLE [dbo].[PR_SistemasMedicionBitacora](
	[Id] INT IDENTITY(1,1) primary KEY,
	[Accion] [varchar](300) NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[IdSistema] [int] ,
	[IdTipoSistema] [int] NULL,
	[Marca] [varchar](300) NULL,
	[Modelo] [varchar](300) NULL,
	[NoSerie] [varchar](300) NULL,
	[TAG] [varchar](300) NULL,
	[Activo] [bit] NULL,
	[TipoMedidor] [varchar](250) NULL,
	[IdContrato] [int] NULL);

