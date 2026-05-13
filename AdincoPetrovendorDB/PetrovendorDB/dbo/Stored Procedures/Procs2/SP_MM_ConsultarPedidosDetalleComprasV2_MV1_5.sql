USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ConsultarPedidosDetalleComprasV2_MV1_5'
)
    DROP PROCEDURE SP_MM_ConsultarPedidosDetalleComprasV2_MV1_5;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 11-07-18
-- Description:	Cambie columna detalle texto largo a texto corto
-- =============================================
-- Author:		Jose Roman
-- Create date: 12-09-2018
-- Description:	Se devuelve 0 en los subtotales y cantidades si el pedido o la partida han sido rechazados por el proveedor
-- =============================================
-- Author:		Daniel AC
-- Create date: 28-10-2019
-- Description:	Agregue condiciones de pago en la columna de observaciones 
-- Author: Daniel AC  
-- Create date: 04/11/2019
-- Description: Comente case que mostraba en 0 las cantidades cuando el estatus era aprobado, pero sin confirmación aceptada
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/10/2023
-- Description:	se agregan estandares de desarrollo
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_ConsultarPedidosDetalleComprasV2_MV1_5] 
    -- Add the parameters for the stored procedure here
    @IdPedido INT,
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @PROVEEDOR_COMPRAS INT = (
                                         SELECT IdProveedorCompras FROM MM_Pedido P WHERE IdPedido = @IdPedido
                                     );

    SELECT ROW_NUMBER() OVER (ORDER BY PD.IdPedidoDetalle ASC) AS Partida,
           PD.IdPedidoDetalle,
           PD.IdMaterialVendedor,
           CONCAT('Concepto: ', POD.MaterialCotizadoTextoC, ' - Descripción: ',POD.MaterialCotizadoTextoL) AS MaterialCotizadoTextoC,
           POD.UnidadProveedor,
           PD.PrecioUnitario,
		   pd.RecepcionPedido,
		   p.RecepcionServicio,
		   o.IdEstatusOperacion,
		   PD.Cantidad AS Cantidad,
           TM.TipoMonedaCorto AS Moneda,
			(PD.PrecioUnitario * PD.Cantidad) AS 
	       Subtotal,
           CASE
               WHEN PD.RecepcionPedido = 1
                    AND P.RecepcionServicio = 1 THEN
                   'Confirmado'
               WHEN PD.RecepcionPedido = 0
                    AND (
                            P.RecepcionServicio = 1
                            OR P.RecepcionServicio = 0
                        ) THEN
                   'Rechazado'
               WHEN P.RecepcionServicio IS NULL
                    AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0 THEN
                   'Vencida'
               ELSE
                   'En confirmación'
           END AS RecepcionPedido,
           PD.PorcentajeContenidoNacional,
           CASE
               WHEN I.NombreInstalacion COLLATE SQL_Latin1_General_CP1_CI_AS IS NOT NULL THEN
           ('Instalación: ' + ISNULL(I.NombreInstalacion COLLATE SQL_Latin1_General_CP1_CI_AS, '') + ' Dirección: '
            + CONCAT(
                        D.Calle,
                        ' ',
                        D.NoInterior,
                        ' ',
                        D.NoExterior,
                        ' ',
                        D.Colonia,
                        ' ',
                        D.Municipio,
                        ' ',
                        D.Estado,
                        ' CP ',
                        D.CodigoPostal
                    )
           )
               ELSE
                   CONCAT(
                             D.Calle,
                             ' ',
                             D.NoInterior,
                             ' ',
                             D.NoExterior,
                             ' ',
                             D.Colonia,
                             ' ',
                             D.Municipio,
                             ' ',
                             D.Estado,
                             ' CP ',
                             D.CodigoPostal
                         )
           END AS DomicilioEntrega,
           HV.FechaVigencia,
           P.IdPedido,
           P.RecepcionServicio,
           CASE
               WHEN SP.EntregasParciales = 1 THEN
                   CONVERT(VARCHAR(11), SP.FechaEntregaRequerida, 103) + ' - '
                   + CONVERT(VARCHAR(11), SP.FechaEntregaFinRequerida, 103)
               ELSE
                   CONVERT(VARCHAR(11), SP.FechaEntregaRequerida, 103)
           END AS FechaEntrega,
           UN.Unidad,
           dbo.CantidadConLetra(PD.Subtotal) AS SubtotalLetra,
           PD.RecepcionPedido,
           CASE
			   WHEN o.IdEstatusOperacion = 3 THEN
					SPD.observaciones
               WHEN PD.RecepcionPedido = 1
                    AND P.RecepcionServicio = 1 THEN
                   SPD.observaciones
               WHEN PD.RecepcionPedido = 0
                    AND (
                            P.RecepcionServicio = 1
                            OR P.RecepcionServicio = 0
                        ) THEN
                   CONCAT('Rechazado por el proveedor | ', ISNULL(SPD.observaciones, 'Sin comentarios'))
               WHEN P.RecepcionServicio IS NULL
                    AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0 THEN
                   CONCAT('Confirmación vencida | ', ISNULL(SPD.observaciones, 'Sin comentarios'))
               ELSE
                   CONCAT('En confirmación | ', ISNULL(SPD.observaciones, 'Sin comentarios'))
           END AS observaciones,
		   CASE WHEN PD.IdCondicionPago= 1 THEN ---> CREDITO
			CONCAT(PD.DiasCredito, ' ',CASE WHEN PD.DiasCredito= 1 THEN 'día' ELSE 'días'END,' de ', CP.CondicionPago )
			ELSE 
			cp.CondicionPago
			END  AS CondicionPago
    FROM MM_Pedido AS P (NOLOCK)
        INNER JOIN MM_PedidoDetalle AS PD (NOLOCK)
            ON P.IdPedido = PD.IdPedido
        INNER JOIN MM_PeticionOferta AS PO (NOLOCK)
            ON P.IdPeticionOferta = PO.IdPeticionOferta
        INNER JOIN MM_PeticionOfertaDetalle AS POD (NOLOCK)
            ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
        INNER JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
            ON P.IdSolicitudPedido = SP.IdSolicitudPedido
        INNER JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
            ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
        INNER JOIN MM_Material AS M (NOLOCK)
            ON PD.IdMaterialVendedor = M.IdMaterial
        INNER JOIN TA_Operacion AS O (NOLOCK)
            ON P.IdSolicitudPedido = O.IdDocumento 
				AND O.NoVersion = P.Version
        INNER JOIN TA_Prioridad AS PR (NOLOCK)
            ON  O.IdPrioridad = PR.IdPrioridad
        INNER JOIN TA_Vencimiento AS V (NOLOCK)
            ON O.IdVigencia = V.IdVencimiento
        INNER JOIN TA_TipoOperacion AS TTO (NOLOCK)
            ON O.IdTipoOperacion = TTO.IdTipoOperacion
        INNER JOIN TA_Estatus AS E (NOLOCK)
            ON O.IdEstatusOperacion = E.IdEstatus
        LEFT JOIN dbo.PV_MM_MaterialUnidad AS UN (NOLOCK)
            ON M.IdUnidad = UN.IdUnidad
        INNER JOIN PV_TipoMoneda AS TM (NOLOCK)
            ON PD.IdMoneda = TM.IdMoneda
        INNER JOIN DG_Domicilio AS D (NOLOCK)
            ON SPD.IdDomicilioEntrega = D.IdDomicilio
        INNER JOIN dbo.MM_HorasVigenciaPedido AS HV (NOLOCK)
            ON P.IdPedido = HV.IdPedido
        LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPL (NOLOCK)
            ON SPD.IdSolicitudPedidoDetalle = SPL.IdSolicitudPedidoDetalle
        LEFT JOIN Adinco.dbo.CO_Instalacion AS I (NOLOCK)
            ON SPL.IdInstalacion = I.IdInstalacion
		LEFT JOIN dbo.MM_CondicionPago CP (NOLOCK)
			ON CP.IdCondicionPago = PD.IdCondicionPago
    WHERE O.IdTipoOperacion = 9
          AND P.IdPedido = @IdPedido
    GROUP BY PD.IdPedidoDetalle,
             PD.IdMaterialVendedor,
             M.DescripcionCorta,
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
             P.FechaEntrega,
             P.IdPedido,
             UN.Unidad,
             SPD.observaciones,
             P.RecepcionServicio,
             SP.FechaEntregaRequerida,
             SP.FechaEntregaFinRequerida,
             SP.EntregasParciales,
             POD.MaterialCotizadoTextoL,
			 POD.MaterialCotizadoTextoC,
             POD.UnidadProveedor,
             I.NombreInstalacion,
			 O.IdEstatusOperacion,
			 PD.IdCondicionPago,
			 CP.CondicionPago, 
			 PD.DiasCredito;

END;


