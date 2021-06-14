CREATE PROCEDURE [dbo].[SP_CO_DesactivarValoresConciliadosProduccion] 
    @IdValoresConciliadosProducion	INT,
	@IdContrato						INT,
	@IdUsuario						INT,
	@Error							VARCHAR(500) OUT    
AS 
BEGIN
	SET @Error = ''  
	SET NOCOUNT ON;
	SET LANGUAGE spanish;
	/*===========*/
	BEGIN TRY
	BEGIN TRAN
	/*===========*/			
		UPDATE [dbo].[CO_ValoresConciliadosProducion] 
		SET Activo = 0, ModificadoPor = @IdUsuario, ModificadoEl = GETDATE()
		WHERE IdValoresConciliadosProducion = @IdValoresConciliadosProducion	

		INSERT INTO [dbo].[CO_ValoresConciliadosProducionBitacora] 
					([IdValoresConciliadosProducion], [Detalle], [Tipo], [UsuarioID], [Fecha])
		VALUES (@IdValoresConciliadosProducion, 'Se Desactiva', 'Eliminación', @IdUsuario, GETDATE())			
	/*===========*/
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		/*===========*/
		ROLLBACK TRAN		
		SET @Error = 'ERROR SP_CO_DesactivarValoresConciliadosProduccion ['+ ERROR_MESSAGE() + '] LINEA ['+ CAST(ERROR_LINE() AS VARCHAR)+']';
		/*===========*/
	END CATCH	
	/*===========*/
END
