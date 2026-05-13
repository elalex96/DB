
create proc sp_PRED_PreviosDetalle_Del
(
	@IdPrevioDetalle	int
)
as
begin
		update		PRED_PreviosDetalle
		set			Activo			=	0
		where		IdPrevioDetalle	=	@IdPrevioDetalle
				
end

