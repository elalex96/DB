CREATE TABLE [dbo].[EN_InstanciasEntregable] (
    [idInstanciaEntregable]           INT      IDENTITY (10000, 1) NOT NULL,
    [FechasLimiteElaboracion]         DATETIME NULL,
    [FechasLimiteRevision]            DATETIME NULL,
    [FechasLimiteAprobacion]          DATETIME NULL,
    [FechaEnvioMensajeAtrasoRevision] DATETIME NULL,
    [idFrecuencua]                    INT      NULL,
    [IdContratoEntregable]            INT      NULL,
    [ContieneAjusteFechas]            INT      NULL,
    [FechaElaboro]                    DATE     NULL,
    [FechaReviso]                     DATE     NULL,
    [FechaAprobo]                     DATE     NULL,
    [CorreoEnviado]                   BIT      DEFAULT ((0)) NULL,
    [ActividadID]                     INT      NULL,
    [CreadoPor]                       INT      NULL,
    [CreadoEn]                        DATETIME NULL,
    [ModificadoPor]                   INT      NULL,
    [ModificadoEn]                    DATETIME NULL,
    [Activo]                          BIT      NULL,
    [FechaCalculadaEntregaReg]        DATETIME NULL,
    [FechaInicioElaboracion]          DATETIME NULL,
    [FechaRealEntregaRegulador]       DATETIME NULL,
    [BitContieneAcuse]                BIT      NULL,
    [IdInstalacion]                   INT      NULL,
    CONSTRAINT [PK__EN_Insta__BFE7FB394EC72BE9] PRIMARY KEY CLUSTERED ([idInstanciaEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_InstanciasEntregable_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_InstanciasEntregable_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [fk_IdContratoEntregable] FOREIGN KEY ([IdContratoEntregable]) REFERENCES [dbo].[EN_ContratoEntregable] ([IdContratoEntregable])
);


GO
CREATE NONCLUSTERED INDEX [indiceContratoEntregableActividad]
    ON [dbo].[EN_InstanciasEntregable]([IdContratoEntregable] ASC, [ActividadID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [EN_InstanciasEntregable_FechaElaboracion]
    ON [dbo].[EN_InstanciasEntregable]([FechasLimiteElaboracion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [IX_EN_InstanciasEntregable]
    ON [dbo].[EN_InstanciasEntregable]([idInstanciaEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

