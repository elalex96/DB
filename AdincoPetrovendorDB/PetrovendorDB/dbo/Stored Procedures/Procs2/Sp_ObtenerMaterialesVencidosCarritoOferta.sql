

-- =============================================
-- Author:		Pedro Acuña
-- Create date: 25 Junio 2019
-- Description:	Store para obtener si ya habia agregado anteriormente ese material y se vencio en otro pedido
-- =============================================

CREATE PROCEDURE Sp_ObtenerMaterialesVencidosCarritoOferta
    @IdSolicitudPedido INT, @IdPeticionOfertaDetalle INT
AS
    BEGIN
        DECLARE
            @IdTipoOperacion          INT
            = 9, --IdTipoOperacion = 9 Aprobación de pedido 
            @IdPedido                 INT


        SELECT  TOP 1
                @IdPedido = pd.IdPedido
        FROM
                dbo.MM_PeticionOfertaDetalle pod
            INNER JOIN
                dbo.MM_PeticionOferta        po
                    ON po.IdPeticionOferta = pod.IdPeticionOferta
            INNER JOIN
                dbo.MM_PedidoDetalle         pd
                    ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
        WHERE
                pod.IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle


        SELECT
                SPD.IdSolicitudPedidoDetalle,
                PD.IdPedidoDetalle,
                PD.IdMaterialVendedor,
                POD.MaterialCotizadoTextoC AS DescripcionCorta,
                POD.MaterialCotizadoTextoL,
                ISNULL(PD.Cantidad, 0)     AS Cantidad,
                POD.UnidadProveedor,
                PD.PrecioUnitario,
                PD.Subtotal,
                TM.TipoMonedaCorto,
                CONCAT(
                    D.Calle, ' ', D.NoInterior, ' ', D.NoExterior, ' ',
                    D.Colonia, ' ', D.Municipio, ' ', D.Estado, ' CP ',
                    D.CodigoPostal)        AS DomicilioEntrega,
                ps.IdPedido                AS IdPedidoGral
        FROM
                dbo.MM_Pedido                 AS P
            INNER JOIN
                dbo.MM_PedidoDetalle          AS PD
                    ON PD.IdPedido = P.IdPedido
            INNER JOIN
                dbo.MM_PeticionOferta         AS PO
                    ON PO.IdPeticionOferta = P.IdPeticionOferta
            INNER JOIN
                dbo.MM_PeticionOfertaDetalle  AS POD
                    ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
            INNER JOIN
                dbo.MM_SolicitudPedidoDetalle AS SPD
                    ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
            INNER JOIN
                dbo.TA_Operacion              AS O
                    ON O.IdDocumento = P.IdSolicitudPedido
            INNER JOIN
                dbo.TA_Vencimiento            AS V
                    ON V.IdVencimiento = O.IdVigencia
            INNER JOIN
                dbo.TA_TipoOperacion          AS TTO
                    ON TTO.IdTipoOperacion = O.IdTipoOperacion
            INNER JOIN
                dbo.TA_Estatus                AS E
                    ON E.IdEstatus = O.IdEstatusOperacion
            INNER JOIN
                dbo.PV_TipoMoneda             AS TM
                    ON TM.IdMoneda = PD.IdMoneda
            INNER JOIN
                dbo.DG_Domicilio              AS D
                    ON D.IdDomicilio = SPD.IdDomicilioEntrega
            INNER JOIN
                dbo.MM_HorasVigenciaPedido    AS HV
                    ON HV.IdPedido = P.IdPedido
            INNER JOIN
                dbo.MM_Pedidos                ps
                    ON ps.IdIdentificador = P.IdPedido
        WHERE
                O.IdTipoOperacion = @IdTipoOperacion
                AND P.IdSolicitudPedido = @IdSolicitudPedido
                AND P.IdPedido = @IdPedido
                AND HV.FechaVigencia < GETDATE()
			 AND	O.IdEstatusOperacion = 1 -- En aprbacion
				AND ISNULL(p.Cerrado, 0) = 0
        GROUP BY
                PD.IdPedidoDetalle,
                PD.IdMaterialVendedor,
                POD.MaterialCotizadoTextoC,
                POD.UnidadProveedor,
                PD.PrecioUnitario,
                PD.Cantidad,
                TM.TipoMonedaCorto,
                PD.Subtotal,
                PD.RecepcionPedido,
                PD.Subtotal,
                PD.PorcentajeContenidoNacional,
                D.Calle,
                D.NoInterior,
                D.NoExterior,
                D.Colonia,
                D.Municipio,
                D.Estado,
                D.CodigoPostal,
                HV.FechaVigencia,
                P.IdPedido,
                P.RecepcionServicio,
                POD.MaterialCotizadoTextoL,
                PD.ModificadoPor,
                SPD.IdSolicitudPedidoDetalle,
                ps.IdPedido
    END
