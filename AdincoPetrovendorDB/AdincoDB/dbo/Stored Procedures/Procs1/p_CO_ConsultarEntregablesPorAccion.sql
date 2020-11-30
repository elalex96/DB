CREATE PROC	p_CO_ConsultarEntregablesPorAccion 
@pIdProgramaImplementaAccion INT
AS
BEGIN
select top 1 
	1
	from [dbo].[CO_ProgramaImplementaAcciones]	 as pia
	left join EN_ContratoEntregableProgramaImplementaAcciones as cepia
	on pia.IdProgramaImplementaAccion = cepia.IdProgramaImplementaAccion
	where @pIdProgramaImplementaAccion in(0,cepia.IdProgramaImplementaAccion)
END