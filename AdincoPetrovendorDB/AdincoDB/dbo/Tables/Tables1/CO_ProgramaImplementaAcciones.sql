CREATE TABLE [dbo].[CO_ProgramaImplementaAcciones] (
    [IdProgramaImplementaAccion]       INT            NOT NULL,
    [IdProgramaImplementaElemento]     INT            NOT NULL,
    [Descripcion]                      VARCHAR (8000) NULL,
    [IdProgramaImplementaDepartamento] SMALLINT       NOT NULL,
    [FechaInicioPrimeraAccion]         DATETIME       NOT NULL,
    [FechaFinPrimeraAccion]            DATETIME       NOT NULL,
    [Anexo3]                           VARCHAR (500)  NOT NULL,
    [ElementosNumerales]               VARCHAR (500)  NOT NULL,
    [IdPeriodicidad]                   INT            NOT NULL,
    [CreadoEl]                         DATETIME       NOT NULL,
    [CreadoPor]                        INT            NOT NULL,
    [ModificadoEl]                     DATETIME       NULL,
    [ModificadoPor]                    INT            NULL,
    [Periodicidad]                     VARCHAR (250)  NULL,
    [Porcentaje]                       FLOAT (53)     NULL,
    Orden                               INT             NULL,
    CONSTRAINT [PK_CO_ProgramaImplementaAcciones] PRIMARY KEY CLUSTERED ([IdProgramaImplementaAccion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaImplementaAcciones_CO_ProgramaImplementaDepartamentos] FOREIGN KEY ([IdProgramaImplementaDepartamento]) REFERENCES [dbo].[CO_ProgramaImplementaDepartamentos] ([IdProgramaImplementaDepartamento]),
    CONSTRAINT [FK_CO_ProgramaImplementaAcciones_CO_ProgramaImplementaElemento] FOREIGN KEY ([IdProgramaImplementaElemento]) REFERENCES [dbo].[CO_ProgramaImplementaElemento] ([IdProgramaImplementaElemento]),
    CONSTRAINT [FK_CO_ProgramaImplementaAcciones_EN_FrecuenciaEntregable] FOREIGN KEY ([IdPeriodicidad]) REFERENCES [dbo].[EN_FrecuenciaEntregable] ([IdFrecuenciaEntregable])
);

