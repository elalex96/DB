-- =============================================
-- Author:		Daniel AC
-- Create date: 14-02-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaCompraVentaMateriales_MV1_5]
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

    SELECT 
	M.IdMaterial,
	M.DescripcionCorta,
	MU.Unidad, 
	(CASE WHEN M.IdTipoCatalogoMaestro = 1 THEN 'Material' ELSE CASE WHEN M.IdTipoCatalogoMaestro = 2 THEN 'Servicio' END END) AS Tipo,
	AC.Nombre AS TipoActividad,
	M.Imagen
	FROM MM_Material AS M
	LEFT JOIN dbo.MM_BS_Actividad AS AC ON AC.IdActividad = M.IdBienServicioEconomia
	LEFT JOIN PV_MM_MaterialUnidad AS MU ON MU.IdUnidad = M.IdUnidad
	WHERE M.IdProveedor = @IdProveedor AND M.Activo = 1 
	ORDER BY M.IdMaterial ASC
END
