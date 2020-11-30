create proc [dbo].[p_CO_SAP_PendienteIMAPResultado]
@pIdContratista	int
as


	select IdContratista,
			uIdMail,
			Success,
			CreadoEl,
			Procesado
	from [CO_SAP_IMAPResultado]
	where IdContratista = @pIdContratista and 
	isnull(Procesado,0) = 0
	