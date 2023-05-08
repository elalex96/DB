
create PROCEDURE [db_owner].[SP_CF_EliminarDeclaracionFiscal]
	@IdDeclaracionFiscal int
AS
BEGIN    
	delete from cf_DeclaracionFiscal
		where IdDeclaracionFiscal = @IdDeclaracionFiscal
END
