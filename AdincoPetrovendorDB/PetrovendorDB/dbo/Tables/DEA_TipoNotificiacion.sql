CREATE TABLE [dbo].[DEA_TipoNotificiacion] (
    [TipoNotificacion] NVARCHAR (100) NULL,
    [Detalle]          NVARCHAR (MAX) NULL,
    [Activo]           BIT            NULL,
    UNIQUE NONCLUSTERED ([TipoNotificacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

