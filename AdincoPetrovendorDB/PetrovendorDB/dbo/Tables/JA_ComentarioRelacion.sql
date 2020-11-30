CREATE TABLE [dbo].[JA_ComentarioRelacion] (
    [IdRelacionComentario]  INT IDENTITY (1, 1) NOT NULL,
    [IdComentarioBase]      INT NULL,
    [IdComentarioRespuesta] INT NULL,
    PRIMARY KEY CLUSTERED ([IdRelacionComentario] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

