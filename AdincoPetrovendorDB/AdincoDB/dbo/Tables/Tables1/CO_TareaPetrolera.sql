CREATE TABLE [dbo].[CO_TareaPetrolera] (
    [IdTareaPetrolera] INT            IDENTITY (1, 1) NOT NULL,
    [id_Tarea]         VARCHAR (150)  NULL,
    [TareaPetrolera]   NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    CONSTRAINT [PK_TareasPetroleras] PRIMARY KEY CLUSTERED ([IdTareaPetrolera] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

