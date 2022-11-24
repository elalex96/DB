CREATE TABLE [dbo].[TA_TareaOperacion] (
    [IdTareaOperacion] INT IDENTITY (1, 1) NOT NULL,
    [IdOperacion]      INT NULL,
    [IdTarea]          INT NOT NULL,
    CONSTRAINT [PK_TA_TareaOperacion] PRIMARY KEY CLUSTERED ([IdTareaOperacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TA_TareaOperacion_TA_Operacion] FOREIGN KEY ([IdOperacion]) REFERENCES [dbo].[TA_Operacion] ([IdOperacion]),
    CONSTRAINT [FK_TA_TareaOperacion_TA_TareaOperacion] FOREIGN KEY ([IdTarea]) REFERENCES [dbo].[TA_Tarea] ([IdTarea])
);

