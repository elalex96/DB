
 -- sp_IN_AL_ObtenerMovimientoReserva 22
create Proc [dbo].[sp_IN_AL_ObtenerMovimientoReserva]
@pIdMovimientoReserva int
as

	select 
			m.IdMovimiento,
			m.IdAlmacen,
			m.IdPedido,
			m.Folio,
			m.IdTipoMovimiento,
			m.FechaMovimiento,
			m.HoraMovimiento,
			m.RecibidoEn,
			m.EntregadoEn,
			m.IdUsuarioAtendio,
			m.Comentarios,
			m.PrecioTotal,
			m.IdUsuarioAutorizo,
			m.FechaAutoriza,
			m.CreadoPor,
			m.CreadoEl,
			m.ModificadoPor,
			m.ModificadoEl,
			m.IsEliminado,
			m.EntregadoA,
			l.IdPresupuesto,
			pc.IdPeriodo,
			l.IdLineaPresupuestoMes,
			NombreAlmacen = al.Nombre

	from IN_AL_Movimiento m
	inner join Adinco.dbo.CO_LineaPresupuestoMes l on  l.IdLineaPresupuestoMes = m.IdLineaPresupuestoMes
	inner join Adinco.dbo.CO_Presupuesto  p on p.IdPresupuesto = l.idPresupuesto

	inner join Adinco.dbo.CO_ProgramaActividad pa on pa.IdProgramaActividad = p.IdProgramaActividad

	inner join Adinco.dbo.CO_PeriodoContrato pc on pc.IdPeriodo = pa.IdPeriodoContrato
	inner join IN_Almacen al on al.IdAlmacen = m.IdAlmacen

	where m.IdMovimiento = @pIdMovimientoReserva
