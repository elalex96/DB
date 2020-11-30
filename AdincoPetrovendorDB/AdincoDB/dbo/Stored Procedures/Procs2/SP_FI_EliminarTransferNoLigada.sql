-- =============================================
-- Author:		Manuel CD
-- Create date: 18-06-2018
-- Description:	
-- =============================================
create PROCEDURE [dbo].[SP_FI_EliminarTransferNoLigada] 
	-- Add the parameters for the stored procedure here
@IdTransfer  INT,
@IdUsuario   INT,
@IdContrato  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             DELETE dbo.FI_TransferFactura
             WHERE IdTransfer = @IdTransfer;
             DELETE dbo.FI_Transfer
             WHERE IdTransferencia = @IdTransfer;
		   --
             IF @@ERROR <> 0
                 SELECT 'false' AS msj;
                 ELSE
             SELECT 'true' AS msj;
         END;
		 --[SP_FI_EliminarTransferNoLigada] 811,1,1