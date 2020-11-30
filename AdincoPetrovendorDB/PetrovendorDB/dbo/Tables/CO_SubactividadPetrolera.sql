CREATE TABLE [dbo].[CO_SubactividadPetrolera] (
    [IdSubactividadPetrolera] INT            IDENTITY (1, 1) NOT NULL,
    [id_Sub-actividad]        NVARCHAR (MAX) NULL,
    [SubactividadPetrolera]   NVARCHAR (MAX) NULL,
    [CreadoPor]               INT            NULL,
    CONSTRAINT [PK_SubactividadesPetroleras] PRIMARY KEY CLUSTERED ([IdSubactividadPetrolera] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

