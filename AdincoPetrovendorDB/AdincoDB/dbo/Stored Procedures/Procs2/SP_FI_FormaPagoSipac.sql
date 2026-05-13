-- =============================================
-- Author:		Manuel CD
-- Create date: 06-10-17
-- Description:	
-- =============================================
create PROCEDURE [dbo].[SP_FI_FormaPagoSipac] 
	-- Add the parameters for the stored procedure here
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdClave,
                Nombre
         FROM AP_Lista
	    WHERE IdGrupo = 10001
     END;
