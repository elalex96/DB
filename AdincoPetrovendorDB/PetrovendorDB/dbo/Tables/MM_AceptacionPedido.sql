CREATE TABLE [dbo].[MM_AceptacionPedido] (
    [IdAceptacionPedido]      INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]             INT            NULL,
    [IdPedido]                INT            NULL,
    [Comentario]              VARCHAR (1500) NULL,
    [NombreUsuarioEntrega]    NVARCHAR (300) NULL,
    [Activo]                  BIT            NULL,
    [Creado]                  DATETIME       NULL,
    [IdDomicilioEntrega]      INT            NULL,
    [CreadorPor]              INT            NULL,
    [Modificado]              DATETIME       NULL,
    [ModificadoPor]           INT            NULL,
    [RecibidoPor]             INT            NULL,
    [NombreRecibidoPor]       NVARCHAR (300) NULL,
    [EntregadoPor]            NVARCHAR (300) NULL,
    [FacturaSolicitada]       BIT            NULL,
    [RecepcionServicio]       BIT            NULL,
    [PCN_Agregado]            BIT            NULL,
    [DocumentoDescargado]     BIT            NULL,
    [NoSecuencia]             INT            NULL,
    [IdNacionalidadProveedor] INT            NULL,
    [IdRegimenProveedor]      INT            NULL,
    [IdPaisProveedor]         INT            NULL,
    [IdEstatusEliminado]      INT            NULL,
    [IdEliminado]             INT            NULL,
    [BtnCartaCarso]           BIT            NULL,
    [IdOcCarso]               VARCHAR (100)  NULL,
    [Asiento]                 VARCHAR (8000) NULL,
    [InicioEjecucion]         DATE FULL,
    [FinEjecucion]            DATE FULL,
    CONSTRAINT [PK_MM_AceptacionPedido] PRIMARY KEY CLUSTERED ([IdAceptacionPedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_AceptacionPedido_DG_Domicilio] FOREIGN KEY ([IdDomicilioEntrega]) REFERENCES [dbo].[DG_Domicilio] ([IdDomicilio]),
    CONSTRAINT [FK_MM_AceptacionPedido_MM_Pedido] FOREIGN KEY ([IdPedido]) REFERENCES [dbo].[MM_Pedido] ([IdPedido])
);


GO
CREATE NONCLUSTERED INDEX [BIRecepcion2]
    ON [dbo].[MM_AceptacionPedido]([IdPedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

