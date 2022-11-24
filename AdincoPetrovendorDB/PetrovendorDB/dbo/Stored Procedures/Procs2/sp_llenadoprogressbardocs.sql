-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/05/2017>
-- Description:	<Procedimiento para insertar un documento en especidico(INE, RCF, ACTA CONSTITUTIVA) en la tabla S_Documento>
-- UPDATE DANIEL AC CAMBIO DE REFERENCIA S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
CREATE PROCEDURE[dbo].[sp_llenadoprogressbardocs] 
	-- Add the parameters for the stored procedure here
	@IdUsuario int,
	@IdProveedor int

AS
BEGIN
     
	 SELECT COUNT(IdDocumento) 
	 FROM dbo.S_Documento_S3 
	 WHERE IdUsuario = @IdUsuario AND IdProveedor = @IdProveedor AND Activo = 1;
	 
END