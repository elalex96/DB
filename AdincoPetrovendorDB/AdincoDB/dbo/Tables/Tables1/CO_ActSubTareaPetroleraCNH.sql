CREATE TABLE [dbo].[CO_ActSubTareaPetroleraCNH] (
    [IdAST]                   INT IDENTITY (1, 1) NOT NULL,
    [IdActividadPetrolera]    INT NULL,
    [IdSubactividadPetrolera] INT NULL,
    [IdTareaPetrolera]        INT NULL,
    [CreadoPor]               INT NULL,
    CONSTRAINT [PK_ActSubTarea] PRIMARY KEY CLUSTERED ([IdAST] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ActSubTarea_ActividadesPetroleras] FOREIGN KEY ([IdActividadPetrolera]) REFERENCES [dbo].[CO_ActividadPetroleraCNH] ([IdActividadPetrolera]),
    CONSTRAINT [FK_ActSubTarea_SubactividadesPetroleras] FOREIGN KEY ([IdSubactividadPetrolera]) REFERENCES [dbo].[CO_SubactividadPetrolera] ([IdSubactividadPetrolera]),
    CONSTRAINT [FK_ActSubTarea_TareasPetroleras] FOREIGN KEY ([IdTareaPetrolera]) REFERENCES [dbo].[CO_TareaPetrolera] ([IdTareaPetrolera])
);

