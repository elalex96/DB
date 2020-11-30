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
    CONSTRAINT [PK_CO_LineaProgramaActividadMes] PRIMARY KEY CLUSTERED ([IdLineaProgramaActividadMes] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_LineaProgramaActividadMes_CO_ActividadPetroleraCNH] FOREIGN KEY ([IdActividadPetrolera]) REFERENCES [dbo].[CO_ActividadPetroleraCNH] ([IdActividadPetrolera]),
    CONSTRAINT [FK_CO_LineaProgramaActividadMes_CO_ProgramaActividad] FOREIGN KEY ([IdProgramaActividad]) REFERENCES [dbo].[CO_ProgramaActividad] ([IdProgramaActividad]),
    CONSTRAINT [FK_CO_LineaProgramaActividadMes_CO_SubactividadPetrolera] FOREIGN KEY ([IdSubactividadPetrolera]) REFERENCES [dbo].[CO_SubactividadPetrolera] ([IdSubactividadPetrolera]),
    CONSTRAINT [FK_CO_LineaProgramaActividadMes_CO_SubTareaPetrolera] FOREIGN KEY ([IdSubTareaPetrolera]) REFERENCES [dbo].[CO_Servicio] ([IdServicio]),
    CONSTRAINT [FK_CO_LineaProgramaActividadMes_CO_TareaPetrolera] FOREIGN KEY ([IdTareaPetrolera]) REFERENCES [dbo].[CO_TareaPetrolera] ([IdTareaPetrolera])
);

