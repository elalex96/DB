
-- sp_IN_AL_ConsultaEntregaMaterial 1,3
CREATE Proc sp_IN_AL_ConsultaEntregaMaterial
@pIdAlmacen int,
@pIdMovimiento int
AS

	DECLARE @IdContratista INT
    
	SELECT @IdContratista = c.IdContratista
	FROM dbo.IN_ContratoAlmacen ac
	INNER JOIN Adinco.DBO.CO_Contrato c ON c.IdContrato = ac.IdContrato
	WHERE IdAlmacen = @pIdAlmacen

	/******oBTENER EL CONTRATISTA*****/

	select pd.IdMaterial,
		   	Disponible = Sum(isnull(md.Disponible,0))
	into #tmpDisponibleAlmacen
	from IN_AL_MovimientoDetalle md
	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
	inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
	where 
	m.idAlmacen = @pidAlmacen and
	m.IdTipoMovimiento = 1 --eNTREGA
	group by pd.IdMaterial	
	


	select ID_ROW =  ROW_NUMBER() OVER(ORDER BY m.IdMovimiento ASC) ,
			m.IdMovimiento,
			md.IdMovimientoDetalle,
			pd.IdPedidoDetalle,
			IdMaterial = mat.IdMaterial,			
			IdUnidad=isnull(u.IdUnidad,0),			
			NombreUnidad = isnull(u.Unidad,'SIN ESPECIFICAR'),
			CantidadEntrega = CASE WHEN ISNULL(md.CantSegundaUnidad,0)  > 0 THEN md.CantSegundaUnidad  
									ELSE md.Cantidad
							end,			
			DisponibleAlmacen = isnull(tmp.Disponible,0), 
			DescripcionCorta = mat.DescripcionCorta,
			md.PrecioTotal,
			IdSegundaUnidad = ISNULL(u2.IdUnidad,md.IdSegundaUnidad),
			md.CantSegundaUnidad,
			mu.EquivUnidadMaestro,
			UnidadEntrega = ISNULL(u2.Unidad,'')
	from IN_AL_Movimiento m
	inner join IN_AL_MovimientoDetalle md on md.IdMovimiento = m.IdMovimiento
	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
	inner join MM_Material mat on mat.IdMaterial = pd.IdMaterial
	LEFT JOIN dbo.IN_AL_MaterialUnidad mu ON mu.IdContratista = @IdContratista AND
											MU.IdMaterial = MD.IdMaterial
	
	left join dbo.PV_MM_MaterialUnidad u on u.IdUnidad = mat.IdUnidad
	left join dbo.PV_MM_MaterialUnidad u2 on u2.IdUnidad = mu.IdUnidad
	left join #tmpDisponibleAlmacen tmp on tmp.IdMaterial = pd.IdMaterial
	where m.IdMovimiento = @pIdMovimiento and
	IdTipoMovimiento = 2 --Entrega


	




