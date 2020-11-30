CREATE TABLE [dbo].[ME_Preguntas] (
    [IdPregunta]         INT           IDENTITY (1, 1) NOT NULL,
    [IdSeccion]          INT           NOT NULL,
    [Pregunta]           VARCHAR (MAX) NOT NULL,
    [IdTipoRespuesta]    INT           NULL,
    [AplicaPersonaMoral] BIT           NOT NULL,
    [Ponderacion]        FLOAT (53)    NOT NULL,
    [RequiereDocumento]  BIT           NOT NULL,
    [Activo]             BIT           NULL,
    CONSTRAINT [PK_ME_Preguntas] PRIMARY KEY CLUSTERED ([IdPregunta] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_Preguntas_ME_Seccion] FOREIGN KEY ([IdSeccion]) REFERENCES [dbo].[ME_Seccion] ([IdSeccion]),
    CONSTRAINT [FK_ME_Preguntas_ME_TiposRespuesta] FOREIGN KEY ([IdTipoRespuesta]) REFERENCES [dbo].[ME_TiposRespuesta] ([IdTipoRespuesta])
);

