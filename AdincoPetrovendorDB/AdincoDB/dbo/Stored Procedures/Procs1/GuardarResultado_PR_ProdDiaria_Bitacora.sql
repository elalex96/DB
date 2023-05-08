CREATE PROCEDURE  GuardarResultado_PR_ProdDiaria_Bitacora
	@ResultadoCarga VARCHAR(500),
	@AwsId INT
AS    
BEGIN       
	UPDATE PR_ProdDiaria_Bitacora
	SET ResultadoCarga = @ResultadoCarga
	WHERE AWSId = @AwsId
END


