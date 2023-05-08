---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:	DANIEL AC
-- Create date: 26/04/2018
-- Description:	<Consulta la infomacion del documento>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarInfoDocumento_S3]
	-- Add the parameters for the stored procedure here
	@IdDocumento int
AS
BEGIN
     
	 SELECT D.IdDocumento, [IdTipoValidacionDoc],[TipoValidacion],TD.[NombreTipoDocumento],D.Documento, D.Carpeta, D.Identificador
	 FROM dbo.S_Documento_S3 D
	 INNER JOIN  [dbo].[S_TipoValidacionDoc] TVD
	 ON D.IdTipoValidacionDocumento = TVD.[IdTipoValidacionDoc]
	 INNER JOIN [dbo].[S_TipoDocumento] TD
	 ON D.IdTipoDocumento = TD.IdTipoDocumento
	 WHERE IdDocumento = @IdDocumento
	 
END