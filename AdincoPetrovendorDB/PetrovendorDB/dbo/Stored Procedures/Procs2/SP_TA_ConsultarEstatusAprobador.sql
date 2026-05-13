
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 05-04-17
-- Description:	Regresa El IdEstatus de la Tarea del Aprobador
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_TA_ConsultarEstatusAprobador] 
	-- Add the parameters for the stored procedure here
	 @IdOperacion int,
	 @IdAprobador int
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT  IdEstatus
	 FROM TA_Tarea AS TA
	 INNER JOIN TA_TareaOperacion AS TTO ON TTO.IdTarea = TA.IdTarea
	 INNER JOIN TA_Operacion AS O ON O.IdOperacion = TTO.IdOperacion
	 WHERE TA.IdAprobador = @IdAprobador AND O.IdOperacion= @IdOperacion
	  

END



