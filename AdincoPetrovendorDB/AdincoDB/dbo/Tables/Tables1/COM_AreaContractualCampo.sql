CREATE TABLE [dbo].[COM_AreaContractualCampo] (
    [IdAreaContractualCampo] INT        IDENTITY (1, 1) NOT NULL,
    [IdAreaContractual]      INT        NULL,
    [IdCampo]                INT        NULL,
    [Porcentaje]             FLOAT (53) NULL,
    CONSTRAINT [PK_COM_AreaContractualCampo] PRIMARY KEY CLUSTERED ([IdAreaContractualCampo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_COM_AreaContractualCampo_CO_AreaContractual] FOREIGN KEY ([IdAreaContractual]) REFERENCES [dbo].[CO_AreaContractual] ([IdAreaContractual]),
    CONSTRAINT [FK_COM_AreaContractualCampo_PD_Campo] FOREIGN KEY ([IdCampo]) REFERENCES [dbo].[PD_Campo] ([IdCampo])
);

