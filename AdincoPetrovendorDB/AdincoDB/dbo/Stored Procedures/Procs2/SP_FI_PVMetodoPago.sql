-- =============================================
-- Author:		Manuel CD
-- ALTER date: 04-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_PVMetodoPago] 
	-- Add the parameters for the stored procedure here
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdMetodoPago,
                MetodoPago
         FROM PV_MetodoPago
         ORDER BY Orden ASC;
     END;
