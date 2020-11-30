CREATE TABLE [dbo].[CO_TareaPetrolera] (
    [IdTareaPetrolera] INT            IDENTITY (1, 1) NOT NULL,
    [id_Tarea]         NVARCHAR (MAX) NULL,
    [TareaPetrolera]   NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    CONSTRAINT [PK_TareasPetroleras] PRIMARY KEY CLUSTERED ([IdTareaPetrolera] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

