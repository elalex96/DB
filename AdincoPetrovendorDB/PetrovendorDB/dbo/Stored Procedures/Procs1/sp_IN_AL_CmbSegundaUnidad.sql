
-- sp_IN_AL_CmbSegundaUnidad 1,11378
create PROC [dbo].[sp_IN_AL_CmbSegundaUnidad]
@pIdAlmacen INT,
@pIdMaterial INT
AS

	SELECT MU.IdUnidad,
			mum.Unidad,
			mu.EquivUnidadMaestro
	FROM dbo.IN_AL_MaterialUnidad  MU
	INNER JOIN dbo.PV_MM_MaterialUnidad MUM ON MUM.IdUnidad = mu.IdUnidad
	INNER JOIN IN_ContratoAlmacen ca ON ca.IdAlmacen = @pIdAlmacen
	INNER JOIN Adinco.dbo.CO_Contrato con ON con.IdContrato = ca.IdContrato AND
									con.IdContratista = mu.IdContratista	
	WHERE IdMaterial = @pIdMaterial
