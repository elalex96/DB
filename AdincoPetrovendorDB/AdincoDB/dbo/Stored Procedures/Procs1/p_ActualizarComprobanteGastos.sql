create proc p_ActualizarComprobanteGastos
@pIdComprobanteGasto	int,
@pIdBeneficiario	int,
@pIdContrato	int,
@pIdFacturaGasto	int,
@pReferencia	varchar(50),
@pComentarios	varchar(500),
@pCreadoPor	int
as

	

	update CO_ComprobanteGastos
	set Referencia = @pReferencia,
		Comentarios = @pComentarios
	where  IdComprobanteGasto = @pIdComprobanteGasto and
	IdContrato = @pIdContrato