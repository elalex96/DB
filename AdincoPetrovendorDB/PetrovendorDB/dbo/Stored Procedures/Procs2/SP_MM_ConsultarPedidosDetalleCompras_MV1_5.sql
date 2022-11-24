-- =============================================
-- Author:		Daniel AC
-- Create date: 20-02-2019
-- Description:	Se actualiza sp de DEV A PR con consulta correcta del monto aceptado
-- =============================================
-- Author:		Luis David De La Cruz Bautsta
-- Create date: 20/01/2021
-- Description:	Se optimiza para issue 920
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarPedidosDetalleCompras_MV1_5]
    -- Add the parameters for the stored procedure here
    @IdProveedorCompras INT,
    @IdPedido INT,
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @TablaAceptado TABLE
    (
        IdPedidoDetalle INT,
        CantidadAceptada FLOAT
    );
    DECLARE @TablaRetorno TABLE
    (
        IdPedidoDetalle INT,
        IdMaterialVendedor INT,
        DescripcionCorta NVARCHAR(MAX),
        PrecioUnitario FLOAT,
        Cantidad FLOAT,
        UnidadCotizada NVARCHAR(MAX),
        Moneda NVARCHAR(100),
        Subtotal FLOAT,
        RecepcionPedido NVARCHAR(500),
        PorcentajeContenidoNacional FLOAT,
        DomicilioEntrega NVARCHAR(MAX),
        FechaVigencia DATETIME,
        IdPedido INT,
        RecepcionServicio INT,
        RecepcionPedidoEntero INT,
        SubTotalAceptado FLOAT,
        CondicionPago NVARCHAR(MAX)       
    );

	/*OBTENER MONTO ACEPTADO POR PEDIDO DETALLE*/
    INSERT INTO @TablaAceptado
    (
        IdPedidoDetalle,
        CantidadAceptada
    )
    SELECT apd.IdPedidoDetalle,
           SUM(apd.Cantidad)
    FROM dbo.MM_PedidoDetalle pd
         JOIN dbo.MM_AceptacionPedidoDetalle apd
            ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
         JOIN dbo.MM_AceptacionPedido AP
            ON apd.IdAceptacionPedido = AP.IdAceptacionPedido
    WHERE AP.IdPedido = @IdPedido
          AND ISNULL(AP.IdEstatusEliminado, 0) = 0--> QUE LA ACEPTACIÓN NO ESTE ELIMINADA
    GROUP BY apd.IdPedidoDetalle;

	/*OBTENER DETALLE DEL PEDIDO*/
    INSERT INTO @TablaRetorno
    (
        IdPedidoDetalle,
        IdMaterialVendedor,
        DescripcionCorta,
        PrecioUnitario,
        Cantidad,
        UnidadCotizada,
        Moneda,
        Subtotal,
        RecepcionPedido,
        PorcentajeContenidoNacional,
        DomicilioEntrega,
        FechaVigencia,
        IdPedido,
        RecepcionServicio,
        RecepcionPedidoEntero,
        SubTotalAceptado,      
        CondicionPago
    )
    SELECT PD.IdPedidoDetalle,
           SPD.IdMaterial AS IdMaterialVendedor,
           CONCAT(
                     'Cod. Proveedor: ',
                     PD.IdMaterialVendedor,
                     ' / Concepto: ',
                     POD.MaterialCotizadoTextoC,
                     ' / Descripción: ',
                     POD.MaterialCotizadoTextoL
                 ) AS DescripcionCorta,
           PD.PrecioUnitario,
           PD.Cantidad,
           POD.UnidadProveedor AS UnidadCotizada,
           TM.TipoMonedaCorto AS Moneda,
           PD.Subtotal,
           CASE
               WHEN PD.RecepcionPedido = 1
                    AND P.RecepcionServicio = 1 THEN
                   'Confirmado'
               WHEN PD.RecepcionPedido = 0
                    AND
                    (
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
           CONCAT(
                     'DOMICILIO: ',
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
                     D.CodigoPostal,
                     '    /  PRESUPUESTO: ',
                     dbo.Fn_RetornarMesProgramadoActividadConcat(SPLPM.IdLineaPresupuesto)
                 ) AS DomicilioEntrega,
           HV.FechaVigencia,
           P.IdPedido,
           P.RecepcionServicio,
           PD.RecepcionPedido,
           0 AS SubTotalAceptado,           
           CASE
               WHEN PD.IdCondicionPago = 1 THEN ---> CREDITO
                   CONCAT(   PD.DiasCredito,
                             ' ',
                             CASE
                                 WHEN PD.DiasCredito = 1 THEN
                                     'día'
                                 ELSE
                                     'días'
                             END,
                             ' de ',
                             CP.CondicionPago
                         )
               ELSE
                   CP.CondicionPago
           END AS CondicionPago
    FROM MM_Pedido AS P
        INNER JOIN MM_PedidoDetalle AS PD
            ON P.IdPedido = PD.IdPedido
        INNER JOIN MM_PeticionOferta AS PO
            ON P.IdPeticionOferta = PO.IdPeticionOferta 
        INNER JOIN MM_PeticionOfertaDetalle AS POD
            ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle 
        INNER JOIN MM_SolicitudPedidoDetalle AS SPD
            ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
        INNER JOIN S_Proveedor AS PV
            ON P.IdSubcontratista = PV.IdProveedor
        INNER JOIN TA_Operacion AS O
            ON P.IdSolicitudPedido = O.IdDocumento
        INNER JOIN TA_Prioridad AS PR
            ON O.IdPrioridad = PR.IdPrioridad
        INNER JOIN TA_Vencimiento AS V
            ON O.IdVigencia = V.IdVencimiento
        INNER JOIN TA_TipoOperacion AS TTO
            ON O.IdTipoOperacion = TTO.IdTipoOperacion
        INNER JOIN TA_Estatus AS E
            ON O.IdEstatusOperacion = E.IdEstatus
        INNER JOIN PV_TipoMoneda AS TM
            ON PD.IdMoneda = TM.IdMoneda
        INNER JOIN dbo.MM_HorasVigenciaPedido AS HV
            ON P.IdPedido = HV.IdPedido        
        INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPLPM
            ON SPD.IdSolicitudPedidoDetalle = SPLPM.IdSolicitudPedidoDetalle 
		LEFT JOIN DG_Domicilio AS D
            ON SPD.IdDomicilioEntrega = D.IdDomicilio
        LEFT JOIN dbo.MM_CondicionPago CP
            ON PD.IdCondicionPago = CP.IdCondicionPago
    WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
          AND O.IdProveedor = @IdProveedorCompras
          AND P.IdPedido = @IdPedido
    GROUP BY PD.IdPedidoDetalle,
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
             SPD.IdMaterial,
             SPLPM.IdLineaPresupuesto,
             PD.DiasCredito,
             PD.IdCondicionPago,
             CP.CondicionPago;

    /*ACTUALIZAR EL MONTO ACEPTADO DEL PEDIDO DETALLE*/
    UPDATE ret
    SET ret.SubTotalAceptado = acept.CantidadAceptada * ret.PrecioUnitario
    FROM @TablaRetorno ret
        LEFT JOIN @TablaAceptado acept
            ON ret.IdPedidoDetalle = acept.IdPedidoDetalle ;

    SELECT IdPedidoDetalle,
           IdMaterialVendedor,
           DescripcionCorta,
           PrecioUnitario,
           Cantidad,
           UnidadCotizada,
           Moneda,
           Subtotal,
           RecepcionPedido,
           PorcentajeContenidoNacional,
           DomicilioEntrega,
           FechaVigencia,
           IdPedido,
           RecepcionServicio,
           RecepcionPedidoEntero,
           SubTotalAceptado,
           CondicionPago           
    FROM @TablaRetorno;
--- IdTipoOperacion = 9--> Aprobación de pedido

END;
