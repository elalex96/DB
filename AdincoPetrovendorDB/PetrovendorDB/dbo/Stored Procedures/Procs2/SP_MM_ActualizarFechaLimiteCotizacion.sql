-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017
-- Description:	Actualizar la fecha de finalización de la cotizacion  
-- =============================================
CREATE PROCEDURE  [dbo].[SP_MM_ActualizarFechaLimiteCotizacion] 
	-- Add the parameters for the stored procedure here
		
	@IdOperacion int,
	@FechaLimiteCotizacion datetime
		 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 --declare @f datetime  = '2017-7-25 12:00'
	
	 
	--execute SP_MM_ActualizarFechaLimiteCotizacion 1295,  @f

	UPDATE TA_Operacion 
	SET FechaFinalizacion = @FechaLimiteCotizacion
	WHERE IdOperacion = @IdOperacion
	
	SELECT 'Operacion Actualizada'


END

