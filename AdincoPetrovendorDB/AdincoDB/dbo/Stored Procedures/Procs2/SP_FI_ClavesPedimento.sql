-- =============================================
-- Author:		Manuel CD
-- Create date: 04-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ClavesPedimento] 
	-- Add the parameters for the stored procedure here
	@IdClavePedimento INT = 0
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here

             SELECT IdPedimento,
                    Clave,
                    Concat(Clave, ' - ', Descripcion) AS Descripcion,
                    IdClavePedimento
             FROM FI_ClavesPedimento;
	    --WHERE IdClavePedimento = @IdClavePedimento

         END;

