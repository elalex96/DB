-- =============================================
-- Author:		Reyna Olvera
-- Create date: 11/01/2018
-- Description:Extrae lista de menu
-- =============================================
CREATE PROCEDURE AP_ListaMenu
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	  SELECT MenuId,
                clave,
				visible
         FROM ap_menun

         
END

