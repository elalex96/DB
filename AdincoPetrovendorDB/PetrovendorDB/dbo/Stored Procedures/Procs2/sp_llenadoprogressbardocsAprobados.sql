-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/05/2017>
-- Description:	<Procedimiento para insertar un documento en especidico(INE, RCF, ACTA CONSTITUTIVA) en la tabla S_Documento>
-- UPDATE DANIEL AC CAMBIO REFERENCIA DE S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
CREATE PROCEDURE[dbo].[sp_llenadoprogressbardocsAprobados] 
	-- Add the parameters for the stored procedure here
	@IdUsuario int,
	@IdProveedor int

AS
BEGIN
     
	 SELECT COUNT(IdDocumento) 
	 FROM S_Documento_S3
	 WHERE IdUsuario = @IdUsuario AND IdProveedor = @IdProveedor AND  IdTipoValidacionDocumento = 2;
	 
END