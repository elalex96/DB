-- =============================================
-- Author:		Pedro Acuna
-- Create date: 2022-04-25
-- Description:	
-- =============================================
CREATE PROCEDURE GuardarRelacionCartaPDFNoExisteEnPetrovendor
@IdFactura INT, 
@AwsId  INT,
@IdContrato INT,
@IdUsuario INT
AS
     BEGIN

		IF EXISTS(SELECT 1 FROM AWS_DocAwsDocAdinco WHERE IdDocAdinco = @IdFactura)
		BEGIN
			DELETE AWS_DocAwsDocAdinco WHERE IdDocAdinco = @IdFactura AND IdTipoDocumento = 1
		END
		
		INSERT INTO AWS_DocAwsDocAdinco(AWSDocumentoId, IdDocAdinco, IdTipoDocumento, IdContrato, CreadoPor, CreadoEn)
		SELECT @AwsId, @IdFactura, 1, @IdContrato, @IdUsuario, GETDATE()
     END;



	 