
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-17
-- Description:	Regresa el Grupo de Operacion
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_TA_ConsultarTipoOperacion] 
	-- Add the parameters for the stored procedure here
	 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT TTO.IdTipoOperacion, TTO.NombreOperacion
	 FROM TA_TipoOperacion AS TTO
	 WHERE TTO.IdTipoOperacion=2

END



