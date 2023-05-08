
create proc sp_PRED_PreviosDetalle_Upd
(
	
	@IdPrevioDetalle	int,
	@IdPrevio			int,
	@Cantidad			float,
	@Concepto			varchar(8000),
	@PrecioUnitario		float,
	@ModificadoPor		int,
	@ModificadoEl		datetime
)
as
begin
		update		PRED_PreviosDetalle
		set			IdPrevio			=	@IdPrevio,
					Cantidad			=	@Cantidad,
					Concepto			=	@Concepto,
					PrecioUnitario		=	@PrecioUnitario,
					ModificadoPor		=	@ModificadoPor,
					ModificadoEl		=	@ModificadoEl
		where		IdPrevioDetalle		=	@IdPrevioDetalle
				
end

