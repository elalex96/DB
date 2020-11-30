-- =============================================
-- Author:		Daniel AC
-- Create date: 18-12-17
-- Description:	Consulta materiales del catálogo de la operadora
-- =============================================
-- Author:           Daniel AC
-- Create date: 13-08-2019
-- Description: Add Marca, Modelo, No Parte a Descripción material 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaMaterialesSolPed_MV1_5]
	-- Add the parameters for the stored procedure here
	@IdTipoPedido INT, @IdProveedor INT ,

	/*--------------------
	parametros contrato 
   --------------------*/
	@IdContrato INT, @IdUsuario INT, @FechaRegistro DATETIME
/*--------------------
   --------------------*/
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;

		-- Insert statements for procedure here
		-- #Donde  MM.IdTipoProveedor = 1 Operador
		CREATE TABLE #MATERIALESTEMP
			( Identificador INT IDENTITY (1, 1) ,
			  IdMaterial INT ,
			  DescripcionCorta NVARCHAR (MAX) ,
			  DescripcionLarga NVARCHAR (MAX) ,
			  NombreUnidad NVARCHAR (50) ,
			  IdUnidad INT )

		DECLARE @IdTipoCatalogoMaestro INT ;

		---DECLARE @IdTipoPedido int  =10001
		IF @IdTipoPedido = 10000 --- MATERIALES
			SET @IdTipoCatalogoMaestro = 1 ;

		IF @IdTipoPedido = 10001 --- SEERVICIOS
			SET @IdTipoCatalogoMaestro = 2 ;

		INSERT INTO #MATERIALESTEMP
		SELECT	MM.IdMaterial ,
				CONCAT ( 'Núm. Material: ', MM.IdMaterial, ' - ',
				 ' Descripción: ', MM.DescripcionCorta,
				 ' Marca: ', CASE WHEN ISNULL(LEN(MM.Marca),0)>0 THEN MM.Marca ELSE ' S/M' END,
				 ' Modelo: ', CASE WHEN ISNULL(LEN(MM.Modelo),0)>0 THEN MM.Modelo ELSE ' S/M' END,
				 ' No. Parte: ',CASE WHEN ISNULL(LEN(MM.NumeroParte),0)>0 THEN MM.NumeroParte  ELSE ' S/NP' END ) AS DescripcionCorta ,
				MM.DescripcionLarga AS DescripcionLarga, U.Unidad AS NombreUnidad, U.IdUnidad
		  FROM	dbo.MM_Material AS MM
				INNER JOIN PV_MM_MaterialUnidad AS U
						   ON U.IdUnidad = MM.IdUnidad
		 WHERE
			--MM.IdTipoCatalogoMaestro = @IdTipoCatalogoMaestro
			--              AND 
				MM.IdTipoProveedor = 1
				AND MM.Activo = 1
				AND ISNULL ( MM.IsEliminado, 0 ) = 0
				AND MM.IdProveedor = @IdProveedor
		UNION
		SELECT	MM.IdMaterial ,
				CONCAT ( 'Núm. Material: ', MM.IdMaterial, 
				' - ', ' Descripción: ', MM.DescripcionCorta,
				' Marca: ', CASE WHEN ISNULL(LEN(MM.Marca),0)>0 THEN MM.Marca ELSE ' S/M' END,
				' Modelo: ', CASE WHEN ISNULL(LEN(MM.Modelo),0)>0 THEN MM.Modelo ELSE ' S/M' END,
				' No. Parte: ',CASE WHEN ISNULL(LEN(MM.NumeroParte),0)>0 THEN MM.NumeroParte  ELSE ' S/NP' END
				) AS DescripcionCorta ,
				MM.DescripcionLarga AS DescripcionLarga, U.Unidad AS NombreUnidad, U.IdUnidad
		  FROM	dbo.MM_Material AS MM
				INNER JOIN PV_MM_MaterialUnidad AS U
						   ON U.IdUnidad = MM.IdUnidad_1
		 WHERE
			--MM.IdTipoCatalogoMaestro = @IdTipoCatalogoMaestro
			--             AND
				MM.IdTipoProveedor = 1
				AND MM.Activo = 1
				AND ISNULL ( MM.IsEliminado, 0 ) = 0
				AND MM.IdProveedor = @IdProveedor
		UNION
		SELECT	MM.IdMaterial ,
				CONCAT ( 'Núm. Material: ', MM.IdMaterial, ' - ', 
				' Descripción: ', MM.DescripcionCorta,
				 ' Marca: ', CASE WHEN ISNULL(LEN(MM.Marca),0)>0 THEN MM.Marca ELSE ' S/M' END,
				 ' Modelo: ', CASE WHEN ISNULL(LEN(MM.Modelo),0)>0 THEN MM.Modelo ELSE ' S/M' END,
				 ' No. Parte: ',CASE WHEN ISNULL(LEN(MM.NumeroParte),0)>0 THEN MM.NumeroParte  ELSE ' S/NP' END				
				) AS DescripcionCorta ,
				MM.DescripcionLarga AS DescripcionLarga, U.Unidad AS NombreUnidad, U.IdUnidad
		  FROM	dbo.MM_Material AS MM
				INNER JOIN PV_MM_MaterialUnidad AS U
						   ON U.IdUnidad = MM.IdUnidad_2
		 WHERE
			--MM.IdTipoCatalogoMaestro = @IdTipoCatalogoMaestro
			--              AND 
				MM.IdTipoProveedor = 1
				AND MM.Activo = 1
				AND ISNULL ( MM.IsEliminado, 0 ) = 0
				AND MM.IdProveedor = @IdProveedor
		UNION
		SELECT	MM.IdMaterial ,
				CONCAT ( 'Núm. Material: ', 
				MM.IdMaterial, ' - ', 
				' Descripción: ', MM.DescripcionCorta,
				 ' Marca: ', CASE WHEN ISNULL(LEN(MM.Marca),0)>0 THEN MM.Marca ELSE ' S/M' END,
				 ' Modelo: ', CASE WHEN ISNULL(LEN(MM.Modelo),0)>0 THEN MM.Modelo ELSE ' S/M' END,
				 ' No. Parte: ',CASE WHEN ISNULL(LEN(MM.NumeroParte),0)>0 THEN MM.NumeroParte  ELSE ' S/NP' END
				 ) AS DescripcionCorta ,
				MM.DescripcionLarga AS DescripcionLarga, U.Unidad AS NombreUnidad, U.IdUnidad
		  FROM	dbo.MM_Material AS MM
				INNER JOIN PV_MM_MaterialUnidad AS U
						   ON U.IdUnidad = MM.IdUnidad_3
		 WHERE
			--MM.IdTipoCatalogoMaestro = @IdTipoCatalogoMaestro
			--              AND 
				MM.IdTipoProveedor = 1
				AND MM.Activo = 1
				AND ISNULL ( MM.IsEliminado, 0 ) = 0
				AND MM.IdProveedor = @IdProveedor

		--Materiales
		--   ORDER BY Materiales.IdMaterial  ASC
		SELECT *  FROM #MATERIALESTEMP
	END

