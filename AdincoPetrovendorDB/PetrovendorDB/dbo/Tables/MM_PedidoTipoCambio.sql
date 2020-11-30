CREATE TABLE [dbo].[MM_PedidoTipoCambio] (
    [FechaTipoCambio]    DATETIME        NULL,
    [IdPedido]           INT             NULL,
    [IdPedidoTipoCambio] INT             IDENTITY (1, 1) NOT NULL,
    [IdTipoMoneda]       INT             NULL,
    [TipoCambio]         DECIMAL (12, 4) NULL
);

