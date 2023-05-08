CREATE TABLE [dbo].[MM_HorasVigenciaPedido] (
    [IdHorasVigencia] INT           IDENTITY (1, 1) NOT NULL,
    [IdPedido]        INT           NOT NULL,
    [HorasVigencia]   INT           NOT NULL,
    [FechaVigencia]   SMALLDATETIME NULL,
    CONSTRAINT [PK_MM_HorasVigenciaPedido] PRIMARY KEY CLUSTERED ([IdHorasVigencia] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_HorasVigenciaPedido_MM_Pedido] FOREIGN KEY ([IdPedido]) REFERENCES [dbo].[MM_Pedido] ([IdPedido])
);


GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
    ON [dbo].[MM_HorasVigenciaPedido]([IdPedido] ASC)
    INCLUDE([FechaVigencia]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

