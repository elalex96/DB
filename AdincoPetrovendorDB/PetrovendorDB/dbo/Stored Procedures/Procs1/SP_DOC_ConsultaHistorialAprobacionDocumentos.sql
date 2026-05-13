-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <27/07/2020>
-- Description:	<Consulta de historial de aprobacion de los documentos solicitados al proveedor>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DOC_ConsultaHistorialAprobacionDocumentos] --4
	-- Add the parameters for the stored procedure here
	@IdAceptacionDocumento INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT
		HFT.IdHistorial,
		HFT.Descripcion,
		HFT.Fecha
	FROM dbo.TA_HistorialFlujoTarea AS HFT
		LEFT JOIN dbo.TA_Operacion AS OP
			ON OP.IdOperacion = HFT.IdOperacion
			AND OP.IdTipoOperacion = 18
		LEFT JOIN dbo.MM_AceptacionDocumento_Proveedor AS ADP
			ON ADP.IdAceptacionDocumento = OP.IdDocumento
	WHERE ADP.IdAceptacionDocumento = @IdAceptacionDocumento
	GROUP BY HFT.IdHistorial,
             HFT.Descripcion,
             HFT.Fecha
	ORDER BY HFT.Fecha ASC;
	
END
