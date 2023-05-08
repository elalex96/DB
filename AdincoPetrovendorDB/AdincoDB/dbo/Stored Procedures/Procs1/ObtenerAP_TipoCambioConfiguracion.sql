CREATE PROCEDURE [dbo].[ObtenerAP_TipoCambioConfiguracion]
AS
BEGIN
	SELECT	 [Hora]
			,[Url]
			,[FrecuenciaDia]
	FROM [dbo].[AP_TipoCambioConfiguracion]
END