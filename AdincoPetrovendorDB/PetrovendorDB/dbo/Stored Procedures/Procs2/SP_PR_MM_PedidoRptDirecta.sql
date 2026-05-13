-- =============================================
-- Author:		Manuel Cruz
-- Create date: 24-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_PedidoRptDirecta]
	-- Add the parameters for the stored procedure here
@IdFactura INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		 declare @IdPedido int
		 declare @FechaFactura date 
		 select @FechaFactura =fecha from FI_Factura where IdFactura= @IdFactura
    -- Insert statements for procedure here

	select @IdPedido= IdPedido from MM_Pedido where Comentarios  = concat('Directa-',@IdFactura)
         SELECT DISTINCT P.IdPedido,
                CONCAT(S.RazonSocial, '  ', S.RegimenCapital) AS Proveedor,
                P.CreadoEl AS FechaRegistro,
                'Alta' as Prioridad ,
                P.IdSolicitudPedido,
                0 as IdPrioridadSolicitudPedido,
                'Compra Directa' as TipoSolicitudPedido,
                 'NO'
                 AS Adjudicable,
                  'NO'
                 AS VisitaRequerida,
                 'NO'
                 AS JuntaAclaracionesRequerida,
                'SI'
                     
                 AS EntregaUnica,
                'NO'
                 AS EntregaParcial,
                 'NO'
                 AS Fianza,
               'NO'
                 AS Controlados,
                CONCAT(CONVERT(varchar(11),@FechaFactura,103), '  ',CONVERT(varchar(11),@FechaFactura,103)) AS FechaEntrega,
			 U.Nombre
         FROM MM_Pedido AS P
              JOIN MM_PedidoDetalle AS PD ON P.IdPedido = PD.IdPedido
              --JOIN MM_SolicitudPedido AS SP ON P.IdSolicitudPedido = SP.IdSolicitudPedido
              --JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
              --JOIN MM_PrioridadSolicitudPedido AS PSP ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
              JOIN S_PROVEEDOR AS S ON P.IdSubcontratista = S.IdProveedor
		    JOIN S_Usuario AS U ON P.CreadoPor = U.IdUsuario
			
         WHERE P.IdPedido = @IdPedido;

	    --EXEC SP_PR_MM_PedidoRpt 1112 1116
     END;
	-- select * from FI_Factura where IdFactura= 18161
