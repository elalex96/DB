CREATE PROCEDURE  Guardar_PR_ProdDiaria_Bitacora
	@NombreArchivo VARCHAR(2000),
	@Observacion VARCHAR(8000),
	@AwsId INT,
	@CreadoPor INT
AS    
BEGIN       
	INSERT INTO PR_ProdDiaria_Bitacora(NombreArchivo, Observacion, CreadoPor, CreadoEn, AwsId)
	SELECT @NombreArchivo, @Observacion, @CreadoPor, GETDATE(), @AwsId

	SELECT SCOPE_IDENTITY();
END


