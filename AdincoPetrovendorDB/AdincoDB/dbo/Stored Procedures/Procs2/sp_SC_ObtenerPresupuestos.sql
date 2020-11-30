

 -- sp_SC_ObtenerPresupuestos 2,10,0
CREATE Proc sp_SC_ObtenerPresupuestos
@pIdContratista int,
@pIdSubContrato int,
@pSoloSeleccionados bit=0
As


	select 
			scp.IdSubContratoPresupuesto,
			p.IdPresupuesto,
			NombrePresupuesto=p.Nombre,
			p.Comentario,
			p.FechaAprobacionPEP
	into #tmpResult
	from CO_Presupuesto p	
	inner join [dbo].[CO_ProgramaActividad] pa on pa.[IdProgramaActividad] = p.[IdProgramaActividad]
	inner join [dbo].[CO_PeriodoContrato] pc on pc.IdPeriodo = pa.IdPeriodoContrato	
	inner join CO_Contrato con on con.IdContrato = pc.IdContrato
	left join SC_Presupuesto scp on scp.IdPresupuesto = p.IdPresupuesto and
									scp.IdSubContrato = @pIdSubContrato
	where con.IdContratista = @pIdContratista and
	p.Activo = 1 and
	(
		(@pSoloSeleccionados = 1 and scp.IdSubContratoPresupuesto is not null)
		OR
		(@pSoloSeleccionados = 0 )
	)
	Order by scp.IdSubContratoPresupuesto desc,p.Nombre

	if not exists(
		select 1
		from #tmpResult
	)
	begin 

		insert into #tmpResult
		select 
			IdSubContratoPresupuesto = 0,
			p.IdPresupuesto,
			NombrePresupuesto=p.Nombre,
			p.Comentario,
			p.FechaAprobacionPEP
		
		from CO_Presupuesto p	
		inner join [dbo].[CO_ProgramaActividad] pa on pa.[IdProgramaActividad] = p.[IdProgramaActividad]
		inner join [dbo].[CO_PeriodoContrato] pc on pc.IdPeriodo = pa.IdPeriodoContrato	
		inner join CO_Contrato con on con.IdContrato = pc.IdContrato
	
		where con.IdContratista = @pIdContratista and
		p.Activo = 1 
		Order by p.Nombre
		
	end

	select * from #tmpResult


