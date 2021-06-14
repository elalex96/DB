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
	SET LANGUAGE spanish;
	DECLARE @Detalle VARCHAR(MAX) = '';
		IF(@IdValoresConciliadosProducion = 0)
			BEGIN
				INSERT INTO [dbo].[CO_ValoresConciliadosProducion]
				([PuntoEntregaID], [Mes], [Aceite], [Gas], [Agua], [IdContrato], [CreadoPor], [CreadoEl], [Activo])
				VALUES (@PuntoEntregaID, @Mes, @Aceite, @Gas, @Agua, @IdContrato, @IdUsuario, GETDATE(), 1)
				
				DECLARE @Id INT = SCOPE_IDENTITY()
				SET @Detalle =  'PuntoEntregaID - ' +CAST(@PuntoEntregaID AS VARCHAR(MAX)) + 
							    ', Mes - ' + CONCAT(DATENAME(MONTH, @Mes), ' ', YEAR(@Mes)) + 
								', Aceite - ' + CAST(@Aceite AS VARCHAR(MAX)) +
								', Gas - ' + CAST(@Gas AS VARCHAR(MAX)) +
								', Agua - ' + CAST(@Agua AS VARCHAR(MAX));

				INSERT INTO [dbo].[CO_ValoresConciliadosProducionBitacora] 
				([IdValoresConciliadosProducion], [Detalle], [Tipo], [UsuarioID], [Fecha])
				VALUES (@Id, @Detalle, 'Creación', @IdUsuario, GETDATE())
			END
		ELSE
			BEGIN
			DECLARE 
				@PuntoEntregaID2				INT,
				@Mes2							DATE,
				@Aceite2						FLOAT,
				@Gas2							FLOAT,
				@Agua2							FLOAT

				SELECT 
					@PuntoEntregaID2 = PuntoEntregaID, 
					@Mes2 = Mes, 
					@Aceite2 = Aceite, 
					@Gas2 = Gas, 
					@Agua2 = Agua
				FROM [dbo].[CO_ValoresConciliadosProducion]
					WHERE IdValoresConciliadosProducion = @IdValoresConciliadosProducion
				--===================

				IF ( (@PuntoEntregaID2) <> @PuntoEntregaID)
				BEGIN
					SET @Detalle = '[Anterior - ' + CAST(@PuntoEntregaID2 AS VARCHAR) + ', Nuevo - ' + CAST(@PuntoEntregaID AS VARCHAR) + ']';
				END

				IF ( @Mes2 <> @Mes)
				BEGIN
					IF(@Detalle = '')
						BEGIN
							SET @Detalle = '[Anterior - ' + CAST(CONCAT(DATENAME(MONTH, @Mes2), ' ', YEAR(@Mes2)) AS VARCHAR) + ', Nuevo - ' + CAST(CONCAT(DATENAME(MONTH, @Mes), ' ', YEAR(@Mes)) AS VARCHAR) + ']'
						END
					ELSE
						BEGIN
							SET @Detalle = @Detalle + ', [Anterior - ' + CAST(CONCAT(DATENAME(MONTH, @Mes2), ' ', YEAR(@Mes2)) AS VARCHAR) + ', Nuevo - ' + CAST(CONCAT(DATENAME(MONTH, @Mes), ' ', YEAR(@Mes)) AS VARCHAR) + ']'
						END	
				END

				IF ( @Aceite2 <> @Aceite)
				BEGIN
					IF(@Detalle = '')
						BEGIN
							SET @Detalle = '[Anterior - ' + CAST(@Aceite2 AS VARCHAR) + ', Nuevo - ' + CAST(@Aceite AS VARCHAR) + ']';
						END
					ELSE
						BEGIN
							SET @Detalle = @Detalle + ', [Anterior - ' + CAST(@Aceite2 AS VARCHAR) + ', Nuevo - ' + CAST(@Aceite AS VARCHAR) + ']';
						END	
				END

				IF ( @Gas2 <> @Gas)
				BEGIN
					IF(@Detalle = '')
						BEGIN
							SET @Detalle = '[Anterior - ' + CAST(@Gas2 AS VARCHAR) + ', Nuevo - ' + CAST(@Gas AS VARCHAR) + ']';
						END
					ELSE
						BEGIN
							SET @Detalle = @Detalle + ', [Anterior - ' + CAST(@Gas2 AS VARCHAR) + ', Nuevo - ' + CAST(@Gas AS VARCHAR) + ']';
						END	
				END

				IF ( @Agua2 <> @Agua)
				BEGIN
					IF(@Detalle = '')
						BEGIN
							SET @Detalle = '[Anterior - ' + CAST(@Agua2 AS VARCHAR) + ', Nuevo - ' + CAST(@Agua AS VARCHAR) + ']';
						END
					ELSE
						BEGIN
							SET @Detalle = @Detalle + ', [Anterior - ' + CAST(@Agua2 AS VARCHAR) + ', Nuevo - ' + CAST(@Agua AS VARCHAR) + ']';
						END	
				END				
				--===================
				IF(@Detalle <> '') 
				BEGIN					
					UPDATE [dbo].[CO_ValoresConciliadosProducion] 
					SET PuntoEntregaID = @PuntoEntregaID, Mes = @Mes, Aceite = @Aceite, Gas = @Gas, Agua = @Agua, ModificadoPor = @IdUsuario, ModificadoEl = GETDATE()
					WHERE IdValoresConciliadosProducion = @IdValoresConciliadosProducion
					INSERT INTO [dbo].[CO_ValoresConciliadosProducionBitacora] 
							([IdValoresConciliadosProducion], [Detalle], [Tipo], [UsuarioID], [Fecha])
					VALUES (@IdValoresConciliadosProducion, @Detalle, 'Edición', @IdUsuario, GETDATE())

				END
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
