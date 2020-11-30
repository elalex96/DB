CREATE TABLE [dbo].[AM_MenuContrato] (
    [Id]         INT IDENTITY (10000, 1) NOT NULL,
    [IdContrato] INT NOT NULL,
    [IdMenu]     INT NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

