
create proc p_Presupuestos_grd
(
	@pIdSubContrato		int
)
as
begin

	--select * from SC_Presupuesto where IdSubContrato = @pIdSubContrato

	select		s.idSubcontrato,
				pre.IdPresupuesto,
				pre.IdAnioContractual,
				pre.IdProgramaActividad,
				pre.Version,
				pre.Nombre,
				pre.Comentario,
				pre.FechaAprobacionPEP,
				pre.Activo,
				pre.IdPresupuestoCNH,
				pre.Actual,
				pre.CIEP,
				pre.ActivoProcura,
				Seleccionado			=	case when p.IdPresupuesto is null then cast(0 as bit) else cast(1 as bit) end
	from		SC_Subcontrato			s
	inner join	CO_PeriodoContrato		pc 
	on			pc.IdContrato			=	s.IdContrato
	inner join	CO_ProgramaActividad	pa 
	on			pa.IdPeriodoContrato	=	pc.IdPeriodo
	inner join	CO_Presupuesto			pre 
	on			pre.IdProgramaActividad =	pa.IdProgramaActividad
	left join	SC_Presupuesto			p
	on			pre.IdPresupuesto		=	p.IdPresupuesto
	and			s.IdSubContrato			=	p.IdSubContrato
	where		s.idSubcontrato			=	@pIdSubContrato --1
end

