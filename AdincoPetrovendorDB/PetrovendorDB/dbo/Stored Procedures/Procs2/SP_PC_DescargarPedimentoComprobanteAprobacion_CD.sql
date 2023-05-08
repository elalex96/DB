-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: 05/09/2020
-- Description:	<Consulta para descarga del pedimento comprobante>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_DescargarPedimentoComprobanteAprobacion_CD]
	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT,
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		NombreExtensionArchivo,
		'.pdf',
		'application/pdf',
		DocumentoByte
	FROM dbo.FI_Documento
	WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
END
