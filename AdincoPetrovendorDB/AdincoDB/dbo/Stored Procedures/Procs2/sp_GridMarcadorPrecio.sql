CREATE PROCEDURE [dbo].sp_GridMarcadorPrecio
@IdContrato INT = 0,
@TipoAccion NVARCHAR(200),
@IdMarcador INT = 0,
@Mes DATE = '20200101',
@Precio DECIMAL(20,4) = 0,
@IdPrecioMarcadorMensual INT = 0,
@IdUsuario INT
AS  
	BEGIN    
        IF(@TipoAccion = 'Select')
		BEGIN
			SELECT
				YEAR(CO_PrecioMarcadorMensual.Mes) AS Anio,
				CO_PrecioMarcadorMensual.IdPrecioMarcadorMensual,
				CO_PrecioMarcadorMensual.IdMarcador,
				CO_Marcador.Marcador,
				CO_PrecioMarcadorMensual.IdContrato,
				CO_PrecioMarcadorMensual.Mes,
				CO_PrecioMarcadorMensual.Precio,
				AP_UsuarioCreado.Nombre AS CreadoPor,
				CO_PrecioMarcadorMensual.CreadoEn,
				AP_UsuarioModificado.Nombre AS ModificadoPor,
				CO_PrecioMarcadorMensual.ModificadoEl 
				FROM CO_PrecioMarcadorMensual 
				LEFT JOIN CO_Marcador ON CO_Marcador.IdMarcador = CO_PrecioMarcadorMensual.IdMarcador
				LEFT JOIN AP_Usuario AP_UsuarioCreado ON AP_UsuarioCreado.UsuarioID = CO_PrecioMarcadorMensual.CreadoPor
				LEFT JOIN AP_Usuario AP_UsuarioModificado ON AP_UsuarioModificado.UsuarioID = CO_PrecioMarcadorMensual.ModificadoPor
				WHERE CO_PrecioMarcadorMensual.IdContrato = @IdContrato
		END

		IF(@TipoAccion = 'Insert')
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM CO_PrecioMarcadorMensual WHERE IdMarcador = @IdMarcador AND Mes = @Mes AND IdContrato = @IdContrato)
			BEGIN
				INSERT INTO CO_PrecioMarcadorMensual (IdMarcador, IdContrato, Mes, Precio, CreadoPor, CreadoEn )
				SELECT @IdMarcador, @IdContrato, @Mes, @Precio, @IdUsuario, GETDATE()
			END
		ELSE
			BEGIN
				SELECT 'Ya existe un registro con la misma fecha y marcador'
			END
		END

		IF(@TipoAccion = 'Update')
		BEGIN
			UPDATE CO_PrecioMarcadorMensual
			SET Precio = @Precio, ModificadoEl = GETDATE(), ModificadoPor = @IdUsuario
			WHERE IdPrecioMarcadorMensual = @IdPrecioMarcadorMensual
		END


		IF(@TipoAccion = 'Delete')
		BEGIN
			DELETE CO_PrecioMarcadorMensual WHERE IdPrecioMarcadorMensual = @IdPrecioMarcadorMensual
		END

		
     END;



