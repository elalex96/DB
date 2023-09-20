CREATE TABLE [dbo].[MM_Localidades] (
    [Id]           INT    IDENTITY (1, 1) NOT NULL,
	[Nombre]	   VARCHAR(500) NOT NULL,
    [IdProveedor]  INT   NOT NULL,
	[IdContrato]   INT   NULL,   
    [Activo]        BIT     NOT NULL,
	[CreadoEl]      DATETIME  NOT NULL,
	[CreadoPor]     INT NULL,
	[ModificadoPor]  INT NULL,
	[ModificadoEl]   DATETIME  NULL,
    CONSTRAINT [PK_MM_Localidades] PRIMARY KEY CLUSTERED ([Id] ASC),
	CONSTRAINT [FK_MM_Localidades_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);