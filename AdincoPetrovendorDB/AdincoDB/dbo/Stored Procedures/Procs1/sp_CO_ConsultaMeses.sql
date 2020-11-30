-- =============================================
-- Author:		Manuel CD
-- Create date: 29-09-17
-- Description:	
-- =============================================
create PROCEDURE [dbo].[sp_CO_ConsultaMeses]
	-- Add the parameters for the stored procedure here
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT DISTINCT
                mes,
                nombremes
         FROM AP_Calendario
         ORDER BY mes,
                  nombremes DESC;
     END;
