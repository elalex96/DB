CREATE TABLE [dbo].[EN_AvanceEntregableSeguimientoUsuario] (
    [Id]                       INT           IDENTITY (1, 1) NOT NULL,
    [EntregableInstanciaId]    INT           NULL,
    [IdEstado]                 INT           NULL,
    [Porcentaje]               FLOAT (53)    NULL,
    [NombreAvance]             VARCHAR (MAX) NULL,
    [UsuarioId]                INT           NULL,
    [CreadoPor]                INT           NULL,
    [CreadoEl]                 DATETIME      NULL,
    [EditadoPor]               INT           NULL,
    [EditadoEl]                DATETIME      NULL,
    [Activo]                   BIT           NULL,
    [ContratoId]               INT           NULL,
    [ComentarioUsuario]        VARCHAR (MAX) NULL,
    [FechaModificacionUsuario] DATETIME      NULL
);

