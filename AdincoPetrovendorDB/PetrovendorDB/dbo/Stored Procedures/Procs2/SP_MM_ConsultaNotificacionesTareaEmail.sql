-- =============================================
-- Author:		Daniel AC
-- Create date: 14-02-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaNotificacionesTareaEmail]
	-- Add the parameters for the stored procedure here
	@IdUsuario int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	---validar si existen tareas nuevas 
	SELECT count(Visto) AS NoTareas FROM TATAREA AS T
	INNER JOIN TaTipoTarea as TT ON T.IdTipoTarea=TT.IdTipoTarea  and TT.IdTipoTarea=1
	INNER JOIN TAOperacion as O on O.IdOperacion=T.IdOperacion
	INNER JOIN TaTareaAprobador AS TAU ON TAU.IdTarea=T.IdTarea
	INNER JOIN S_Usuario AS U ON U.IdUsuario = TAU.IdUsuario
	WHERE Visto = 0 AND U.IdUsuario= @IdUsuario  AND T.IdEstatus=1
   
END  
