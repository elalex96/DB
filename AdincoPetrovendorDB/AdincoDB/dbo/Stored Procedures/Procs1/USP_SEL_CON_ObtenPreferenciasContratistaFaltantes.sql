IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE name = 'USP_SEL_CON_ObtenPreferenciasContratistaFaltantes'
		)
	DROP PROCEDURE USP_SEL_CON_ObtenPreferenciasContratistaFaltantes;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CON_ObtenPreferenciasContratistaFaltantes]
	@IdUsuario INT = 0
	,@IdContrato INT = 0
	,@IdContratista INT
AS
BEGIN
	SELECT APP_Preferencias.Id
		,APP_Preferencias.Nombre
		,APP_Preferencias.Descripcion
		,ISNULL(APP_Preferencias.RequiereValor, 0) AS RequiereValor
		,'' AS Valor
	FROM APP_Preferencias WITH (NOLOCK)
	LEFT JOIN CON_ContratistaPreferencias WITH (NOLOCK) ON APP_Preferencias.Id = CON_ContratistaPreferencias.PreferenciaId
		AND CON_ContratistaPreferencias.ContratistaId = @IdContratista
	WHERE ISNULL(APP_Preferencias.EsDeContratista, 0) = 1
		AND CON_ContratistaPreferencias.Id IS NULL
	GROUP BY APP_Preferencias.Id
		,APP_Preferencias.Nombre
		,APP_Preferencias.Descripcion
		,ISNULL(APP_Preferencias.RequiereValor, 0)
	ORDER BY APP_Preferencias.Nombre ASC;
END;