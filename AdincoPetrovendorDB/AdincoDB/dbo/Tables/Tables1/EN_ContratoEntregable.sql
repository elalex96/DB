CREATE TABLE [dbo].[EN_ContratoEntregable] (
    [IdContratoEntregable]        INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]                  INT            NULL,
    [IdEntregable]                INT            NULL,
    [AreaResponsable]             NVARCHAR (MAX) NULL,
    [Elabora]                     NVARCHAR (MAX) NULL,
    [Revisa]                      NVARCHAR (MAX) NULL,
    [Aprueba]                     NVARCHAR (MAX) NULL,
    [UsuarioElabora]              INT            NULL,
    [UsuarioRevision]             INT            NULL,
    [UsuarioAprueba]              INT            NULL,
    [DiasRevision]                INT            NULL,
    [DiasAprobacion]              INT            NULL,
    [DiasAlerta]                  INT            NULL,
    [ReceptorAlerta]              NVARCHAR (MAX) NULL,
    [CreadoPor]                   INT            NULL,
    [CreadoEl]                    DATETIME       NULL,
    [ModificadoPor]               INT            NULL,
    [ModificadoEl]                DATETIME       NULL,
    [Activo]                      BIT            NULL,
    [Entrega]                     VARCHAR (300)  NULL,
    [FechaLimiteEntrega]          DATETIME       NULL,
    [FechaLimiteEntregaRegulador] DATE           NULL,
    [DiasElaboracion]             INT            NULL,
    [IdArea]                      INT            NULL,
    [Subfuncion]                  VARCHAR (300)  NULL,
    [FocalPoint]                  VARCHAR (250)  NULL,
    [AccountableCompliance]       VARCHAR (250)  NULL,
    [Accountable]                 VARCHAR (250)  NULL,
    [ContieneInformacionSensible] BIT            NULL,
    [BitMostrarLineaTiempo]       BIT            NULL,
    [BitCortoPlazo]               BIT            NULL,
    [BitMedianoPlazo]             BIT            NULL,
    [BitLargoPlazo]               BIT            NULL,
    [BitNA]                       BIT            DEFAULT ((0)) NULL,
    [Radar]                       BIT            NULL,
    CONSTRAINT [PK_CO_ContratoEntregable] PRIMARY KEY CLUSTERED ([IdContratoEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_ContratoEntregable_EN_Area] FOREIGN KEY ([IdArea]) REFERENCES [dbo].[EN_Area] ([idArea])
);


GO
CREATE NONCLUSTERED INDEX [EN_CONTRATO_ENTREGABLE_CONTRATO_ACTIVO]
    ON [dbo].[EN_ContratoEntregable]([IdContrato] ASC, [Activo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [IX_EN_ContratoEntregable]
    ON [dbo].[EN_ContratoEntregable]([IdContratoEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

