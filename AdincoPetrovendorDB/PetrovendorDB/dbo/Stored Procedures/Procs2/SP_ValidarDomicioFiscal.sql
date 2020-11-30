-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarDomicioFiscal]
@IdProveedor INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @UNICO INT 
	SET @UNICO = (SELECT COUNT(IdDomicilio) FROM DG_Domicilio WHERE IdTipoDomicilio = 1 AND IdProveedor = @IdProveedor AND Activo = 1)

	IF (@UNICO > 0)
	BEGIN
	SELECT 'DOMICILIO_EXISTENTE' 
	END
	ELSE
	BEGIN
	SELECT 'NUEVO_DOMICILIO'
	END

END

