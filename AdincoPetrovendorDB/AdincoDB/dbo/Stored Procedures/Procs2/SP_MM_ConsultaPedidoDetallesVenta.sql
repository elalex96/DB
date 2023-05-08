-- =============================================
-- Author:		Dany Boy
-- Create date: 25-05-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidoDetallesVenta] 
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdPedido    INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT PD.IdPedidoDetalle,
                P.IdPedido,
                PD.IdMaterial,
                M.DescripcionCorta,
                S.RazonSocial,
                POD.PrecioMasIVA,
                POD.IVA_Porcentaje,
                POD.AddCantidadTemp,
                POD.AddSubTotalTemp,
                ISNULL(PD.ConfirmacionSurtido, 'false') AS ConfirmacionSurtido,
                ISNULL(PD.AceptacionServicio, 'false') AS AceptacionServio
         FROM MM_PedidoDetalle AS PD
              INNER JOIN MM_Pedido AS P ON P.IdPedido = PD.IdPedido
              INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
              INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento = SP.IdSolicitudPedido
              INNER JOIN PV_Subcontratista AS S ON S.IdSubcontratista = P.IdSubcontratista
              INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterial
              INNER JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
         WHERE TAO.IdTipoOperacion = 7
               AND P.IdPedido = @IdPedido
               AND P.IdSubcontratista = @IdProveedor
         ORDER BY DescripcionCorta ASC;

		    --EXEC SP_MM_DetallePedidoProveedor 6,1000
     END;
