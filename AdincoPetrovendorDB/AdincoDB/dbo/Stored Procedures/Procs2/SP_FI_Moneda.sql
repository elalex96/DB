-- =============================================
-- Author:		Manuel Cruz
-- Create date: 18-09-17
-- Description:	
-- =============================================
create PROCEDURE SP_FI_Moneda 
	-- Add the parameters for the stored procedure here

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdMoneda,
                TipoMonedaCorto
         FROM PV_TipoMoneda
         WHERE Eliminado = 0;
     END;