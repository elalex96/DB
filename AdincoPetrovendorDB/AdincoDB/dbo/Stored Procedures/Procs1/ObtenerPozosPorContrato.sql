CREATE PROCEDURE ObtenerPozosPorContrato 
@IdContrato INT
AS
BEGIN
	SELECT CO_Instalacion.IdInstalacion,
		LTRIM(RTRIM(CO_Instalacion.NombreInstalacion)) AS NombreInstalacion,
		LTRIM(RTRIM(CO_Instalacion.NombreInstalacionAlterno)) AS NombreInstalacionAlterno,
		CO_Instalacion.IdCampo,
		CO_Instalacion.IdCampo IdCampoMostrar,
		CO_Instalacion.IdCatalogoSCIEP,
		ISNULL(CO_Instalacion.Activo, 0) Activo,
		CO_Instalacion.WelIID, 
		PD_Campo.NombreCampo
	FROM CO_Instalacion(NOLOCK)
	INNER JOIN CO_Contrato(NOLOCK) 
	ON CO_Instalacion.IdAreaContractual = CO_Contrato.IdAreaContractual
	AND CO_Instalacion.IdActividad = 5
	AND CO_Contrato.IdContrato = @IdContrato
	INNER JOIN PD_Campo (NOLOCK) ON CO_Instalacion.IdCampo = PD_Campo.IdCampo
	WHERE CO_Contrato.IdContrato = @IdContrato
	GROUP BY CO_Instalacion.IdInstalacion,
		CO_Instalacion.NombreInstalacion,
		CO_Instalacion.NombreInstalacionAlterno,
		CO_Instalacion.IdCampo,
		CO_Instalacion.IdCatalogoSCIEP,
		ISNULL(CO_Instalacion.Activo, 0),
		CO_Instalacion.WelIID, 
		PD_Campo.NombreCampo
	ORDER BY CO_Instalacion.IdInstalacion DESC
END