CREATE TABLE [dbo].[PC_Sector] (
    [IdSector]  INT           IDENTITY (10000, 1) NOT NULL,
    [CvSector]  NVARCHAR (10) NULL,
    [CreadoPor] INT           NULL,
    [CreadoEn]  DATETIME      NULL,
    CONSTRAINT [PK_PC_Sector] PRIMARY KEY CLUSTERED ([IdSector] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

