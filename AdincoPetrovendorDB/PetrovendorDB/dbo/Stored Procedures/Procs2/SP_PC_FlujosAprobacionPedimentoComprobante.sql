-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <08/09/2020>
-- Description:	<Consulta del flujo de aprobacion de pedimento/comprobante compra directa>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_FlujosAprobacionPedimentoComprobante]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		FT.IdFlujoTarea,
		FT.Nombre
	FROM dbo.TA_FlujoTarea AS FT
	WHERE FT.IdProveedor = @IdProveedor
		AND FT.IdTipoOperacion = 19
		AND FT.Activo = 1;

END
