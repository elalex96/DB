create proc p_InsertarComprobanteGastos
@pIdComprobanteGasto	int out,
@pIdBeneficiario	int,
@pIdContrato	int,
@pIdFacturaGasto	int,
@pReferencia	varchar(50),
@pComentarios	varchar(500),
@pCreadoPor	int,
@pError varchar(250) out
as

	if not exists(
		select 1
		from CO_ComprobanteGastos
		where IdBeneficiario = @pIdBeneficiario and
		IdContrato = @pIdContrato and
		IdFacturaGasto = @pIdFacturaGasto
	)
	begin

		select  @pIdComprobanteGasto = isnull(max(IdComprobanteGasto),0) + 1 
		from CO_ComprobanteGastos

		insert into CO_ComprobanteGastos(
			IdComprobanteGasto,		IdBeneficiario,		IdContrato,		IdFacturaGasto,
			Referencia,				Comentarios,		CreadoEl,		CreadoPor	
		)
		select @pIdComprobanteGasto,@pIdBeneficiario,@pIdContrato,		@pIdFacturaGasto,
		@pReferencia,				@pComentarios,		getdate(),		@pCreadoPor

	end
	else
	begin
		set @pError = 'No es posible duplicar un comprobante de gasto'
	end