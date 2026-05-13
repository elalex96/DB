
create proc sp_FI_Transfer_AWSPDFId_Upd
(
	@IdTransferencia	int,
	@AWSPDFId			int
)
as
begin
	update	FI_Transfer
	set		AWSPDFId		=	@AWSPDFId
	where	IdTransferencia	=	@IdTransferencia
end


--sp_FI_Transfer_AWSPDFId_Upd


--select * from FI_Transfer where IdTransferencia = 87