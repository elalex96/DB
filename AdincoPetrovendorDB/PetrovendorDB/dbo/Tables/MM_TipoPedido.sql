CREATE TABLE [dbo].[MM_TipoPedido] (
    [IdTipoPedido] INT            IDENTITY (1, 1) NOT NULL,
    [TipoPedido]   NVARCHAR (300) NULL,
    PrefijoSAP varchar(30)
    PRIMARY KEY CLUSTERED ([IdTipoPedido] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

