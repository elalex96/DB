
create proc sp_PRED_Previos_Del
(
	@IdPrevio	int
)
as
begin

	
		update		PRED_Previos
		set			Activo			=	0
		where	
					IdPrevio		=	@IdPrevio
				
end