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
	DECLARE @Fecha DATETIME = GETDATE();
	BEGIN TRY
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
		FROM @Preferencias;

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
		FROM @Preferencias p
		INNER JOIN APP_Preferencias c ON c.Id = p.Id;-- Para obtener el nombre

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

