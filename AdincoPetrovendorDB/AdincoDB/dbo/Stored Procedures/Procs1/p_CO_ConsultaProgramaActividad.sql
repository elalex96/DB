
-- p_CO_ConsultaProgramaActividad 3
create Proc [dbo].[p_CO_ConsultaProgramaActividad]
@pIdContrato int
as

	select 
		--PROGRAMA ACTIVIDAD
		pa.IdProgramaActividad,
		pa.IdPeriodoContrato,
		pa.IdTipoProgramaActividad,
		pa.NombrePrograma,
		pa.FechaPresentacion,
		pa.NumeroRegistroContenidoNacional,		
		pa.CreadoEl,		
		pa.Activo,
		--PRESUPUESTO
		pre.IdPresupuesto,		
		pre.Version,
		pre.Nombre,
		--ANIO CONTRACTUAL
		ac.IdAnioContractual,
		ac.Anio,
		ac.Inicio,
		ac.Termino,
		ac.IdContrato
	from CO_ProgramaActividad pa
	inner join CO_Presupuesto pre on pre.IdProgramaActividad = pa.IdProgramaActividad and pre.Activo = 1 and
									pre.actual = 1
	inner join CO_AnioContractual ac on ac.IdAnioContractual = pre.IdAnioContractual
	inner join co_periodocontrato pc on pc.IdPeriodo = pa.IdPeriodoContrato
	where ac.idContrato = @pIdContrato
	group by pa.IdProgramaActividad,
		pa.IdPeriodoContrato,
		pa.IdTipoProgramaActividad,
		pa.NombrePrograma,
		pa.FechaPresentacion,
		pa.NumeroRegistroContenidoNacional,		
		pa.CreadoEl,		
		pa.Activo,
		--PRESUPUESTO
		pre.IdPresupuesto,
		
		pre.Version,
		pre.Nombre,
		--ANIO CONTRACTUAL
		ac.IdAnioContractual,
		ac.Anio,
		ac.Inicio,
		ac.Termino,
		ac.IdContrato
	order by ac.IdAnioContractual,
		ac.Anio,
		ac.Inicio,
		ac.Termino,
		ac.IdContrato