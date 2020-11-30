
create proc sp_CAT_Estados_Cmb
(
	@IdPais		int
)
as
begin
	select	e.IdEstado,
			e.IdPais,
			e.Estado
	from	CAT_Estados		e
	where	((e.IdPais		=	@IdPais)	or	@IdPais	=	-1)
end