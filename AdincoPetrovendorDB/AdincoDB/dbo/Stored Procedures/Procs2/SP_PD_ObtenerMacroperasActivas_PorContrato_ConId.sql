
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Creación:	02 de Marzo del 2023
-- Descripción:			Obtener macroperas por contrato activas e identificador por si la seleccionada es una inactiva
-- =============================================
CREATE PROCEDURE [dbo].[SP_PD_ObtenerMacroperasActivas_PorContrato_ConId]
	@ContratoId INT,
	@Id INT = 0
AS
BEGIN
	SELECT PD_Campo.IdCampo,
		LTRIM(RTRIM(PD_Campo.Clave)) AS Clave,
		LTRIM(RTRIM(PD_Campo.NombreCampo)) AS NombreCampo,
		CASE 
			WHEN ISNULL(PD_Campo.Activo, 0) = 0
				THEN 'Inactivo'
			ELSE 'Activo'
			END Activo
	FROM CO_AreaContractualYacimiento(NOLOCK)
	INNER JOIN CO_Contrato(NOLOCK) ON CO_AreaContractualYacimiento.IdAreaContractual = CO_Contrato.IdAreaContractual
	INNER JOIN PD_Campo(NOLOCK) ON CO_AreaContractualYacimiento.IdYacimiento = PD_Campo.IdYacimiento
	WHERE CO_Contrato.IdContrato = @ContratoId
		AND ISNULL(PD_Campo.Activo, 0) = 1
		OR PD_Campo.IdCampo = @Id
	GROUP BY PD_Campo.IdCampo,
		PD_Campo.Clave,
		PD_Campo.NombreCampo,
		PD_Campo.Activo
	ORDER BY PD_Campo.Activo,
		PD_Campo.NombreCampo
END