
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 04-09-2019
-- Description:	Regresa los aprobadores de un flujo de tarea de factura que estan activos		
-- =============================================
	
CREATE PROCEDURE SP_TA_ConsultarFlujoTareaAprobadoresREFactura
	-- Add the parameters for the stored procedure here
	 @IdOperacion int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT T.IdAprobador, O.IdFlujoTarea, T.NoSecuencia, U.Nombre, U.Correo, ISNULL(U.Telefono, '')
	 FROM dbo.TA_Tarea AS T
	 INNER JOIN dbo.TA_Operacion O ON O.IdOperacion=T.IdOperacion
	 INNER JOIN S_Usuario AS U on U.IdUsuario = T.IdAprobador
	 WHERE T.IdOperacion = @IdOperacion
	 AND T.Activo=1
	 ORDER BY  NoSecuencia ASC

END

