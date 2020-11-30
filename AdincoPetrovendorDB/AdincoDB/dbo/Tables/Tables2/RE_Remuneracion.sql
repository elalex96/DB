CREATE TABLE [dbo].[RE_Remuneracion] (
    [IdRemuneracion] INT        NOT NULL,
    [IdContrato]     INT        NULL,
    [WTSMesAnterior] FLOAT (53) NULL,
    [API]            FLOAT (53) NULL,
    CONSTRAINT [PK_Remuneracion] PRIMARY KEY CLUSTERED ([IdRemuneracion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Remuneracion_Contratos] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

