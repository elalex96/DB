-- =============================================
-- Author:		DANIEL AC
-- Create date:02/10/2017
-- Description:	 Consulta materiales por filtro 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_PV_FiltroCatalogoMateriales]  
 @TipoMaterialCatalogo int, 
 @MaterialBuscar NVARCHAR(MAX),
 @Marca NVARCHAR(MAX),
 @Modelo NVARCHAR(MAX)
 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @SQL_QUERY  NVARCHAR(MAX)=''
	DECLARE @SQL_MODELO  NVARCHAR(MAX)=''
	DECLARE @SQL_MARCA  NVARCHAR(MAX)=''
	--[SP_MM_PV_FiltroCatalogoMateriales] 1,'Cargador','',''

	IF @TipoMaterialCatalogo = 1 
	BEGIN 
		
		IF   LTRIM(RTRIM(@Marca)) <> ''
		BEGIN
			SET @SQL_MARCA =' AND M.[Marca]  LIKE ''%'+@Marca+'%'' ' 
		END  
		ELSE 
		BEGIN
			SET @SQL_MARCA ='' 
		END 

		IF  LTRIM(RTRIM(@Modelo)) <> ''
		BEGIN
			SET @SQL_MODELO =' AND M.[Modelo]  LIKE ''%'+@Modelo+'%'' ' 
		END  
		ELSE 
		BEGIN
			SET @SQL_MODELO ='' 
		END 
		 

		SET  @SQL_QUERY = (N'SELECT  M.IdMaterial,Unidad,DescripcionCorta,Marca,Modelo,NumeroParte '
		+'FROM [dbo].[MM_Material] AS M ' 
		+'INNER JOIN [dbo].[MM_MaterialesVentaProveedor] AS MP ON MP.[IdMaterial]=M.[IdMaterial] '
		+'INNER JOIN [dbo].[PV_MM_MaterialUnidad] AS MU ON MU.[IdUnidad] = M.[IdUnidad] '
		+'INNER JOIN [dbo].[MM_Maestro] AS MT ON  MT.[IdMaestro] = M.[IdMaestro] '
		+'INNER JOIN [dbo].[MM_TipoMaterialProcura] AS TM ON TM.[IdTipoMaterialProcura] =  MT.[IdTipoCatalogoMaestro] '
		+'WHERE M.[Activo]= 1 AND TM.[IdTipoMaterialProcura] = '+ CAST(@TipoMaterialCatalogo  AS NVARCHAR(100)) +' '+
		+'AND M.[DescripcionCorta]  LIKE ''%'+LTRIM(RTRIM(@MaterialBuscar))+'%'' '  
		+' ##MARCA## '
		+' ##MODELO## ')

		 SET @SQL_QUERY = (SELECT REPLACE(@SQL_QUERY,'##MARCA##',@SQL_MARCA))
		 SET @SQL_QUERY = (SELECT REPLACE(@SQL_QUERY,'##MODELO##',@SQL_MODELO))

		---SELECT @SQL_QUERY
		 EXECUTE  sp_executesql @SQL_QUERY
	END 

	IF @TipoMaterialCatalogo = 2
	BEGIN 
		SELECT M.IdMaterial,Unidad,DescripcionCorta,Marca,Modelo,NumeroParte
		FROM [dbo].[MM_Material] AS M 
		INNER JOIN [dbo].[MM_MaterialesVentaProveedor] AS MP ON MP.[IdMaterial]=M.[IdMaterial]
		INNER JOIN [dbo].[PV_MM_MaterialUnidad] AS MU ON MU.[IdUnidad] = M.[IdUnidad]
		INNER JOIN [dbo].[MM_Maestro] AS MT ON  MT.[IdMaestro] = M.[IdMaestro]
		INNER JOIN [dbo].[MM_TipoMaterialProcura] AS TM ON TM.[IdTipoMaterialProcura] =  MT.[IdTipoCatalogoMaestro]
		WHERE M.[Activo]= 1 AND TM.[IdTipoMaterialProcura] = @TipoMaterialCatalogo AND  M.[DescripcionCorta]  LIKE '%'+LTRIM(RTRIM(@MaterialBuscar))+'%'
	END 
	
END
 

