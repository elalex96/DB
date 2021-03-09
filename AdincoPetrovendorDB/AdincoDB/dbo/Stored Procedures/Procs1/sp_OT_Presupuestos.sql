CREATE Proc sp_OT_Presupuestos
@pIdContratista int,
@pIdSubContrato int,
@pSoloSeleccionados bit=0
As


	select 
			
			p.IdPresupuesto,
			NombrePresupuesto=p.Nombre,
			p.Comentario,
			p.FechaAprobacionPEP,
			P.IdPresupuestoCNH
	into #tmpResult
	from CO_Presupuesto p	
	inner join [dbo].[CO_ProgramaActividad] pa on pa.[IdProgramaActividad] = p.[IdProgramaActividad]
	inner join [dbo].[CO_PeriodoContrato] pc on pc.IdPeriodo = pa.IdPeriodoContrato	
	inner join CO_Contrato con on con.IdContrato = pc.IdContrato
	inner join SC_Presupuesto scp on scp.IdPresupuesto = p.IdPresupuesto and
									scp.IdSubContrato = @pIdSubContrato
	where con.IdContratista = @pIdContratista and
	p.Activo = 1 and
	(
		(@pSoloSeleccionados = 1 and scp.IdSubContratoPresupuesto is not null)
		OR
		(@pSoloSeleccionados = 0 )
	)
	group by 
			p.IdPresupuesto,
			p.Nombre,
			p.Comentario,
			p.FechaAprobacionPEP,
			P.IdPresupuestoCNH
	Order by p.IdPresupuesto desc,p.Nombre

	if not exists(
		select 1
		from #tmpResult
	)
	begin 

		insert into #tmpResult
		select 
			
			p.IdPresupuesto,
			NombrePresupuesto=p.Nombre,
			p.Comentario,
			p.FechaAprobacionPEP,
			P.IdPresupuestoCNH		
		from CO_Presupuesto p	
		inner join SC_SubContrato sc on sc.IdSubContrato = @pIdSubContrato
		inner join [dbo].[CO_ProgramaActividad] pa on pa.[IdProgramaActividad] = p.[IdProgramaActividad]
		inner join [dbo].[CO_PeriodoContrato] pc on pc.IdPeriodo = pa.IdPeriodoContrato	
		inner join CO_Contrato con on con.IdContrato = pc.IdContrato and 
									con.IdContrato = sc.IdContrato
	
		where con.IdContratista = @pIdContratista and
		p.Activo = 1  and @pIdSubContrato > 0
		group by 
			p.IdPresupuesto,
			p.Nombre,
			p.Comentario,
			p.FechaAprobacionPEP,
			P.IdPresupuestoCNH
		Order by p.IdPresupuesto desc
		
	end

	select * from #tmpResult
	order by IdPresupuesto desc






