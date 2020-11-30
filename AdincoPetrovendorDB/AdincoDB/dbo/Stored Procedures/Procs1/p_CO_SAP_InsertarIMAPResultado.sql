create proc [dbo].[p_CO_SAP_InsertarIMAPResultado]
@pIdContratista	int,
@pIdMail	varchar(50),
@pSuccess	bit,
@pProcesado bit
as

	if not exists (
		select 1
		from [CO_SAP_IMAPResultado]
		where IdContratista = @pIdContratista and
		uIdMail = @pIdMail
	)
	begin
		insert into [dbo].[CO_SAP_IMAPResultado](
			IdContratista,uIdMail,Success,CreadoEl,Procesado
		)
		select @pIdContratista,@pIdMail,@pSuccess,getdate(),@pProcesado

	end