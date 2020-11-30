-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/11/2018
-- Description:	Consulta los datos de un documento de soporte de la PRESES para descargarlo
-- =============================================
CREATE procedure [dbo].[SP_MPY_DatosDocSoportePRESE] 
	-- Add the parameters for the stored procedure here
	@IdDocumentoSoporte INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		DOC.NombreDoc,
		DOC.Extension,
		DOC.Mime,
		DOC.Identificador,
		DOC.Carpeta
	FROM Adinco.dbo.MPY_DocumentosPRESES AS DOC
	WHERE DOC.IdDocumento = @IdDocumentoSoporte
END
