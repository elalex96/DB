
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PorcenDatosContacto] 
	-- Add the parameters for the stored procedure here
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Porcentaje int
	DECLARE @CANTCONTA INT

    SET @Porcentaje = 0
	SET @CANTCONTA = 0

	  DECLARE @VENTAS INT = (
					SELECT
					  COUNT(CASE SC.IdTipoContacto WHEN 1 THEN 'VENTAS' ELSE NULL END) AS VENTAS
					  FROM  S_Contacto_PA SC
					  WHERE SC.IdProveedor = @IdProveedor AND SC.IsEliminado = 0
						)
	IF @VENTAS > 0
	BEGIN
		SET @Porcentaje = @Porcentaje + 33
		SET @CANTCONTA = @CANTCONTA + 1
	END

	DECLARE @COMPRAS INT = (
					SELECT
					  COUNT(CASE SC.IdTipoContacto WHEN 3 THEN 'COMPRAS' ELSE NULL END) AS VENTAS
					  FROM  S_Contacto_PA SC
					  WHERE SC.IdProveedor = @IdProveedor AND SC.IsEliminado = 0
						)

	IF @COMPRAS > 0
	BEGIN
		SET @Porcentaje = @Porcentaje + 33
		SET @CANTCONTA = @CANTCONTA + 1
	END

	DECLARE @TESORERIA INT = (
					SELECT
					  COUNT(CASE SC.IdTipoContacto WHEN 4 THEN 'TESORERIA' ELSE NULL END) AS VENTAS
					  FROM  S_Contacto_PA SC
					  WHERE SC.IdProveedor = @IdProveedor AND SC.IsEliminado = 0
						)
	IF @TESORERIA > 0
	BEGIN
		SET @Porcentaje = @Porcentaje + 33
		SET @CANTCONTA = @CANTCONTA + 1
	END

	DECLARE @CONTACADD INT
	SET @CONTACADD = @CANTCONTA
	DECLARE @CONTACRES INT = (3 - @CANTCONTA)

	IF(@Porcentaje = 99)
	BEGIN
	SET @Porcentaje = 100
	END

	SELECT @Porcentaje AS Porcentaje, @VENTAS AS VENTAS, @COMPRAS AS COMPRAS, @TESORERIA AS TESORERIA,@CONTACADD AS CONTAADD, @CONTACRES AS CONTACRE

 -- DECLARE @VENTAS INT = (
	--				SELECT
	--				  COUNT(CASE SC.IdTipoContacto WHEN 1 THEN 'VENTAS' ELSE NULL END) AS VENTAS
	--				  FROM PV_ContratistaSubContratista AS CS
	--				  INNER JOIN S_Contacto_PA AS SC ON SC.IdProveedor = CS.IdRelacion
	--				  WHERE CS.IdContratista = 2205
	--					)
	--IF @VENTAS > 0
	--BEGIN
	--	SET @Porcentaje = @Porcentaje + 33
	--	SET @CANTCONTA = @CANTCONTA + 1
	--END

	--DECLARE @COMPRAS INT = (
	--				SELECT
	--				  COUNT(CASE SC.IdTipoContacto WHEN 3 THEN 'COMPRAS' ELSE NULL END) AS VENTAS
	--				  FROM PV_ContratistaSubContratista AS CS
	--				  INNER JOIN S_Contacto_PA AS SC ON SC.IdContratistaSubContratista = CS.IdRelacion
	--				  WHERE CS.IdContratista = @IdProveedor
	--					)

	--IF @COMPRAS > 0
	--BEGIN
	--	SET @Porcentaje = @Porcentaje + 33
	--	SET @CANTCONTA = @CANTCONTA + 1
	--END

	--DECLARE @TESORERIA INT = (
	--				SELECT
	--				  COUNT(CASE SC.IdTipoContacto WHEN 4 THEN 'TESORERIA' ELSE NULL END) AS VENTAS
	--				  FROM PV_ContratistaSubContratista AS CS
	--				  INNER JOIN S_Contacto_PA AS SC ON SC.IdContratistaSubContratista = CS.IdRelacion
	--				  WHERE CS.IdContratista = @IdProveedor
	--					)
	--IF @TESORERIA > 0
	--BEGIN
	--	SET @Porcentaje = @Porcentaje + 33
	--	SET @CANTCONTA = @CANTCONTA + 1
	--END

	--DECLARE @CONTACADD INT
	--SET @CONTACADD = @CANTCONTA
	--DECLARE @CONTACRES INT = (3 - @CANTCONTA)

	--SELECT @Porcentaje AS Porcentaje, @VENTAS AS VENTAS, @COMPRAS AS COMPRAS, @TESORERIA AS TESORERIA,@CONTACADD AS CONTAADD, @CONTACRES AS CONTACREST
END


