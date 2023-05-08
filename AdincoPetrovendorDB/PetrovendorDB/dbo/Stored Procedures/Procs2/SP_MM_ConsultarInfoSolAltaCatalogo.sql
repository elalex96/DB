-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarInfoSolAltaCatalogo]
@IdAltaCatalogoProveedor INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	CM.DescripcionCorta,
    CM.DescripcionLarga,
    MU.Unidad,
    M.TipoMoneda AS Moneda,
    CM.Precio,
    CM.ImagenMaterial,
    CASE WHEN FichaTecnica != '' THEN FichaTecnica ELSE 'NO' END AS FichaTecnica,
    CM.FechaRegistro,
	P.RazonSocial + P.RegimenCapital AS Empresa,
	U.Nombre AS Solicitante,
	MU.IdUnidad,
	M.IdMoneda,
    ISNULL(GFS.IdGrupo,0),
	ISNULL(GFS.IdFamilia,0),
	ISNULL(GFS.IdSubFamilia,0)
	FROM PV_MM_AltaCatalogoProveedorTemp CM
	INNER JOIN PV_MM_MaterialUnidad MU ON CM.UMB = MU.IdUnidad
	INNER JOIN PV_TipoMoneda M ON CM.IdTipoMoneda = M.IdMoneda
	INNER JOIN S_Proveedor P ON CM.IdProveedor = P.IdProveedor
	INNER JOIN S_Usuario U ON CM.CreadoPor = U.IdUsuario
	LEFT JOIN PV_MM_GrupoFamiliaSubFamiliaUnidadTipo GFS ON GFS.IdSubFamilia = CM.IdSubFamilia 
	WHERE CM.IdAltaCatalogoProveedor = @IdAltaCatalogoProveedor
	


END

