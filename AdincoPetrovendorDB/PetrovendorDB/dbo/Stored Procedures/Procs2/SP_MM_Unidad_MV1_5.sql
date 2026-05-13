USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_Unidad_MV1_5'
)
    DROP PROCEDURE SP_MM_Unidad_MV1_5;
/****** Object:  StoredProcedure [dbo].[SP_MM_Unidad_MV1_5]    Script Date: 11/09/2023 08:06:21 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC 
-- Create date: 08/01/2024
-- Description:	 Se agrega is null a la columna eliminado ya que no estaba contemplando cuando es null 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Unidad_MV1_5]

    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	     CREATE TABLE #UnidadesTemp (IdUnidad INT,Unidad varchar(MAX))
		 CREATE TABLE #Unidad(IdRow int,IdUnidad int, Unidad varchar(MAX))
		 INSERT INTO #UnidadesTemp(IdUnidad, Unidad)VALUES(0,'-- Seleccione una unidad --')
		 
		 INSERT INTO  #Unidad(IdUnidad, Unidad)
         SELECT 		
		 IdUnidad,
		 Unidad	
         FROM PV_MM_MaterialUnidad as T (NOLOCK)
		WHERE	IsActivo				=	1
		AND	ISNULL(IsEliminado,0)				=	0
		ORDER BY Unidad ASC

		SELECT  IdUnidad, Unidad   FROM #UnidadesTemp 
		UNION 
		SELECT IdUnidad, Unidad  FROM #Unidad 

END