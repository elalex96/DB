CREATE TABLE [dbo].[LOG_CalculoProduccionMensual] (
    [IdCalculoProduccion] INT        IDENTITY (1, 1) NOT NULL,
    [IdContrato]          INT        NOT NULL,
    [MesReporte]          DATE       NOT NULL,
    [PuntoEntregaID]      INT        NOT NULL,
    [VolumenPetroleo]     FLOAT (53) NULL,
    [VolumenGas]          FLOAT (53) NULL,
    [VolumenCondensado]   FLOAT (53) NULL,
    [GradosAPI]           FLOAT (53) NULL,
    [Azufre]              FLOAT (53) NULL,
    [Cromatografia_C1]    FLOAT (53) NULL,
    [Cromatografia_C2]    FLOAT (53) NULL,
    [Cromatografia_C3]    FLOAT (53) NULL,
    [Cromatografia_nC4]   FLOAT (53) NULL,
    [Cromatografia_iC4]   FLOAT (53) NULL,
    [Cromatografia_nC5]   FLOAT (53) NULL,
    [Cromatografia_iC5]   FLOAT (53) NULL,
    [Cromatografia_C6]    FLOAT (53) NULL,
    [Cromatografia_CO2]   FLOAT (53) NULL,
    [Cromatografia_H2S]   FLOAT (53) NULL,
    [Cromatografia_N2]    FLOAT (53) NULL,
    [ImportePetroleo]     FLOAT (53) NULL,
    [ImporteGas]          FLOAT (53) NULL,
    [UsuarioID]           INT        NOT NULL,
    [FecMovto]            DATETIME   NOT NULL,
    [Cromatografia_C7]    FLOAT (53) NULL,
    [Cromatografia_C8]    FLOAT (53) NULL,
    [Cromatografia_C9]    FLOAT (53) NULL,
    [Cromatografia_C10]   FLOAT (53) NULL,
    CONSTRAINT [PK_LOG_CalculoProduccionMensual] PRIMARY KEY CLUSTERED ([IdCalculoProduccion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_LOG_CalculoProduccionMensual_AP_Usuario] FOREIGN KEY ([UsuarioID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_LOG_CalculoProduccionMensual_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_LOG_CalculoProduccionMensual_CO_PuntosdeEntrega] FOREIGN KEY ([PuntoEntregaID]) REFERENCES [dbo].[CO_PuntosdeEntrega] ([PuntoEntregaID])
);


GO
CREATE NONCLUSTERED INDEX [idx_ContratoMesPtoEntrega]
    ON [dbo].[LOG_CalculoProduccionMensual]([IdContrato] ASC, [MesReporte] ASC, [PuntoEntregaID] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

