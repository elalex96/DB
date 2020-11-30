-- =============================================
-- Author:		Manuel CD
-- Create date: 18-06-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_VerificarTransferSiTieneRelacion] 
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
             IF EXISTS
				(
					SELECT *
					FROM dbo.FI_TransferFactura TF JOIN CO_Registro R ON TF.IdFactura = R.IdFactura
					WHERE IdTransfer = @IdTransfer
				)
                OR EXISTS
				(
					SELECT *
					FROM dbo.FI_TransferFactura TF JOIN CO_Registro R ON TF.IdPedimentoComprobante = R.IdPedimentoComprobante
					WHERE IdTransfer = @IdTransfer
				)
                 SELECT 1 AS Relacion;
                 ELSE
             SELECT 0 AS Relacion;
         END;

		 --[SP_FI_VerificarTransferSiTieneRelacion] 811,1,1