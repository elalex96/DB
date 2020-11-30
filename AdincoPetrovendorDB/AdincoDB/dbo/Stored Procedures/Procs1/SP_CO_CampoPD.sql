-- =============================================
-- Author:		Manuel CD
-- Create date: 18-09-17
-- Description:	
-- =============================================
create PROCEDURE [dbo].[SP_CO_CampoPD]
	-- Add the parameters for the stored procedure here
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdCampo,
                NombreCampo AS Campo
         FROM PD_Campo
         WHERE Activo = 1
	    ORDER BY Campo ASC
     END;
