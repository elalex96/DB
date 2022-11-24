CREATE TABLE [dbo].[PRED_Previos] (
    [IdPrevio]          INT            NOT NULL,
    [IdPredio]          INT            NULL,
    [TabuladorIndaabin] VARCHAR (30)   NULL,
    [Vigencia]          DATETIME       NULL,
    [IdGestor]          INT            NULL,
    [IdJefeCampo]       INT            NULL,
    [Descripcion]       VARCHAR (MAX)  NULL,
    [CreadoPor]         INT            NULL,
    [CreadoEl]          DATETIME       NULL,
    [ModificadoPor]     INT            NULL,
    [ModificadoEl]      DATETIME       NULL,
    [Activo]            BIT            NULL,
    [IdTipoBDT]         INT            NULL,
    [IdTipoInstalacion] INT            NULL,
    [Gestor]            NVARCHAR (MAX) NULL,
    [JefeCampo]         NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_PRED_Previos] PRIMARY KEY CLUSTERED ([IdPrevio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PRED_Previos_CAT_TipoInstalacion] FOREIGN KEY ([IdTipoInstalacion]) REFERENCES [dbo].[CAT_TipoInstalacion] ([IdTipoInstalacion]),
    CONSTRAINT [FK_PRED_Previos_CAT_TiposBDT] FOREIGN KEY ([IdTipoBDT]) REFERENCES [dbo].[CAT_TiposBDT] ([IdTipoBDT])
);

