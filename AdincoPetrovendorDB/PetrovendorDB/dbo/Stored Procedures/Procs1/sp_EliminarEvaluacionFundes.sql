---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <02/07/2017>
-- Description:	<Consulta la infomacion del documento>
-- =============================================
CREATE PROCEDURE [dbo].[sp_EliminarEvaluacionFundes]
	-- Add the parameters for the stored procedure here
	@IdEvaluacionFundes int

AS
BEGIN
     
	 UPDATE PV_FundesEvaluacion
	 SET Activo = 0
	 WHERE IdEvaluacionFundes = @IdEvaluacionFundes 
	 IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
	 
END



