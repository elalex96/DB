
	create proc sp_PRED_Predios_Del
	(
		@IdPredio				int
	)
	as
	begin
		update	PRED_Predios
		set		Activo				=	0
		where	IdPredio			=	@IdPredio
	end