IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE name = 'USP_INS_CON_RegistrarPreferenciasContratista'
		)
	DROP PROCEDURE USP_INS_CON_RegistrarPreferenciasContratista;
GO

CREATE PROCEDURE [dbo].[USP_INS_CON_RegistrarPreferenciasContratista] @IdUsuario INT = 0
	,@IdContrato INT
	,@IdContratista INT
	,@Preferencias CO_Type_ContratistaPreferencias READONLY
AS
BEGIN
	DECLARE @Fecha DATETIME = GETDATE()
		,@Id INT
		,@Valor VARCHAR(5000);

	BEGIN TRY
		CREATE TABLE #ContratistaPreferencias (
			Id INT NULL
			,Valor VARCHAR(5000) NULL
			,EstaRegistrado BIT NULL
			,ContratistaPreferenciaId INT NULL
			);

		INSERT INTO #ContratistaPreferencias (
			Id
			,Valor
			,EstaRegistrado
			,ContratistaPreferenciaId
			)
		SELECT Id
			,Valor
			,0
			,0
		FROM @Preferencias

		UPDATE #ContratistaPreferencias
		SET ContratistaPreferenciaId = CON_ContratistaPreferencias.Id
			,EstaRegistrado = 1
		FROM #ContratistaPreferencias
		JOIN CON_ContratistaPreferencias ON #ContratistaPreferencias.Id = CON_ContratistaPreferencias.PreferenciaId
			AND @IdContratista = CON_ContratistaPreferencias.ContratistaId

		DECLARE cur CURSOR
		FOR
		SELECT ContratistaPreferenciaId
			,Valor
		FROM #ContratistaPreferencias
		WHERE EstaRegistrado = 1;

		OPEN cur;

		FETCH NEXT
		FROM cur
		INTO @Id
			,@Valor;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC USP_UPD_CON_ActualizaPreferenciasContratistaRelacionadas @IdUsuario = @IdUsuario
				,@IdContrato = @IdContrato
				,@IdContratista = @IdContratista
				,@Id = @Id
				,@Valor = @Valor;

			FETCH NEXT
			FROM cur
			INTO @Id
				,@Valor;
		END

		CLOSE cur;

		DEALLOCATE cur;

		INSERT INTO CON_ContratistaPreferencias (
			ContratistaId
			,PreferenciaId
			,Valor
			,CreadoPor
			,CreadoEl
			)
		SELECT @IdContratista
			,Id
			,Valor
			,@IdUsuario
			,@Fecha
		FROM #ContratistaPreferencias
		WHERE EstaRegistrado = 0;

		-- Insertar en Bitácora
		-- Insertar en Bitácora por cada preferencia registrada
		INSERT INTO dbo.AP_Bitacora (
			Fecha
			,Tipo
			,Mensaje
			,Detalle
			,UsuarioId
			,ContratoId
			)
		SELECT @Fecha AS Fecha
			,'Creación' AS Tipo
			,'Creación de relación CON_ContratistaPreferencias en la página AdministracionPreferenciasContratista.aspx' AS Mensaje
			,'Valor: ' + ISNULL(p.Valor, '') + ', del registro insertado para la preferencia [' + ISNULL(c.Nombre, '') + '], contratistaId [' + CAST(@IdContratista AS VARCHAR(20)) + '].' AS Detalle
			,@IdUsuario AS UsuarioId
			,@IdContrato AS ContratoId
		FROM #ContratistaPreferencias p
		INNER JOIN APP_Preferencias c ON c.Id = p.Id
			AND p.EstaRegistrado = 0;-- Para obtener el nombre

		DROP TABLE #ContratistaPreferencias

		-- Retornar registro actualizado
		SELECT *
		FROM dbo.CON_ContratistaPreferencias WITH (NOLOCK)
		WHERE ContratistaId = @IdContratista;
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
			,@ErrorNumber INT = ERROR_NUMBER()
			,@ErrorLine INT = ERROR_LINE()
			,@ErrorProc NVARCHAR(200) = ISNULL(ERROR_PROCEDURE(), 'Desconocido')
			,@FechaError DATETIME = GETDATE();

		RAISERROR (
				'Error en SP [%s]: %s'
				,16
				,1
				,@ErrorProc
				,@ErrorMessage
				);
	END CATCH;
END;
GO

