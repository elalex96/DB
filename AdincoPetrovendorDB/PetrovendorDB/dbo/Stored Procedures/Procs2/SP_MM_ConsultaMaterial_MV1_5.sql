-- =============================================
-- Author:	Abel R
-- Create date: 14-12-17
-- Description:	Consultar detalle del material 
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Update date: 12-01-17 10:51 am
-- Description:	Agregue isnull
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaMaterial_MV1_5]  
	-- Add the parameters for the stored procedure here
	@IdMaterial INT,
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
	M.IdProveedor,
    ISNULL(M.IdSubFamilia,0),
    ISNULL(M.IdUnidad,0),
    ISNULL(CM.IdTipoMaterial,0) AS IdTipo,
    ISNULL(M.DescripcionCorta,''),
    ISNULL(M.DescripcionLarga,''),
    ISNULL(M.Modelo,''),
    ISNULL(M.NumeroParte,''),
    ISNULL(M.Presentacion,''),
    ISNULL(M.Consumible,0),
    ISNULL(M.Inventariable,0),
    ISNULL(M.TiempoEntregaEstimadoDias,0) AS TiempoEntregaEstimadoDias,
    ISNULL(M.Marca,''),
    M.Imagen_real,
    M.FichaTecnica,
    ISNULL(M.IdMaestro,0) AS IdMaestro,
    ISNULL(M.IdBienServicioEconomia,0) AS IdBienServicioEconomia,
    ISNULL(M.IdUnidad_1,0) AS IdUnidad_1,
    ISNULL(M.IdUnidad_2,0) AS IdUnidad_2,
    ISNULL(M.IdUnidad_3,0) AS IdUnidad_3,
    ISNULL(M.IdTipoCatalogoMaestro,0),
	M.Imagen_thumb
	FROM MM_Material AS M
	LEFT JOIN MM_BS_Actividad AS ACBSH ON ACBSH.IdActividad = M.IdBienServicioEconomia
	LEFT JOIN dbo.MM_Maestro CM ON CM.IdMaestro = M.IdMaestro
    LEFT JOIN PV_MM_MaterialUnidad AS MU ON MU.IdUnidad = M.IdUnidad
	LEFT JOIN PV_MM_MaterialUnidad AS MU1 ON MU1.IdUnidad = M.IdUnidad_1
	LEFT JOIN PV_MM_MaterialUnidad AS MU2 ON MU2.IdUnidad = M.IdUnidad_2
	LEFT JOIN PV_MM_MaterialUnidad AS MU3 ON MU3.IdUnidad = M.IdUnidad_3
	WHERE M.IdMaterial =  @IdMaterial AND M.IdProveedor=@IdProveedor AND M.Activo=1 AND ISNULL(M.IsEliminado,0)=0
	 

END
