-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/07/2017
-- Description:	Metodo que obtiene los nombres de un grupo, familia, tipo, unidad y subfamilia de un material
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_MaterialDetalles]
	-- Add the parameters for the stored procedure here
	@IdMaestro int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MAS.TextoLargo,
	 CASE WHEN  MG.Grupo = 'Temporal Grupo' THEN 'Servicio' ELSE MG.Grupo END , 
	 CASE WHEN  MF.Familia = 'Temporal Familia' THEN 'Servicio' ELSE MF.Familia END ,
	 CASE WHEN  MSF.SubFamilia = 'Temporal SubFamilia' THEN 'Servicio' ELSE MSF.SubFamilia END,
	 CASE WHEN  MT.TipoMaterial = 'Sin clasificación' THEN 'Servicio' ELSE MSF.SubFamilia END, 
	 MU.Unidad
	FROM MM_Maestro AS MAS
	INNER JOIN PV_MM_GrupoFamiliaSubFamiliaUnidadTipo AS GFST ON GFST.IdSubFamilia = MAS.IdSubFamilia
	INNER JOIN PV_MM_MaterialGrupo AS MG ON MG.IdGrupo = GFST.IdGrupo
	INNER JOIN PV_MM_MaterialFamilia AS MF ON MF.IdFamilia = GFST.IdFamilia
	INNER JOIN PV_MM_MaterialSubFamilia AS MSF ON MSF.IdSubFamilia = GFST.IdSubFamilia
	INNER JOIN PV_MM_MaterialTipo AS MT ON MT.IdTipoMaterial = GFST.IdTipoMaterial
	INNER JOIN PV_MM_MaterialUnidad AS MU ON MU.IdUnidad = GFST.IdUnidad
	WHERE MAS.IdMaestro =  @IdMaestro
END

