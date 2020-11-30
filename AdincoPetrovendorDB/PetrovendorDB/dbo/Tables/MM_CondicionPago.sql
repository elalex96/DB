CREATE TABLE [dbo].[MM_CondicionPago] (
    [IdCondicionPago] INT            NULL,
    [CondicionPago]   NVARCHAR (MAX) NULL,
    [Activo]          BIT            NULL,
    UNIQUE NONCLUSTERED ([IdCondicionPago] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

