-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <03/07/2020>
-- Description:	<Verificacion de que la operadora ya tenga un flujo de aprobacion de documento>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DOC_ValidarFlujoAprobacionDocumento] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IDFLUJOAPROBACION INT = (SELECT TOP 1 IdFlujoTarea FROM dbo.TA_FlujoTarea WHERE IdTipoOperacion = 18 AND Activo = 1 AND Predeterminado = 1 AND IdProveedor = @IdProveedor);

	IF ISNULL(@IDFLUJOAPROBACION,0) <> 0
	BEGIN
	    
		SELECT 'SUCCESS'

	END
	ELSE
	BEGIN

		SELECT 'SIN FLUJO DE DOCUMENTOS'
		
	END

END
