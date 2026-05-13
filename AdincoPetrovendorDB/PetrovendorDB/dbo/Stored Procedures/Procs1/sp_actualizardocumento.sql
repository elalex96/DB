-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/05/2017>
-- Description:	<Procedimiento para insertar un documento en especidico(INE, RCF, ACTA CONSTITUTIVA) en la tabla S_Documento>
-- DANIEL 08/05/2018 UPDATE REFERENCIAS S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
CREATE PROCEDURE[dbo].[sp_actualizardocumento] 
	-- Add the parameters for the stored procedure here
	@IdTipoDocumento int,
	@IdUsuario int,
	@IdProveedor int

AS
	DECLARE @idDocumento int;
BEGIN
	 SET @idDocumento = (SELECT IdDocumento FROM dbo.S_Documento_S3
	 WHERE IdUsuario = @IdUsuario AND IdProveedor = @IdProveedor AND IdTipoDocumento = @IdTipoDocumento AND IdTipoValidacionDocumento = 3);
	 IF @idDocumento > 0
	 BEGIN
	 UPDATE dbo.S_Documento_S3 SET Activo = 0 WHERE IdDocumento = @idDocumento;
	 END
END