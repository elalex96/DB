CREATE TABLE [dbo].[AX_Remision] (
    [IdRemision]      INT           IDENTITY (1, 1) NOT NULL,
    [IdOC]            VARCHAR (100) NULL,
    [RECID]           VARCHAR (MAX) NULL,
    [DataAreaId]      VARCHAR (MAX) NULL,
    [IdPedido]        INT           NULL,
    [Item]            VARCHAR (MAX) NULL,
    [Cantidad]        FLOAT (53)    NULL,
    [Asiento]         VARCHAR (100) NULL,
    [fecharegistro]   DATETIME      NULL,
    [IdRemisionCARSO] VARCHAR (MAX) NULL,
    [FechaEdicion]    DATETIME      NULL,
    CONSTRAINT [PK_AX_Remision] PRIMARY KEY CLUSTERED ([IdRemision] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AX_Remision_MM_Pedido] FOREIGN KEY ([IdPedido]) REFERENCES [dbo].[MM_Pedido] ([IdPedido])
);

