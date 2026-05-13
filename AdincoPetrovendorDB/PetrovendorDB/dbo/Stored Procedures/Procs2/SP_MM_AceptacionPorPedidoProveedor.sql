-- =============================================
-- Author:		Daniel Cruz
-- Create date: 17-11-17
-- Description: Consultar acepetaciones de pedido por pedido
-- Author:		Daniel Cruz
-- Update date: 01-06-18
-- Description: Consultar acepetaciones de pedido por pedido donde la aceptación no este eliminada
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AceptacionPorPedidoProveedor]
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdPedido INT

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT 
                AP.IdAceptacionPedido,               
				AP.Comentario,
                AP.Creado,
				CONCAT(LE.[Calle],' ',LE.[NoExterior],' ',LE.[NoInterior],' ',LE.[Colonia],' ',LE.[Municipio],' ',LE.[Estado], ' ', PAIS.Pais) AS LugarEntrega,                
				AP.NombreRecibidoPor			
         FROM MM_AceptacionPedido AS AP
		 INNER JOIN MM_Pedido AS MP ON MP.IdPedido = AP.IdPedido
		 INNER JOIN DG_Domicilio AS LE ON LE.IdDomicilio = AP.IdDomicilioEntrega
		 INNER JOIN DG_TipoDomicilio AS  TD ON TD.IdTipoDomicilio = LE.IdTipoDomicilio
		 INNER JOIN PV_PaisRepublica AS PAIS ON PAIS.id = LE.IdPais
		 INNER JOIN S_Proveedor AS P ON P.IdProveedor =  MP.IdSubcontratista
         WHERE AP.IdProveedor = @IdProveedor 
		 AND MP.IdPedido= @IdPedido 
		 AND ISNULL(AP.IdEstatusEliminado,0) <> 1 --> Donde la ap no tenga un estatus de eliminado
		 ORDER BY IdAceptacionPedido DESC
     END;
