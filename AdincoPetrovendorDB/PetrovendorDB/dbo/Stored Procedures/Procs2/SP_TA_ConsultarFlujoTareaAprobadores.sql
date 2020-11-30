-- =============================================
-- Author:		Daniel Cruz
-- Create date: 27-03-17
-- Description:	Regresa los aprobadores de un flujo de tarea				
-- =============================================
-- Author:		Jose Roman
-- Create date: 16-08-2018
-- Description:	Se agrega la consulta del telefono				
-- =============================================
	CREATE  PROCEDURE SP_TA_ConsultarFlujoTareaAprobadores
	-- Add the parameters for the stored procedure here
	 @IdFlujoTarea int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT A.IdUsuario, IdFlujoTarea, NoSecuencia, Nombre, Correo, ISNULL(U.Telefono, '')
	 FROM TA_Aprobador AS A
	 INNER JOIN S_Usuario AS U on U.IdUsuario = A.IdUsuario
	 WHERE A.IdFlujoTarea = @IdFlujoTarea
	 ORDER BY  NoSecuencia ASC

END