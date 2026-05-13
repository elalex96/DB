CREATE TABLE [dbo].[EN_AvanceEntregableHistorial] (
    [Id]                    INT            IDENTITY (1, 1) NOT NULL,
    [EntregableInstanciaId] INT            NULL,
    [IdEstado]              INT            NULL,
    [Porcentaje]            FLOAT (53)     NULL,
    [Detalle]               NVARCHAR (MAX) NULL,
    [Comentario]            NVARCHAR (MAX) NULL,
    [AvancePersonalizado]   BIT            NULL,
    [CreadoPor]             INT            NULL,
    [CreadoEl]              DATETIME       NULL,
    [Activo]                BIT            NULL,
    [ContratoId]            INT            NULL
);

