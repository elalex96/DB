CREATE TABLE [dbo].[TA_HistorialEdicionPedidoDetalle] (
    [IdHistorial] INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion] NVARCHAR (MAX) NULL,
    [IdPedido]    INT            NULL,
    [IdUsuario]   INT            NULL,
    [IdContrato]  INT            NULL,
    [Fecha]       DATETIME       NULL
);

