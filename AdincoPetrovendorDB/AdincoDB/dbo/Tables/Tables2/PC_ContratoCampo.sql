CREATE TABLE [dbo].[PC_ContratoCampo] (
    [IdContratoCampo] INT      IDENTITY (10000, 1) NOT NULL,
    [IdContrato]      INT      NULL,
    [IdCampo]         INT      NULL,
    [CreadoPor]       INT      NULL,
    [CreadoEn]        DATETIME NULL,
    CONSTRAINT [PK_PC_ContratoCampo] PRIMARY KEY CLUSTERED ([IdContratoCampo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PC_ContratoCampo_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_PC_ContratoCampo_PC_Campo] FOREIGN KEY ([IdCampo]) REFERENCES [dbo].[PC_Campo] ([IdCampo])
);

