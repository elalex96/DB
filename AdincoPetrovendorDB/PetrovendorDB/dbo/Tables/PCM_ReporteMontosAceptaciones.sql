CREATE TABLE [dbo].[PCM_ReporteMontosAceptaciones] (
    [IdPedido]              INT            NULL,
    [IdPedidoDetalle]       INT            NULL,
    [DescripcionLarga]      NVARCHAR (MAX) NULL,
    [Cantidad]              FLOAT (53)     NULL,
    [PrecioUnitario]        FLOAT (53)     NULL,
    [Subtotal]              FLOAT (53)     NULL,
    [MonedaPedido]          VARCHAR (MAX)  NULL,
    [MontoPedidoUSD]        FLOAT (53)     NULL,
    [CantidadAceptada]      FLOAT (53)     NULL,
    [MontoAceptado]         FLOAT (53)     NULL,
    [MonedaPedido_Aceptado] NVARCHAR (MAX) NULL,
    [Diferencia]            FLOAT (53)     NULL,
    [MontoPorAceptar]       FLOAT (53)     NULL,
    [MontoPorAceptarUSD]    FLOAT (53)     NULL,
    [CreadoEl]              DATETIME       NULL,
    [TipoCambio]            FLOAT (53)     NULL
);

