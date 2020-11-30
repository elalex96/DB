

CREATE PROCEDURE [dbo].[SP_CO_ActividadesCIEP]
	-- Add the parameters for the stored procedure here
AS

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Manuel CD
-- Create date: 18-09-17
-- Description:	
-- =============================================
     BEGIN


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT NombreActividad AS Actividad,
                ID_CATACTIV
         FROM CO_ActividadCIEP;
     END;

