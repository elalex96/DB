USE [Adinco]
GO
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ENIJointVentureTablaDinamica'
)
    DROP PROCEDURE SP_ENIJointVentureTablaDinamica;
GO
/****** Object:  StoredProcedure [dbo].[SP_ENIJointVenture]    Script Date: 19/05/2022 12:04:50 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: 19-05-2022
-- Description:	 Retronar lista para tabla sin columnas definidas, agregar los alias segun se desea en el idioma deseado
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENIJointVentureTablaDinamica] 
-- Add the parameters for the stored procedure here
	@IdContrato INT, 
	@IdUsuario  INT,
	@Idioma INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

		 DECLARE @TABLE AS TABLE (Contrato NVARCHAR(MAX), FechaInicio DATETIME , FechaFin DATETIME) 
		 --INSERT INTO @TABLE(Contrato,FechaInicio,FechaFin)
		 --VALUES('CNH-R01-L03-A00/2015',CAST(N'2015-12-05T00:00:00.000' AS DateTime),CAST(N'2015-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2016	',CAST(N'2016-12-05T00:00:00.000' AS DateTime),CAST(N'2016-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2017	',CAST(N'2017-12-05T00:00:00.000' AS DateTime),CAST(N'2017-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2018	',CAST(N'2018-12-05T00:00:00.000' AS DateTime),CAST(N'2018-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2019	',CAST(N'2019-12-05T00:00:00.000' AS DateTime),CAST(N'2019-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2020	',CAST(N'2020-12-05T00:00:00.000' AS DateTime),CAST(N'2020-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2021	',CAST(N'2021-12-05T00:00:00.000' AS DateTime),CAST(N'2021-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2016	',CAST(N'2016-12-05T00:00:00.000' AS DateTime),CAST(N'2016-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2017	',CAST(N'2017-12-05T00:00:00.000' AS DateTime),CAST(N'2017-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2018	',CAST(N'2018-12-05T00:00:00.000' AS DateTime),CAST(N'2018-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2019	',CAST(N'2019-12-05T00:00:00.000' AS DateTime),CAST(N'2019-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2020	',CAST(N'2020-12-05T00:00:00.000' AS DateTime),CAST(N'2020-12-05T00:00:00.000' AS DateTime)),
		 --('CNH-R01-L03-A00/2021	',CAST(N'2021-12-05T00:00:00.000' AS DateTime),CAST(N'2021-12-05T00:00:00.000' AS DateTime))

		 
		 IF @Idioma = 2 -->EN(COLUMNAS EN INGLES)
		 BEGIN

		 SELECT 
		 Contrato AS Contract, 
		 FechaInicio AS [Start Date],
		 FechaFin AS  [End Date],
		 @IdContrato AS  [Contract Number]
		 FROM @TABLE


		 END 
		 ELSE 
		 BEGIN  -->ES(COLUMNAS EN ESPAÑOL)
		 
		  SELECT 
		 Contrato AS Contrato, 
		 FechaInicio AS [FechaInicio],
		 FechaFin AS [Fecha Fin],
		 @IdContrato AS [Número de Contrato]
		 FROM @TABLE

		 END 
 END;

