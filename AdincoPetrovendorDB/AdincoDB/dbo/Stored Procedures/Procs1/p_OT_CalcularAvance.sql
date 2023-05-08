------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- p_OT_CalcularAvance 1

CREATE proc p_OT_CalcularAvance
@pIdOTEstimacion int
as

	
			

	select 
		ed.IdOTSolicitudMaterial,
		CantidadEjecutadaOT = ed.Cantidad,
		CantidadAcumuladoOT = Sum(ed2.Cantidad),
		ImporteOT = ed.Importe,
		ImporteAcumuadoOT = Sum(ed2.Importe),
		PorcAvanceOT = (ed.Cantidad * 1) / sd.Cantidad,
		PorcAvanceAcumuadoOT = (Sum(ed2.Cantidad) * 1) / sd.Cantidad
	into #tmpCalculo
	from OT_EstimacionDetalle ed
	inner join OT_SolicitudMaterial sd on sd.IdOTSolicitudMaterial = ed.IdOTSolicitudMaterial
	inner join OT_EstimacionDetalle ed2 on ed2.IdOTSolicitudMaterial = sd.IdOTSolicitudMaterial 
						and ed2.IdOTEstimacion <= @pIdOTEstimacion
	inner join OT_Estimacion e1 on e1.IdOTEstimacion = ed.IdOTEstimacion and
									isnull(e1.Cancelada,0) = 0
	inner join OT_Estimacion e2 on e2.IdOTEstimacion = ed2.IdOTEstimacion and
									isnull(e2.Cancelada,0) = 0
	where ed.IdOTEstimacion = @pIdOTEstimacion
	group by ed.IdOTSolicitudMaterial,ed.Cantidad, ed.Importe,sd.Cantidad

	update OT_EstimacionDetalle
	set CantidadAcumulado = tmp.CantidadAcumuladoOT,
		TotalAvanceAcumulado =tmp. ImporteAcumuadoOT,
		PorcAvanceOT = tmp.PorcAvanceOT,
		PorcAvanceAcumulado = tmp.PorcAvanceAcumuadoOT
	from OT_EstimacionDetalle t1
	inner join #tmpCalculo tmp on tmp.IdOTSolicitudMaterial = t1.IdOTSolicitudMaterial
	where t1.IdOTEstimacion = @pIdOTEstimacion

	

