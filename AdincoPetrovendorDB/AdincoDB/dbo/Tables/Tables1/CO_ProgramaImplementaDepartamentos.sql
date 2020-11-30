CREATE TABLE [dbo].[CO_ProgramaImplementaDepartamentos] (
    [IdProgramaImplementaDepartamento] SMALLINT      NOT NULL,
    [IdContrato]                       INT           NOT NULL,
    [Descripcion]                      VARCHAR (250) NOT NULL,
    [CreadoEl]                         DATETIME      NOT NULL,
    [CreadoPor]                        INT           NOT NULL,
    [Activo]                           BIT           NULL,
    CONSTRAINT [PK_CO_ProgramaImplementaDepartamentos] PRIMARY KEY CLUSTERED ([IdProgramaImplementaDepartamento] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaImplementaDepartamentos_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ProgramaImplementaDepartamentos_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

