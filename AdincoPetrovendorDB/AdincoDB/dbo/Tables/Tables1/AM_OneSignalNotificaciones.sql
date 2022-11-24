CREATE TABLE [dbo].[AM_OneSignalNotificaciones] (
    [IdNotificacion]    INT            IDENTITY (1000, 1) NOT NULL,
    [Para]              NVARCHAR (200) NULL,
    [Player]            NVARCHAR (200) NULL,
    [TItulo]            NVARCHAR (100) NULL,
    [Subtitulo]         NVARCHAR (MAX) NULL,
    [Mensaje]           NVARCHAR (MAX) NULL,
    [FechaCreacion]     DATETIME       NULL,
    [FechaModificacion] DATETIME       NULL,
    [Enviado]           BIT            NULL,
    [Enviar]            BIT            NULL,
    [IdTareaOrigen]     INT            NULL,
    PRIMARY KEY CLUSTERED ([IdNotificacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

