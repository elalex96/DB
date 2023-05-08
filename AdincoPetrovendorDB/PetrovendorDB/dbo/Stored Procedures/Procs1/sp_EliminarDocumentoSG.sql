---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <02/07/2017>
-- Description:	<Consulta la infomacion del documento>
-- =============================================
CREATE PROCEDURE [dbo].[sp_EliminarDocumentoSG]
	-- Add the parameters for the stored procedure here
	@IdSistemaGestion int

AS
BEGIN
     
	 UPDATE PV_SistemaGestion
	 SET Activo = 0
	 WHERE IdSistemaGestion = @IdSistemaGestion 
	 IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
	 
END



