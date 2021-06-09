CREATE PROCEDURE [dbo].[SP_CO_ValidacionMesVCP]
	@IdValoresConciliadosProducion	INT,
	@PuntoEntregaID					INT,
	@Mes							DATE,
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
		IF EXISTS (SELECT *
					FROM [dbo].[CO_ValoresConciliadosProducion]
					WHERE PuntoEntregaID = @PuntoEntregaID AND 
						  Mes = @Mes AND 
						  IdContrato = @IdContrato AND
						  Activo = 1 AND
						  IdValoresConciliadosProducion NOT IN (@IdValoresConciliadosProducion)
					)
		BEGIN
			DECLARE @Nombre VARCHAR(MAX), @Fecha VARCHAR(MAX);
			SET @Nombre = (SELECT Nombre FROM [dbo].[CO_PuntosdeEntrega] WHERE PuntoEntregaID = @PuntoEntregaID)
			SET @Fecha = CAST(CONCAT(DATENAME(MONTH, @Mes), ' ', YEAR(@Mes)) AS VARCHAR)
			IF(@IdValoresConciliadosProducion = 0)
				BEGIN
					SET @Error = 'Ya se encuentra un registro de '+@Nombre+' con mes '+@Fecha+'.'
				END
			ELSE
				BEGIN
				SET @Error = 'Ya se encuentra otro registro de '+@Nombre+' con mes '+@Fecha+'.'
				END
		END
	/*===========*/
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		/*===========*/
		ROLLBACK TRAN		
		SET @Error = 'ERROR SP_CO_ValidacionMesVCP ['+ ERROR_MESSAGE() + '] LINEA ['+ CAST(ERROR_LINE() AS VARCHAR)+']';
		/*===========*/
	END CATCH	
	/*===========*/
END
