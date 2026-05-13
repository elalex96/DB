-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_CM_ListaMateriales
@IdTipoCatalogo INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	  SELECT 
	  M.IdMaterial,
      M.IdProveedor,
	  P.RazonSocial,
      M.IdSubFamilia,
      ISNULL(MU.Unidad, 'NO ESPECIFICADO') AS Unidad,
      ISNULL(MT.TipoMaterial,'Sin clasificación') AS TipoMaterial,
      M.DescripcionCorta,
      M.DescripcionLarga,
      M.IdMaestro,
	  ISNULL(BSA.Nombre, 'NO ESPECIFICADA') AS BienServicioEconomia,
      CASE WHEN M.IdTipoCatalogoMaestro = 1 THEN 'Material' ELSE 'Servicio' END AS IdTipoCatalogoMaestro,
      M.Imagen_thumb
	  FROM MM_Material M
	  INNER JOIN dbo.S_Proveedor P ON P.IdProveedor = M.IdProveedor
	  LEFT JOIN dbo.PV_MM_MaterialUnidad MU ON MU.IdUnidad = M.IdUnidad
	  LEFT JOIN dbo.PV_MM_MaterialTipo MT ON MT.IdTipoMaterial = M.IdTipo
	  LEFT JOIN dbo.MM_BS_Actividad BSA ON BSA.IdActividad = M.IdBienServicioEconomia
	  WHERE M.IsClasificionMaestro = 0
	  and m.Activo = 1 
	  AND M.IdTipoCatalogoMaestro = @IdTipoCatalogo



END
