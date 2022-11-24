CREATE TABLE [dbo].[MM_HorasVigenciaPedidoHistorial] (
    [IdHorasVigencia]  INT            IDENTITY (1, 1) NOT NULL,
    [IdPedido]         INT            NULL,
    [HorasVigencia]    INT            NULL,
    [FechaVigencia]    DATETIME       NULL,
    [FechaCreacion]    DATETIME       NULL,
    [IdUsuarioCreador] INT            NULL,
    [Motivo]           NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdHorasVigencia] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

