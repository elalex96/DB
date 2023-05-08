
-- sp_IN_AL_Cmb_MaterialEntrega 1
cREATE Proc sp_IN_AL_Cmb_MaterialEntrega
@pIdAlmacen int
AS

	DECLARE @IdContratista INT
    
	SELECT @IdContratista = c.IdContratista
	FROM dbo.IN_ContratoAlmacen ac
	INNER JOIN Adinco.DBO.CO_Contrato c ON c.IdContrato = ac.IdContrato
	WHERE IdAlmacen = @pIdAlmacen


	select IdMaterial = mat.IdMaterial,
			DescripcionCorta = mat.DescripcionCorta,
			Unidad = isnull(u.Unidad,'SIN ESPECIFICAR'),
			DisponibleTotal = (select max(DisponibleTotalAlmacen) from [dbo].[vw_IN_AL_Movimientos] exs where exs.IdMaterial = mat.IdMaterial),
			IdSegundaUnidad = mu.IdUnidad,
			SegundaUnidad = U2.Unidad,
			mu.EquivUnidadMaestro

	from IN_AL_Movimiento mov
	Inner join IN_AL_MovimientoDetalle movD on movD.IdMovimiento = mov.IdMovimiento
	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = movD.IdPedidoDetalle
	inner join MM_Material mat on mat.IdMaterial = pd.IdMaterial
	LEFT JOIN dbo.IN_AL_MaterialUnidad mu ON mu.IdContratista = @IdContratista AND
											mu.IdMaterial = MAT.IdMaterial
	left join PV_MM_MaterialUnidad u on u.IdUnidad = mat.IdUnidad
	LEFT JOIN dbo.PV_MM_MaterialUnidad u2 ON u2.IdUnidad = mu.IdUnidad
	where mov.idAlmacen = @pIdAlmacen 
	AND mov.IdTipoMovimiento = 1 --Recepcion
	AND mov.IdUsuarioAutorizo > 0
	--AND movD.IdEstatus = 1--Libre
	group by mat.IdMaterial,
			mat.DescripcionCorta,
			u.Unidad,
			mu.IdUnidad,
			U2.Unidad,
			mu.EquivUnidadMaestro


