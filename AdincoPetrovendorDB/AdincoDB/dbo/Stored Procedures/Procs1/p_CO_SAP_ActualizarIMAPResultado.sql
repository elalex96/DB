
create proc [dbo].[p_CO_SAP_ActualizarIMAPResultado]
@pIdContratista	int,
@pIdMail	varchar(500),
@pSuccess	bit,
@pProcesado bit
as

	update [CO_SAP_IMAPResultado]
	set Success = @pSuccess,
		Procesado = @pProcesado,
		FechaProcesado = getdate()
	where IdContratista = @pIdContratista and
	uIdMail = @pIdMail

