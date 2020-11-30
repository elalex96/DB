-- =============================================
-- Author: Manuel Cruz
-- Create date: 01-05-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_UpdateHash] 
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT,
@IdOper     INT,
@Hash256    NVARCHAR(MAX),
@IdTipo     INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             IF @IdTipo = 1
                 BEGIN
                     UPDATE dbo.FI_Factura
                       SET
                           HashSHA256 = @Hash256
                     WHERE IdFactura = @IdOper;
                 END;
             IF @IdTipo IN(2, 3)
                 BEGIN
                     UPDATE dbo.FI_PedimentoComprobante
                       SET
                           HashSHA256 = @Hash256
                     WHERE IdPedimentoComprobante = @IdOper;
                 END;
             IF @IdTipo = 4
                 BEGIN
                     UPDATE dbo.FI_Transfer
                       SET
                           HashSHA256 = @Hash256
                     WHERE IdTransferencia = @IdOper;
                 END;
             IF @IdTipo = 5
                 BEGIN
                     UPDATE dbo.FI_EstudioPreciosTransfer
                       SET
                           HashSHA256 = @Hash256
                     WHERE IdEstudioPrecioTransfer = @IdOper;
                 END;

		   --Devuelve error o no
             IF @@ERROR <> 0
                 SELECT 'false' AS msj;
                 ELSE
             SELECT 'true' AS msj;
         END;
