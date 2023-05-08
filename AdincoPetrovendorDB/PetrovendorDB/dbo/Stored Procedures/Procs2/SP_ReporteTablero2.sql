

-- =============================================
-- Author:		Pedro Acuña
-- Create date: 05-Jun-18
-- Description:	segundo reporte donde se desgloza los aprobadores
-- =============================================
-- Author:		Jose Roman
-- Create date: 08-02-2019
-- Description:	se agrega filtro para no mostrar pedidos eliminados y requisiciones canceladas
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 17/04/2019
-- Description:	se modifica el store para agilizar el tiempo que tarda en hacer las consultas, se remueven las funciones
-- =============================================

CREATE PROCEDURE SP_ReporteTablero2
      @IdProveedor INT, @IdContrato INT, @IdUsuario INT, @IdTipoUsuario INT
AS
      BEGIN

            DECLARE @TablaTarea TABLE ( IdOperacion        INT,
                                        FechaCambioEstatus DATETIME,
                                        FechaRegistro      DATETIME,
                                        IdEstatusOperacion INT,
                                        IdTipoOperacion    INT,
                                        IdEstadoFlujo      INT,
                                        NoVersion          INT )


            DECLARE @TablaFechaAprobacionPedido TABLE ( IdOperacion INT, FechaAprobacionPedido DATETIME )


            DECLARE @TablaFechaAprobacionCN TABLE ( IdAceptacionPedido INT, IdAceptacionCartaPCN INT, FechaEvaluacion DATETIME, CreadoEl DATETIME )


            DECLARE @TablaAprobacionFactura TABLE ( IdAceptacionPedido  INT,
                                                    IdAceptacionFactura INT,
                                                    IdEstatusOperacion  INT,
                                                    FechaCambioEstatus  DATETIME,
                                                    FechaRegistro       DATETIME )


            DECLARE @TablaPedido TABLE ( IdPedido               INT,
                                         IdPedidos              INT,
                                         IdSolicitudPedido      INT,
                                         CreadoElPedido         DATETIME,
                                         FechaEnvioPedido       DATETIME,
                                         TotalPedido            FLOAT,
                                         Proveedor              NVARCHAR (MAX),
                                         RecepcionServicio      NVARCHAR (MAX),
                                         EstatusPedido          NVARCHAR (MAX),
                                         Version                INT,
                                         TipoMoneda             NVARCHAR (100),
                                         TipoPedido             NVARCHAR (MAX),
                                         IdTipoPedido           INT,
                                         FechaRegistroPedido    DATETIME,
                                         IdOperacion            INT,
                                         IdEstatusOperacion     INT,
                                         Cerrado                BIT,
                                         FechaRecepcionServicio DATETIME,
                                         IdProveedor            INT )


            DECLARE @TablaAceptacionPedido TABLE ( IdAceptacionPedido        INT,
                                                   IdPedido                  INT,
                                                   ComentarioAceptcionPedido NVARCHAR (MAX),
                                                   CreadoAceptacion          DATETIME,
                                                   DomicilioAceptacion       NVARCHAR (MAX),
                                                   TipoDomicilio             NVARCHAR (MAX),
                                                   Proveedor                 NVARCHAR (MAX),
                                                   IdPedidos                 INT,
                                                   TipoPedido                NVARCHAR (MAX),
                                                   IdSolicitudPedido         INT )


            -- Se obtiene los subtotales del pedido , el idpedido y el idpedido general
            INSERT INTO @TablaPedido ( IdPedido,
                                       IdPedidos,
                                       IdSolicitudPedido,
                                       CreadoElPedido,
                                       FechaEnvioPedido,
                                       TotalPedido,
                                       Proveedor,
                                       RecepcionServicio,
                                       EstatusPedido,
                                       Version,
                                       TipoMoneda,
                                       TipoPedido,
                                       IdTipoPedido,
                                       FechaRegistroPedido,
                                       IdOperacion,
                                       IdEstatusOperacion,
                                       Cerrado,
                                       FechaRecepcionServicio,
                                       IdProveedor )
            SELECT        P.IdPedido, PG.IdPedido                                    AS IdPedidoGeneral, P.IdSolicitudPedido, P.CreadoEl AS CreadoEl,
                          P.FechaEnvioPedido                                         AS FechaEnvioPedido, SUM(PD.Subtotal) AS TotalPedido,
                          ISNULL(RazonSocial, '') + ' ' + ISNULL(RegimenCapital, '') AS Proveedor,
                          CASE
                                WHEN P.RecepcionServicio = 1
                                      THEN
                                      'Confirmación Aceptada'
                                WHEN P.RecepcionServicio = 0
                                      THEN
                                      'Confirmación Rechazada'
                                WHEN P.RecepcionServicio IS NULL
                                     AND ( DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0
                                     AND O.IdEstatusOperacion = 2
                                      THEN
                                      'Confirmación Vencida '
                                WHEN P.RecepcionServicio IS NULL
                                     AND ( DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0
                                     AND O.IdEstatusOperacion = 2
                                      THEN
                                      'En Confirmación'
                                ELSE
                                      'Confirmación No Iniciada '
                          END                                                        AS RecepcionServicio, E.Nombre, P.Version, TM.TipoMonedaCorto AS TipoMoneda, TP.TipoPedido,
                          TP.IdTipoPedido, O.FechaRegistro, O.IdOperacion, O.IdEstatusOperacion, P.Cerrado,
                          P.FechaRecepcionServicio, PV.IdProveedor
              FROM
                          MM_Pedido              AS P
                    INNER JOIN
                          MM_PedidoDetalle       AS PD
                                ON PD.IdPedido = P.IdPedido
                    INNER JOIN
                          MM_PeticionOferta      AS PO
                                ON PO.IdPeticionOFerta = P.IdPeticionOferta
                    INNER JOIN
                          S_Proveedor            AS PV
                                ON PV.IdProveedor = P.IdSubcontratista
                    INNER JOIN
                          TA_Operacion           AS O
                                ON O.IdDocumento = P.IdSolicitudPedido
                                   AND P.Version = O.NoVersion
                    INNER JOIN
                          TA_Prioridad           AS PR
                                ON PR.IdPrioridad = O.IdPrioridad
                    INNER JOIN
                          TA_Vencimiento         AS V
                                ON V.IdVencimiento = O.IdVigencia
                    INNER JOIN
                          TA_TipoOperacion       AS TTO
                                ON TTO.IdTipoOperacion = O.IdTipoOperacion
                    INNER JOIN
                          TA_Estatus             AS E
                                ON E.IdEstatus = O.IdEstatusOperacion
                    INNER JOIN
                          MM_HorasVigenciaPedido AS HV
                                ON P.IdPedido = HV.IdPedido
                    INNER JOIN
                          PV_TipoMoneda          AS TM
                                ON TM.IdMoneda = P.IdMoneda
                    INNER JOIN
                          MM_Pedidos             AS PG
                                ON P.IdPedido = PG.IdIdentificador
                                   AND PG.IdProveedorCliente = @IdProveedor
                    LEFT JOIN
                          dbo.MM_TipoPedido      AS TP
                                ON TP.IdTipoPedido = PG.IdTipoPedido
             WHERE
                          O.IdTipoOperacion = 9
                          AND O.IdProveedor = @IdProveedor
                          AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
             GROUP BY
                  P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial, +RegimenCapital,
                  P.RecepcionServicio, E.Nombre, P.Version, TM.TipoMonedaCorto, HV.FechaVigencia, O.IdEstatusOperacion,
                  P.CreadoEl, PG.IdPedido, TP.TipoPedido, TP.IdTipoPedido, P.IdEstatusEliminado, O.FechaRegistro,
                  O.IdOperacion, P.Cerrado, P.FechaRecepcionServicio, PV.IdProveedor
             ORDER BY
                  PG.IdPedido DESC


            --guarda todas las tareas, pero agrupa las tareas y solo toma al
            INSERT INTO @TablaTarea ( IdOperacion,
                                      FechaCambioEstatus,
                                      FechaRegistro,
                                      IdEstatusOperacion,
                                      IdTipoOperacion,
                                      IdEstadoFlujo,
                                      NoVersion )
            SELECT temp.IdOperacion, temp.FechaCambioEstatus, temp.FechaRegistro, temp.IdEstatusOperacion,
                   temp.IdTipoOperacion, temp.IdEstadoFlujo, temp.NoVersion
              FROM (     SELECT        ROW_NUMBER() OVER ( PARTITION BY t.IdOperacion ORDER BY t.IdOperacion ) AS rw,
                                       t.IdOperacion, MAX(t.FechaCambioEstatus)                                AS FechaCambioEstatus,
                                       MAX(  t.FechaRegistro)                                                  AS FechaRegistro, tao.IdEstatusOperacion, tao.IdTipoOperacion,
                                       IdEstadoFlujo, tao.NoVersion
                           FROM
                                       dbo.TA_Tarea     t
                                 INNER JOIN
                                       dbo.TA_Operacion tao
                                             ON tao.IdOperacion = t.IdOperacion
                          WHERE
                                       tao.IdProveedor = @IdProveedor
                                       AND t.IdOperacion IS NOT NULL
                          GROUP BY
                               t.IdOperacion, tao.IdEstatusOperacion, tao.IdTipoOperacion, tao.IdEstadoFlujo,
                               tao.NoVersion ) AS temp
             WHERE
                   temp.rw = 1


            -- solo obtiene la fecha en que se aprobo ya que de todos los aprobadores solo obtiene la ultima fecha
            INSERT INTO @TablaFechaAprobacionPedido ( IdOperacion, FechaAprobacionPedido )
            SELECT t.IdOperacion, CASE WHEN t.IdEstadoFlujo = 3 THEN MAX(t.FechaCambioEstatus) ELSE NULL END
              FROM
                   @TablaTarea t
             GROUP BY
                  t.IdOperacion, t.IdEstadoFlujo


            -- se Obtiene la fecha de aprobacion de la carta de contenido
            INSERT INTO @TablaFechaAprobacionCN ( IdAceptacionPedido, IdAceptacionCartaPCN, FechaEvaluacion, CreadoEl )
            SELECT        ap.IdAceptacionPedido, AC.IdAceptacionCartaPCN, MAX(AC.FechaEvaluacion), s3.CreadoEl
              FROM
                          dbo.MM_AceptacionCartaPCN AC
                    LEFT JOIN
                          dbo.S_Documento_S3        s3
                                ON s3.IdDocumento = AC.IdDocumento
                    LEFT JOIN
                          dbo.MM_AceptacionPedido   ap
                                ON ap.IdAceptacionPedido = AC.IdAceptacionPedido
             WHERE
                          ap.IdProveedor = @IdProveedor --AND AC.IdEstatus = 2 -- aprobada
                          AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
             GROUP BY
                  ap.IdAceptacionPedido, AC.IdAceptacionCartaPCN, s3.CreadoEl


            DECLARE @TablaAceptacionFactura TABLE ( IdAceptacionPedido  INT,
                                                    IdPedidos           INT,
                                                    IdPedido            INT,
                                                    FechaRegistro       DATETIME,
                                                    Proveedor           NVARCHAR (MAX),
                                                    EstatusAceptacion   NVARCHAR (MAX),
                                                    TipoPedido          NVARCHAR (MAX),
                                                    TotalPedido         FLOAT,
                                                    Moneda              NVARCHAR (MAX),
                                                    RFC                 NVARCHAR (MAX),
                                                    IdSolicitudPedido   INT,
                                                    IdEstatusAceptacion INT )


            -- Toda la info de la factura excepto la fecha de aprobacion
            INSERT INTO @TablaAceptacionFactura ( IdAceptacionPedido,
                                                  IdPedidos,
                                                  IdPedido,
                                                  FechaRegistro,
                                                  Proveedor,
                                                  EstatusAceptacion,
                                                  TipoPedido,
                                                  TotalPedido,
                                                  Moneda,
                                                  RFC,
                                                  IdSolicitudPedido,
                                                  IdEstatusAceptacion )
            SELECT        AF.IdAceptacionPedido, PG.IdPedido, PE.IdPedido, O.FechaRegistro,
                          PR.RazonSocial + ' ' + ISNULL(PR.RegimenCapital, '') AS Proveedor, E.Nombre, TP.TipoPedido,
                          SUM(  APD.Cantidad * PED.PrecioUnitario)             AS TotalPedido, TM.TipoMonedaCorto AS Moneda, PR.RFC,
                          PE.IdSolicitudPedido, E.IdEstatus
              FROM
                          MM_AceptacionFactura           AS AF
                    INNER JOIN
                          TA_Operacion                   AS O
                                ON O.IdDocumento = AF.IdAceptacionFactura
                    INNER JOIN
                          TA_Estatus                     AS E
                                ON E.IdEstatus = O.IdEstatusOperacion
                    INNER JOIN
                          MM_AceptacionPedido            AS AP
                                ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                    INNER JOIN
                          dbo.MM_AceptacionPedidoDetalle AS APD
                                ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                    INNER JOIN
                          MM_Pedido                      AS PE
                                ON PE.IdPedido = AP.IdPedido
                                   AND PE.IdSubcontratista = O.IdProveedor
                    INNER JOIN
                          MM_PedidoDetalle               AS PED
                                ON PED.IdPedido = PE.IdPedido
                                   AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
                    INNER JOIN
                          MM_Pedidos                     AS PG
                                ON PE.IdPedido = PG.IdIdentificador
                                   AND PG.IdProveedorCliente = @IdProveedor
                    INNER JOIN
                          S_Proveedor                    AS PR
                                ON PR.IdProveedor = PE.IdSubcontratista
                    INNER JOIN
                          dbo.PV_TipoMoneda              AS TM
                                ON TM.IdMoneda = PE.IdMoneda
                    LEFT JOIN
                          dbo.MM_TipoPedido              AS TP
                                ON TP.IdTipoPedido = PG.IdTipoPedido
                    LEFT JOIN
                          dbo.TA_Tarea                   t
                                ON t.IdOperacion = O.IdOperacion
             WHERE
                          O.IdTipoOperacion = 10
                          AND PE.IdProveedorCompras = @IdProveedor
                          AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
             GROUP BY
                  AF.IdAceptacionPedido, PE.IdPedido, O.FechaRegistro, PR.RazonSocial, PR.RegimenCapital, E.Nombre,
                  PG.IdPedido, TP.TipoPedido, TM.TipoMonedaCorto, PR.RFC, AF.IdEstatusEliminado, PE.IdSolicitudPedido,
                  E.IdEstatus
             ORDER BY
                  AF.IdAceptacionPedido DESC


            DECLARE @TablaFechaAprobacionFactura TABLE ( IdOperacion INT, IdAceptacionPedido INT, FechaCambioEstatus DATETIME )


            -- solo obtener la fechas de aprobacion de la factura
            INSERT INTO @TablaFechaAprobacionFactura ( IdOperacion, IdAceptacionPedido, FechaCambioEstatus )
            SELECT        TAO.IdOperacion, af.IdAceptacionPedido, MAX(TT.FechaCambioEstatus)
              FROM
                          TA_Estatus               TE
                    INNER JOIN
                          TA_Tarea                 TT
                                ON TE.IdEstatus = TT.IdEstatus
                    INNER JOIN
                          S_Usuario                U
                                ON U.IdUsuario = TT.IdAprobador
                    INNER JOIN
                          TA_Operacion             TAO
                                ON TT.IdOperacion = TAO.IdOperacion
                    INNER JOIN
                          dbo.MM_AceptacionFactura af
                                ON TAO.IdDocumento = af.IdAceptacionFactura
             WHERE
                          TAO.IdTipoOperacion = 10
                          AND TAO.IdEstatusOperacion = 2
             GROUP BY
                  TAO.IdOperacion, af.IdAceptacionPedido


            SELECT        sp.IdSolicitudPedido                                                 AS IdRequisicion, sp.MotivoUrgencia AS Descripcion,
                          sp.FechaAlta                                                         AS FechaRegistro,
                          CASE
                                WHEN tao.IdEstatusOperacion = 3
                                      THEN
                                      CASE WHEN t.FechaCambioEstatus IS NULL THEN t.FechaRegistro ELSE t.FechaCambioEstatus END
                          END                                                                  AS FechaRechazado,
                          CASE
                                WHEN tao.IdEstatusOperacion = 2
                                      THEN
                                      CASE WHEN t.FechaCambioEstatus IS NULL THEN t.FechaRegistro ELSE t.FechaCambioEstatus END
                          END                                                                  AS FechaAprobado, po.IdPeticionOferta, po.CreadoEl AS FechaPeticionOferta, prov.RazonSocial,
                          prov.IdProveedor, po.FechaFinalizado                                 AS FechaCotizacionOC, p.CreadoElPedido AS FechaPedido,
                          p.IdPedidos                                                          AS NumPedido, p.Version, TA1.FechaCambioEstatus AS Aprobador1,
                          TA2.FechaCambioEstatus                                               AS Aprobador2, TA3.FechaCambioEstatus AS Aprobador3,
                          TA4.FechaCambioEstatus                                               AS Aprobador4, TA5.FechaCambioEstatus AS Aprobador5,
                          aprobacion.FechaAprobacionPedido                                     AS AprobacionPedido,
                          CASE WHEN p.Cerrado = 1 THEN 'Cerrado' ELSE EstatusPedido.Nombre END AS EstatusPedido,
                          p.TotalPedido                                                        AS Costo, p.TipoMoneda AS Moneda, p.FechaRecepcionServicio AS OrdenCompra,
                          AP.IdAceptacionPedido                                                AS IdAceptacionPedido, AP.Creado AS EntregaRecepcion,
                          fechaCarta.CreadoEl                                                  AS RegistroPCN, fechaCarta.FechaEvaluacion AS AprobacionPCN,
                          factura.FechaRegistro                                                AS RecepcionFactura, t2.FechaCambioEstatus AS AprobacionFactura,
                          AC.NombreAreaContractual, spdl.IdInstalacion, inst.NombreInstalacion, E.Nombre AS EstatusRequisicion
              FROM
                          dbo.MM_SolicitudPedido                        sp
                    LEFT JOIN
                          dbo.MM_SolicitudPedidoDetalle                 spd
                                ON spd.IdSolicitudPedido = sp.IdSolicitudPedido
                    LEFT JOIN
                          dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
                                ON spdl.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
                    LEFT JOIN
                          dbo.MM_PeticionOferta                         po
                                ON po.IdSolicitudPedido = sp.IdSolicitudPedido
                    LEFT JOIN
                          dbo.MM_PeticionOfertaDetalle                  pod
                                ON pod.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
                                   AND pod.IdSolicitudPedidoDetalle = spdl.IdSolicitudPedidoDetalle
                    LEFT JOIN
                          dbo.TA_Operacion                              tao
                                ON tao.IdDocumento = sp.IdSolicitudPedido
                                   AND tao.IdTipoOperacion = 2
                    LEFT JOIN
                          dbo.TA_Estatus                                E
                                ON E.IdEstatus = tao.IdEstatusOperacion
                    LEFT JOIN
                          dbo.S_Proveedor                               prov
                                ON prov.IdProveedor = po.IdSubcontratista
                    LEFT JOIN
                          @TablaTarea                                   t
                                ON t.IdOperacion = tao.IdOperacion
                                   AND t.IdEstatusOperacion = tao.IdEstatusOperacion
                                   AND t.IdTipoOperacion = 2
                    LEFT JOIN
                          @TablaPedido                                  p
                                ON p.IdSolicitudPedido = sp.IdSolicitudPedido
                                   AND p.IdProveedor = po.IdSubcontratista
                    LEFT JOIN
                          dbo.TA_Operacion                              AS OPES
                                ON OPES.IdDocumento = p.IdSolicitudPedido
                                   AND OPES.IdTipoOperacion = 9 --APROBACION DE PEDIDO
                                   --AND OPES.IdEstatusOperacion = 2 -- PEDIDO APROBADO
                                   --AND OPES.IdEstadoFlujo = 3 --FLUJO APROBADO PEDIDO
                                   AND OPES.NoVersion = p.Version
                                   AND ISNULL(OPES.IdEstatusEliminado, 0) <> 1
                    LEFT JOIN
                          Petrovendor.dbo.TA_Tarea                      AS TA1
                                ON TA1.IdOperacion = OPES.IdOperacion
                                   AND TA1.NoSecuencia = 1
                    LEFT JOIN
                          Petrovendor.dbo.TA_Tarea                      AS TA2
                                ON TA2.IdOperacion = OPES.IdOperacion
                                   AND TA2.NoSecuencia = 2
                    LEFT JOIN
                          Petrovendor.dbo.TA_Tarea                      AS TA3
                                ON TA3.IdOperacion = OPES.IdOperacion
                                   AND TA3.NoSecuencia = 3
                    LEFT JOIN
                          Petrovendor.dbo.TA_Tarea                      AS TA4
                                ON TA4.IdOperacion = OPES.IdOperacion
                                   AND TA4.NoSecuencia = 4
                    LEFT JOIN
                          Petrovendor.dbo.TA_Tarea                      AS TA5
                                ON TA5.IdOperacion = OPES.IdOperacion
                                   AND TA5.NoSecuencia = 5
                    LEFT JOIN
                          dbo.MM_AceptacionPedido                       AP
                                ON AP.IdPedido = p.IdPedido
                    LEFT JOIN
                          @TablaFechaAprobacionPedido                   aprobacion
                                ON aprobacion.IdOperacion = TA1.IdOperacion
                    LEFT JOIN
                          dbo.TA_Estatus                                EstatusPedido
                                ON EstatusPedido.IdEstatus = OPES.IdEstatusOperacion
                    LEFT JOIN
                          @TablaFechaAprobacionCN                       fechaCarta
                                ON fechaCarta.IdAceptacionPedido = AP.IdAceptacionPedido
                    LEFT JOIN
                          @TablaAceptacionFactura                       factura
                                ON factura.IdAceptacionPedido = AP.IdAceptacionPedido
                                   AND factura.IdSolicitudPedido = sp.IdSolicitudPedido
                    LEFT JOIN
                          @TablaFechaAprobacionFactura                  t2
                                ON t2.IdAceptacionPedido = AP.IdAceptacionPedido
                    LEFT JOIN
                          Adinco.dbo.CO_Contrato                        C
                                ON C.IdContrato = sp.IdContrato
                    LEFT JOIN
                          Adinco.dbo.CO_AreaContractual                 AC
                                ON AC.IdAreaContractual = C.IdAreaContractual
                    LEFT JOIN
                          Adinco.dbo.CO_Instalacion                     inst
                                ON inst.IdInstalacion = spdl.IdInstalacion
             WHERE
                          sp.IdProveedor = @IdProveedor
                          AND sp.IdContrato = @IdContrato
                          AND ISNULL(sp.IdEstatusEliminado, 0) <> 1
             GROUP BY
                  sp.IdSolicitudPedido, sp.MotivoUrgencia, sp.FechaAlta, tao.IdEstatusOperacion, t.FechaCambioEstatus,
                  t.FechaRegistro, p.Cerrado, po.IdPeticionOferta, po.CreadoEl, prov.RazonSocial, prov.IdProveedor,
                  po.FechaFinalizado, p.CreadoElPedido, p.IdPedidos, p.Version, TA1.FechaCambioEstatus,
                  TA2.FechaCambioEstatus, TA3.FechaCambioEstatus, TA4.FechaCambioEstatus, TA5.FechaCambioEstatus,
                  EstatusPedido.Nombre, aprobacion.FechaAprobacionPedido, p.TotalPedido, p.TipoMoneda,
                  p.FechaRecepcionServicio, AP.IdAceptacionPedido, AP.Creado, fechaCarta.CreadoEl,
                  fechaCarta.FechaEvaluacion, factura.FechaRegistro, t2.FechaCambioEstatus, AC.NombreAreaContractual,
                  spdl.IdInstalacion, inst.NombreInstalacion, E.Nombre
             ORDER BY
                  sp.IdSolicitudPedido, p.IdPedidos
      END