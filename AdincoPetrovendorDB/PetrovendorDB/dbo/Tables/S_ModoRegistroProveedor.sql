CREATE TABLE [dbo].[S_ModoRegistroProveedor] (
    [IdModoRegistroProv] INT      IDENTITY (1, 1) NOT NULL,
    [IdProveedor]        INT      NULL,
    [IdModoRegistro]     INT      NULL,
    [FechaRegistro]      DATETIME NULL
);

