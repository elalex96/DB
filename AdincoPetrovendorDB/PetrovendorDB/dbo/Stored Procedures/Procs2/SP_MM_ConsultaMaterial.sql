-- =============================================
-- Author:		Daniel AC
-- Create date: 14-02-17
-- Description:	
-- Author: Daniel Ac
-- Update date: 04/10/17
-- Agregue nombre de proveedor del material
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaMaterial] 
	-- Add the parameters for the stored procedure here
	@IdMaterial int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	IdMaterial, 
	DescripcionCorta, 
	DescripcionLarga, 
	Marca, 
	Modelo, 
	NumeroParte, 
	MU.Unidad,
	ISNULL(IdUnidadAlterna,0) AS IdUnidadAlterna,
	Presentacion, 
	Consumible, 
	Inventariable, 
	M.Activo, 
	ISNULL(TiempoEntregaEstimadoDias,0) AS TiempoEntregaEstimadoDias, 
	--Costo,
	--ISNULL(M.IdMoneda,0) AS IdMoneda, 
	TM.TipoMoneda, 
	MT.TipoMaterial,
	MG.Grupo,
	MF.Familia,
	MSF.SubFamilia,
	ACBSH.Nombre AS Actividad_CBSH,
	GCBSH.Nombre AS GRUPO_CBSH,
	--Ubicacion, 
	FechaAlta,  
	IsPublico,
	CASE WHEN  [Imagen] IS NULL THEN (SELECT TOP 1 [ImagenText] FROM [dbo].[PV_ImagenPredeterminada] WHERE [IdImagenPredeterminada]=1) WHEN  [Imagen] = '' THEN (SELECT TOP 1 [ImagenText] FROM [dbo].[PV_ImagenPredeterminada] WHERE [IdImagenPredeterminada]=1) ELSE [Imagen] END  AS Imagen ,--Imagen,
	FichaTecnica,
	P.IdProveedor,
	(P.RazonSocial + ' '+P.RegimenCapital) AS Proveedor,
	[dbo].[ObtenerEstrellas] (P.IdProveedor) AS Estrellas
	FROM MM_Material AS M
	LEFT JOIN PV_MM_GrupoFamiliaSubFamiliaUnidadTipo AS GFSUT ON GFSUT.IdSubFamilia = M.IdSubFamilia
	LEFT JOIN PV_MM_MaterialFamilia AS MF ON MF.IdFamilia = GFSUT.IdFamilia
	LEFT JOIN PV_MM_MaterialGrupo AS MG ON MG.IdGrupo = GFSUT.IdGrupo
	LEFT JOIN PV_MM_MaterialSubFamilia AS MSF ON MSF.IdSubFamilia = GFSUT.IdSubFamilia
	LEFT JOIN PV_MM_MaterialUnidad AS MU ON MU.IdUnidad = GFSUT.IdUnidad
	LEFT JOIN MM_Unidad AS MUA ON MUA.IdUnidad = M.IdUnidadAlterna
	LEFT JOIN PV_MM_MaterialTipo AS MT ON MT.IdTipoMaterial = GFSUT.IdTipoMaterial
	LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = M.IdMoneda
	LEFT JOIN MM_BS_Grupo AS GCBSH ON GCBSH.IdGrupo = M.IdGrupo_CBSH
	LEFT JOIN MM_BS_Actividad AS ACBSH ON ACBSH.IdActidad = M.IdActividad_CBSH
	LEFT JOIN S_Proveedor AS P ON P.IdProveedor = M.IdProveedor 
	WHERE M.IdMaterial =  @IdMaterial
END

