CREATE TABLE [dbo].[MM_SolicitudPedido] (
    [IdSolicitudPedido]          INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]                 INT            NULL,
    [IdTipoSolicitudPedido]      INT            NULL,
    [IdUsuarioSolicitante]       INT            NULL,
    [AdjudicableParcialmente]    BIT            NULL,
    [IdPrioridadSolicitudPedido] INT            NULL,
    [MotivoUrgencia]             NVARCHAR (MAX) NULL,
    [IdEstado]                   INT            NULL,
    [VisitaRequerida]            BIT            NULL,
    [JuntaAclaracionesRequerida] BIT            NULL,
    [Controlados]                BIT            NULL,
    [Fianza]                     BIT            NULL,
    [IdProcedimientoProcura]     INT            NULL,
    [IdTipoContrato]             INT            NULL,
    [UnaSolaEntregaRequerida]    BIT            NULL,
    [Activo]                     BIT            NULL,
    [FechaEntregaRequerida]      DATETIME       NULL,
    [FechaEntregaFinRequerida]   DATETIME       NULL,
    [IdProveedor]                INT            NULL,
    [FechaAlta]                  DATETIME       NULL,
    [EntregasParciales]          BIT            NULL,
    [PeticionEnviada]            BIT            NULL,
    [IdCentroCosto]              INT            NULL,
    [IdLineaPresupuesto]         INT            NULL,
    [IdTipoGasto]                INT            NULL,
    [IdTerminoInternacionales]   INT            NULL,
    [IdDomicilioEntrega]         INT            NULL,
    [UnicoDomicilioEntrega]      BIT            NULL,
    [IdPresupuesto]              INT            NULL,
    [IdPeriodo]                  INT            NULL,
    [NoSecuencia]                INT            NULL,
    [IdTipoCompra]               INT            NULL,
    [IdFirma]                    NVARCHAR (35)  NULL,
    [IdTipoProceso]              INT            NULL,
    [Visible]                    BIT            NULL,
    [IdEstatusEliminado]         INT            NULL,
    [IdEliminado]                INT            NULL,
    [JustificacionSolOferta]     NVARCHAR (MAX) NULL,
    [IdDinamicsAx]               INT            NULL,
    [Asignado]                   INT            NULL,
    [ComentarioInternoPO]        NVARCHAR (MAX) NULL,
    [FechaAsignado]              DATETIME       NULL,
    [FechaComentarioMod]         DATETIME       NULL,
    [Solicitante]                INT            NULL,
    [IdLocalidad]                INT            NULL,
    CONSTRAINT [PK_MM_SolicitudPedido] PRIMARY KEY CLUSTERED ([IdSolicitudPedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_SolicitudPedido_MM_TipoSolicitudPedido] FOREIGN KEY ([IdTipoSolicitudPedido]) REFERENCES [dbo].[MM_TipoSolicitudPedido] ([IdTipoSolicitudPedido]),
    CONSTRAINT [FK_MM_SolicitudPedido_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_MM_SolicitudPedido_MM_Localidades_IdLocalidad] FOREIGN KEY (IdLocalidad) REFERENCES MM_Localidades(Id)
);


GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
    ON [dbo].[MM_SolicitudPedido]([IdProveedor] ASC)
    INCLUDE([IdSolicitudPedido], [IdContrato]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [<IndexIdContratoIdProveedor, sysname,>]
    ON [dbo].[MM_SolicitudPedido]([IdContrato] ASC, [IdProveedor] ASC)
    INCLUDE([IdSolicitudPedido]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [<IdSolpedIdContratoFechaAlta, sysname,>]
    ON [dbo].[MM_SolicitudPedido]([IdProveedor] ASC)
    INCLUDE([IdSolicitudPedido], [IdContrato], [FechaAlta]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idxSolicitudPedido_IdDinamicsAx]
    ON [dbo].[MM_SolicitudPedido]([IdDinamicsAx] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

