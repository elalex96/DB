CREATE TABLE [dbo].[OT_ProgramaBitacoraSemana] (
    [IdOTProgramaBitacoraSemana] INT           NOT NULL,
    [IdOTSolicitud]              INT           NOT NULL,
    [SemanaID]                   VARCHAR (21)  NOT NULL,
    [FechaRegistro]              DATETIME      NOT NULL,
    [Comentarios]                VARCHAR (500) NOT NULL,
    [CreadoPor]                  VARCHAR (50)  NOT NULL,
    [UsuarioPetrovendorID]       INT           NULL,
    [UsuarioAdincoID]            INT           NULL,
    [TipoUsuario]                TINYINT       NULL,
    CONSTRAINT [PK_OT_ProgramaBitacoraSemana] PRIMARY KEY CLUSTERED ([IdOTProgramaBitacoraSemana] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_ProgramaBitacoraSemana_OT_Solicitud] FOREIGN KEY ([IdOTSolicitud]) REFERENCES [dbo].[OT_Solicitud] ([IdOTSolicitud])
);

