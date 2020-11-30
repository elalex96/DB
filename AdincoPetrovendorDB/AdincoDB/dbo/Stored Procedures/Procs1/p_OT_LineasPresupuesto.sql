-- p_OT_LineasPresupuesto 9
Create Proc p_OT_LineasPresupuesto
@pIdOTSolicitud int
as

	select olp.IdLineaPresupuestoMes, 
		lp.IdInstalacion,
		i.NombreInstalacion,
		ac.NombreActividad
	from [OT_LineaPresupuesto] olp
	inner join [dbo].[CO_LineaPresupuestoMes] lp on lp.IdLineaPresupuestomes = olp.IdLineaPresupuestoMes
	left join CO_Instalacion i on i.IdInstalacion = lp.IdInstalacion
	LEFT JOIN CO_ActividadCIEP ac on ac.IdActividad = lp.IdActividad
	
	where olp.IdOTSolicitud = @pIdOTSolicitud
