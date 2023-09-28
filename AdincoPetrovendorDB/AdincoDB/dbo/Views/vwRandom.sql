USE [Adinco]
GO

GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'vwRandom'
)
    DROP VIEW vwRandom;
GO

CREATE VIEW [dbo].[vwRandom]
AS
SELECT RAND() as Rnd
GO


