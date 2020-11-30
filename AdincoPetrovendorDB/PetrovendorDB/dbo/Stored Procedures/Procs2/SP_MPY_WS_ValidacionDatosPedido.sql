-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09-07-2018
-- Description: Validar que los datos de un pedido que no existan mediante el webService
-- =============================================
CREATE procedure [dbo].[SP_MPY_WS_ValidacionDatosPedido]
	-- Add the parameters for the stored procedure here
	@IdProveedor NVARCHAR(20),
    @IdPedido NVARCHAR(20),
    @IdSubContratista NVARCHAR(20),
    @IdContrato NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE  @RESPONSE BIT = 1;
	DECLARE @COUNT INT = (SELECT COUNT(IdAceptacionPedido) FROM dbo.MPY_MM_AceptacionPedido 
								WHERE IdProveedor = @IdProveedor AND
										IdPedido = @IdPedido AND
										IdSubContratista = @IdSubContratista AND 
										IdContrato = @IdContrato);

	IF @COUNT > 0
	BEGIN
		SET @RESPONSE = 0;
	END

	SELECT @RESPONSE

END
