create proc p_CO_PorcentajePorElemento
@pIdProgramaImplementaElemento int,
@pIdProgramaImplementaAccion int,
@pPorcentaje float
as
begin
	SELECT SUM(isnull(Porcentaje,0))  + @pPorcentaje /*case when @pIdProgramaImplementaAccion <> 0 then @pPorcentaje else 0 end*/
	as 'porcentaje' 
	FROM CO_ProgramaImplementaAcciones 
	WHERE IdProgramaImplementaElemento = @pIdProgramaImplementaElemento and
	IdProgramaImplementaAccion <> @pIdProgramaImplementaAccion
end