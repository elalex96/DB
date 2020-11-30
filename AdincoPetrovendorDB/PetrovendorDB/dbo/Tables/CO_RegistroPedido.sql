CREATE TABLE [dbo].[CO_RegistroPedido] (
    [IdRegistroPedido]  INT      IDENTITY (1, 1) NOT NULL,
    [IdFactura]         INT      NULL,
    [IdSolicitudPedido] INT      NULL,
    [CreadorEl]         DATETIME NULL,
    [CreadoPor]         INT      NULL
);

