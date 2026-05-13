-- =============================================
-- Author:		Manuel Cruz
-- Create date: 24-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_PedidoRpt]
	-- Add the parameters for the stored procedure here
@IdPedido INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT DISTINCT P.IdPedido,
                CONCAT(S.RazonSocial, '  ', S.RegimenCapital) AS Proveedor,
                P.CreadoEl AS FechaRegistro,
                PSP.Prioridad,
                P.IdSolicitudPedido,
                SP.IdPrioridadSolicitudPedido,
                TSP.TipoSolicitudPedido,
                CASE SP.AdjudicableParcialmente
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS Adjudicable,
                CASE SP.VisitaRequerida
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS VisitaRequerida,
                CASE SP.JuntaAclaracionesRequerida
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS JuntaAclaracionesRequerida,
                CASE SP.UnaSolaEntregaRequerida
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS EntregaUnica,
                CASE SP.UnaSolaEntregaRequerida
                    WHEN 0
                    THEN 'SI'
                    ELSE 'NO'
                END AS EntregaParcial,
                CASE SP.Fianza
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS Fianza,
                CASE SP.Controlados
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS Controlados,
                CONCAT(CONVERT(varchar(11),SP.FechaEntregaRequerida,103), '  ',CONVERT(varchar(11),SP.FechaEntregaFinRequerida,103)) AS FechaEntrega,
			 U.Nombre
         FROM MM_Pedido AS P
              JOIN MM_PedidoDetalle AS PD ON P.IdPedido = PD.IdPedido
              JOIN MM_SolicitudPedido AS SP ON P.IdSolicitudPedido = SP.IdSolicitudPedido
              JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
              JOIN MM_PrioridadSolicitudPedido AS PSP ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
              JOIN S_PROVEEDOR AS S ON P.IdSubcontratista = S.IdProveedor
		    JOIN S_Usuario AS U ON P.CreadoPor = U.IdUsuario
         WHERE P.IdPedido = @IdPedido;

	    --EXEC SP_PR_MM_PedidoRpt 1112 1116
     END;

