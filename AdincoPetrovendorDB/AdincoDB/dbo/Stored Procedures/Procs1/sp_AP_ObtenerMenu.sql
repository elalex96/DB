-- =============================================
-- Author:		Oscar Mtz
-- Create date: 14/06/2017
-- Description:	Devuelve el listado de los elementos que integran el menu.
-- =============================================
CREATE PROCEDURE dbo.sp_AP_ObtenerMenu 	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [MenuId]
		  ,[MenuKey]
		  ,[Link]
		  ,[Texto]
		  ,[Titulo]
		  ,[CssClass]
		  ,[ImagenRuta]
		  ,[MenuKeyPadre]
		  ,[Tipo]
		  ,[CreadoPor]
	  FROM [dbo].[AP_Menu]
	  WHERE Visible=1;
END
