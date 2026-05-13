-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <26/05/2022>
-- Description:	<Consulta de solicitude de descarga de archivos de contract files pendientes>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_CF_ConsultaSolicitudesDescargaPendientes]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		IdSolicitud,
		ContratoId,
		SolicitadoPor,
		RutaDescargada
	FROM EN_CF_SolicitUDescargaCarpetas
	WHERE Procesado = 0
	
END
