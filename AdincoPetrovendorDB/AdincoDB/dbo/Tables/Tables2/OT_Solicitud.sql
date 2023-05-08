CREATE TABLE [dbo].[OT_Solicitud] (
    [IdOTSolicitud]        INT           NOT NULL,
    [IdSubContrato]        INT           NOT NULL,
    [Folio]                VARCHAR (30)  NOT NULL,
    [FechaInicio]          DATETIME      NULL,
    [FechaFin]             DATETIME      NULL,
    [PlazoEjecucion]       INT           NOT NULL,
    [CreadoPor]            INT           NOT NULL,
    [CreadoEl]             DATETIME      NOT NULL,
    [ModificadoPor]        INT           NULL,
    [ModificadoEl]         DATETIME      NULL,
    [IsActivo]             BIT           NOT NULL,
    [IsEliminado]          BIT           NOT NULL,
    [IdPresupuesto]        INT           NULL,
    [Objeto]               VARCHAR (600) NULL,
    [IdOTEstatus]          TINYINT       NOT NULL,
    [FechaFinExtendida]    DATETIME      NULL,
    [IdOTEstatusAnt]       TINYINT       NULL,
    [IdMatContratista]     INT           NULL,
    [IdMatSubcontratista]  INT           NULL,
    [IdCentroCosto]        INT           NULL,
    [ProgIniPorProveedor]  BIT           NULL,
    [IdMoneda]             INT           NULL,
    [CapturaManual]        BIT           NULL,
    [SAPPR]                VARCHAR (15)  NULL,
    [FechaAprobacionSAPPR] DATETIME      NULL,
    [Notas]                VARCHAR (300) NULL,
    [IdTerminos]           INT           NULL,
    CONSTRAINT [PK_OT_Solicitud] PRIMARY KEY CLUSTERED ([IdOTSolicitud] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__OT_Solici__IdOTE__0B3F165E] FOREIGN KEY ([IdOTEstatusAnt]) REFERENCES [dbo].[OT_Estatus] ([IdOtEstatus]),
    CONSTRAINT [FK__OT_Solici__IdOTE__7EA4354F] FOREIGN KEY ([IdOTEstatusAnt]) REFERENCES [dbo].[OT_Estatus] ([IdOtEstatus]),
    CONSTRAINT [FK__OT_Solici__IdPre__79C9A642] FOREIGN KEY ([IdPresupuesto]) REFERENCES [dbo].[CO_Presupuesto] ([IdPresupuesto]),
    CONSTRAINT [FK_OT_Solicitud_OT_Estatus] FOREIGN KEY ([IdOTEstatus]) REFERENCES [dbo].[OT_Estatus] ([IdOtEstatus]),
    CONSTRAINT [FK_OT_Solicitud_SC_SubContrato] FOREIGN KEY ([IdSubContrato]) REFERENCES [dbo].[SC_SubContrato] ([IdSubContrato])
);


GO
CREATE NONCLUSTERED INDEX [IX_OT_Solicitud]
    ON [dbo].[OT_Solicitud]([IdSubContrato] ASC, [IsActivo] ASC, [IsEliminado] ASC, [IdOTEstatus] ASC)
    INCLUDE([IdOTSolicitud], [Folio], [FechaInicio], [FechaFin], [PlazoEjecucion], [CreadoPor], [CreadoEl], [ModificadoPor], [ModificadoEl], [IdPresupuesto], [Objeto], [FechaFinExtendida], [IdOTEstatusAnt], [IdMatContratista], [IdMatSubcontratista], [IdCentroCosto], [ProgIniPorProveedor], [IdMoneda], [CapturaManual], [SAPPR], [FechaAprobacionSAPPR], [Notas], [IdTerminos]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

