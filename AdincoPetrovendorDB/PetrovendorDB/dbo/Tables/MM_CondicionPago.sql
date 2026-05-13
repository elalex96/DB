CREATE TABLE [dbo].[MM_CondicionPago] (
    [IdCondicionPago] INT            NULL,
    [CondicionPago]   NVARCHAR (MAX) NULL,
    [Activo]          BIT            NULL,
    UNIQUE NONCLUSTERED ([IdCondicionPago] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

