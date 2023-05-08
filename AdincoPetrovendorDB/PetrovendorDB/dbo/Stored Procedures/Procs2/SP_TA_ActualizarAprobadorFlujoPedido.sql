-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 11/09/2017
-- Description:	Eliminar flujo de aprobación de pedido 
-- =============================================
create  PROCEDURE  [dbo].[SP_TA_ActualizarAprobadorFlujoPedido] 
-- Add the parameters for the stored procedure here
 @Aprobador int, 
 @IdFlujoTarea int,
 @NoSecuencia int,
 @IdAprobador int
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
    -- Insert statements for procedure here
	UPDATE TA_Aprobador
  SET IdUsuario = @Aprobador
  WHERE IdFlujoTarea = @IdFlujoTarea AND NoSecuencia = @NoSecuencia
END

