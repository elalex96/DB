CREATE TABLE [dbo].[MM_TipoPedido] (
    [IdTipoPedido] INT            IDENTITY (1, 1) NOT NULL,
    [TipoPedido]   NVARCHAR (300) NULL,
    [PrefijoSAP]   VARCHAR (30)   NULL,
    PRIMARY KEY CLUSTERED ([IdTipoPedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

