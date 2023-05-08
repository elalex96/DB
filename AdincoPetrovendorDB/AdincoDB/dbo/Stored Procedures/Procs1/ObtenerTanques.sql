CREATE PROCEDURE ObtenerTanques @IdContrato INT
AS
BEGIN
		SELECT PR_Tanque.Id,
		LTRIM(RTRIM(PR_Tanque.Clave)) AS Clave,
		LTRIM(RTRIM(PR_Tanque.Nombre)) AS Nombre,
		PR_Tanque.Descripcion,
		PD_Campo.IdCampo,
		PD_Campo.IdCampo IdCampoMostrar,
		PR_Tanque.Activo,
		PD_Campo.NombreCampo
	FROM PR_Tanque(NOLOCK)
	LEFT JOIN PR_Tanque_Macropera(NOLOCK) ON PR_Tanque.Id = PR_Tanque_Macropera.IdTanque
	INNER JOIN PD_Campo(NOLOCK) ON PR_Tanque_Macropera.IdCampo = PD_Campo.IdCampo
	INNER JOIN CO_AreaContractualYacimiento(NOLOCK) ON PD_Campo.IdYacimiento = CO_AreaContractualYacimiento.IdYacimiento
	INNER JOIN CO_Contrato(NOLOCK) ON CO_AreaContractualYacimiento.IdAreaContractual = CO_Contrato.IdAreaContractual
	WHERE CO_Contrato.IdContrato = @IdContrato
	ORDER BY PR_Tanque.Id DESC
END



