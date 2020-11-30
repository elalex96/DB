CREATE TABLE [dbo].[S_UsuarioProveedor] (
    [IdUsuarioProveedor] INT IDENTITY (1, 1) NOT NULL,
    [IdUsuario]          INT NULL,
    [IdProveedor]        INT NULL,
    [IdTipoPaquete]      INT NULL,
    [IsAdmin]            BIT NULL,
    CONSTRAINT [PK_S_UsuarioProveedor] PRIMARY KEY CLUSTERED ([IdUsuarioProveedor] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

