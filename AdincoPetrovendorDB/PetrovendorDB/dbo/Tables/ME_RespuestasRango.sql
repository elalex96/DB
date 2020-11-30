CREATE TABLE [dbo].[ME_RespuestasRango] (
    [IdRespuestasRango] INT           IDENTITY (1, 1) NOT NULL,
    [IdPregunta]        INT           NOT NULL,
    [ValorMin]          INT           NOT NULL,
    [ValorMax]          INT           NOT NULL,
    [Valor]             FLOAT (53)    NOT NULL,
    [Respuesta]         VARCHAR (MAX) NULL,
    CONSTRAINT [PK_ME_RespuestasRango] PRIMARY KEY CLUSTERED ([IdRespuestasRango] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_RespuestasRango_ME_Preguntas] FOREIGN KEY ([IdPregunta]) REFERENCES [dbo].[ME_Preguntas] ([IdPregunta])
);

