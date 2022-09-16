-- p_OT_LineasPresupuesto 9
create Proc [dbo].[p_OT_LineasPresupuesto]
@pIdOTSolicitud int
as

	select OT_LineaPresupuesto.IdLineaPresupuestoMes, 
		CO_LineaPresupuestoMes.IdInstalacion,
		CO_Instalacion.NombreInstalacion,
		CO_ActividadCIEP.NombreActividad
	from OT_LineaPresupuesto (NOLOCK)
	inner join CO_LineaPresupuestoMes (NOLOCK) on OT_LineaPresupuesto.IdLineaPresupuestoMes = CO_LineaPresupuestoMes.IdLineaPresupuestomes 
	left join CO_Instalacion (NOLOCK) on CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion 
	LEFT JOIN CO_ActividadCIEP (NOLOCK) on CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad  	
	where OT_LineaPresupuesto.IdOTSolicitud = @pIdOTSolicitud
GO


