CREATE TABLE [dbo].[AM_StatusAprobacionM] (
    [IdStatusAprobacionM] INT           IDENTITY (1, 1) NOT NULL,
    [Status]              VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([IdStatusAprobacionM] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

