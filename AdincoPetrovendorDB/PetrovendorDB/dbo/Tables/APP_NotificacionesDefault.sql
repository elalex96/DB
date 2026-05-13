CREATE TABLE [dbo].[APP_NotificacionesDefault] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [ContratoId]        INT            NULL,
    [Titulo]            NVARCHAR (200) NULL,
    [Mensaje]           NVARCHAR (MAX) NULL,
    [CreadoEl]          DATETIME       NULL,
    [ModificadoEl]      DATETIME       NULL,
    [FechaInicio]       DATETIME       NULL,
    [FechaFinalizacion] DATETIME       NULL,
    [Activo]            BIT            NULL,
    [CreadoPor]         INT            NULL,
    [ModificadoPor]     INT            NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [idx_APP_NotificacionesDefault_ContratoId]
    ON [dbo].[APP_NotificacionesDefault]([ContratoId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

