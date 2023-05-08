
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Edición:	02 de Marzo del 2023
-- Descripción:			Se agregan LTRIM y RTRIM correspondientes
-- =============================================
CREATE PROCEDURE [dbo].[ObtenerMacroperasPorContrato] @IdContrato INT
AS
BEGIN
	SELECT PD_Campo.IdCampo,
		LTRIM(RTRIM(PD_Campo.Clave)) AS Clave,
		LTRIM(RTRIM(PD_Campo.NombreCampo)) AS NombreCampo,
		PD_Campo.IdYacimiento,
		ISNULL(PD_Campo.Activo, 0) Activo
	FROM CO_AreaContractualYacimiento(NOLOCK)
	INNER JOIN CO_Contrato(NOLOCK) ON CO_Contrato.IdContrato = @IdContrato
		AND CO_AreaContractualYacimiento.IdAreaContractual = CO_Contrato.IdAreaContractual
	INNER JOIN PD_Campo(NOLOCK) ON CO_AreaContractualYacimiento.IdYacimiento = PD_Campo.IdYacimiento
	WHERE CO_Contrato.IdContrato = @IdContrato
	GROUP BY PD_Campo.IdCampo,
		PD_Campo.Clave,
		PD_Campo.NombreCampo,
		PD_Campo.IdYacimiento,
		PD_Campo.Activo
	ORDER BY PD_Campo.IdCampo DESC
END