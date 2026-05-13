
create proc sp_PRED_PrediosDetalle_Upd
(
	@IdPredioDetalle	int,
	@IdPredio			int,
	@Cantidad			float,
	@Concepto			varchar(max),
	@PrecioUnitario		float
)
as
begin

	update	PRED_PrediosDetalle
	set		IdPredio			=	@IdPredio,
			Cantidad			=	@Cantidad,
			Concepto			=	@Concepto,
			PrecioUnitario		=	@PrecioUnitario
	where	IdPredioDetalle		=	@IdPredioDetalle
					
end