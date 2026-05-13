-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <12-06-2019>
-- Description:	<Actualizar la opcion de edicion de contenido nacional>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CN_ActualizarEdicionCNHabilitado] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@EdicionCN BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.S_Proveedor
	SET EdicionCN = @EdicionCN
	WHERE IdProveedor = @IdProveedor


	SELECT 'SUCCESS' AS RESPONSE
END
