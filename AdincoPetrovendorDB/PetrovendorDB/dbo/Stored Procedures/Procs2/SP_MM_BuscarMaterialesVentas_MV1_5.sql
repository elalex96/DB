-- =============================================
-- Author:		Daniel AC
-- Create date: 14-02-17
-- Description:	Filtro de materiales 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_BuscarMaterialesVentas_MV1_5] 
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
	@Buscar NVARCHAR(200),
	@Condicion NVARCHAR(50),
	/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME
  /*--------------------
  --------------------*/
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	 
	IF @Condicion ='BUSCAR'
		SELECT 
					M.IdMaterial,
					M.DescripcionCorta,
					MU.Unidad,
					Tipo				=	(CASE WHEN M.IdTipoCatalogoMaestro = 1 THEN 'Material' ELSE CASE WHEN M.IdTipoCatalogoMaestro = 2 THEN 'Servicio' END END),	
					M.Imagen_thumb,
					M.DescripcionLarga
		FROM		MM_Material				AS	M	
		inner JOIN	PV_MM_MaterialUnidad	AS	MU 
		ON			MU.IdUnidad				=	M.IdUnidad
		LEFT join	dbo.S_Usuario			u	
		ON			u.IdUsuario				=	m.CreadoPor
		WHERE		M.IdProveedor			=	@IdProveedor 
		AND			M.Activo				=	1 
		AND			(		M.DescripcionCorta	LIKE '%'+@Buscar+'%' 
						OR	M.DescripcionLarga	LIKE '%'+@Buscar+'%' 
						OR	M.IdMaterial		LIKE '%'+@Buscar+'%')
		ORDER BY M.IdMaterial ASC
	
	IF @Condicion ='TODOS'
		SELECT 
					M.IdMaterial,
					M.DescripcionCorta,
					MU.Unidad,
					Tipo					=	(CASE	WHEN	M.IdTipoCatalogoMaestro = 1 THEN 'Material' ELSE CASE WHEN M.IdTipoCatalogoMaestro = 2 THEN 'Servicio' END END),	
					Imagen_thumb			=	CASE	WHEN	DATALENGTH(M.Imagen_thumb) IS NOT NULL AND  DATALENGTH(M.Imagen_thumb) > 0	THEN  M.Imagen_thumb
														ELSE	(
																	SELECT Top 1 D.ImagenThumb
																	FROM [dbo].[PV_ImagenPredeterminada] AS D
																	WHERE D.[IdImagenPredeterminada] = 1  --IMAGEN DEFAUL PARA MATERIAL SIN IMAGEN
																)  END,
		DescripcionLarga					=	(CASE WHEN LEN(M.DescripcionLarga) = 0 THEN 'Sin descripción' ELSE M.DescripcionLarga END)
		FROM		dbo.MM_Material			AS	M	
		inner JOIN	PV_MM_MaterialUnidad	AS	MU 
		ON			MU.IdUnidad				=	M.IdUnidad 
		LEFT join	dbo.S_Usuario			u	ON u.IdUsuario = m.CreadoPor
		WHERE		M.IdProveedor			=	@IdProveedor 
		AND			M.Activo				=	1 
		ORDER BY	M.IdMaterial ASC
	
		
END
