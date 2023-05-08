Create Proc p_ObtenerComprobanteGasto
@pId int,
@pIdContrato int
as

	select	IdComprobanteGasto,
			IdBeneficiario,
			IdContrato,
			IdFacturaGasto,
			Referencia,
			Comentarios,
			CreadoEl,
			CreadoPor
	from CO_ComprobanteGastos
	where IdComprobanteGasto = @pId and
	IdContrato = @pIdContrato