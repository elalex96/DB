CREATE TABLE [dbo].[TA_ComentariosTareaCancelada] (
    [IdComentario] INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion]  NVARCHAR (MAX) NULL,
    [IdOperacion]  INT            NULL,
    [IdUsuario]    INT            NULL,
    CONSTRAINT [PK_TA_}] PRIMARY KEY CLUSTERED ([IdComentario] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TA_ComentariosCancelada_TA_Operacion] FOREIGN KEY ([IdOperacion]) REFERENCES [dbo].[TA_Operacion] ([IdOperacion])
);

