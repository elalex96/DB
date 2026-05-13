use Petrovendor
go
drop proc if exists USP_INS_SP_RegistrarContratistaAdinco
go
-- ============================================
-- Author:		<Daniel>
-- Create date: <13-04-2026>
-- Description:	Registrar contratista a tabla de proveedores de petrovendor
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_SP_RegistrarContratistaAdinco]
	@RFC NVARCHAR(50),
	@IdNacionalidad INT,
	@IdPais INT,
	@IdTipoRegimen INT,
	@IdRegimenCapital INT,
	@Alias NVARCHAR(200),
	@RazonSocial NVARCHAR(MAX),
	@Entidad NVARCHAR(50),
	@Municipio NVARCHAR(50),
	@Colonia NVARCHAR(50),
	@NumeroExterior NVARCHAR(8),
	@CodigoPostal NVARCHAR(10),
	@Pais NVARCHAR(50),
	@Calle NVARCHAR(50),
	@Telefono NVARCHAR(20),
	@CreadoPor INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @RegimenCapital NVARCHAR(MAX);
	DECLARE @Detalle NVARCHAR(MAX);
	DECLARE @ExisteEnAdinco BIT = 0;
	DECLARE @IdPetrovendor INT = 0;

	SET @RFC = UPPER(LTRIM(RTRIM(ISNULL(@RFC, N''))));
	SET @Alias = NULLIF(LTRIM(RTRIM(ISNULL(@Alias, N''))), N'');
	SET @RazonSocial = NULLIF(LTRIM(RTRIM(ISNULL(@RazonSocial, N''))), N'');
	SET @Entidad = NULLIF(LTRIM(RTRIM(ISNULL(@Entidad, N''))), N'');
	SET @Municipio = NULLIF(LTRIM(RTRIM(ISNULL(@Municipio, N''))), N'');
	SET @Colonia = NULLIF(LTRIM(RTRIM(ISNULL(@Colonia, N''))), N'');
	SET @NumeroExterior = NULLIF(LTRIM(RTRIM(ISNULL(@NumeroExterior, N''))), N'');
	SET @CodigoPostal = NULLIF(LTRIM(RTRIM(ISNULL(@CodigoPostal, N''))), N'');
	SET @Pais = NULLIF(LTRIM(RTRIM(ISNULL(@Pais, N''))), N'');
	SET @Calle = NULLIF(LTRIM(RTRIM(ISNULL(@Calle, N''))), N'');
	SET @Telefono = NULLIF(LTRIM(RTRIM(ISNULL(@Telefono, N''))), N'');

	BEGIN TRY
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
		BEGIN TRANSACTION;

		IF EXISTS
		(
			SELECT 1
			FROM dbo.S_Proveedor WITH (UPDLOCK, HOLDLOCK)
			WHERE UPPER(LTRIM(RTRIM(ISNULL(RFC, '')))) = @RFC
		)
		BEGIN
			ROLLBACK TRANSACTION;
			SELECT Resultado = 'DUPLICADO';
			RETURN;
		END;

		SELECT TOP 1
			@ExisteEnAdinco = 1
		FROM Adinco.dbo.CO_Contratista C
		WHERE UPPER(LTRIM(RTRIM(ISNULL(C.RFC, N'')))) COLLATE DATABASE_DEFAULT = @RFC COLLATE DATABASE_DEFAULT

		IF @ExisteEnAdinco = 0
		BEGIN
			ROLLBACK TRANSACTION;
			SELECT Resultado = 'NO_EXISTE_EN_ADINCO';
			RETURN;
		END;

		IF ISNULL(@IdNacionalidad, 0) <= 0
			OR ISNULL(@IdPais, 0) <= 0
			OR ISNULL(@IdTipoRegimen, 0) <= 0
			OR ISNULL(@IdRegimenCapital, 0) <= 0
			OR @Alias IS NULL
			OR @RazonSocial IS NULL
			OR @Entidad IS NULL
			OR @Municipio IS NULL
			OR @Colonia IS NULL
			OR @NumeroExterior IS NULL
			OR @CodigoPostal IS NULL
			OR @Pais IS NULL
			OR @Calle IS NULL
			OR @Telefono IS NULL
		BEGIN
			ROLLBACK TRANSACTION;
			SELECT Resultado = 'DATOS_REQUERIDOS';
			RETURN;
		END;

		SELECT @RegimenCapital = CASE WHEN @IdRegimenCapital = 5 THEN N'' ELSE ISNULL(R.Regimen, N'') END
		FROM dbo.RegimenCapital R
		WHERE R.IdRegimenCapital = @IdRegimenCapital;

		IF @RegimenCapital IS NULL
		BEGIN
			ROLLBACK TRANSACTION;
			SELECT Resultado = 'DATOS_REQUERIDOS';
			RETURN;
		END;

		SET @RegimenCapital = ISNULL(@RegimenCapital, N'');

		INSERT INTO dbo.S_Proveedor
		(
			IdNacionalidad,
			RFC,
			IdTipoRegimen,
			RazonSocial,
			RegimenCapital,
			Pais,
			IdPais,
			Entidad,
			Municipio,
			Colonia,
			NombreVialidad,
			NumExterior,
			CodigoPostal,
			Alias,
			Telefono,
			IdRegimenCapital,
			IsEliminado,
			Activo,
			CreadoPor,
			CreadoEl,
			ModificadoPor,
			ModificadoEl
		)
		VALUES
		(
			@IdNacionalidad,
			@RFC,
			@IdTipoRegimen,
			@RazonSocial,
			@RegimenCapital,
			@Pais,
			@IdPais,
			@Entidad,
			@Municipio,
			@Colonia,
			@Calle,
			LEFT(@NumeroExterior, 8),
			@CodigoPostal,
			@Alias,
			@Telefono,
			@IdRegimenCapital,
			0,
			1,
			@CreadoPor,
			GETDATE(),
			NULL,
			NULL
		);

		SELECT @IdPetrovendor = SCOPE_IDENTITY()
		SET @Detalle = CONCAT(
		'RFC: ', @RFC,
		', Razon Social: ', @RazonSocial,
		', Nacionalidad: ', CAST(@IdNacionalidad AS VARCHAR),
		', IdPais: ', CAST(@IdPais AS VARCHAR),
		', Tipo Regimen: ', CAST(@IdTipoRegimen AS VARCHAR),
		', Regimen Capital: ', @RegimenCapital,
		', Pais: ', @Pais,
		', Entidad: ', @Entidad,
		', Municipio: ', @Municipio,
		', Colonia: ', @Colonia,
		', Calle: ', @Calle,
		', Num Ext: ', LEFT(@NumeroExterior, 8),
		', CP: ', @CodigoPostal,
		', Alias: ', @Alias,
		', Tel: ', @Telefono,
		', IdRegimenCapital: ', CAST(@IdRegimenCapital AS VARCHAR),
		', IdProveedor(Petrovendor): ', CAST(@IdPetrovendor AS VARCHAR)
	  );

		INSERT INTO AP_Bitacora
		(Fecha,
		Tipo,
		Mensaje,
		Detalle,
		UsuarioId,
		ContratoId)
		VALUES (
		GETDATE(),
		'Importación contratista',
		'Se importo el contratista de Adinco a Petrovendor',
		@Detalle,
		@CreadoPor,
		0
		)
		COMMIT TRANSACTION;
		SELECT Resultado = 'SUCCESS';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		THROW;
	END CATCH;
END
