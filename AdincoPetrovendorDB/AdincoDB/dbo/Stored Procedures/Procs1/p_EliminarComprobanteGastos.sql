create proc p_EliminarComprobanteGastos
@pIdComprobanteGasto	int,
@pIdContrato	int
as	

	delete CO_ComprobanteGastos	
	where  IdComprobanteGasto = @pIdComprobanteGasto and
	IdContrato = @pIdContrato