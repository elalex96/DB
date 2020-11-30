CREATE TABLE [dbo].[MM_CondicionPago] (
    [IdCondicionPago] INT            IDENTITY (10000, 1) NOT NULL,
    [Condicion]       NVARCHAR (MAX) NULL,
    [Condition]       NVARCHAR (MAX) NULL,
    [Activo]          BIT            NULL,
    CONSTRAINT [PK_MM_CondicionPago] PRIMARY KEY CLUSTERED ([IdCondicionPago] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

