-- =============================================
-- Author:		Manuel CD
-- Create date: 04-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminarRelacionTransferFactura] 
-- Add the parameters for the stored procedure here
@IdTransfer INT, 
@IdContrato INT = 0, 
@IdUsuario  INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         DELETE FI_TransferFactura
         WHERE IdTransfer = @IdTransfer;
     END;