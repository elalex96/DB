 -- sp_SC_ObtenerPresupuestos 2,10,0
create Proc [dbo].[sp_SC_ObtenerPresupuestos]
@pIdContratista int,
@pIdSubContrato int,
@pSoloSeleccionados bit=0
As
	
	CREATE TABLE #tmpResult(IdSubContratoPresupuesto INT, IdPresupuesto INT, NombrePresupuesto NVARCHAR(MAX), Comentario NVARCHAR(MAX), FechaAprobacionPEP DATE)

	INSERT INTO #tmpResult(IdSubContratoPresupuesto, IdPresupuesto, NombrePresupuesto, Comentario, FechaAprobacionPEP)
	SELECT 
			SC_Presupuesto.IdSubContratoPresupuesto,
			CO_Presupuesto.IdPresupuesto,
			NombrePresupuesto = CO_Presupuesto.Nombre,
			CO_Presupuesto.Comentario,
			CO_Presupuesto.FechaAprobacionPEP
	FROM CO_Presupuesto (NOLOCK)	
	inner join CO_ProgramaActividad (NOLOCK) on CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad 
	inner join CO_PeriodoContrato (NOLOCK) on CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo 
	inner join CO_Contrato (NOLOCK) on CO_PeriodoContrato.IdContrato = CO_Contrato.IdContrato 
	left join SC_Presupuesto (NOLOCK) on CO_Presupuesto.IdPresupuesto = SC_Presupuesto.IdPresupuesto   
								and SC_Presupuesto.IdSubContrato = @pIdSubContrato
	where CO_Contrato.IdContratista = @pIdContratista and
	CO_Presupuesto.Activo = 1 and
	(
		(@pSoloSeleccionados = 1 and SC_Presupuesto.IdSubContratoPresupuesto is not null)
		OR
		(@pSoloSeleccionados = 0 )
	)
	Order by SC_Presupuesto.IdSubContratoPresupuesto desc,CO_Presupuesto.Nombre

	if not exists(
		select 1
		from #tmpResult
	)
	begin 

		insert into #tmpResult#tmpResult(IdSubContratoPresupuesto, IdPresupuesto, NombrePresupuesto, Comentario, FechaAprobacionPEP)
		select 
			IdSubContratoPresupuesto = 0,
			CO_Presupuesto.IdPresupuesto,
			NombrePresupuesto = CO_Presupuesto.Nombre,
			CO_Presupuesto.Comentario,
			CO_Presupuesto.FechaAprobacionPEP	
		from CO_Presupuesto (NOLOCK)	
		inner join CO_ProgramaActividad (NOLOCK) on CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad 
		inner join CO_PeriodoContrato (NOLOCK) on CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo 
		inner join CO_Contrato on CO_PeriodoContrato.IdContrato = CO_Contrato.IdContrato 
		where CO_Contrato.IdContratista = @pIdContratista and
		CO_Presupuesto.Activo = 1 
		Order by CO_Presupuesto.Nombre
		
	end

	select * from #tmpResult


GO


