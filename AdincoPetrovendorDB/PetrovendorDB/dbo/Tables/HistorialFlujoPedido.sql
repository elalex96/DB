CREATE TABLE [dbo].[HistorialFlujoPedido] (
    [Id]               INT        IDENTITY (1, 1) NOT NULL,
    [IdOperacion]      INT        NULL,
    [IdPedido]         INT        NULL,
    [Idflujo]          INT        NULL,
    [ValorInicial]     FLOAT (53) NULL,
    [ValorFinal]       FLOAT (53) NULL,
    [TotalPedidoEnDls] FLOAT (53) NULL,
    [FechaCreacion]    DATETIME   NULL
);

