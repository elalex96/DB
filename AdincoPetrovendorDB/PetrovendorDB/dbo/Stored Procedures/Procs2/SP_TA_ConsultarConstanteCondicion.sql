
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-17
-- Description:	Regresa las constantes de posibles condiciones para un flujo de Tarea 
			
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_TA_ConsultarConstanteCondicion] 
	-- Add the parameters for the stored procedure here
	@IdTipoOperacion int
	 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT  IdConstante,Nombre
	 FROM  TA_FlujoTareaConstante 
	 WHERE IdTipoOperacion =@IdTipoOperacion


END



