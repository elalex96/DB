USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_MM_ConsultaDetalleAceptacionPedido_MV1_5
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 05-01-2021
-- Description: Se agrego infromación del yacimiento en la descripción del material
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultaDetalleAceptacionPedido_MV1_5] --442
@IdAceptacionPedido INT, 
@IdContrato         INT      = NULL, 
@IdUsuario          INT      = NULL, 
@FechaRegistro      DATETIME = NULL
AS
    BEGIN

	    SELECT M.IdMaterial, 
               CONCAT(POD.MaterialCotizadoTextoC, ' Descripción: ', POD.MaterialCotizadoTextoL) AS DescripcionCorta, 
               U.Unidad AS NombreUnidad, 
               CONCAT(APD.Cantidad, ' / ', APD.Excedente) AS Cantidad, 
			   CONCAT((CASE
                           WHEN LEN(APD.Detalle) > 0
                           THEN CONCAT(APD.Detalle, ' | ')
                           ELSE ' '
                       END), ISNULL('Instalación: ' + INS.NombreInstalacion COLLATE Modern_Spanish_CI_AS, ' '),' | ', dbo.Fn_RetornarMesProgramadoActividadConcat(lp.IdLineaPresupuestoMes)) AS Detalle
        FROM MM_AceptacionPedidoDetalle AS APD
             LEFT JOIN MM_AceptacionPedido AS AP ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
             LEFT JOIN dbo.MM_Pedido P (NOLOCK) ON AP.IdPedido = P.IdPedido
             LEFT JOIN MM_PedidoDetalle AS PD (NOLOCK) ON APD.IdPedidoDetalle = PD.IdPedidoDetalle
                                                 AND P.IdPedido = PD.IdPedido
             LEFT JOIN dbo.MM_PeticionOferta PO ON P.IdPeticionOferta = PO.IdPeticionOferta
             LEFT JOIN dbo.MM_PeticionOfertaDetalle POD (NOLOCK) ON PO.IdPeticionOferta = POD.IdPeticionOferta
                                                           AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
             LEFT JOIN MM_Material AS M (NOLOCK) ON PD.IdMaterialVendedor = M.IdMaterial
             LEFT JOIN PV_MM_MaterialUnidad AS U (NOLOCK) ON M.IdUnidad = U.IdUnidad
             LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI (NOLOCK) ON AP.IdAceptacionPedido = APDI.IdAceptacionPedido
                                                                            AND APD.IdAceptacionPedidoDetalle = APDI.IdAceptacionPedidoDetalle
             LEFT JOIN Adinco.dbo.CO_Instalacion AS INS (NOLOCK) ON APDI.IdInstalacion = INS.IdInstalacion
             LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS lp (NOLOCK) ON APDI.IdLineaPresupuesto = lp.IdLineaPresupuestoMes
			 LEFT JOIN Adinco..CO_Yacimiento Y (NOLOCK) ON Y.IdYacimiento = INS.IdYacimiento
        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;
    END;
