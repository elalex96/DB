CREATE TABLE [dbo].[AP_Bitacora]
(
    [Id] INT IDENTITY(1, 1) NOT NULL,
    [Fecha] DATETIME NOT NULL,
    [Tipo] VARCHAR(100) NULL,
    [Mensaje] VARCHAR(2000) NULL,
    [Detalle] VARCHAR(MAX) NULL,
    [UsuarioId] INT NULL,
    [ContratoId] INT NULL,
    CONSTRAINT [PK_AP_Bitacora]
        PRIMARY KEY CLUSTERED ([Id] ASC)
);