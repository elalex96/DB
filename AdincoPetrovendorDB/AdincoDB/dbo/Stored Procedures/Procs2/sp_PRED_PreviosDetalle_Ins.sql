
create proc sp_PRED_PreviosDetalle_Ins
(
	
	@IdPrevioDetalle	int		out,
	@IdPrevio			int,
	@Cantidad			float,
	@Concepto			varchar(8000),
	@PrecioUnitario		float,
	@CreadoPor			int,
	@CreadoEl			datetime,
	@Activo				bit
)
as
begin

	
select	@IdPrevioDetalle	=	isnull(max(IdPrevioDetalle),0)+1 from PRED_PreviosDetalle
insert	into	PRED_PreviosDetalle
				(
					
					IdPrevioDetalle,
					IdPrevio,
					Cantidad,
					Concepto,
					PrecioUnitario,
					CreadoPor,
					CreadoEl,
					Activo
				)
			values
				(
					
					@IdPrevioDetalle,
					@IdPrevio,
					@Cantidad,
					@Concepto,
					@PrecioUnitario,
					@CreadoPor,
					@CreadoEl,
					1
				)
	
end