CREATE procedure [dbo].[SP_Correo_ConsultaCorreo]
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	
 SELECT IdCorreo,HTML,Asunto, C.Descripcion, IdServidor
	 FROM [dbo].[TA_Correo] AS C
	 ORDER BY C.IdCorreo ASC

END