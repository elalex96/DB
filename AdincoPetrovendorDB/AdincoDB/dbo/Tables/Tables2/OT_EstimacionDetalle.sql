CREATE TABLE [dbo].[OT_EstimacionDetalle] (
    [IdOTEstimacionDetalle] INT        NOT NULL,
    [IdOTEstimacion]        INT        NOT NULL,
    [IdOTSolicitudMaterial] INT        NOT NULL,
    [Cantidad]              FLOAT (53) NOT NULL,
    [PrecioUnitario]        MONEY      NOT NULL,
    [Importe]               MONEY      NOT NULL,
    [CreadoEl]              DATETIME   NOT NULL,
    [CantidadAcumulado]     FLOAT (53) NULL,
    [TotalAvanceAcumulado]  FLOAT (53) NULL,
    [PorcAvanceOT]          FLOAT (53) NULL,
    [PorcAvanceAcumulado]   FLOAT (53) NULL,
    CONSTRAINT [PK_OT_EstimacionDetalle] PRIMARY KEY CLUSTERED ([IdOTEstimacionDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_EstimacionDetalle_OT_Estimacion] FOREIGN KEY ([IdOTEstimacion]) REFERENCES [dbo].[OT_Estimacion] ([IdOTEstimacion]),
    CONSTRAINT [FK_OT_EstimacionDetalle_OT_SolicitudMaterial] FOREIGN KEY ([IdOTSolicitudMaterial]) REFERENCES [dbo].[OT_SolicitudMaterial] ([IdOTSolicitudMaterial])
);

