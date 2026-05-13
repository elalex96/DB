-- =============================================
-- Author:		Manuel CD
-- Create date: 22-11-2017
-- Description:	
-- =============================================
CREATE PROCEDURE SP_EN_ListaReguladores 
	-- Add the parameters for the stored procedure here
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT IdRegulador,
                    Regulador
             FROM CO_Regulador

         END

