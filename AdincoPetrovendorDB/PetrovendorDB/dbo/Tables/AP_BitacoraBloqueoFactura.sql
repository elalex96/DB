CREATE TABLE [dbo].[AP_BitacoraBloqueoFactura] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [Motivo]               VARCHAR (300) NULL,
    [Descripcion]          VARCHAR (100) NULL,
    [Bloqueado]            BIT           NULL,
    [IdProveedor]          INT           NULL,
    [IdProveedorBloqueado] INT           NULL,
    [CreadoEl]             DATETIME      NULL,
    [CreadoPor]            INT           NULL,
    [ModificadoEl]         DATETIME      NULL,
    [ModificadoPor]        INT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
    FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    FOREIGN KEY ([IdProveedorBloqueado]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

