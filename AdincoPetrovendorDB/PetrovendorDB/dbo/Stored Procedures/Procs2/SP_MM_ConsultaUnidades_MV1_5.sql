USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ConsultaUnidades_MV1_5'
)
DROP PROCEDURE SP_MM_ConsultaUnidades_MV1_5;
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaUnidades_MV1_5]    Script Date: 25/08/2022 02:43:13 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DANIEL AC	
-- Create date: 22/12/2017
-- Description:	Consulta unidades para alta express
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaUnidades_MV1_5] 
	@IdContrato    INT,
	@IdUsuario     INT,
	@FechaRegistro DATETIME

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		      
	  SELECT IdUnidad, Unidad 
	  FROM  PV_MM_MaterialUnidad  (NOLOCK)
	  WHERE IsActivo=1   
	  ORDER BY Unidad ASC 

END
