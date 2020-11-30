
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 27-03-17
-- Description:	Regresa los flujo de tarea por tipo de operacion
				
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarFlujosTareaXTipoOperacion] 
	-- Add the parameters for the stored procedure here
@IdTipoOperacion INT,
@IdProveedor     INT
AS
     BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdFlujoTarea,
                Concat(Nombre, ' - ', Descripcion) AS Descripcion
         FROM TA_FlujoTarea
         WHERE IdTipoOperacion = @IdTipoOperacion
               AND IdProveedor = @IdProveedor;
     END;
