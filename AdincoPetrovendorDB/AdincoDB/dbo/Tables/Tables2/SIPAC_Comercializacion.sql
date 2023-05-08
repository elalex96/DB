CREATE TABLE [dbo].[SIPAC_Comercializacion] (
    [ComercializacionId] INT        IDENTITY (1, 1) NOT NULL,
    [RM00_01]            DATETIME   NOT NULL,
    [RM00_02]            INT        NOT NULL,
    [RM00_03]            INT        NOT NULL,
    [RM00_04]            FLOAT (53) NOT NULL,
    [RM00_05]            FLOAT (53) NOT NULL,
    [AreaConrtactualID]  INT        NOT NULL,
    CONSTRAINT [PK_SIPAC_Comercializacion] PRIMARY KEY CLUSTERED ([ComercializacionId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SIPAC_Comercializacion_CO_AreaContractual] FOREIGN KEY ([AreaConrtactualID]) REFERENCES [dbo].[CO_AreaContractual] ([IdAreaContractual]),
    CONSTRAINT [FK_SIPAC_Comercializacion_SIPAC_GeneralTipoHidrocarburos] FOREIGN KEY ([RM00_02]) REFERENCES [dbo].[SIPAC_GeneralTipoHidrocarburos] ([IdTipoHidrocarburo])
);

