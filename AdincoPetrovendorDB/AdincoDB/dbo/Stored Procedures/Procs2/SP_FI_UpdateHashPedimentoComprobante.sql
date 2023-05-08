CREATE PROCEDURE [dbo].[SP_FI_UpdateHashPedimentoComprobante] 
	@IdPedComp  INT,
	@Hash256    NVARCHAR(MAX),
	@HashBit    INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	/*===========*/
	DECLARE @validacion VARCHAR(MAX) = '';
	BEGIN TRY
	BEGIN TRAN		
	/*===========*/
	IF (@HashBit = 1)
	BEGIN
		UPDATE 
			dbo.FI_PedimentoComprobante
		SET
			HashSHA256 = @Hash256,
			ProcesadoHash = 1
		WHERE 
			IdPedimentoComprobante = @IdPedComp;
	END
	ELSE
	BEGIN
		UPDATE 
			dbo.FI_PedimentoComprobante
		SET
			ProcesadoHash = 1
		WHERE 
			IdPedimentoComprobante = @IdPedComp;
	END
		
	/*===========*/
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		/*===========*/
		ROLLBACK TRAN		
		SET @validacion = 'ERROR SP_FI_UpdateHashPedimentoComprobante ['+ ERROR_MESSAGE() + '] LINEA ['+ CAST(ERROR_LINE() AS VARCHAR)+']';
		/*===========*/
	END CATCH	
	/*===========*/
	SELECT @validacion AS Validación
END;