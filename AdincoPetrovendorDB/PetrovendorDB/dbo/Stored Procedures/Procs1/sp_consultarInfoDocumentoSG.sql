---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <02/07/2017>
-- Description:	<Consulta la infomacion del documento>
-- =============================================
-- =============================================
-- Author:           Daniel AC
-- Create date: 26-09-2019
-- Description: Add parametros de referencia al s3
-- =============================================
CREATE  PROCEDURE [dbo].[sp_consultarInfoDocumentoSG]
	-- Add the parameters for the stored procedure here
	@IdDoc int
AS
BEGIN     
	 SELECT SG.IdSistemaGestion, DSG.DocSistemaGestion, SG.NombreCertificacion, '', Activo, SG.Carpeta, SG.Mime, SG.Extension, SG.Identificador, Bucket
	 FROM PV_SistemaGestion SG
	 INNER JOIN PV_DocSistemGestion AS DSG ON DSG.IdDocSistemaGestion = SG.IdTipoDocSG
	 WHERE SG.IdSistemaGestion = @IdDoc	 
END



