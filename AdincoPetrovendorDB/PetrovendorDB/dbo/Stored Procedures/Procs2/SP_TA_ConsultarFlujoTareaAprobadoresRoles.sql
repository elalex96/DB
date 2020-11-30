
-- =============================================
-- Author:		Alexander G
-- Create date: 27-03-17
-- Description:	Regresa los aprobadores de un flujo de tareas con sus respectivos roles
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_TA_ConsultarFlujoTareaAprobadoresRoles] 
	-- Add the parameters for the stored procedure here
	 @IdFlujoTarea int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT A.IdUsuario, IdFlujoTarea, NoSecuencia, Nombre, Correo, TU.NombreTipoUsuario
	 FROM TA_Aprobador AS A
	 INNER JOIN S_Usuario AS U on U.IdUsuario = A.IdUsuario
	 INNER JOIN S_TipoUsuario AS TU ON TU.IdTipoUsuario = U.IdTipoUsuario
	 WHERE A.IdFlujoTarea = @IdFlujoTarea
	 ORDER BY  NoSecuencia ASC

END



