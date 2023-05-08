
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-17
-- Description:	consulta los correos
			
-- =============================================
CREATE  PROCEDURE [dbo].[SP_AD_ActualizarCorreo] 
	-- Add the parameters for the stored procedure here
	 	@IdCorreo INT,
		@Asunto NVARCHAR(500),
		@Descripcion NVARCHAR(500),
		@HTML NVARCHAR(MAX),
		@IdServidor INT
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here

	UPDATE dbo.TA_Correo
	SET HTML=@HTML,
	Asunto=@Asunto, 
	Descripcion=@Descripcion, 
	IdServidor=@IdServidor
	WHERE IdCorreo=@IdCorreo
	 

END

 