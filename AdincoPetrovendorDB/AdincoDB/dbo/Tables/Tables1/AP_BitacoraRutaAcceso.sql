CREATE TABLE [dbo].[AP_BitacoraRutaAcceso] (
    [IdBitacoraRutaAcceso] INT           IDENTITY (10000, 1) NOT NULL,
    [Ruta]                 VARCHAR (250) NULL,
    [IdUsuario]            INT           NULL,
    [IdContrato]           INT           NULL,
    [CreadoEl]             DATETIME      NULL,
    CONSTRAINT [PK_BitacoraRutaAcceso] PRIMARY KEY CLUSTERED ([IdBitacoraRutaAcceso] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_BitacoraRutaAcceso_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_BitacoraRutaAcceso_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

