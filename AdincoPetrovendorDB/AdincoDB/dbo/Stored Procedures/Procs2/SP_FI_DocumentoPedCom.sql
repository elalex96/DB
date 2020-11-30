-- =============================================
-- Author:		Manuel CD
-- Create date: 16-11-2017
-- Description:	
-- =============================================
create PROCEDURE [dbo].[SP_FI_DocumentoPedCom] 
	-- Add the parameters for the stored procedure here
@IdPedCom INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdPedimentoComprobante, DocumentoByte
         FROM dbo.FI_Documento
         WHERE IdTipoDocumento IN(4, 5)
         AND IdPedimentoComprobante = @IdPedCom

     END
