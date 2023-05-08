---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <02/07/2017>
-- Description:	<Consulta la infomacion del documento>
-- =============================================
-- =============================================
-- Author:           Daniel AC
-- Create date: 26-09-2019
-- Description: Cambie la columna de Documento a ''
-- =============================================
CREATE  PROCEDURE [dbo].[sp_consultarInfoDocsSG]
	-- Add the parameters for the stored procedure here
	@IdDocs int,
	@IdProvedor int
AS
BEGIN
     
	 SELECT  SG.IdSistemaGestion, DSG.DocSistemaGestion AS DocSistemaGestion, SG.NombreCertificacion,'' AS Documento , Activo
	 FROM PV_SistemaGestion SG
	 INNER JOIN PV_DocSistemGestion AS DSG ON DSG.IdDocSistemaGestion = SG.IdTipoDocSG
	 WHERE SG.IdTipoDocSG = @IdDocs AND SG.IdProveedor = @IdProvedor AND SG.Activo = 1	 
END
