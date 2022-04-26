CREATE PROCEDURE GuardarRelacionCartaPDFNoExisteEnPetrovendor
@IdFactura INT, 
@AwsId  INT,
@IdContrato INT,
@IdUsuario INT
AS
     BEGIN
		DECLARE @AWSDocumentoId INT,
				@IdDocAwsDocAdinco INT

		SELECT @AWSDocumentoId = AWSDocumentoId FROM AWS_Documentos WHERE AWSDocumentoId = @AwsId

		SELECT @IdDocAwsDocAdinco = IdDocAwsDocAdinco FROM AWS_DocAwsDocAdinco WHERE AWSDocumentoId = @AWSDocumentoId

		IF(ISNULL(@IdDocAwsDocAdinco, 0) > 0)
		BEGIN
			DELETE AWS_DocAwsDocAdinco WHERE IdDocAdinco = @IdFactura
		END
		
		INSERT INTO AWS_DocAwsDocAdinco(AWSDocumentoId, IdDocAdinco, IdTipoDocumento, IdContrato, CreadoPor, CreadoEn)
		SELECT @AWSDocumentoId, @IdFactura, 1, @IdContrato, @IdUsuario, GETDATE()
     END;



