
CREATE TABLE [dbo].[PR_EquiposAutoconsumoBitacora](
	[Id] INT IDENTITY(1,1) primary KEY,
	[Accion] [varchar](300) NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[IdContrato] [int] NOT NULL,
	[IdEquipo] [int] NOT NULL,
	[Fecha] [datetime] NULL,
	[UTMX] [float] NULL,
	[UTMY] [float] NULL,
	[Producto] [varchar](50) NULL,
	[TipoEquipo] [varchar](250) NULL,
	[TAG] [varchar](300) NULL,
	[FluidoDesplazado] [varchar](300) NULL,
	[ConsumoTeorico] [float] NULL,
	[ConsumoReal] [float] NULL,
	[ConsumoEnergetico] [float] NULL,
	[DispositivoInyeccion] [varchar](1000) NULL,
	[Obervaciones] [varchar](1000) NULL,
	Activo BIT)

ALTER TABLE [dbo].[PR_EquiposAutoconsumoBitacora] ADD FOREIGN KEY([IdContrato])
REFERENCES [dbo].[CO_Contrato] ([IdContrato]);
ALTER TABLE [dbo].[PR_EquiposAutoconsumoBitacora] ADD FOREIGN KEY(CreadoPor)
REFERENCES [dbo].[AP_USUARIO] ([UsuarioID]);
GO
--------------------------------------------------------------------------------
