-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <02/06/2017>
-- Description:	<Procedimiento para consultar el estatus de validacion de algun documento>
-- UPDATE DANIEL AC CAMBIO DE REFERENCIA S_DOCUMENTO A S_DOCUMENTO_S3 08/05/2018
-- =============================================
CREATE PROCEDURE[dbo].[sp_consultarEstatusDocumentos] 
	-- Add the parameters for the stored procedure here	
	@IdUsuario int,
	@IdProveedor int

AS
BEGIN
     
	 SELECT IdDocumento , IdTipoValidacionDocumento
	 FROM S_Documento_S3 
	 WHERE IdUsuario = @IdUsuario AND IdProveedor = @IdProveedor AND Activo = 1; 
	 
END