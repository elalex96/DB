CREATE TABLE [dbo].[PC_AnalisisCromatograficoGas] (
    [IdAnalisisCromatograficoGas] INT        IDENTITY (10000, 1) NOT NULL,
    [IdContrato]                  INT        NULL,
    [MesReporte]                  DATE       NULL,
    [IdPtoExpedicionRecepcion]    INT        NULL,
    [Dia]                         INT        NULL,
    [Grav_H2Sppm]                 FLOAT (53) NULL,
    [PoderEspec_adm]              FLOAT (53) NULL,
    [Poder_CO2mol]                FLOAT (53) NULL,
    [Temp_N2mol]                  FLOAT (53) NULL,
    [Presion_C1mol]               FLOAT (53) NULL,
    [C2mol]                       FLOAT (53) NULL,
    [C3mol]                       FLOAT (53) NULL,
    [IC4mol]                      FLOAT (53) NULL,
    [NC4mol]                      FLOAT (53) NULL,
    [IC5mol]                      FLOAT (53) NULL,
    [NC5mol]                      FLOAT (53) NULL,
    [C6mol]                       FLOAT (53) NULL,
    [PM_LBmol]                    FLOAT (53) NULL,
    [LIC_Bmmpc]                   FLOAT (53) NULL,
    [Cal_BTUf3]                   FLOAT (53) NULL,
    [Calorico_KCAm3]              FLOAT (53) NULL,
    [GradosC]                     FLOAT (53) NULL,
    [KGcm2]                       FLOAT (53) NULL,
    [CreadoPor]                   INT        NULL,
    [CreadoEn]                    DATETIME   NULL,
    CONSTRAINT [PK_PC_AnalisisCromatograficoGas] PRIMARY KEY CLUSTERED ([IdAnalisisCromatograficoGas] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__PC_Analis__IdPto__137F56A4] FOREIGN KEY ([IdPtoExpedicionRecepcion]) REFERENCES [dbo].[PC_PtoExpedicionRecepcion] ([IdPtoExpedicionRecepcion]),
    CONSTRAINT [FK_PC_AnalisisCromatograficoGas_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PC_AnalisisCromatograficoGas_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);


GO
CREATE NONCLUSTERED INDEX [idx_Contrato_MesReporte_IdPtoExpedicionRecepcion_Dia]
    ON [dbo].[PC_AnalisisCromatograficoGas]([IdContrato] ASC, [MesReporte] ASC, [IdPtoExpedicionRecepcion] ASC, [Dia] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

