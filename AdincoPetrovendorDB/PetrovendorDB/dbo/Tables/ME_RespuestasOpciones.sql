CREATE TABLE [dbo].[ME_RespuestasOpciones] (
    [IdRespuestasOpciones] INT           IDENTITY (1, 1) NOT NULL,
    [IdPregunta]           INT           NOT NULL,
    [Respuesta]            VARCHAR (MAX) NOT NULL,
    [Valor]                FLOAT (53)    NOT NULL,
    CONSTRAINT [PK_ME_RespuestasOpciones] PRIMARY KEY CLUSTERED ([IdRespuestasOpciones] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_RespuestasOpciones_ME_Preguntas] FOREIGN KEY ([IdPregunta]) REFERENCES [dbo].[ME_Preguntas] ([IdPregunta])
);

