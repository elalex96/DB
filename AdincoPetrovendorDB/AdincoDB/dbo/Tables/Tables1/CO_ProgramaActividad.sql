CREATE TABLE [dbo].[CO_ProgramaActividad] (
    [IdProgramaActividad]             INT            IDENTITY (10000, 1) NOT NULL,
    [IdPeriodoContrato]               INT            NULL,
    [IdTipoProgramaActividad]         INT            NULL,
    [NombrePrograma]                  NVARCHAR (MAX) NULL,
    [FechaPresentacion]               DATE           NULL,
    [NumeroRegistroContenidoNacional] NVARCHAR (MAX) NULL,
    [CreadoPor]                       INT            NULL,
    [CreadoEl]                        DATETIME       NULL,
    [ModificadoPor]                   INT            NULL,
    [ModificadoEl]                    DATETIME       NULL,
    [Activo]                          BIT            NULL,
    CONSTRAINT [PK_CO_ProgramaActividad] PRIMARY KEY CLUSTERED ([IdProgramaActividad] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaActividad_AP_Usuario] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ProgramaActividad_CO_PeriodoContrato] FOREIGN KEY ([IdPeriodoContrato]) REFERENCES [dbo].[CO_PeriodoContrato] ([IdPeriodo]),
    CONSTRAINT [FK_CO_ProgramaActividad_CO_TipoProgramaActividad] FOREIGN KEY ([IdTipoProgramaActividad]) REFERENCES [dbo].[CO_TipoProgramaActividad] ([IdTipoProgramaActividad])
);

