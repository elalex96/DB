
/****** Object:  Table [dbo].[CO_WDEA_Produccion_Diaria_Detalle]    Script Date: 09/07/2021 06:12:30 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CO_WDEA_Produccion_Diaria_Detalle](
	[IdDetalle] [int] IDENTITY(1,1) NOT NULL,
	[Id] [int] NULL,
	[Pozo] [varchar](500) NULL,
	[BateriaSeparacion] [varchar](500) NULL,
	[Operativo] [bit] NULL,
	[Descarga] [varchar](10) NULL,
	[Sistema] [varchar](100) NULL,
	[BN] [varchar](10) NULL,
	[MedicionFecha] [datetime] NULL,
	[MedicionCIA] [varchar](100) NULL,
	[MedicionQBruto] [float] NULL,
	[MedicionQNeto] [float] NULL,
	[MedicionQAgua] [float] NULL,
	[MedicionFAgua] [float] NULL,
	[MedicionQGasTotal] [float] NULL,
	[MedicionQGasForm] [float] NULL,
	[MedicionQGasiny] [float] NULL,
	[CA_LAB_Fw] [float] NULL,
	[ProduccionQBruto] [float] NULL,
	[ProduccionQNeto] [float] NULL,
	[ProduccionQAgua] [float] NULL,
	[ProduccionFAgua] [float] NULL,
	[ProduccionQGasTotal] [float] NULL,
	[ProduccionQGasForm] [float] NULL,
	[ProduccionQGasiny] [float] NULL,
	[ProduccionPGasiny] [float] NULL,
	[ProduccionRGA] [float] NULL,
	[ProduccionEstTp] [varchar](100) NULL,
	[ProduccionPTP] [float] NULL,
	[ProduccionObservaciones] [varchar](500) NULL,
	[EstadoQBruto] [float] NULL,
	[EstadoQNeto] [float] NULL,
	[EstadoQAgua] [float] NULL,
	[EstadoFAgua] [float] NULL,
	[EstadoQGasTotal] [float] NULL,
	[EstadoQGasForm] [float] NULL,
	[EstadoQGasiny] [float] NULL,
	[EstadoRGA] [float] NULL,
	[DiferenciaQBruto] [float] NULL,
	[DiferenciaQNeto] [float] NULL,
	[DiferenciaQAgua] [float] NULL,
	[DiferenciaFAgua] [float] NULL,
	[DiferenciaQGasTotal] [float] NULL,
	[DiferenciaQGasForm] [float] NULL,
	[DiferenciaQGasiny] [float] NULL,
	[DiferenciaRGA] [float] NULL,
	[DiferenciaObservaciones] [varchar](500) NULL,
	[MovimientoPozo] [varchar](500) NULL,
	[MovimientoSistema] [varchar](500) NULL,
	[MovimientoBateria] [varchar](500) NULL,
	[Movimiento] [varchar](500) NULL,
	[MovimientoHrsCierre] [varchar](50) NULL,
	[MovimientoPB] [float] NULL,
	[MovimientoAgua] [float] NULL,
	[MovimientoPN] [float] NULL,
	[MovimientoGF] [float] NULL,
	[MovimientoGI] [float] NULL,
	[MovimientoPB_BLS] [float] NULL,
	[MovimientoPN_BLS] [float] NULL,
	[MovimientoPRES_TP] [float] NULL,
	[MovimientoPRES_LDD] [float] NULL,
	[MovimientoAjusteEst] [varchar](100) NULL,
	[MovimientoAjustePB] [float] NULL,
	[MovimientoAjustePN] [float] NULL,
	[MovimientoAjusteGF] [float] NULL,
	[MovimientoAjusteGI] [float] NULL,
	[CreadoEl] [datetime] NULL,
	[CreadoPor] [int] NULL,
 CONSTRAINT [PK_CO_WDEA_Produccion_Diaria_Detalle] PRIMARY KEY CLUSTERED 
(
	[IdDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CO_WDEA_Produccion_Diaria_Detalle]  WITH CHECK ADD  CONSTRAINT [FK_CO_WDEA_Produccion_Diaria_Detalle_AP_Usuario] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
GO

ALTER TABLE [dbo].[CO_WDEA_Produccion_Diaria_Detalle] CHECK CONSTRAINT [FK_CO_WDEA_Produccion_Diaria_Detalle_AP_Usuario]
GO

ALTER TABLE [dbo].[CO_WDEA_Produccion_Diaria_Detalle]  WITH CHECK ADD  CONSTRAINT [FK_CO_WDEA_Produccion_Diaria_Detalle_CO_WDEA_Produccion_Diaria] FOREIGN KEY([Id])
REFERENCES [dbo].[CO_WDEA_Produccion_Diaria] ([Id])
GO

ALTER TABLE [dbo].[CO_WDEA_Produccion_Diaria_Detalle] CHECK CONSTRAINT [FK_CO_WDEA_Produccion_Diaria_Detalle_CO_WDEA_Produccion_Diaria]
GO


