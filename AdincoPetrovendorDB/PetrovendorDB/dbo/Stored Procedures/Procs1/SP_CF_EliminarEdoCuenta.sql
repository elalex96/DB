-- =============================================
-- Author:           Daniel AC
-- Create date: 13-08-2019
-- Description: Cambie el eliminado fisico a logico
-- =============================================
CREATE PROCEDURE [dbo].[SP_CF_EliminarEdoCuenta]
	@IdEdoCuenta int
AS
BEGIN    
	UPDATE CF_EdoCuentaDocumentos 
	SET isEliminado=1	
	WHERE IdEdoCuenta = @IdEdoCuenta
END