
create proc sp_PRED_PrediosDetalle_Del
(
	@IdPredioDetalle	int
)
as
begin

	delete	PRED_PrediosDetalle
	where	IdPredioDetalle			=	@IdPredioDetalle
					
end