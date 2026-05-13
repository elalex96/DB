CREATE TABLE [dbo].[TaPrioridad] (
    [IdPrioridad] INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TaPrioridad] PRIMARY KEY CLUSTERED ([IdPrioridad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

