CREATE PROCEDURE ObtenerYacimientosPorContrato @IdContrato INT
AS
BEGIN
	SELECT CO_Yacimiento.IdYacimiento, CO_Yacimiento.NombreYacimiento
	 FROM CO_AreaContractualYacimiento (NOLOCK)
	 INNER JOIN CO_Contrato (NOLOCK) ON CO_AreaContractualYacimiento.IdAreaContractual = CO_Contrato.IdAreaContractual
	 INNER JOIN CO_Yacimiento (NOLOCK) ON CO_AreaContractualYacimiento.IdYacimiento = CO_Yacimiento.IdYacimiento
	 WHERE CO_Contrato.IdContrato = @IdContrato
	 GROUP BY CO_Yacimiento.IdYacimiento, CO_Yacimiento.NombreYacimiento
	 ORDER BY CO_Yacimiento.NombreYacimiento
END




