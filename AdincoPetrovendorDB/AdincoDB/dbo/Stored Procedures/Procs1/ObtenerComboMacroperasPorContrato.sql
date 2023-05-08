CREATE PROCEDURE ObtenerComboMacroperasPorContrato @IdContrato INT
AS
BEGIN
	SELECT PD_Campo.IdCampo, PD_Campo.Clave, PD_Campo.NombreCampo, ISNULL(PD_Campo.Activo, 0) Activo
	 FROM CO_AreaContractualYacimiento (NOLOCK)
	 INNER JOIN CO_Contrato (NOLOCK) ON CO_Contrato.IdContrato = @IdContrato
		AND CO_AreaContractualYacimiento.IdAreaContractual = CO_Contrato.IdAreaContractual
	 INNER JOIN PD_Campo (NOLOCK) ON CO_AreaContractualYacimiento.IdYacimiento = PD_Campo.IdYacimiento
	 WHERE CO_Contrato.IdContrato = @IdContrato
	 GROUP BY PD_Campo.IdCampo, PD_Campo.Clave, PD_Campo.NombreCampo, PD_Campo.Activo
	 ORDER BY PD_Campo.NombreCampo
END
