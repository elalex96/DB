
create proc sp_PRED_PrediosDetalle_Ins
(
	@IdPredioDetalle	int,
	@IdPredio			int,
	@Cantidad			float,
	@Concepto			varchar(max),
	@PrecioUnitario		float
)
as
begin

	select	@IdPredioDetalle	=	isnull(max(IdPredioDetalle),0)+1 from PRED_PrediosDetalle

	insert	into	PRED_PrediosDetalle
				(
					IdPredioDetalle,
					IdPredio,
					Cantidad,
					Concepto,
					PrecioUnitario,
					Activo	
				)
			values
				(
					@IdPredioDetalle,
					@IdPredio,
					@Cantidad,
					@Concepto,
					@PrecioUnitario,
					1
				)
	
end