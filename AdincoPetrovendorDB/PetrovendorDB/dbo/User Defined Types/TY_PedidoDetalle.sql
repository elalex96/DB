CREATE TYPE [dbo].[TY_PedidoDetalle] AS TABLE (
    [IdSolicitudPedidoDetalle] INT        NOT NULL,
    [Cantidad]                 FLOAT (53) NOT NULL,
    [CantidadSolicitar]        FLOAT (53) NOT NULL);

