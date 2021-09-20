

CREATE PROCEDURE [dbo].[SP_CF_descargaEdoCuenta]
	@IdEdoCuenta int
AS
BEGIN    
	select	IdEdoCuenta,  
			NombreDoc , 
			Carpeta,  
			Mime,	
			Extension,
			Identificador,
			Bucket
	from	CF_EdoCuentaDocumentos
	where	IdEdoCuenta = @IdEdoCuenta
END
