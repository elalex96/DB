CREATE TABLE [dbo].[AX_Layout] (
    [IdLayoutAX]          INT            IDENTITY (1, 1) NOT NULL,
    [Empresa]             NVARCHAR (50)  NULL,
    [NoOrden]             NVARCHAR (50)  NULL,
    [Estatus]             NVARCHAR (500) NULL,
    [FechaRegistroCompra] NVARCHAR (500) NULL,
    [FechaEntrega]        NVARCHAR (500) NULL,
    [NoPedidoADINCO]      NVARCHAR (50)  NULL,
    [FechaReg]            DATETIME       NULL,
    [FechaMod]            DATETIME       NULL,
    CONSTRAINT [PK_AX_Layout] PRIMARY KEY CLUSTERED ([IdLayoutAX] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

