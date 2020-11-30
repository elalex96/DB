-- =============================================
-- Author:		Daniel AC
-- Create date: 14-02-17
-- Description:	
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_ConsultaMateriales_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	
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

    -- Insert statements for procedure here
	SELECT 
	M.IdMaterial, 
	M.DescripcionCorta, 
	M.DescripcionLarga, 
	M.Marca, 
	M.Modelo, 
	M.NumeroParte, 
	MU.Unidad, 
	M.FechaAlta,
	M.Imagen
	FROM MM_Material AS M
	--INNER JOIN PV_MM_GrupoFamiliaSubFamiliaUnidadTipo AS GFST ON GFST.IdSubFamilia = M.IdSubFamilia
	--INNER JOIN PV_MM_MaterialGrupo AS MG ON MG.IdGrupo = GFST.IdGrupo
	--INNER JOIN PV_MM_MaterialFamilia AS MF ON MF.IdFamilia = GFST.IdFamilia
	--INNER JOIN PV_MM_MaterialSubFamilia AS MSF ON MSF.IdSubFamilia = GFST.IdSubFamilia
	--INNER JOIN PV_MM_MaterialTipo AS MT ON MT.IdTipoMaterial = GFST.IdTipoMaterial
	LEFT JOIN PV_MM_MaterialUnidad AS MU ON MU.IdUnidad = M.IdUnidad
	--LEFT JOIN PV_MM_MaterialUnidad AS M1 ON M1.IdUnidad = M.IdUnidad_1
	--LEFT JOIN PV_MM_MaterialUnidad AS M2 ON M2.IdUnidad = M.IdUnidad_2
	--LEFT JOIN PV_MM_MaterialUnidad AS M3 ON M3.IdUnidad = M.IdUnidad_3
	WHERE M.IdProveedor = @IdProveedor AND M.Activo = 1 
	ORDER BY M.IdMaterial ASC
END
