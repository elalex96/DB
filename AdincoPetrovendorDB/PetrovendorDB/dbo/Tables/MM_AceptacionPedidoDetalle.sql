CREATE TABLE [dbo].[MM_AceptacionPedidoDetalle] (
    [IdAceptacionPedidoDetalle] INT            IDENTITY (1, 1) NOT NULL,
    [IdAceptacionPedido]        INT            NULL,
    [IdPedidoDetalle]           INT            NULL,
    [Cantidad]                  FLOAT (53)     NULL,
    [Detalle]                   VARCHAR (1500) NULL,
    [CreadoPor]                 INT            NULL,
    [Creado]                    DATETIME       NULL,
    [Excedente]                 FLOAT (53)     NULL,
    [PCN]                       FLOAT (53)     NULL,
    [PCN_Agregado]              BIT            NULL,
    [EditadoPor]                INT            NULL,
    [EditadoEl]                 DATETIME       NULL,
    [ClasificacionCN]           INT            NULL,
    [IdEstatusEliminado]        INT            NULL,
    [IdEliminado]               INT            NULL,
    [RecId]                     VARCHAR (8000) NULL,
    [DataAreaId]                CHAR (10)      NULL,
    [IdAnterior]                INT            NULL,
    [IsReclasificada]           BIT            NULL,
    CONSTRAINT [PK_MM_AceptacionPedidoDetalle] PRIMARY KEY CLUSTERED ([IdAceptacionPedidoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_AceptacionPedidoDetalle_MM_AceptacionPedido] FOREIGN KEY ([IdAceptacionPedido]) REFERENCES [dbo].[MM_AceptacionPedido] ([IdAceptacionPedido])
);


GO
CREATE NONCLUSTERED INDEX [<MM_APD_IdAcep, sysname,>]
    ON [dbo].[MM_AceptacionPedidoDetalle]([IdAceptacionPedido] ASC) WITH (STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idxIdPedidoDetalle_MM_AceptacionPedidoDetalle]
    ON [dbo].[MM_AceptacionPedidoDetalle]([IdPedidoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

