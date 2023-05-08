CREATE TABLE [dbo].[CO_ProduccionCrudoMensualCIEP] (
    [IdProduccionCrudoMensual] INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]               INT            NULL,
    [QCE]                      FLOAT (53)     NULL,
    [API]                      FLOAT (53)     NULL,
    [Mes]                      DATE           NULL,
    [CreadoPor]                INT            NULL,
    [CreadoEl]                 DATETIME       NULL,
    [ModificadoPor]            INT            NULL,
    [ModificadoEl]             DATETIME       NULL,
    [Activo]                   BIT            NULL,
    [PDF]                      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CO_ProduccionCrudoMensualCIEP] PRIMARY KEY CLUSTERED ([IdProduccionCrudoMensual] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProduccionCrudoMensualCIEP_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

