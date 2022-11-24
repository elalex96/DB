CREATE TABLE [dbo].[ENT_BitacoraArchivos] (
    [Id]               INT           IDENTITY (1, 1) NOT NULL,
    [ModuloId]         INT           NULL,
    [Fecha]            DATETIME      NULL,
    [Ruta]             VARCHAR (300) NULL,
    [Archivo]          VARCHAR (500) NULL,
    [AWSArchivoId]     INT           NULL,
    [AWSIdentificador] VARCHAR (MAX) NOT NULL,
    [UsuarioId]        INT           NULL,
    [IdContrato]       INT           NULL,
    [Accion]           VARCHAR (300) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    FOREIGN KEY ([UsuarioId]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

