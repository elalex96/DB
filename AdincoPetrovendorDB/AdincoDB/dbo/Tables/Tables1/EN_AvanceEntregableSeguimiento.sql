CREATE TABLE [dbo].[EN_AvanceEntregableSeguimiento] (
    [Id]                    INT        IDENTITY (1, 1) NOT NULL,
    [EntregableInstanciaId] INT        NULL,
    [Porcentaje]            FLOAT (53) NULL,
    [CreadoPor]             INT        NULL,
    [CreadoEl]              DATETIME   NULL,
    [EditadoPor]            INT        NULL,
    [EditadoEl]             DATETIME   NULL,
    [Activo]                BIT        NULL,
    [ContratoId]            INT        NULL
);

