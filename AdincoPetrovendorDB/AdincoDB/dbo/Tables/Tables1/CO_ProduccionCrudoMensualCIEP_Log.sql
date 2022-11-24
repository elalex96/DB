CREATE TABLE [dbo].[CO_ProduccionCrudoMensualCIEP_Log] (
    [IdProduccionCrudoMensual_Log] INT        IDENTITY (10000, 1) NOT NULL,
    [IdProduccionCrudoMensual]     INT        NULL,
    [IdContrato]                   INT        NULL,
    [QCE]                          FLOAT (53) NULL,
    [API]                          FLOAT (53) NULL,
    [Mes]                          DATE       NULL,
    [CreadoPor]                    INT        NULL,
    [CreadoEl]                     DATETIME   NULL,
    [ModificadoPor]                INT        NULL,
    [ModificadoEl]                 DATETIME   NULL,
    [Activo]                       BIT        NULL,
    CONSTRAINT [PK_CO_ProduccionCrudoMensualCIEP_Log] PRIMARY KEY CLUSTERED ([IdProduccionCrudoMensual_Log] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProduccionCrudoMensualCIEP_Log_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

