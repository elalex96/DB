IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE name = 'USP_DEL_CON_EliminarPreferenciaContratista'
		)
	DROP PROCEDURE USP_DEL_CON_EliminarPreferenciaContratista;
GO

CREATE PROCEDURE [dbo].[USP_DEL_CON_EliminarPreferenciaContratista] 
	 @IdUsuario INT = 0
	,@IdContrato INT
	,@IdContratista INT
	,@Id INT
AS
BEGIN
	
		DECLARE @Fecha DATETIME = GETDATE();
	DECLARE @Valor VARCHAR(5000) = '';
	DECLARE @PreferenciaId INT;
	DECLARE @Preferencia VARCHAR(1000) = '';

	-- Obtener valor y PreferenciaId
	SELECT @Valor = Valor
		,@PreferenciaId = PreferenciaId
	FROM dbo.CON_ContratistaPreferencias WITH (NOLOCK)
	WHERE Id = @Id;

	-- Obtener nombre de la preferencia
	SELECT @Preferencia = Nombre
	FROM dbo.APP_Preferencias WITH (NOLOCK)
	WHERE Id = @PreferenciaId;
	BEGIN TRY
		DELETE FROM CON_ContratistaPreferencias WHERE Id = @Id

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
		VALUES (
			@Fecha
			,'Eliminación'
			,'Eliminación de relación CON_ContratistaPreferencias en la página AdministracionPreferenciasContratista.aspx'
			,'Id: ['+CAST(@Id AS VARCHAR(20))+'], Valor: ' + ISNULL(@Valor, '') + ', del registro insertado para la preferencia [' + ISNULL(@Preferencia, '') + '], contratistaId [' + CAST(@IdContratista AS VARCHAR(20)) + '].' 
			,@IdUsuario
			,@IdContrato
			);

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

