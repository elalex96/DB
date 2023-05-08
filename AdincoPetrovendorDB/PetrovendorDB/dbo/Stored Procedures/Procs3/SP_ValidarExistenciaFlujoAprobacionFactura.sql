-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarExistenciaFlujoAprobacionFactura]
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @EXISTE INT = (SELECT COUNT(IdFlujoTarea) FROM dbo.TA_FlujoTarea WHERE IdProveedor = @IdProveedor /*AND Predeterminado = 1*/ AND IdTipoOperacion = 10)
	IF (@EXISTE > 0)
	BEGIN
	SELECT 'EXISTE'
	END
	ELSE
	BEGIN
	SELECT 'NO_TIENE_FLUJOS'
	END

END
