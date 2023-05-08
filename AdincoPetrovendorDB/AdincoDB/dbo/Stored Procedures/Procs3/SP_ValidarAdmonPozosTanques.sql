-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Creación:	01 de Marzo del 2023
-- Descripción:			Validaciones de los campos por tipo de grid en la pantalla de AdmonPozosTanques
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarAdmonPozosTanques] 
	@Id INT = 0,
	@Tipo VARCHAR(100),
	@ContratoId INT = 0,
	@UsuarioId INT = 0,
	@Clave VARCHAR(500),
	@NombreCampo VARCHAR(500),
	@NombreInstalacion VARCHAR(500),
	@NombreInstalacionAlterno VARCHAR(500),
	@Nombre VARCHAR(500),
	@NombreUnidad VARCHAR(500),
	@NombreSistema VARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Mensaje VARCHAR(100) = 'VALIDO';

	IF (@Tipo = 'GridMacropera')
	BEGIN
		IF EXISTS (
				SELECT TOP 1 PD_Campo.IdCampo,
					PD_Campo.Clave,
					PD_Campo.NombreCampo,
					PD_Campo.IdYacimiento,
					ISNULL(PD_Campo.Activo, 0) Activo
				FROM CO_AreaContractualYacimiento(NOLOCK)
				INNER JOIN CO_Contrato(NOLOCK) ON CO_Contrato.IdContrato = @ContratoId
					AND CO_AreaContractualYacimiento.IdAreaContractual = CO_Contrato.IdAreaContractual
				INNER JOIN PD_Campo(NOLOCK) ON CO_AreaContractualYacimiento.IdYacimiento = PD_Campo.IdYacimiento
				WHERE CO_Contrato.IdContrato = @ContratoId
					AND UPPER(LTRIM(RTRIM(PD_Campo.Clave))) = UPPER(LTRIM(RTRIM(@Clave)))
					AND PD_Campo.IdCampo <> @Id
				GROUP BY PD_Campo.IdCampo,
					PD_Campo.Clave,
					PD_Campo.NombreCampo,
					PD_Campo.IdYacimiento,
					PD_Campo.Activo
				)
		BEGIN
			SET @Mensaje = ('NO_VALIDO_MACROPERA_CLAVE')
		END

		IF EXISTS (
				SELECT TOP 1 PD_Campo.IdCampo,
					PD_Campo.Clave,
					PD_Campo.NombreCampo,
					PD_Campo.IdYacimiento,
					ISNULL(PD_Campo.Activo, 0) Activo
				FROM CO_AreaContractualYacimiento(NOLOCK)
				INNER JOIN CO_Contrato(NOLOCK) ON CO_Contrato.IdContrato = @ContratoId
					AND CO_AreaContractualYacimiento.IdAreaContractual = CO_Contrato.IdAreaContractual
				INNER JOIN PD_Campo(NOLOCK) ON CO_AreaContractualYacimiento.IdYacimiento = PD_Campo.IdYacimiento
				WHERE CO_Contrato.IdContrato = @ContratoId
					AND UPPER(LTRIM(RTRIM(PD_Campo.NombreCampo))) = UPPER(LTRIM(RTRIM(@NombreCampo)))
					AND PD_Campo.IdCampo <> @Id
				GROUP BY PD_Campo.IdCampo,
					PD_Campo.Clave,
					PD_Campo.NombreCampo,
					PD_Campo.IdYacimiento,
					PD_Campo.Activo
				)
		BEGIN
			IF (@Mensaje = 'VALIDO')
			BEGIN
				SET @Mensaje = ('NO_VALIDO_MACROPERA_NOMBRE')
			END
			ELSE
			BEGIN
				SET @Mensaje = ('NO_VALIDO_MACROPERA_CLAVE_NOMBRE')
			END
		END
	END;

	IF (@Tipo = 'GridPozos')
	BEGIN
		IF EXISTS (
				SELECT TOP 1 CO_Instalacion.IdInstalacion,
					CO_Instalacion.NombreInstalacion,
					CO_Instalacion.NombreInstalacionAlterno,
					CO_Instalacion.IdCampo,
					CO_Instalacion.IdCatalogoSCIEP,
					ISNULL(CO_Instalacion.Activo, 0) Activo
				FROM CO_Instalacion(NOLOCK)
				INNER JOIN CO_Contrato(NOLOCK) 
					ON CO_Instalacion.IdAreaContractual = CO_Contrato.IdAreaContractual
					AND CO_Instalacion.IdActividad = 5
				WHERE CO_Contrato.IdContrato = @ContratoId
					AND UPPER(LTRIM(RTRIM(CO_Instalacion.NombreInstalacion))) = UPPER(LTRIM(RTRIM(@NombreInstalacion)))
					AND CO_Instalacion.IdInstalacion <> @Id
				GROUP BY CO_Instalacion.IdInstalacion,
					CO_Instalacion.NombreInstalacion,
					CO_Instalacion.NombreInstalacionAlterno,
					CO_Instalacion.IdCampo,
					CO_Instalacion.IdCatalogoSCIEP,
					ISNULL(CO_Instalacion.Activo, 0)
				)
		BEGIN
			SET @Mensaje = ('NO_VALIDO_POZO_INSTALACION')
		END

		IF EXISTS (
				SELECT TOP 1 CO_Instalacion.IdInstalacion,
					CO_Instalacion.NombreInstalacion,
					CO_Instalacion.NombreInstalacionAlterno,
					CO_Instalacion.IdCampo,
					CO_Instalacion.IdCatalogoSCIEP,
					ISNULL(CO_Instalacion.Activo, 0) Activo
				FROM CO_Instalacion(NOLOCK)
				INNER JOIN CO_Contrato(NOLOCK) 
					ON CO_Instalacion.IdAreaContractual = CO_Contrato.IdAreaContractual
					AND CO_Instalacion.IdActividad = 5
				WHERE CO_Contrato.IdContrato = @ContratoId
					AND UPPER(LTRIM(RTRIM(CO_Instalacion.NombreInstalacionAlterno))) = UPPER(LTRIM(RTRIM(@NombreInstalacionAlterno)))
					AND CO_Instalacion.IdInstalacion <> @Id
				GROUP BY CO_Instalacion.IdInstalacion,
					CO_Instalacion.NombreInstalacion,
					CO_Instalacion.NombreInstalacionAlterno,
					CO_Instalacion.IdCampo,
					CO_Instalacion.IdCatalogoSCIEP,
					ISNULL(CO_Instalacion.Activo, 0)
				)
		BEGIN
			IF (@Mensaje = 'VALIDO')
			BEGIN
				SET @Mensaje = ('NO_VALIDO_POZO_INSTALACIONALTERNO')
			END
			ELSE
			BEGIN
				SET @Mensaje = ('NO_VALIDO_POZO_INSTALACION_INSTALACIONALTERNO')
			END
		END
	END;

	IF (@Tipo = 'GridTanques')
	BEGIN
		IF EXISTS (
				SELECT TOP 1 *
				FROM PR_Tanque(NOLOCK)
				LEFT JOIN PR_Tanque_Macropera(NOLOCK) ON PR_Tanque.Id = PR_Tanque_Macropera.IdTanque
				INNER JOIN PD_Campo(NOLOCK) ON PR_Tanque_Macropera.IdCampo = PD_Campo.IdCampo
				INNER JOIN CO_AreaContractualYacimiento(NOLOCK) ON PD_Campo.IdYacimiento = CO_AreaContractualYacimiento.IdYacimiento
				INNER JOIN CO_Contrato(NOLOCK) ON CO_AreaContractualYacimiento.IdAreaContractual = CO_Contrato.IdAreaContractual
				WHERE CO_Contrato.IdContrato = @ContratoId
					AND UPPER(LTRIM(RTRIM(PR_Tanque.Clave))) = UPPER(LTRIM(RTRIM(@Clave)))
					AND PR_Tanque.Id <> @Id
				)
		BEGIN
			SET @Mensaje = ('NO_VALIDO_TANQUE_CLAVE')
		END

		IF EXISTS (
				SELECT TOP 1 *
				FROM PR_Tanque(NOLOCK)
				LEFT JOIN PR_Tanque_Macropera(NOLOCK) ON PR_Tanque.Id = PR_Tanque_Macropera.IdTanque
				INNER JOIN PD_Campo(NOLOCK) ON PR_Tanque_Macropera.IdCampo = PD_Campo.IdCampo
				INNER JOIN CO_AreaContractualYacimiento(NOLOCK) ON PD_Campo.IdYacimiento = CO_AreaContractualYacimiento.IdYacimiento
				INNER JOIN CO_Contrato(NOLOCK) ON CO_AreaContractualYacimiento.IdAreaContractual = CO_Contrato.IdAreaContractual
				WHERE CO_Contrato.IdContrato = @ContratoId
					AND UPPER(LTRIM(RTRIM(PR_Tanque.Nombre))) = UPPER(LTRIM(RTRIM(@Nombre)))
					AND PR_Tanque.Id <> @Id
				)
		BEGIN
			IF (@Mensaje = 'VALIDO')
			BEGIN
				SET @Mensaje = ('NO_VALIDO_TANQUE_NOMBRE')
			END
			ELSE
			BEGIN
				SET @Mensaje = ('NO_VALIDO_TANQUE_CLAVE_NOMBRE')
			END
		END
	END;

	IF (@Tipo = 'GridUnidades')
	BEGIN
		IF EXISTS (
				SELECT TOP 1 *
				FROM PR_Unidades(NOLOCK)
				WHERE UPPER(LTRIM(RTRIM(NombreUnidad))) = UPPER(LTRIM(RTRIM(@NombreUnidad)))
					AND IdUnidad <> @Id
				)
		BEGIN
			SET @Mensaje = ('NO_VALIDO_NOMBRE_UNIDAD')
		END
	END;

	IF (@Tipo = 'GridSistemas')
	BEGIN
		IF EXISTS (
				SELECT TOP 1 *
				FROM PR_Sistemas(NOLOCK)
				WHERE UPPER(LTRIM(RTRIM(NombreSistema))) = UPPER(LTRIM(RTRIM(@NombreSistema)))
					AND IdSistema <> @Id
				)
		BEGIN
			SET @Mensaje = ('NO_VALIDO_NOMBRE_SISTEMA')
		END
	END;

	SELECT @Mensaje AS 'MENSAJE';
END
