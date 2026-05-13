CREATE TABLE [dbo].[MM_HistorialCambiosCotizacion] (
    [FechaActual]       DATETIME       NULL,
    [FechaEdicion]      DATETIME       NULL,
    [FechaNueva]        DATETIME       NULL,
    [Id_Historial]      INT            IDENTITY (1, 1) NOT NULL,
    [IdEditadoPor]      INT            NULL,
    [IdOperacion]       INT            NULL,
    [IdSolicitudPedido] INT            NULL,
    [Motivo]            NVARCHAR (MAX) NULL
);

