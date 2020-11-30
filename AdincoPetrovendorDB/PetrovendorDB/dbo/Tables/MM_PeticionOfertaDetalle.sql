CREATE TABLE [dbo].[MM_PeticionOfertaDetalle] (
    [IdPeticionOfertaDetalle]  INT            IDENTITY (10000, 1) NOT NULL,
    [IdPeticionOferta]         INT            NULL,
    [IdMaterial]               INT            NULL,
    [ComentariosComprador]     NVARCHAR (MAX) NULL,
    [PrecioUnitario]           FLOAT (53)     NULL,
    [IdMaterialVendedor]       INT            NULL,
    [IdMoneda]                 INT            NULL,
    [Disponibilidad]           FLOAT (53)     NULL,
    [Dias]                     INT            NULL,
    [ComentarioSubcontratista] NVARCHAR (MAX) NULL,
    [Fecha]                    DATETIME       NULL,
    [Cotizado]                 BIT            NULL,
    [Editable]                 BIT            NULL,
    [CreadoPor]                INT            NULL,
    [CreadoEl]                 DATETIME       NULL,
    [ModificadoPor]            INT            NULL,
    [ModificadoEl]             DATETIME       NULL,
    [Activo]                   BIT            NULL,
    [NoMaterialesRequeridos]   FLOAT (53)     NULL,
    [IdEstatus]                INT            NULL,
    [IdProveedorVenta]         INT            NULL,
    [IVA_Porcentaje]           FLOAT (53)     NULL,
    [SubTotal]                 FLOAT (53)     NULL,
    [IVA_Activo]               BIT            NULL,
    [AddPedidoTemp]            BIT            NULL,
    [AddCantidadTemp]          FLOAT (53)     NULL,
    [AddSubTotalTemp]          FLOAT (53)     NULL,
    [AddValidado]              BIT            NULL,
    [PrecioMasIVA]             FLOAT (53)     NULL,
    [CantidadIVa]              FLOAT (53)     NULL,
    [FechaVigencia]            DATETIME       NULL,
    [ModificadoProveedorPor]   INT            NULL,
    [IdSolicitudPedidoDetalle] INT            NULL,
    [AddPedidoFinal]           BIT            NULL,
    [NoCotizar]                BIT            NULL,
    [IdUnidad]                 INT            NULL,
    [IdUnidadProveedor]        INT            NULL,
    [UnidadProveedor]          NVARCHAR (350) NULL,
    [MaterialCotizadoTextoC]   NVARCHAR (MAX) NULL,
    [MaterialCotizadoTextoL]   NVARCHAR (MAX) NULL,
    [IdEstatusEliminado]       INT            NULL,
    [FechaEntrega]             DATETIME       NULL,
    [IdCondicionPago]          INT            NULL,
    [DiasCredito]              INT            NULL,
    [UpdateDiasCredito]        BIT            NULL,
    [IdCondicionPagoTemp]      INT            NULL,
    [DiasCreditoTemp]          INT            NULL,
    CONSTRAINT [PK_MM_PeticionOfertaDetalle] PRIMARY KEY CLUSTERED ([IdPeticionOfertaDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [idxIdPeticionOferta_MM_PeticionOfertaDetalle]
    ON [dbo].[MM_PeticionOfertaDetalle]([IdPeticionOferta] ASC) WITH (STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idxIdSolicitudPedidoDetalle_MM_PeticionOfertaDetalle]
    ON [dbo].[MM_PeticionOfertaDetalle]([IdSolicitudPedidoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

