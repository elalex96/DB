
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Edición:	02 de Marzo del 2023
-- Descripción:			Se agregan LTRIM y RTRIM correspondientes
-- =============================================
CREATE PROCEDURE [dbo].[ActualizarInsertarTanquesAmat] @IdUsuario INT,
	@Clave VARCHAR(20),
	@Id INT = 0, --> Cuando es 0 es Insert y cuando es mayor a 0 es update
	@Nombre VARCHAR(200),
	@IdCampo INT,
	@Activo BIT
AS
BEGIN
	DECLARE @IdTipoTanque INT,
		@IdEstacion INT,
		@IdTanque INT

	SELECT TOP 1 @IdTipoTanque = IdTipoTanque
	FROM PR_TiposTanques
	WHERE LTRIM(RTRIM(UPPER(Descripcion))) COLLATE Latin1_general_CI_AI LIKE 'ESFERICO' COLLATE Latin1_general_CI_AI

	SELECT TOP 1 @IdEstacion = Id
	FROM PR_Estacion

	IF (ISNULL(@Id, 0) <> 0)
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM PR_Tanque_Macropera
				WHERE IdTanque = @Id
				)
		BEGIN
			DELETE PR_Tanque_Macropera
			WHERE IdTanque = @Id
		END

		IF NOT EXISTS (
				SELECT 1
				FROM PR_Tanque_Macropera
				WHERE @IdCampo = IdCampo
					AND @Id = IdTanque
				)
		BEGIN
			INSERT INTO PR_Tanque_Macropera (
				IdCampo,
				IdTanque
				)
			SELECT @IdCampo,
				@Id
		END

		UPDATE PR_Tanque
		SET Clave = LTRIM(RTRIM(@Clave)), --> Clave que registra el usuario
			Nombre = LTRIM(RTRIM(@Nombre)), --> Nombre que registra el usuario
			Descripcion = LTRIM(RTRIM(@Nombre)), --> Nombre que registra el usuario
			Estatus = 1, --> 1
			Estacion = @IdEstacion, --> Registra el valor default de la tabla pr_estacion
			Capacidad = 0, --> 0
			Producto = 0, --> 0
			Diametro = 0, --> 0
			Altura = 0, --> 0
			Constante = 0, --> 0
			PctNoBombeable = 0, --> 0
			VolNoBombeable = 0, --> 0
			PctMaximo = 0, --> 0
			VolMaximo = 0, --> 0
			PorcentajeAgua = 0, --> 0
			ProductoAlmacenado = 0, --> 0
			IdTipoTanque = @IdTipoTanque, --> Registra el valor "Esférico" correspondiente en la tabla PR_TiposTanques
			MedicionManual = 0, --> 0
			PuntoEntregaID = NULL, --> NULL
			CreadoPor = @IdUsuario, --> Dato interno que no se muestra en pantalla
			CreadoEl = GETDATE(), --> Dato interno que no se muestra en pantalla
			Activo = @Activo
		WHERE Id = @Id
	END

	IF (ISNULL(@Id, 0) = 0)
	BEGIN
		INSERT INTO PR_Tanque (
			Clave, --> Clave que registra el usuario
			Nombre, --> Nombre que registra el usuario
			Descripcion, --> Nombre que registra el usuario
			Estatus, --> 1
			Estacion, --> Registra el valor default de la tabla pr_estacion
			Capacidad, --> 0
			Producto, --> 0
			Diametro, --> 0
			Altura, --> 0
			Constante, --> 0
			PctNoBombeable, --> 0
			VolNoBombeable, --> 0
			PctMaximo, --> 0
			VolMaximo, --> 0
			PorcentajeAgua, --> 0
			TIMESTAMP, --> NULL
			ProductoAlmacenado, --> 0
			IdTipoTanque, --> Registra el valor "Esférico" correspondiente en la tabla PR_TiposTanques
			MedicionManual, --> 0
			PuntoEntregaID, --> NULL
			ModificadoPor, --> Dato interno que no se muestra en pantalla
			ModificadoEl, --> Dato interno que no se muestra en pantalla
			Activo
			)
		SELECT LTRIM(RTRIM(@Clave)),
			LTRIM(RTRIM(@Nombre)),
			LTRIM(RTRIM(@Nombre)),
			1,
			@IdEstacion,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			NULL,
			0,
			@IdTipoTanque,
			0,
			NULL,
			@IdUsuario,
			GETDATE(),
			@Activo

		SELECT @IdTanque = SCOPE_IDENTITY()

		INSERT INTO PR_Tanque_Macropera (
			IdTanque,
			IdCampo
			)
		SELECT @IdTanque,
			@IdCampo
	END
END