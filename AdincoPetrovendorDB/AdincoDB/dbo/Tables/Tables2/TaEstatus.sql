CREATE TABLE [dbo].[TaEstatus] (
    [IdEstatus] INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]    NVARCHAR (MAX) NULL,
    [Name]      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TaEstatus] PRIMARY KEY CLUSTERED ([IdEstatus] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

