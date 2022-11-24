CREATE TABLE [dbo].[CO_ActividadPetroleraCNH] (
    [IdActividadPetrolera]          INT            IDENTITY (1, 1) NOT NULL,
    [id_Actividad]                  NVARCHAR (MAX) NULL,
    [DescripcionActividadPetrolera] NVARCHAR (MAX) NOT NULL,
    [CreadoPor]                     INT            NULL,
    CONSTRAINT [PK_ActividadesPetroleras] PRIMARY KEY CLUSTERED ([IdActividadPetrolera] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

