CREATE TABLE [dbo].[EN_ContratoEntregableProgramaImplementaAcciones] (
    [idConEntregableProgramaImpAccion] INT  IDENTITY (10000, 1) NOT NULL,
    [IdContratoEntregable]             INT  NOT NULL,
    [IdProgramaImplementaAccion]       INT  NOT NULL,
    [CreadoEl]                         DATE NULL,
    [CreadoPor]                        INT  NULL,
    [ModificadoEl]                     DATE NULL,
    [ModificadoPor]                    INT  NULL,
    [Activo]                           BIT  NULL,
    CONSTRAINT [PK_EN_ContratoEntregableProgramaImplementaAcciones] PRIMARY KEY CLUSTERED ([IdContratoEntregable] ASC, [IdProgramaImplementaAccion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [CreadoEl_EN_ContratoEntregableCO_ProgramaImplementa] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [IdEntregable_EN_ContratoEntregable] FOREIGN KEY ([IdContratoEntregable]) REFERENCES [dbo].[EN_ContratoEntregable] ([IdContratoEntregable]),
    CONSTRAINT [IdProgramaImplementaAccion_CO_ProgramaImplementaAcciones] FOREIGN KEY ([IdProgramaImplementaAccion]) REFERENCES [dbo].[CO_ProgramaImplementaAcciones] ([IdProgramaImplementaAccion]),
    CONSTRAINT [ModificadoPor_EN_ContratoEntregableCO_ProgramaImplementa] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

