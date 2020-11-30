CREATE TABLE [dbo].[DEA_TipoNotificiacion] (
    [TipoNotificacion] NVARCHAR (100) NULL,
    [Detalle]          NVARCHAR (MAX) NULL,
    [Activo]           BIT            NULL,
    UNIQUE NONCLUSTERED ([TipoNotificacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

