CREATE TABLE [dbo].[ENT_BitacoraEliminacionProgramacionDetalle](	
	[BitacoraEliminacionProgramacionId] [int]  NOT NULL,	
	[InstanciaEntregableId] [int] NULL,	
	[ContratoEntregableId] [int] NULL,
	CONSTRAINT [FK_ENT_BitacoraEliminacionProgramacionDetalle] FOREIGN KEY ([BitacoraEliminacionProgramacionId]) REFERENCES [dbo].[ENT_BitacoraEliminacionInstancia] ([Id]),
)