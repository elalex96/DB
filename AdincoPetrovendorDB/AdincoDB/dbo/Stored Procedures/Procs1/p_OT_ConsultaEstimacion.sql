-- p_OT_ConsultaEstimacion 1
create proc [dbo].[p_OT_ConsultaEstimacion]
@pIdOTSolicitud int
as

	select	IdOTSolicitud,
			IdOTEstimacion,
			FolioEstimacion,
			FolioOT,
			FolioSC,
			FechaIniCorte,
			FechaFinCorte,
			Instalacion,
			Actividad,
			Presupuesto,
			Subcontratista,
			Total = Sum(vw.Importe),
			Moneda = vw.Moneda
	from [dbo].[vwOTEstimacion] vw (NOLOCK)
	where IdOTSolicitud = @pIdOTSolicitud
	group by IdOTSolicitud,
			IdOTEstimacion,
			FolioEstimacion,
			FolioOT,
			FolioSC,
			FechaIniCorte,
			FechaFinCorte,
			Instalacion,
			Actividad,
			Presupuesto,
			Subcontratista,
			vw.Moneda
			
