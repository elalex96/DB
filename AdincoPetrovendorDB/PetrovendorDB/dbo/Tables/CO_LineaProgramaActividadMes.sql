CREATE TABLE [dbo].[CO_LineaProgramaActividadMes] (
    [IdLineaProgramaActividadMes] INT        IDENTITY (10000, 1) NOT NULL,
    [IdProgramaActividad]         INT        NULL,
    [IdActividadPetrolera]        INT        NULL,
    [IdSubactividadPetrolera]     INT        NULL,
    [IdTareaPetrolera]            INT        NULL,
    [IdSubTareaPetrolera]         INT        NULL,
    [NumeroAnio]                  INT        NULL,
    [NumeroMes]                   INT        NULL,
    [Actividades]                 FLOAT (53) NULL,
    [Fecha]                       DATE       NULL,
    CONSTRAINT [PK_CO_LineaProgramaActividadMes] PRIMARY KEY CLUSTERED ([IdLineaProgramaActividadMes] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

