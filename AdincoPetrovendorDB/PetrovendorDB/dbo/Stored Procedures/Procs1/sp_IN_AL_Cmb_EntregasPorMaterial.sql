
-- sp_IN_AL_Cmb_EntregasPorMaterial 2,0
create proc [dbo].[sp_IN_AL_Cmb_EntregasPorMaterial]
@pIdAlmacen int,
@pIdMaterial int
as

	--select IdMovimientoDetalle = -1,
	--		Descripcion = '(SIN REFERENCIA)',
	--	  Folio = '',
	--	  FechaMovimiento = getdate(),
	--	  Comentarios = '',
	--	  CantidadEntregada = 0

	--union

	

	select v.IdMovimientoDetalle,
			Descripcion = 'Folio:'+cast(v.Folio as varchar) + ' Fecha Mov: ' + convert(varchar,v.FechaMovimiento,103),
		  v.Folio,
		  v.FechaMovimiento,
		  v.Comentarios,
		  CantidadEntregada = Cantidad
	from vw_IN_AL_Movimientos v
	where v.IdAlmacen = @pIdAlmacen and
	v.IdTipoMovimiento = 2 and
	@pIdMaterial IN (v.IdMaterial ,0) AND
	V.IdUsuarioAutorizo > 0
	ORDER BY FechaMovimiento desc
