-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <12-06-2019>
-- Description:	<Actualizar la opcion de restriccion de cotizacion>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CN_ActualizarRestriccionCotizacion] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@Habilitado BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.S_Proveedor
	SET CotizacionesRestringidas = @Habilitado
	WHERE IdProveedor = @IdProveedor


	SELECT 'SUCCESS' AS RESPONSE
END
