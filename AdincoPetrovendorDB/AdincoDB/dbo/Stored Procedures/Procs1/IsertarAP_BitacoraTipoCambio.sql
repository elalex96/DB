CREATE PROCEDURE [dbo].[IsertarAP_BitacoraTipoCambio]
		@Estatus BIT,
		@FilasAfectadas INT,
		@MensajeError VARCHAR(300)
	AS 
		BEGIN
		DECLARE @RowAffected as int;
		SET NOCOUNT ON;
		BEGIN TRY

				INSERT INTO [dbo].[AP_BitacoraTipoCambio]
				([Fecha],
				 [Estatus],
				 [FilasAfectadas],
				 [MensajeError]
				)
		VALUES (GETDATE(), @Estatus, @FilasAfectadas, @MensajeError)
	

select @RowAffected= @@ROWCOUNT
 select @RowAffected as FilasAfectadas;
 END try
 	BEGIN CATCH
	SELECT   
	 ERROR_NUMBER() AS NumeroError  	
	,ERROR_PROCEDURE() AS ProcedimientoError  
	,ERROR_LINE() AS LineaError  
	,ERROR_MESSAGE() AS MensajeError;   
	END CATCH
END