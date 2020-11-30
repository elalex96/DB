Create Proc p_CO_ObtenerContrato
@pIdContrato int
as
	select *
	from CO_Contrato
	where idContrato = @pIdContrato