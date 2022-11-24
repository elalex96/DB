CREATE TABLE [dbo].[MM_PedidoDetalle] (
    [IdPedidoDetalle]             INT            IDENTITY (1, 1) NOT NULL,
    [IdPedido]                    INT            NULL,
    [IdMaterial]                  INT            NULL,
    [IdPeticionOfertaDetalle]     INT            NULL,
    [Posicion]                    INT            NULL,
    [ComentariosCompras]          NVARCHAR (MAX) NULL,
    [PrecioUnitario]              FLOAT (53)     NULL,
    [CreadoPor]                   INT            NULL,
    [CreadoEl]                    DATETIME       NULL,
    [ModificadoPor]               INT            NULL,
    [ModificadoEl]                DATETIME       NULL,
    [Activo]                      BIT            NULL,
    [AceptacionServicio]          BIT            NULL,
    [Eliminado]                   BIT            NULL,
    [IdUsuarioAceptacionServicio] INT            NULL,
    [FechaAceptacionServicio]     DATETIME       NULL,
    [PorcentajeIVA]               INT            NULL,
    [Subtotal]                    FLOAT (53)     NULL,
    [Entregado]                   BIT            NULL,
    [ConfirmacionSurtido]         BIT            NULL,
    CONSTRAINT [PK_MM_PedidoDetalle] PRIMARY KEY CLUSTERED ([IdPedidoDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

