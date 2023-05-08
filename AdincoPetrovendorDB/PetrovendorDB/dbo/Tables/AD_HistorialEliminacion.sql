CREATE TABLE [dbo].[AD_HistorialEliminacion] (
    [IdHistorialEliminacion] INT            IDENTITY (1, 1) NOT NULL,
    [IdEliminacion]          INT            NULL,
    [Detalle]                NVARCHAR (MAX) NULL,
    [Activo]                 BIT            NULL,
    [CreadoPor]              INT            NULL,
    [CreadoEl]               DATETIME       NULL,
    [EditadoPor]             INT            NULL,
    [EditadoEl]              DATETIME       NULL,
    [ProcesoDe]              NVARCHAR (10)  NULL
);

