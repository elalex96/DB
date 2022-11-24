CREATE TABLE [dbo].[CO_ValoresConciliadosProducion] (
    [IdValoresConciliadosProducion] INT        IDENTITY (10000, 1) NOT NULL,
    [PuntoEntregaID]                INT        NOT NULL,
    [Mes]                           DATE       NOT NULL,
    [Aceite]                        FLOAT (53) NOT NULL,
    [Gas]                           FLOAT (53) NOT NULL,
    [Agua]                          FLOAT (53) NOT NULL,
    [IdContrato]                    INT        NOT NULL,
    [CreadoPor]                     INT        NOT NULL,
    [CreadoEl]                      DATETIME   NOT NULL,
    [ModificadoPor]                 INT        NULL,
    [ModificadoEl]                  DATETIME   NULL,
    [Activo]                        BIT        NOT NULL,
    PRIMARY KEY CLUSTERED ([IdValoresConciliadosProducion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    FOREIGN KEY ([PuntoEntregaID]) REFERENCES [dbo].[CO_PuntosdeEntrega] ([PuntoEntregaID])
);

