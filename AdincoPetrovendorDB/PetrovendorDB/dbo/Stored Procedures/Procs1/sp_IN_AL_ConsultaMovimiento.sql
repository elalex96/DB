
-- sp_IN_AL_ConsultaMovimiento 1,1
CREATE PROC [dbo].[sp_IN_AL_ConsultaMovimiento]
@pIdAlmacen int,
@pIdTipoMovimiento int,
@pFechaMovIni datetime=null,
@pFechaMovFin datetime=null
as


	set @pFechaMovIni = case when @pFechaMovIni = '' then null else @pFechaMovIni end
	set @pFechaMovFin = case when @pFechaMovFin = '' then null else @pFechaMovFin end

	select mov.IdMovimiento,
		mov.IdAlmacen,
		mov.IdPedido,
		mov.Folio,
		mov.IdTipoMovimiento,
		TipoMovimiento = tipoMov.Nombre,
		mov.FechaMovimiento,
		mov.HoraMovimiento,
		mov.RecibidoEn,
		mov.EntregadoEn,
		mov.IdUsuarioAtendio,
		mov.Comentarios,
		mov.PrecioTotal,
		mov.IdUsuarioAutorizo,
		mov.FechaAutoriza,
		mov.CreadoPor,
		mov.CreadoEl,
		mov.ModificadoPor,
		mov.ModificadoEl
	from IN_AL_Movimiento mov
	inner join IN_AL_TipoMovimiento tipoMov on tipoMov.IdTipoMovimiento = mov.IdTipoMovimiento
	where mov.IdAlmacen = @pIdAlmacen and
	@pIdTipoMovimiento in (0,mov.IdTipoMovimiento) and
	(
		convert(varchar,mov.FechaMovimiento,112) between convert(varchar,@pFechaMovIni,112) and convert(varchar,@pFechaMovFin,112) OR
		(@pFechaMovIni is null and @pFechaMovFin is null)
	)

