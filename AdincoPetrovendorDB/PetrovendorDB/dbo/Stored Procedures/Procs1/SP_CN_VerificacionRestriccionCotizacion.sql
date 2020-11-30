-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <12-06-2019>
-- Description:	<Consula para verificar que el proveedor tiene hablitada la restriccion de cotizacion
-- =============================================
CREATE PROCEDURE [dbo].[SP_CN_VerificacionRestriccionCotizacion] --420
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @RESPONSE BIT = (SELECT CotizacionesRestringidas FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);

	SELECT ISNULL(@RESPONSE,0) AS RESPONSE

END
