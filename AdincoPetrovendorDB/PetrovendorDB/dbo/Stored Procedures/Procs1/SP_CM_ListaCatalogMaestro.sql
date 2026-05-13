-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <28-12-17>
-- Description:	<Consulta la tabla MM_Maestro>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CM_ListaCatalogMaestro]
@IdTipoCatalogo INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	  SELECT 
	  M.IdMaestro,
      CASE WHEN M.IdTipoCatalogoMaestro = 1 THEN 'Material' ELSE 'Servicio' END AS IdTipoCatalogoMaestro,
      M.IdSubFamilia,
      M.TextoCorto,
      M.TextoLargo,
	  ISNULL(MT.IdTipoMaterial,10007) AS IdTipoMaterial,
      ISNULL(MT.TipoMaterial,'Sin clasificación') AS TipoMaterial,
	  ISNULL(MU.IdUnidad,10013) AS IdUnidad,
      ISNULL(MU.Unidad, 'NO ESPECIFICADO') AS Unidad
      FROM MM_Maestro M
	  LEFT JOIN PV_MM_MaterialTipo MT 
	  ON MT.IdTipoMaterial = M.IdTipoMaterial
	  LEFT JOIN dbo.PV_MM_GrupoFamiliaSubFamiliaUnidadTipo GFST
	  ON M.IdSubFamilia = GFST.IdSubFamilia
	  LEFT JOIN dbo.PV_MM_MaterialUnidad MU
	  ON MU.IdUnidad = GFST.IdUnidad
	  WHERE M.IsActivo = 1 
	  and M.IdTipoCatalogoMaestro = @IdTipoCatalogo

	  


END
