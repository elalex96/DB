CREATE TABLE [dbo].[ME_Respuestas] (
    [IdRespuestas]        INT           IDENTITY (1, 1) NOT NULL,
    [IdProveedorEvaluado] INT           NOT NULL,
    [IdMatrizEvaluacion]  INT           NOT NULL,
    [IdSeccion]           INT           NOT NULL,
    [IdPregunta]          INT           NOT NULL,
    [Respuesta]           VARCHAR (MAX) NOT NULL,
    [ValorRespuesta]      FLOAT (53)    NOT NULL,
    [RespondidoPor]       INT           NOT NULL,
    [RespondidoEl]        SMALLDATETIME NOT NULL,
    [IdPedido]            INT           NULL,
    [ValorAutorizado]     FLOAT (53)    NULL,
    CONSTRAINT [PK_ME_Respuestas] PRIMARY KEY CLUSTERED ([IdRespuestas] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_Respuestas_ME_MatrizEvaluacion] FOREIGN KEY ([IdMatrizEvaluacion]) REFERENCES [dbo].[ME_MatrizEvaluacion] ([IdMatrizEvaluacion]),
    CONSTRAINT [FK_ME_Respuestas_ME_Preguntas] FOREIGN KEY ([IdPregunta]) REFERENCES [dbo].[ME_Preguntas] ([IdPregunta]),
    CONSTRAINT [FK_ME_Respuestas_ME_Seccion] FOREIGN KEY ([IdSeccion]) REFERENCES [dbo].[ME_Seccion] ([IdSeccion]),
    CONSTRAINT [FK_ME_Respuestas_S_Proveedor] FOREIGN KEY ([IdProveedorEvaluado]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_ME_Respuestas_S_Usuario] FOREIGN KEY ([RespondidoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

