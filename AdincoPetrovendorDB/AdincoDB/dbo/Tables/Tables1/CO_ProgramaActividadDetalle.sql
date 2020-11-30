CREATE TABLE [dbo].[CO_ProgramaActividadDetalle] (
    [IdProgramaActividadDetalle] INT            IDENTITY (10000, 1) NOT NULL,
    [IdProgramaActividad]        INT            NULL,
    [IdActividadPetrolera]       INT            NULL,
    [IdSubactividadPetrolera]    INT            NULL,
    [IdTareaPetrolera]           INT            NULL,
    [Id_Subtarea]                NVARCHAR (MAX) NULL,
    [IdSubtareaPetrolera]        INT            NULL,
    [CreadoPor]                  INT            NULL,
    [CreadoEl]                   DATETIME       NULL,
    [ModificadoPor]              INT            NULL,
    [ModificadoEl]               DATETIME       NULL,
    [Activo]                     BIT            NULL,
    CONSTRAINT [PK_CO_ProgramaActividadDetalle] PRIMARY KEY CLUSTERED ([IdProgramaActividadDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaActividadDetalle_CO_ProgramaActividad] FOREIGN KEY ([IdProgramaActividad]) REFERENCES [dbo].[CO_ProgramaActividad] ([IdProgramaActividad]),
    CONSTRAINT [FK_CO_ProgramaActividadDetalle_CO_ProgramaActividadDetalle] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

