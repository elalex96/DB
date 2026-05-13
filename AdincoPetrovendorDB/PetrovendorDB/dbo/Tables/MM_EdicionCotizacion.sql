CREATE TABLE [dbo].[MM_EdicionCotizacion] (
    [CreadoEl]            DATETIME NULL,
    [IdCreadorPor]        INT      NULL,
    [IdEdicionCotizacion] INT      IDENTITY (1, 1) NOT NULL,
    [IdEstatus]           INT      NULL,
    [IdPeticionOferta]    INT      NULL,
    [IdProveedor]         INT      NULL,
    [ModificadoEl]        DATETIME NULL,
    [ModificadoPor]       INT      NULL
);

