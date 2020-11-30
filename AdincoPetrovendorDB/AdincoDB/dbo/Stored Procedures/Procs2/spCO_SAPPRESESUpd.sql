
CREATE proc spCO_SAPPRESESUpd
(
	@pIdPRESES			int,
	@pReferenceNumber	varchar(20),
	@pSESNumber			nvarchar(100)
)
as
begin
		update	CO_SAPPRESES
		set		SAPSESNumber	=	@pReferenceNumber,
				SESN			=	@pSESNumber,
				ModificadoEl = getdate()
		where	IdPRESES		=	@pIdPRESES
end


