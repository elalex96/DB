CREATE TABLE [dbo].[MM_PeticionOferta] (
    [IdPeticionOferta]          INT            IDENTITY (1, 1) NOT NULL,
    [IdLicitacion]              INT            NULL,
    [IdSolicitudPedido]         INT            NULL,
    [IdSubcontratista]          INT            NULL,
    [Fecha]                     DATETIME       NULL,
    [CreadoPor]                 INT            NULL,
    [CreadoEl]                  DATETIME       NULL,
    [ModificadoPor]             INT            NULL,
    [ModificadoEl]              DATETIME       NULL,
    [Activo]                    BIT            NULL,
    [Visto]                     BIT            NULL,
    [Iniciada]                  BIT            NULL,
    [Finalizado]                BIT            NULL,
    [FechaFinalizado]           DATETIME       NULL,
    [Cotizado]                  BIT            NULL,
    [IdEstatus]                 INT            NULL,
    [NoCotizar]                 BIT            NULL,
    [NoSecuencia]               INT            NULL,
    [AceptoTerminosCondiciones] BIT            NULL,
    [Verificable]               BIT            NULL,
    [IdTipoProceso]             INT            NULL,
    [JustificacionAdjDirecta]   NVARCHAR (MAX) NULL,
    [DocAdjudicacionDirecta]    NVARCHAR (MAX) NULL,
    [Visible]                   BIT            NULL,
    [JustificacionAmplicacion]  NVARCHAR (MAX) NULL,
    [FechaAmpliacion]           DATETIME       NULL,
    [AmpliacionPor]             INT            NULL,
    [IdEstatusEliminado]        INT            NULL,
    [IdEliminado]               INT            NULL,
    [AMS3]                      BIT            NULL,
    [CotizacionRestringida]     BIT            NULL,
    CONSTRAINT [PK_MM_PeticionOferta] PRIMARY KEY CLUSTERED ([IdPeticionOferta] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_PeticionOferta_MM_SolicitudPedido] FOREIGN KEY ([IdSolicitudPedido]) REFERENCES [dbo].[MM_SolicitudPedido] ([IdSolicitudPedido]),
    CONSTRAINT [FK_MM_PeticionOferta_PV_Subcontratista] FOREIGN KEY ([IdSubcontratista]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);


GO
CREATE NONCLUSTERED INDEX [idxActivo_MM_PeticionOferta]
    ON [dbo].[MM_PeticionOferta]([Activo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idxIdSolicitudPedido_MM_PeticionOferta]
    ON [dbo].[MM_PeticionOferta]([IdSolicitudPedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idxIdSubcontratista_MM_PeticionOferta]
    ON [dbo].[MM_PeticionOferta]([IdSubcontratista] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

