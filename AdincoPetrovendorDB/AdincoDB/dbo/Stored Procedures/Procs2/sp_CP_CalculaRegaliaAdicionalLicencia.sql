CREATE PROCEDURE [dbo].[sp_CP_CalculaRegaliaAdicionalLicencia] 
-- Add the parameters for the stored procedure here
@IdContrato INT  = 0,
@Periodo    DATE
AS
BEGIN
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 2017-01-01
-- Description:	Calcula valor de los hidrocarburos
--------------------------------------------------------
-- 20180626	BAAC	Se modifica para solo usar 2 decimales en el precio al calcular las contraprestaciones
--					para que el calculo coincida con el formato proporcionado por CNH
-- =============================================
    SET NOCOUNT ON
-- =============================================
    -- Insert statements for procedure here
	SELECT
		dbo.CO_TipoHidrocarburo.Hidrocarburo,
		ROUND(ISNULL(MCHM.Precio, 0),2)						AS Precio,
		--MCHM.Precio,
		ISNULL( MCHM.Volumen, 0 )                                             AS Volumen,
		--ISNULL( dbo.CP_MetodoCalculoHidrocarburoMes.Valor, 0 )                                               AS Valor,
		-- SE CALCULO EL VALOR DE LOS HIDROCARBUROS PARA QUE COINCIDA CON EL ARCHIVO DE CNH, QUE SOLO USA 2 DECIMALES EN EL PRECIO DEL HIDROCARBURO
		ISNULL(MCHM.Volumen, 0) * ROUND(ISNULL(MCHM.Precio, 0),2)          AS Valor,
		dbo.CO_Contrato.ValorRegaliaAdicional,
		(ISNULL(MCHM.Volumen, 0) * ROUND(ISNULL(MCHM.Precio, 0),2)) * (dbo.CO_Contrato.ValorRegaliaAdicional / 100) AS Regalia
	  FROM
		dbo.CP_MetodoCalculoHidrocarburoMes		MCHM
	 INNER JOIN
		dbo.CO_Contrato
		ON MCHM.IdContrato         = dbo.CO_Contrato.IdContrato
	 RIGHT OUTER JOIN
		dbo.CO_TipoHidrocarburo
		ON MCHM.IdTipoHidrocarburo = dbo.CO_TipoHidrocarburo.TipoHidrocarburo
	 WHERE
		(MCHM.IdContrato = @IdContrato)
	   AND (MCHM.Mes     = @Periodo)
END