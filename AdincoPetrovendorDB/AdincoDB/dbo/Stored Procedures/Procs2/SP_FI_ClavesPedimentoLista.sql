-- =============================================
-- Author:		Manuel CD
-- Create date: 04-10-17
-- Description:	
-- =============================================
create PROCEDURE [dbo].[SP_FI_ClavesPedimentoLista] 
	-- Add the parameters for the stored procedure here

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdPedimentoLista,
                IdClavePedimento,
                TipoClavePedimento
         FROM FI_ClavesPedimentoLista

     END
