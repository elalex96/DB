CREATE PROCEDURE sp_CP_CalculaValorHidrocarburosLicencia 
	@IdContrato INT  = 0,
	@Periodo    DATE
AS
BEGIN
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 2017-01-01
-- Description:	Calcula valor de los hidrocarburos
-- =============================================
SET NOCOUNT ON
-- =============================================

SELECT
	dbo.CO_TipoHidrocarburo.Hidrocarburo, 
	--dbo.CP_MetodoCalculoHidrocarburoMes.Precio, 
	ROUND(ISNULL(CP_MetodoCalculoHidrocarburoMes.Precio, 0),2)	AS [Precio],
	ISNULL(dbo.CP_MetodoCalculoHidrocarburoMes.Volumen, 0) AS Volumen, 
    --ISNULL(dbo.CP_MetodoCalculoHidrocarburoMes.Valor, 0) AS Valor
	-- SE CALCULO EL VALOR DE LOS HIDROCARBUROS PARA QUE COINCIDA CON EL ARCHIVO DE CNH, QUE SOLO USA 2 DECIMALES EN EL PRECIO DEL HIDROCARBURO
	ISNULL(dbo.CP_MetodoCalculoHidrocarburoMes.Volumen, 0) * ROUND(ISNULL(CP_MetodoCalculoHidrocarburoMes.Precio, 0),2)          AS Valor
FROM
	dbo.CP_MetodoCalculoHidrocarburoMes 
RIGHT  JOIN
	dbo.CO_TipoHidrocarburo 
	ON dbo.CP_MetodoCalculoHidrocarburoMes.IdTipoHidrocarburo = dbo.CO_TipoHidrocarburo.TipoHidrocarburo
WHERE
	dbo.CP_MetodoCalculoHidrocarburoMes.IdContrato = @IdContrato
	AND dbo.CP_MetodoCalculoHidrocarburoMes.Mes = @Periodo
END