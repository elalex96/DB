-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Pedido Detalle
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidosDetalleCliente]
	-- Add the parameters for the stored procedure here
@IdSolicitudPedido INT,
@IdProveedor       INT
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
                ISNULL(PD.AceptacionServicio, 'false') AS AceptacionServicio
         FROM MM_PedidoDetalle AS PD
              INNER JOIN MM_Pedido AS P ON P.IdPedido = PD.IdPedido
              INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
              INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento = SP.IdSolicitudPedido
              INNER JOIN PV_Subcontratista AS S ON S.IdSubcontratista = P.IdSubcontratista
              INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterial
              INNER JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
         WHERE TAO.IdTipoOperacion = 7
               AND SP.IdSolicitudPedido = @IdSolicitudPedido
               AND SP.IdProveedor = @IdProveedor
         ORDER BY DescripcionCorta ASC;

	--- IdTipoOperacion = 7--> Pedido

     END;
