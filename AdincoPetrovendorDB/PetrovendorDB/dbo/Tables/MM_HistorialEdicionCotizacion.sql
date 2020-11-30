CREATE TABLE [dbo].[MM_HistorialEdicionCotizacion] (
    [Descripcion]             NVARCHAR (MAX) NULL,
    [EdicionCabecera]         BIT            NULL,
    [Fecha]                   DATETIME       NULL,
    [IdEdicionCotizacion]     INT            NULL,
    [IdHistorial]             INT            IDENTITY (1, 1) NOT NULL,
    [IdPeticionOfertaDetalle] INT            NULL,
    [IdProveedor]             INT            NULL,
    [IdUsuario]               INT            NULL,
    [Motivo]                  NVARCHAR (MAX) NULL
);

