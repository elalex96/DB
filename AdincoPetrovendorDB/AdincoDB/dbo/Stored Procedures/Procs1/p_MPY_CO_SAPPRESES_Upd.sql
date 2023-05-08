
create proc p_MPY_CO_SAPPRESES_Upd
(
	@ReferenceNumber	varchar(50),
	@GRNumber			varchar(50),
	@ModificadoPor		int,
	@IdPreses			int
)
as
begin
	update	CO_SAPPRESES
	set		SAPSESNumber	=	@ReferenceNumber,	--ok
			MatDocN			=	@GRNumber,			--ok
			ModificadoPor	=	@ModificadoPor,		--??
			ModificadoEl	=	getdate()
	where	IdPRESES		=	@IdPreses

	
end

