-- p_OT_LineasPresupuestoOT 9
Create Proc p_OT_LineasPresupuestoOT
@pIdOTSolicitud int
as

	select lp.*
	from [OT_LineaPresupuesto] olp
	inner join [dbo].[CO_LineaPresupuestoMes] lp on lp.IdLineaPresupuestomes = olp.IdLineaPresupuestoMes
	where olp.IdOTSolicitud = @pIdOTSolicitud
