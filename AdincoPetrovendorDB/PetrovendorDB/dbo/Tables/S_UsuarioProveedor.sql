CREATE TABLE [dbo].[S_UsuarioProveedor] (
    [IdUsuarioProveedor] INT IDENTITY (1, 1) NOT NULL,
    [IdUsuario]          INT NULL,
    [IdProveedor]        INT NULL,
    [IdTipoPaquete]      INT NULL,
    [IsAdmin]            BIT NULL,
    [idContrato]         INT NULL,
    CONSTRAINT [PK_S_UsuarioProveedor] PRIMARY KEY CLUSTERED ([IdUsuarioProveedor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__S_Usuario__IdPro__54CB950F] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK__S_Usuario__IdUsu__53D770D6] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
    CONSTRAINT [FK_TipoPaquete] FOREIGN KEY ([IdTipoPaquete]) REFERENCES [dbo].[TipoPaquete] ([IdPaquete])
);

