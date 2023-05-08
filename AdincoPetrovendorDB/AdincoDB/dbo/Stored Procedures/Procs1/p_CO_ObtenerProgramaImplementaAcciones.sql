CREATE Proc p_CO_ObtenerProgramaImplementaAcciones
@pIdProgramaImplementaElemento int,
@pIdProgramaImplementaAccion int
as

	select 
			pia.IdProgramaImplementaAccion,
			pia.IdProgramaImplementaElemento,
			pia.Descripcion,
			pia.IdProgramaImplementaDepartamento,
			pia.FechaInicioPrimeraAccion,
			pia.FechaFinPrimeraAccion,
			pia.Anexo3,
			pia.ElementosNumerales,
			pia.IdPeriodicidad,
			pia.CreadoEl,
			pia.CreadoPor,
			pia.ModificadoEl,
			pia.ModificadoPor,
			pia.Periodicidad,
			Concat (isnull(pia.Porcentaje,0) , ' %') as Porcentaje,
			case when 
			isnull(cepia.idConEntregableProgramaImpAccion,0) = 0 
				then 0 else 1 end as EsCreado
	from [dbo].[CO_ProgramaImplementaAcciones]	 as pia
	left join EN_ContratoEntregableProgramaImplementaAcciones as cepia
	on pia.IdProgramaImplementaAccion = cepia.IdProgramaImplementaAccion
	where @pIdProgramaImplementaElemento in(0,IdProgramaImplementaElemento)
	order by Orden,pia.Descripcion
