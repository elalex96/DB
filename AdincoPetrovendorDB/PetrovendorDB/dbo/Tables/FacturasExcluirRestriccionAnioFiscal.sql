CREATE TABLE [dbo].[FacturasExcluirRestriccionAnioFiscal] (
    [Id] [int] IDENTITY(1,1) NOT NULL,
	[RFCOperadora] [nvarchar](max) NULL,
	[Activo] [bit] NULL,
	[AnioExclucion] [int] NULL,
	[FechaVigencia] [datetime] NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
	[ModificadoEl] [datetime] NULL
);

