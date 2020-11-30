-- =============================================
-- Author:		Manuel Cruz
-- Create date: 28-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_PCN_Actualizar]
	-- Add the parameters for the stored procedure here
@p1 INT = 0
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
         SELECT *
         FROM MM_PCN_MaterialesUtilizados
         SELECT *
         FROM MM_PCN_ValoresPesos
         SELECT *
         FROM MM_AceptacionPedidoDetalle
         SELECT *
         FROM MM_AceptacionPedido
         SELECT *
         FROM MM_Pedido
     END;

