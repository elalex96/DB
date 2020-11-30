
create proc sp_PRED_PreviosDetalle_Grd
(
	@IdPrevio		int
)
as
begin
	select	p.IdPrevioDetalle,
			p.IdPrevio,
			p.Cantidad,
			p.Concepto,
			p.PrecioUnitario 
	from	PRED_PreviosDetalle		p
	where	p.IdPrevio				=	@IdPrevio
	and		p.Activo				=	1
end

