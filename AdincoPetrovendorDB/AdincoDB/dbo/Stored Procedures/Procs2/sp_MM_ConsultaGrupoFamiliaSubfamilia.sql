-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_MM_ConsultaGrupoFamiliaSubfamilia 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT        MM_GrupoFamiliaSubFamiliaTipo.IdGrupoFamiliaSubfamilia, MM_GrupoFamiliaSubFamiliaTipo.IdGrupo, MM_MaterialGrupoDisciplina.MaterialGrupo, MM_GrupoFamiliaSubFamiliaTipo.IdFamilia, 
                         MM_MaterialFamilia.Familia, MM_GrupoFamiliaSubFamiliaTipo.IdSubFamilia, MM_MaterialSubFamilia.SubFamilia, MM_GrupoFamiliaSubFamiliaTipo.IdTipoMaterial, MM_MaterialTipo.TipoMaterial
FROM            MM_GrupoFamiliaSubFamiliaTipo INNER JOIN
                         MM_MaterialGrupoDisciplina ON MM_GrupoFamiliaSubFamiliaTipo.IdGrupo = MM_MaterialGrupoDisciplina.IdGrupoDisciplina INNER JOIN
                         MM_MaterialFamilia ON MM_GrupoFamiliaSubFamiliaTipo.IdFamilia = MM_MaterialFamilia.IdMaterialFamilia INNER JOIN
                         MM_MaterialSubFamilia ON MM_GrupoFamiliaSubFamiliaTipo.IdSubFamilia = MM_MaterialSubFamilia.IdSubFamilia INNER JOIN
                         MM_MaterialTipo ON MM_GrupoFamiliaSubFamiliaTipo.IdTipoMaterial = MM_MaterialTipo.IdTipoMaterial
END
