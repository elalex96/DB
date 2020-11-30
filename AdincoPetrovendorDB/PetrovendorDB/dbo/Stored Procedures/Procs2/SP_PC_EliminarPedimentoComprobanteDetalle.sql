-- =============================================
-- Author:		DANIEL AC
-- Create date: 27-03-18
-- Description:	eliminar Detalle de pedimento comprobante 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_EliminarPedimentoComprobanteDetalle] 
	-- Add the parameters for the stored procedure here

@IdProveedor        INT,
@IdContrato    INT,
@IdUsuario     INT,
@IdPedimentoComprobanteDetalle INT 


AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		   

           DELETE dbo.FI_PedimentoComprobanteDetalle 
		   WHERE IdPedimentoComprobanteDetalle=@IdPedimentoComprobanteDetalle

		   SELECT 'SUCCESS' 
     END;

 