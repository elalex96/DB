
create PROC [dbo].[p_CO_SAP_ObtenerFallidosIMAPResultado]
@pIdContratista int
as

	select *
	from CO_SAP_IMAPResultado
	where Success = 0 and
	IdContratista = @pIdContratista