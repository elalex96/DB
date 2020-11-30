-- =============================================
-- Author:		Manuel Cruz
-- Create date: 17-02-17
-- Description:	
-- =============================================
CREATE PROCEDURE SP_TaConsultaAprobadores 
	-- Add the parameters for the stored procedure here
	@IdTarea int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT U.Usuario, U.UsuarioID FROM TaTareaAprobador T 
	JOIN AP_Usuario U ON U.UsuarioID = T.IdUsuario 
	WHERE T.IdTarea = @IdTarea

END
