CREATE PROCEDURE [dbo].[SP_CO_GuardaValoresConciliadosProduccion]
	@IdValoresConciliadosProducion	INT,
	@PuntoEntregaID					INT,
	@Mes							DATE,
	@Aceite							FLOAT,
	@Gas							FLOAT,
	@Agua							FLOAT,
	@IdContrato						INT,
	@IdUsuario						INT,
	@Error							VARCHAR(500) OUT    
AS 
BEGIN
	SET @Error = ''  
	SET NOCOUNT ON;
	/*===========*/
	BEGIN TRY
	BEGIN TRAN
	/*===========*/	
		IF(@IdValoresConciliadosProducion = 0)
			BEGIN
				INSERT INTO [dbo].[CO_ValoresConciliadosProducion]
				([PuntoEntregaID], [Mes], [Aceite], [Gas], [Agua], [IdContrato], [CreadoPor], [CreadoEl], [Activo])
				VALUES (@PuntoEntregaID, @Mes, @Aceite, @Gas, @Agua, @IdContrato, @IdUsuario, GETDATE(), 1)
			END
		ELSE
			BEGIN
				UPDATE [dbo].[CO_ValoresConciliadosProducion] 
				SET PuntoEntregaID = @PuntoEntregaID, Mes = @Mes, Aceite = @Aceite, Gas = @Gas, Agua = @Agua, ModificadoPor = @IdUsuario, ModificadoEl = GETDATE()
				WHERE IdValoresConciliadosProducion = @IdValoresConciliadosProducion
			END		
	/*===========*/
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		/*===========*/
		ROLLBACK TRAN		
		SET @Error = 'ERROR SP_CO_GuardaValoresConciliadosProduccion ['+ ERROR_MESSAGE() + '] LINEA ['+ CAST(ERROR_LINE() AS VARCHAR)+']';
		/*===========*/
	END CATCH	
	/*===========*/
END
