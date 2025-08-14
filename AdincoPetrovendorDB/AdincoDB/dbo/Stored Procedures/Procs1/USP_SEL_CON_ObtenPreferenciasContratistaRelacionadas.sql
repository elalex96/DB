IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE name = 'USP_SEL_CON_ObtenPreferenciasContratistaRelacionadas'
		)
	DROP PROCEDURE USP_SEL_CON_ObtenPreferenciasContratistaRelacionadas;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CON_ObtenPreferenciasContratistaRelacionadas] 
	@IdUsuario INT = 0
	,@IdContrato INT = 0
	,@IdContratista INT
AS
BEGIN
	SELECT CON_ContratistaPreferencias.Id
		,APP_Preferencias.Nombre AS Nombre
		,APP_Preferencias.Descripcion
		,ISNULL(APP_Preferencias.RequiereValor, 0) AS RequiereValor
		,CON_ContratistaPreferencias.Valor
		,ISNULL(AP_Usuario.Nombre, '') AS CreadoPor
		,CON_ContratistaPreferencias.CreadoEl
		,ISNULL(AP_UsuarioMod.Nombre, '') AS ModificadoPor
		,CON_ContratistaPreferencias.ModificadoEl
	FROM CON_ContratistaPreferencias WITH (NOLOCK)
	JOIN CO_Contratista WITH (NOLOCK) ON CON_ContratistaPreferencias.ContratistaId = CO_Contratista.IdContratista
	JOIN APP_Preferencias WITH (NOLOCK) ON CON_ContratistaPreferencias.PreferenciaId = APP_Preferencias.Id
	LEFT JOIN AP_Usuario WITH (NOLOCK) ON CON_ContratistaPreferencias.CreadoPor = AP_Usuario.UsuarioID
	LEFT JOIN AP_Usuario AS AP_UsuarioMod WITH (NOLOCK) ON CON_ContratistaPreferencias.ModificadoPor = AP_UsuarioMod.UsuarioID
	WHERE CON_ContratistaPreferencias.ContratistaId = @IdContratista
	GROUP BY CON_ContratistaPreferencias.Id
		,APP_Preferencias.Nombre
		,APP_Preferencias.Descripcion
		,APP_Preferencias.RequiereValor
		,CON_ContratistaPreferencias.Valor
		,AP_Usuario.Nombre
		,CON_ContratistaPreferencias.CreadoEl
		,AP_UsuarioMod.Nombre
		,CON_ContratistaPreferencias.ModificadoEl
	ORDER BY APP_Preferencias.Nombre ASC;
END;