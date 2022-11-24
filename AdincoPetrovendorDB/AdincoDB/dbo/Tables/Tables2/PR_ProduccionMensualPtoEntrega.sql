CREATE TABLE [dbo].[PR_ProduccionMensualPtoEntrega] (
    [IdProduccionMensualPtoEntrega] INT        IDENTITY (1000, 1) NOT NULL,
    [IdContrato]                    INT        NULL,
    [IdFecha]                       DATE       NULL,
    [PuntoEntregaID]                INT        NULL,
    [IdTipoHidrocarburo]            INT        NULL,
    [VolumenProducido]              FLOAT (53) NULL,
    [VolumenVendido]                FLOAT (53) NULL,
    [idUnidadMedida]                INT        NULL,
    [CreadoPor]                     INT        NULL,
    [CreadoEl]                      DATETIME   NULL,
    [ModificadoPor]                 INT        NULL,
    [ModificadoEl]                  DATETIME   NULL,
    [Precio]                        MONEY      NULL,
    CONSTRAINT [PK_PR_ProduccionMensualPtoEntrega] PRIMARY KEY CLUSTERED ([IdProduccionMensualPtoEntrega] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PR_ProduccionMensualPtoEntrega_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_PR_ProduccionMensualPtoEntrega_CO_PuntosdeEntrega] FOREIGN KEY ([PuntoEntregaID]) REFERENCES [dbo].[CO_PuntosdeEntrega] ([PuntoEntregaID]),
    CONSTRAINT [FK_PR_ProduccionMensualPtoEntrega_CO_TipoHidrocarburo] FOREIGN KEY ([IdTipoHidrocarburo]) REFERENCES [dbo].[CO_TipoHidrocarburo] ([IdTipoHidrocarburo]),
    CONSTRAINT [FK_PR_ProduccionMensualPtoEntrega_CO_UnidadMedida] FOREIGN KEY ([idUnidadMedida]) REFERENCES [dbo].[CO_UnidadMedida] ([idUnidadMedida])
);

