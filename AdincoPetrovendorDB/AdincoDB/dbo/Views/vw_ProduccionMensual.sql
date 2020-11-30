CREATE VIEW dbo.vw_ProduccionMensual
AS
	SELECT
		IdContrato,
		IdFecha,
		IdTipoHidrocarburo,
		SUM(VolumenProducido)	AS [VolumenProducido],
		SUM(VolumenVendido)		AS [VolumenVendido],
		idUnidadMedida
	FROM
		PR_ProduccionMensualPtoEntrega
	GROUP BY
		IdContrato,
		IdFecha,
		IdTipoHidrocarburo,
		idUnidadMedida