
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-17
-- Description:	consulta los correos
			
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_AD_ConsultarCorreo] 
	-- Add the parameters for the stored procedure here
	 
	
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	 SELECT IdCorreo,HTML,Asunto, C.Descripcion, IdServidor
	 FROM TA_Correo AS C
	 ORDER BY C.IdCorreo ASC

END

 