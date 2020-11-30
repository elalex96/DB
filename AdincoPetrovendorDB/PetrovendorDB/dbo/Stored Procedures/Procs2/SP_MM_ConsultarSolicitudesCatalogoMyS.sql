-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarSolicitudesCatalogoMyS]
@IdAprobador INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--DECLARE @TIPO NVARCHAR(20) = (SELECT CASE WHEN IdTipoCatalogo = 1 THEN 'material' ELSE 'servicio' FROM MM_Maestro)

	SELECT CM.IdAltaCatalogoProveedor,
	CASE WHEN CM.IdTipoCatalogo = 1 THEN 'Material' ELSE 'Servicio' END AS TipoCatalogo,
	E.Nombre,
	CASE WHEN CM.IdSugerencia = 1 THEN REPLACE(CMS.Descripcion,'##CATALOGO##',CASE WHEN CM.IdTipoCatalogo = 1 THEN 'material' ELSE 'servicio' END) 
	                              ELSE REPLACE(CMS.Descripcion,'##CATALOGO##',CASE WHEN CM.IdTipoCatalogo = 1 THEN 'materiales' ELSE 'servicios' END) END AS Descripcion,
	O.IdOperacion
 	FROM PV_MM_AltaCatalogoProveedorTemp CM
	LEFT JOIN PV_MM_AltaCatalogoSugerencia CMS ON CM.IdSugerencia = CMS.IdSugerenciaMyS
	INNER JOIN TA_Operacion O ON O.IdDocumento = CM.IdAltaCatalogoProveedor
	INNER JOIN TA_Tarea TA ON TA.IdOperacion = O.IdOperacion
	INNER JOIN TA_FlujoTarea FT ON O.IdFlujoTarea = FT.IdFlujoTarea
	INNER JOIN TA_Estatus E ON O.IdEstatusOperacion = E.IdEstatus
	WHERE FT.IdTipoOperacion = 15 AND TA.IdAprobador = @IdAprobador

	
END

