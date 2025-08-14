IF OBJECT_ID('dbo.USP_UPD_CON_ActualizaPreferenciasContratistaRelacionadas', 'P') IS NOT NULL
	DROP PROCEDURE dbo.USP_UPD_CON_ActualizaPreferenciasContratistaRelacionadas;
GO

CREATE PROCEDURE dbo.USP_UPD_CON_ActualizaPreferenciasContratistaRelacionadas 
	@IdUsuario INT = 0
	,@IdContrato INT
	,@IdContratista INT
	,@Id INT
	,@Valor VARCHAR(5000)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Fecha DATETIME = GETDATE();
	DECLARE @ValorAntes VARCHAR(5000) = '';
	DECLARE @PreferenciaId INT;
	DECLARE @Preferencia VARCHAR(1000) = '';

	-- Obtener valor anterior y PreferenciaId
	SELECT @ValorAntes = Valor
		,@PreferenciaId = PreferenciaId
	FROM dbo.CON_ContratistaPreferencias WITH (NOLOCK)
	WHERE Id = @Id;

	-- Obtener nombre de la preferencia
	SELECT @Preferencia = Nombre
	FROM dbo.APP_Preferencias WITH (NOLOCK)
	WHERE Id = @PreferenciaId;

	BEGIN TRY
		-- Actualizar preferencia
		UPDATE dbo.CON_ContratistaPreferencias
		SET Valor = ISNULL(@Valor, '')
			,ModificadoPor = @IdUsuario
			,ModificadoEl = @Fecha
		WHERE Id = @Id;

		-- Insertar en Bitácora
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
			,'Edición'
			,'Edición de Valor de CON_ContratistaPreferencias en la página AdministracionPreferenciasContratista.aspx'
			,'Valor Nuevo: ' + ISNULL(@Valor, '') + ', Antes: ' + ISNULL(@ValorAntes, '') + ', del registro con Id ' + CAST(@Id AS VARCHAR(20)) + ', preferencia [' + ISNULL(@Preferencia, '') + '], contratistaId [' + CAST(@IdContratista AS VARCHAR(20)) + '].'
			,@IdUsuario
			,@IdContrato
			);

		-- Retornar registro actualizado
		SELECT *
		FROM dbo.CON_ContratistaPreferencias WITH (NOLOCK)
		WHERE Id = @Id;
	END TRY

	BEGIN CATCH
		 DECLARE 
            @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
            @ErrorNumber INT = ERROR_NUMBER(),
            @ErrorLine INT = ERROR_LINE(),
            @ErrorProc NVARCHAR(200) = ISNULL(ERROR_PROCEDURE(), 'Desconocido'),
            @FechaError DATETIME = GETDATE();

		RAISERROR('Error en SP [%s]: %s', 16, 1, @ErrorProc, @ErrorMessage);
	END CATCH;
END;
GO

