-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarCatalogoMaestro]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TextoCorto,
		   MG.Grupo,
		   MF.Familia,
		   MS.SubFamilia,
		   MT.TipoMaterial,
		   MU.Unidad
	       FROM MM_Maestro M
		   INNER JOIN PV_MM_GrupoFamiliaSubFamiliaUnidadTipo GFCU
		   ON M.IdSubFamilia = GFCU.IdSubFamilia
		   INNER JOIN PV_MM_MaterialGrupo MG ON GFCU.IdGrupo = MG.IdGrupo
		   INNER JOIN PV_MM_MaterialFamilia MF ON GFCU.IdFamilia = MF.IdFamilia
		   INNER JOIN PV_MM_MaterialSubFamilia MS ON GFCU.IdSubFamilia = MS.IdSubFamilia
		   INNER JOIN PV_MM_MaterialTipo MT ON GFCU.IdTipoMaterial = MT.IdTipoMaterial
		   INNER JOIN PV_MM_MaterialUnidad MU ON GFCU.IdUnidad = MU.IdUnidad



END

