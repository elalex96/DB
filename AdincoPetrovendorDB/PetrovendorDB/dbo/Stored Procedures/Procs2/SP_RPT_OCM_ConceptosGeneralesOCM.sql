-- =============================================
-- Author: Daniel AC
-- Create date: 15-09-17
-- Description: Consultar Pedido Detalle Encabezado
-- Author: Daniel AC
-- Update date: 22-05-2018
-- Description: Revisión de funcionamiento de sp, se le agrego que el domicilio este activo, 
--- que el número de pedido sea el mismo numero de version de la operación y se desaagrupo el pedido detalle subtotal 
-- Author: Daniel AC  
-- Create date: 04/11/2019
-- Description: Comente case que mostraba en 0 las cantidades cuando el estatus era aprobado, pero sin confirmación aceptada
-- =============================================
CREATE PROCEDURE SP_RPT_OCM_ConceptosGeneralesOCM
    -- Add the parameters for the stored procedure here

    @IdPedido INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @IdSolicitudPedido INT;
    DECLARE @IdFactura INT;
    DECLARE @IVA DECIMAL(18, 2);
    DECLARE @MONTO_FINAL DECIMAL(18, 2);

    -- Insert statements for procedure here

    ----- IdTipoOperacion = 9--> Aprobación de pedido
    DECLARE @IdProveedor INT = (
                                   SELECT PR.IdProveedor
                                   FROM S_Proveedor AS PR
                                       LEFT JOIN dbo.MM_Pedido AS PE
                                           ON PE.IdProveedorCompras = PR.IdProveedor
                                   WHERE PE.IdPedido = @IdPedido
                               );

    DECLARE @PROVEDORACTUAL VARCHAR(MAX) = (
                                               SELECT CONCAT(RazonSocial, RegimenCapital)
                                               FROM S_Proveedor
                                               WHERE IdProveedor = @IdProveedor
                                           );
    DECLARE @PROVEDORACTUALDOMICILIO VARCHAR(MAX)
        =   (
                SELECT CONCAT(
                                 'Col.',
                                 DF.Colonia,
                                 ' ',
                                 'Calle.',
                                 DF.NombreViabilidad,
                                 ' ',
                                 'N°Interior.',
                                 DF.NoExterior,
                                 ' ',
                                 'N°Exterior.',
                                 DF.NoInterior,
                                 ' ',
                                 'CP.',
                                 DF.CodigoPostal
                             )
                FROM S_Proveedor AS PV
                    INNER JOIN DG_Domicilio AS DF
                        ON DF.IdProveedor = PV.IdProveedor
                           AND DF.IdTipoDomicilio = 1
                           AND DF.Activo = 1
                WHERE PV.IdProveedor = @IdProveedor
            );

    /*----------------- CONSULTAR CONDICIONES DE PAGO ----------------*/
    DECLARE @PROVEEDOR_VENTAS INT = (
                                        SELECT IdSubcontratista
                                        FROM MM_Pedido P
                                        WHERE IdProveedorCompras = @IdProveedor
                                              AND IdPedido = @IdPedido
                                    );
    DECLARE @CONDICIONES_PAGO NVARCHAR(30);
    DECLARE @EXISTEN_CONDICIONES_PAGO INT = (
                                                SELECT COUNT(CP.IdCondicionPago)
                                                FROM PV_CondicionesPago CP
                                                    INNER JOIN PV_ContratistaSubContratista CSC
                                                        ON CP.IdContratistaSubContratista = CSC.IdRelacion
                                                    INNER JOIN S_Proveedor P
                                                        ON P.IdProveedor = CSC.IdContratista
                                                WHERE CSC.IdContratista = @PROVEEDOR_VENTAS
                                                      AND CSC.IdSubContratista = @IdProveedor
                                                      AND CSC.IsActivo = 1
                                            );
    IF (@EXISTEN_CONDICIONES_PAGO > 0)
    BEGIN
        DECLARE @TIENE_CREDITO BIT = (
                                         SELECT CP.Credito
                                         FROM PV_CondicionesPago CP
                                             INNER JOIN PV_ContratistaSubContratista CSC
                                                 ON CP.IdContratistaSubContratista = CSC.IdRelacion
                                             INNER JOIN S_Proveedor P
                                                 ON P.IdProveedor = CSC.IdContratista
                                         WHERE CSC.IdContratista = @PROVEEDOR_VENTAS
                                               AND CSC.IdSubContratista = @IdProveedor
                                               AND CSC.IsActivo = 1
                                     );
        IF (@TIENE_CREDITO = 1)
        BEGIN
            SET @CONDICIONES_PAGO =
            (
                SELECT CP.DiasCredito
                FROM PV_CondicionesPago CP
                    INNER JOIN PV_ContratistaSubContratista CSC
                        ON CP.IdContratistaSubContratista = CSC.IdRelacion
                    INNER JOIN S_Proveedor P
                        ON P.IdProveedor = CSC.IdContratista
                WHERE CSC.IdContratista = @PROVEEDOR_VENTAS
                      AND CSC.IdSubContratista = @IdProveedor
                      AND CSC.IsActivo = 1
            );

            SELECT @CONDICIONES_PAGO = @CONDICIONES_PAGO + ' días de crédito';

        END;
        ELSE
        BEGIN
            SELECT @CONDICIONES_PAGO = 'Contado';
        END;
    END;
    ELSE
    BEGIN
        SELECT @CONDICIONES_PAGO = 'Contado';
    END;
    /*----------------- FIN CONDICIONES DE PAGO ----------------*/

    /*
PEDIDO GENERADO POR COMPRA DIRECTA 


*/
    SET @IdSolicitudPedido =
    (
        SELECT IdSolicitudPedido FROM dbo.MM_Pedido WHERE IdPedido = @IdPedido
    );

    SET @IdFactura =
    (
        SELECT IdFactura
        FROM dbo.CO_RegistroPedido
        WHERE IdSolicitudPedido = @IdSolicitudPedido
    );
    IF @IdFactura IS NOT NULL
    BEGIN
        SET @MONTO_FINAL =
        (
            SELECT MontoConIva FROM dbo.FI_Factura WHERE IdFactura = @IdFactura
        );
        SET @IVA =
        (
            SELECT (ISNULL(MontoConIva, 0) - ISNULL(SubTotal, 0))
            FROM dbo.FI_Factura
            WHERE IdFactura = @IdFactura
        );

    END;

    SELECT PG.IdPedido,
           P.IdSolicitudPedido,
           SUM(   
				--CASE
    --                  WHEN (
    --                           PD.RecepcionPedido = 1
    --                           AND P.RecepcionServicio = 1
    --                       )
    --                       OR O.IdEstatusOperacion = 1 THEN
    --                      PD.Subtotal
    --                  ELSE
    --                      PD.Subtotal
    --              END
				PD.Subtotal
              ) AS SubtotalPedido,
           O.IdFlujoTarea,
           O.IdOperacion,
           IdEstatusOperacion,
           O.Descripcion,
           PV.RFC,
           PV.Telefono,
           U.Correo,
           ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Cliente,
           PV.Municipio + ' ' + PV.Entidad AS LugarCliente,
           CONCAT(
                     'Col.',
                     DF.Colonia,
                     ' ',
                     'Calle.',
                     DF.NombreViabilidad,
                     ' ',
                     'N°Interior.',
                     DF.NoExterior,
                     ' ',
                     'N°Exterior.',
                     DF.NoInterior,
                     ' ',
                     'CP.',
                     DF.CodigoPostal
                 ) AS Domicilio,
				 '' AS Logo,
           --IP.Imagen AS Logo,
           E.Nombre,
           U.Nombre AS Elaboro,
           O.FechaRegistro,
           H.FechaVigencia,
           P.Version,
           @PROVEDORACTUAL AS ProveedorActual,
           @PROVEDORACTUALDOMICILIO AS DomicilioProveedorActual,
           CASE P.RecepcionServicio
               WHEN 1 THEN
                   'CONFIRMADA_ACEPTADA'
               WHEN 0 THEN
                   'CONFIRMACION_RECHAZADA'
               ELSE
                   'EN_RECEPCION'
           END AS ESTATUS,
           PSP.Prioridad,
           TSP.TipoSolicitudPedido,
           CAST(P.IdSolicitudPedido AS NVARCHAR(100)) + ' ' + 'Versión' + ' ' + CAST(P.Version AS NVARCHAR(100)) AS concatVersion,
           TM.TipoMonedaCorto AS Moneda,
           CASE
               WHEN @IdFactura IS NOT NULL THEN
                   @IVA
               ELSE
                   0
           END AS PorcentajeIVA,
           CASE
               WHEN @IdFactura <> 0 THEN
                   ISNULL(@MONTO_FINAL, 0)
               ELSE
                   SUM(PD.Subtotal)
           END AS Total,
           @CONDICIONES_PAGO AS CondicionesDePago,
           dbo.CantidadConLetraReportes(SUM(   
												--CASE
            --                                       WHEN (
            --                                                PD.RecepcionPedido = 1
            --                                                AND P.RecepcionServicio = 1
            --                                            )
            --                                            OR O.IdEstatusOperacion = 1 THEN
            --                                           PD.Subtotal
            --                                       ELSE
            --                                           PD.Subtotal
            --                                   END
												PD.Subtotal
                                           ),
                                        TM.TipoMonedaCorto
                                       ) AS SubtotalLetra
    FROM MM_Pedido AS P
        LEFT JOIN MM_PedidoDetalle AS PD
            ON PD.IdPedido = P.IdPedido
        LEFT JOIN MM_PeticionOferta AS PO
            ON PO.IdPeticionOferta = P.IdPeticionOferta
        LEFT JOIN S_Proveedor AS PV
            ON PV.IdProveedor = P.IdSubcontratista
        LEFT JOIN S_ImagenPerfil AS IP
            ON IP.IdProveedor = P.IdSubcontratista
        LEFT JOIN DG_Domicilio AS DF
            ON DF.IdProveedor = P.IdSubcontratista
               AND DF.IdTipoDomicilio = 1
               AND DF.Activo = 1
        LEFT JOIN TA_Operacion AS O
            ON O.IdDocumento = P.IdSolicitudPedido AND o.NoVersion = p.Version
        LEFT JOIN S_Usuario AS U
            ON U.IdUsuario = O.IdAsignador
        LEFT JOIN TA_Prioridad AS PR
            ON PR.IdPrioridad = O.IdPrioridad
        LEFT JOIN TA_Vencimiento AS V
            ON V.IdVencimiento = O.IdVigencia
        LEFT JOIN TA_TipoOperacion AS TTO
            ON TTO.IdTipoOperacion = O.IdTipoOperacion
        LEFT JOIN TA_Estatus AS E
            ON E.IdEstatus = O.IdEstatusOperacion
        LEFT JOIN dbo.MM_HorasVigenciaPedido AS H
            ON H.IdPedido = P.IdPedido
        LEFT JOIN MM_SolicitudPedido AS SP
            ON SP.IdSolicitudPedido = P.IdSolicitudPedido
        LEFT JOIN MM_PrioridadSolicitudPedido AS PSP
            ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
        LEFT JOIN MM_TipoSolicitudPedido AS TSP
            ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
        LEFT JOIN PV_TipoMoneda AS TM
            ON TM.IdMoneda = PD.IdMoneda
        LEFT JOIN MM_Pedidos AS PG
            ON P.IdPedido = PG.IdIdentificador
               AND PG.IdProveedorCliente = @IdProveedor
    WHERE O.IdTipoOperacion = 9
          AND O.IdProveedor = @IdProveedor
          AND P.IdPedido = @IdPedido
          AND P.Version = O.NoVersion
    GROUP BY PG.IdPedido,
             P.IdSolicitudPedido,
             O.IdFlujoTarea,
             O.IdOperacion,
             O.IdEstatusOperacion,
             O.Descripcion,
             PV.RazonSocial,
             PV.RegimenCapital,
             PV.Municipio,
             PV.Entidad,
             E.Nombre,
             O.FechaRegistro,
             U.Nombre,
             H.FechaVigencia,
             P.Version,
             P.RecepcionServicio,
             DF.Colonia,
             DF.NombreViabilidad,
             DF.NoExterior,
             DF.NoInterior,
             DF.CodigoPostal,
             IP.Imagen,
             PV.RFC,
             PV.Telefono,
             U.Correo,
             PSP.Prioridad,
             TSP.TipoSolicitudPedido,
             TM.TipoMonedaCorto;

END;


