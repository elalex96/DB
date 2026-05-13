
create PROCEDURE [dbo].[SP_CF_descargaDeclaracionFiscal]
	@IdDeclaracionFiscal int
AS
BEGIN    
	select DeclaracionFiscal, NombreDoc
		from CF_DeclaracionFiscal
		where IdDeclaracionFiscal = @IdDeclaracionFiscal
END

