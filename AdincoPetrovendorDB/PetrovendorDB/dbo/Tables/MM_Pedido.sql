CREATE TABLE [dbo].[MM_Pedido] (
    [IdPedido]                   INT            IDENTITY (1000, 1) NOT NULL,
    [IdSolicitudPedido]          INT            NULL,
    [IdContrato]                 INT            NULL,
    [IdSubcontratista]           INT            NULL,
    [Fecha]                      DATETIME       NULL,
    [FechaEntrega]               DATETIME       NULL,
    [Comentarios]                NVARCHAR (MAX) NULL,
    [LugarEntrega]               NVARCHAR (MAX) NULL,
    [Editado]                    BIT            NULL,
    [Version]                    INT            NULL,
    [Activado]                   NVARCHAR (50)  NULL,
    [Aprobado]                   BIT            NULL,
    [ValorRetencion]             FLOAT (53)     NULL,
    [Clave]                      NVARCHAR (MAX) NULL,
    [ConfirmacionClave]          NVARCHAR (MAX) NULL,
    [IdMoneda]                   INT            NULL,
    [Enviado]                    BIT            NULL,
    [CondicionesPago]            INT            NULL,
    [Anticipo]                   FLOAT (53)     NULL,
    [Impuesto]                   FLOAT (53)     NULL,
    [Envio]                      FLOAT (53)     NULL,
    [Importacion]                FLOAT (53)     NULL,
    [IVA]                        FLOAT (53)     NULL,
    [Descuento]                  BIT            NULL,
    [CantidadDescuento]          FLOAT (53)     NULL,
    [PedidoAutomatico]           BIT            NULL,
    [CreadoPor]                  INT            NULL,
    [CreadoEl]                   DATETIME       NULL,
    [ModificadoPor]              INT            NULL,
    [ModificadoEl]               DATETIME       NULL,
    [Activo]                     BIT            NULL,
    [TotalPedido]                FLOAT (53)     NULL,
    [SubTotal]                   FLOAT (53)     NULL,
    [IdDomicilioEntrega]         INT            NULL,
    [RecepcionServicio]          BIT            NULL,
    [FechaRecepcionServicio]     DATETIME       NULL,
    [IdUsuarioRecepcionServicio] INT            NULL,
    [AceptacionPedidoGral]       BIT            NULL,
    [AprobacionPedido]           BIT            NULL,
    [IdProveedorCompras]         INT            NULL,
    [IdPeticionOferta]           INT            NULL,
    [FechaEnvioPedido]           DATETIME       NULL,
    [NoSecuencia]                INT            NULL,
    [IdFirma]                    NVARCHAR (35)  NULL,
    [IdEstatusEliminado]         INT            NULL,
    [IdEliminado]                INT            NULL,
    [DiasCredito]                INT            NULL,
    [Cerrado]                    BIT            NULL,
    [NoCartaCN]                  BIT            NULL,
    [AsignadoA]                  INT            NULL,
    [ComentariosAsignado]        NVARCHAR (MAX) NULL,
    [UnicaCondicionPago]         BIT            NULL,
    [FechaEntregaPedido]         DATETIME       NULL,
    CONSTRAINT [PK_MM_Pedido] PRIMARY KEY CLUSTERED ([IdPedido] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_Pedido_MM_SolicitudPedido] FOREIGN KEY ([IdSolicitudPedido]) REFERENCES [dbo].[MM_SolicitudPedido] ([IdSolicitudPedido]),
    CONSTRAINT [FK_MM_Pedido_S_Proveedor] FOREIGN KEY ([IdSubcontratista]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_MM_Pedido_S_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
    CONSTRAINT [FK_MM_Pedido_S_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
    CONSTRAINT [FK_MM_Pedido_S_UsuarioRecepcion] FOREIGN KEY ([IdUsuarioRecepcionServicio]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);


GO
CREATE NONCLUSTERED INDEX [idxIdProveedorCompras_MM_Pedido]
    ON [dbo].[MM_Pedido]([IdProveedorCompras] ASC) WITH (STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [MM_Pedido_IdSolPedido]
    ON [dbo].[MM_Pedido]([IdSolicitudPedido] ASC, [Version] ASC)
    INCLUDE([IdSubcontratista]) WITH (STATISTICS_NORECOMPUTE = ON);

