CREATE TABLE [dbo].[OT_Configurador] (
    [IdContratista]                 INT     NOT NULL,
    [IdContrato]                    INT     NOT NULL,
    [DiasToleranciaCapAct]          INT     NULL,
    [ProgarmaInicialPorOperador]    BIT     NOT NULL,
    [PermitirAprobarSubcontratista] BIT     NULL,
    [PermitirConvenios]             BIT     NULL,
    [PermitirOTExcedida]            BIT     NULL,
    [IdUsuarioTaskPetro]            INT     NULL,
    [PermitirAceptacionAut]         BIT     NULL,
    [Decimales]                     TINYINT NULL,
    CONSTRAINT [PK_OT_Configurador] PRIMARY KEY CLUSTERED ([IdContratista] ASC, [IdContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_Configurador_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista]),
    CONSTRAINT [FK_OT_Configurador_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

