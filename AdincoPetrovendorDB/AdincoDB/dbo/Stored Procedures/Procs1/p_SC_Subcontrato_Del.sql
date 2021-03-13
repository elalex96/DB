CREATE proc p_SC_Subcontrato_Del
(
	@IdSubContrato	int
)
as
begin

	if not exists(
		select	1 
		from	OT_Solicitud
		where	IdOTEstatus		in (2,3,4,5,6,9,10,11) 
		and		IdSubcontrato	= @IdSubcontrato
		)
	begin
		if not exists (
			select 1
			from OT_Solicitud
			where IdSubcontrato = @IdSubContrato and
			isnull(IsActivo,0) = 1
		)
		begin
		

			update	SC_SubContrato 
			set		IsEliminado		=	1,
					IsActivo = 0
			where	IdSubContrato	=	@IdSubContrato
		end
		select	Error = 0
	end
	select Error = 2
end

