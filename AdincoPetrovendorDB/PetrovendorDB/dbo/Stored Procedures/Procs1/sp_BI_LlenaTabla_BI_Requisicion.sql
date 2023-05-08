
CREATE PROCEDURE [dbo].[sp_BI_LlenaTabla_BI_Requisicion]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AprobadoresR TABLE
    (
        IdRequisicion INT,
        AprobadorActual VARCHAR(6000),
        NoSecuenciaInicial INT
    );
    DECLARE @Aprobadores TABLE
    (
        IdRequisicion INT,
        AprobadorActual VARCHAR(6000),
        NoSecuencia INT,
        IdTipoFlujo INT
    );

    DECLARE @SolicitudPedidoDetalle TABLE
    (
        ID_BI_SolicitudPedido INT,
        IdSolicitudPedido INT,
        NoPartidaDetalle INT
    );

    DECLARE @Proveedores TABLE
    (
        IdProveedor INT
    );
    INSERT INTO @Proveedores
    (
        IdProveedor
    )
    VALUES
    (606),
    (676),
    (690),
    (1315),
    (1424),
    (1835);

    DECLARE @PartidaEnPedido TABLE
    (
        IdRequisicion INT,
        IdRequisicionDetalle INT,
        Cantidad FLOAT
    );

    DECLARE @FechaAprobacion TABLE
    (
        IdRequisicion INT,
        FechaAprobacion DATETIME
    );

    DECLARE @DisponibilidadVigCotizacionDetalle TABLE
    (
        IdSolicitudPedido INT,
        OfertaVencida INT
    );

    DECLARE @PedidosPorRequisicion TABLE
    (
        IdSolicitudPedido INT,
        NoPedidos INT
    );

    DECLARE @EstatusCotizacion TABLE
    (
        IdSolicituPedido INT,
        Estatus VARCHAR(1000),
		CantidadProveedoresCotizaron VARCHAR(MAX)
    );

    --CONSULTAR APROBADORES DE PEDIDOS 
    INSERT INTO @Aprobadores
    (
        IdRequisicion,
        AprobadorActual,
        NoSecuencia,
        IdTipoFlujo
    )
    SELECT SP.IdSolicitudPedido,
           U.Nombre,
           TA.NoSecuencia,
           FT.IdTipoFlujo
    FROM @Proveedores PS
        JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
            ON PS.IdProveedor = SP.IdProveedor
        JOIN dbo.TA_Operacion TAO (NOLOCK)
            ON SP.IdSolicitudPedido = TAO.IdDocumento
               AND TAO.IdTipoOperacion = 2 --> APROBACIÓN DE SOLICITUD DE PEDIDO
               AND TAO.IdEstatusOperacion = 1 --> EN APROBACIÓNES DE PEDIDO EN APROBACIÓN   
        JOIN dbo.TA_Tarea TA (NOLOCK)
            ON TAO.IdOperacion = TA.IdOperacion
               AND TA.IdEstatus = 1 --> ESTATUS DE APROBADORES EN APROBACIÓN
               AND TA.Activo = 1 --> APROBADOR ACTIVO
        JOIN dbo.TA_FlujoTarea FT (NOLOCK)
            ON FT.IdFlujoTarea = TAO.IdFlujoTarea
        JOIN dbo.S_Usuario U (NOLOCK)
            ON TA.IdAprobador = U.IdUsuario;

    --AGREGAR APROBADORES SERIALES --> OBTENER EL DE MENOR SECUENCIA 
    INSERT INTO @AprobadoresR
    (
        IdRequisicion,
        AprobadorActual,
        NoSecuenciaInicial
    )
    SELECT A.IdRequisicion,
           '',
           MIN(A.NoSecuencia)
    FROM @Aprobadores A
    WHERE A.IdTipoFlujo = 1 --> --> FLUJO SERIAL 
    GROUP BY A.IdRequisicion;

    UPDATE AR
    SET AR.AprobadorActual = A.AprobadorActual
    FROM @AprobadoresR AR
        INNER JOIN @Aprobadores A
            ON AR.IdRequisicion = A.IdRequisicion
               AND AR.NoSecuenciaInicial = A.NoSecuencia;

    --OBTENER LOS APROBADORES PARALELOS CONCATENADOS 
    INSERT INTO @AprobadoresR
    (
        IdRequisicion,
        AprobadorActual,
        NoSecuenciaInicial
    )
    SELECT A.IdRequisicion,
           (
               SELECT STUFF(
                      (
                          SELECT ', ' + AI.AprobadorActual
                          FROM @Aprobadores AI
                          WHERE A.IdRequisicion = AI.IdRequisicion
                          ORDER BY AI.NoSecuencia ASC
                          FOR XML PATH('')
                      ),
                      1,
                      2,
                      ''
                           )
           ),
           0
    FROM @Aprobadores A
    WHERE A.IdTipoFlujo = 2 --> FLUJO PARALELO
    GROUP BY A.IdRequisicion;


    ---CALCULO DE REQUISICIONES DETALLE QUE ESTAN EN UN PEDIDO
    INSERT INTO @PartidaEnPedido
    (
        IdRequisicion,
        IdRequisicionDetalle,
        Cantidad
    )
    SELECT SP.IdSolicitudPedido,
           SPD.IdSolicitudPedidoDetalle,
           SUM(PD.Cantidad)
    FROM @Proveedores PS
        JOIN dbo.MM_Pedido P (NOLOCK)
            ON PS.IdProveedor = P.IdProveedorCompras
        JOIN dbo.MM_PeticionOferta PO (NOLOCK)
            ON P.IdPeticionOferta = PO.IdPeticionOferta
        JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
            ON P.IdSolicitudPedido = SP.IdSolicitudPedido
        JOIN dbo.MM_PedidoDetalle PD (NOLOCK)
            ON P.IdPedido = PD.IdPedido
        JOIN dbo.MM_PeticionOfertaDetalle POD (NOLOCK)
            ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
               AND PO.IdPeticionOferta = POD.IdPeticionOferta
        JOIN dbo.MM_SolicitudPedidoDetalle SPD (NOLOCK)
            ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
               AND SP.IdSolicitudPedido = SPD.IdSolicitudPedido
    WHERE P.IdEstatusEliminado IS NULL ---> NO ESTE ELIMINADO EL PEDIDO
    GROUP BY SP.IdSolicitudPedido,
             SPD.IdSolicitudPedidoDetalle;

    --OBTENER LA FECHA DE APROBACIÓN DE LA REQUISICIÓN
    INSERT INTO @FechaAprobacion
    (
        IdRequisicion,
        FechaAprobacion
    )
    SELECT SP.IdSolicitudPedido,
           MAX(TA.FechaCambioEstatus)
    FROM @Proveedores PS
        JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
            ON PS.IdProveedor = SP.IdProveedor
        JOIN dbo.TA_Operacion TAO (NOLOCK)
            ON SP.IdSolicitudPedido = TAO.IdDocumento
               AND TAO.IdTipoOperacion = 2 --> APROBACIÓN DE SOLICITUD DE PEDIDO
               AND TAO.IdEstatusOperacion = 2 --> EN APROBACIÓNES DE PEDIDO EN APROBADAS 
        JOIN dbo.TA_Tarea TA (NOLOCK)
            ON TAO.IdOperacion = TA.IdOperacion
               AND TA.Activo = 1 --> APROBADOR ACTIVO
    GROUP BY SP.IdSolicitudPedido;

    ---OBTENER COTIZACIONES POR DETALLE DONDE YA VENCIO LA FECHA DE VIGENCIA DE COTIZACIÓN

    INSERT INTO @DisponibilidadVigCotizacionDetalle
    SELECT SP.IdSolicitudPedido,
           SUM(   CASE
                      WHEN POD.FechaVigencia < GETDATE() THEN
                          1
                      WHEN POD.FechaVigencia > GETDATE() THEN
                          0
                  END
              )
    FROM @Proveedores PV
        JOIN MM_SolicitudPedido AS SP (NOLOCK)
            ON SP.IdProveedor = PV.IdProveedor
        JOIN MM_PeticionOferta AS PO (NOLOCK)
            ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
        JOIN MM_PeticionOfertaDetalle AS POD (NOLOCK)
            ON PO.IdPeticionOferta = POD.IdPeticionOferta
        JOIN dbo.MM_SolicitudPedidoDetalle SPD (NOLOCK)
            ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
               AND SP.IdSolicitudPedido = SPD.IdSolicitudPedido
    WHERE POD.Cotizado = 1
          AND POD.FechaVigencia IS NOT NULL
    GROUP BY SP.IdSolicitudPedido;


    --OBTENER LA CANTIDAD DE PEDIDOS DE LAS REQUISICIONES DE LOS PROVEEDORES SELECCIONADOS 
    INSERT INTO @PedidosPorRequisicion
    (
        IdSolicitudPedido,
        NoPedidos
    )
    SELECT SP.IdSolicitudPedido,
           COUNT(P.IdPedido)
    FROM @Proveedores PC
        JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
            ON PC.IdProveedor = SP.IdProveedor
        JOIN dbo.MM_Pedido AS P (NOLOCK)
            ON SP.IdSolicitudPedido = P.IdSolicitudPedido
               AND ISNULL(P.IdEstatusEliminado, 0) = 0 --> PEDIDO ESTE ACTIVO
    GROUP BY SP.IdSolicitudPedido;


    -- OBTENER EL ESTATUS DE LAS REQUISICIONES QUE YA ESTAN EN COTIZACIÓN DE LOS PROVEEDORES SELECCIONADOS 
    INSERT INTO @EstatusCotizacion
    (
        IdSolicituPedido,
        Estatus,
		CantidadProveedoresCotizaron
    )
    SELECT SP.IdSolicitudPedido,
           (CASE
                WHEN (DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) < 0) THEN
                    'EN COTIZACIÓN'
                WHEN DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) > 0
                     AND (PR.NoPedidos) >= 1 THEN
                    'COTIZACION CON OC ADJUDICADA'
                WHEN DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) > 0
                     AND (SUM(   CASE
                                     WHEN
                                     (
                                         PO.NoCotizar = 1
                                         OR PO.Cotizado = 1
                                     ) THEN
                                         1
                                     ELSE
                                         0
                                 END
                             )
                         ) >= 1 THEN
                    'COTIZACION FINALIZADA'
                WHEN DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) > 0
                     AND (SUM(   CASE
                                     WHEN
                                     (
                                         PO.NoCotizar = 1
                                         OR PO.Cotizado = 1
                                     ) THEN
                                         1
                                     ELSE
                                         0
                                 END
                             )
                         ) < 1 THEN
                    'FINALIZADA PROVEEDOR NO COTIZÓ'
            END
           ) + (CASE
                    WHEN DPOD.OfertaVencida > 0 THEN
                        ' / ALGUNAS COTIZACIONES VENCIDAS'
                    WHEN DPOD.OfertaVencida = 0 THEN
                        ' / OFERTA(s) DE PROVEEDOR VIGENTE'
                    ELSE
                        ' '
                END
               ),
			CAST(SUM(CASE
                            WHEN PO.NoCotizar = 1 THEN
                                1
                            ELSE
                                CASE
                                    WHEN PO.Cotizado = 1 THEN
                                        1
                                    ELSE
                                        0
                                END
                        END
                    ) AS NVARCHAR(MAX)) + '/' + CAST(COUNT(PO.IdPeticionOferta) AS NVARCHAR(MAX)) AS ProveedoresCotizaron
    FROM @Proveedores PV
        JOIN MM_SolicitudPedido AS SP (NOLOCK)
            ON PV.IdProveedor = SP.IdProveedor
        JOIN TA_Operacion AS O (NOLOCK)
            ON SP.IdSolicitudPedido = O.IdDocumento
               AND O.IdTipoOperacion = 6 --> OPERACIÓN DE COTIZACIÓN
        LEFT JOIN dbo.MM_PeticionOferta AS PO (NOLOCK)
            ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
        LEFT JOIN @PedidosPorRequisicion AS PR
            ON SP.IdSolicitudPedido = PR.IdSolicitudPedido
        LEFT JOIN @DisponibilidadVigCotizacionDetalle DPOD
            ON SP.IdSolicitudPedido = DPOD.IdSolicitudPedido
    GROUP BY SP.IdSolicitudPedido,
             O.FechaFinalizacion,
             PR.NoPedidos,
             DPOD.OfertaVencida;

    TRUNCATE TABLE BI_Requisicion;
    INSERT INTO dbo.BI_Requisicion
    (
        IdUnicoDeRequisicion,
        Contrato,
        FechaRegistro,
        Solicitante,
        IdRequisicion,
        Periodo,
        Presupuesto,
        EstatusRequisicion,
        Tarea,
        Subtarea,
        NombreInstalacion,
        LugarEntrega,
        Concepto,
        Descripcion,
        AprobadorActual,
        IdSolicitudPedidoDetalle,
        TienePedido,
        FechaAprobacion,
        EstatusCotizacion,
        DescripcionGral,
        ObservacionPartidaReq,
		Modelo,
		Marca,
		NumeroParte,
		CentroCosto,
		CantidadProveedoresCotizaron
    )
    SELECT R.IdSolicitudPedido AS 'idunico de requisicion',
           C.NumeroContrato AS 'Contrato',
           R.FechaAlta AS 'FechaRegistro',
           U.Nombre AS 'Solicitante',
           R.IdSolicitudPedido AS 'IdRequisicion',
           '' AS 'Periodo', -->(Plan) PC.NombrePeriodo
           P.Nombre AS 'Presupuesto',
           E.Nombre AS 'Estatus Requisición',
           TP.id_Tarea AS 'Tarea',
           ST.NombreServicio AS 'Subtarea',
           I.NombreInstalacion AS 'Nombre Instalacion',
           CONCAT(
                     ISNULL(D.Calle, ''),
                     ' Colonia ',
                     ISNULL(D.Colonia, ''),
                     ' CP ',
                     ISNULL(D.CodigoPostal, ''),
                     ' ',
                     ISNULL(D.Municipio, ''),
                     ' ',
                     ISNULL(D.Estado, '')
                 ) AS 'Lugar entrega',
           M.DescripcionCorta AS 'Concepto',
           M.DescripcionLarga AS 'Descripción',
           AR.AprobadorActual AS 'Aprobador actual',
           SPD.IdSolicitudPedidoDetalle AS 'Partida',
           CASE
               WHEN ISNULL(PD.Cantidad, 0) > 0 THEN
                   'Si'
               ELSE
                   'No'
           END AS 'Tiene Pedido',
           FA.FechaAprobacion AS 'Fecha Aprobacion',
           CASE
               WHEN ISNULL(R.PeticionEnviada, 0) = 0
                    AND TAO.IdEstatusOperacion = 2 THEN
                   'SIN ENVIAR A COTIZACIÓN'
               WHEN ISNULL(R.PeticionEnviada, 0) = 1
                    AND TAO.IdEstatusOperacion = 2 THEN
                   EC.Estatus
               ELSE
                   ''
           END AS EstatusCotizacion,
           R.MotivoUrgencia AS 'Descripcion pedido',
           SPD.observaciones AS 'Observacion detalle requisicion',
		   M.Modelo,
		   M.Marca,
		   M.NumeroParte,
		   CC.CentroCosto,
		   EC.CantidadProveedoresCotizaron
    FROM @Proveedores EP
        JOIN MM_SolicitudPedido AS R (NOLOCK)
            ON EP.IdProveedor = R.IdProveedor
        JOIN S_Usuario AS U (NOLOCK)
            ON R.IdUsuarioSolicitante = U.IdUsuario
        JOIN TA_Operacion AS TAO (NOLOCK)
            ON R.IdSolicitudPedido = TAO.IdDocumento
               AND TAO.IdTipoOperacion = 2 --> APROBACIÓN DE SOLICITUD DE PEDIDO 
        JOIN TA_Estatus AS E (NOLOCK)
            ON TAO.IdEstatusOperacion = E.IdEstatus
        JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
            ON R.IdContrato = C.IdContrato
        JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
            ON R.IdSolicitudPedido = SPD.IdSolicitudPedido
        JOIN dbo.MM_Material M (NOLOCK)
            ON SPD.IdMaterial = M.IdMaterial
        JOIN DG_Domicilio AS D (NOLOCK)
            ON SPD.IdDomicilioEntrega = D.IdDomicilio
        LEFT JOIN @EstatusCotizacion EC
            ON R.IdSolicitudPedido = EC.IdSolicituPedido
        JOIN MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDL (NOLOCK)
            ON SPD.IdSolicitudPedidoDetalle = SPDL.IdSolicitudPedidoDetalle
		LEFT JOIN CC_CentroCosto AS CC (NOLOCK)
			ON SPDL.IdCentroCosto=CC.IdCentroCosto
        LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS L (NOLOCK)
            ON SPDL.IdLineaPresupuesto = L.IdLineaPresupuestoMes
        LEFT JOIN Adinco.dbo.CO_Presupuesto AS P (NOLOCK)
            ON R.IdPresupuesto = P.IdPresupuesto
        LEFT JOIN Adinco.dbo.CO_TareaPetrolera AS TP (NOLOCK)
            ON L.IdTareaPetrolera = TP.IdTareaPetrolera
        LEFT JOIN Adinco.dbo.CO_Servicio AS ST (NOLOCK)
            ON L.IdServicio = ST.IdServicio
        LEFT JOIN Adinco.dbo.CO_ProgramaActividad AS PA (NOLOCK)
            ON P.IdProgramaActividad = PA.IdProgramaActividad
        LEFT JOIN Adinco.dbo.CO_Instalacion AS I (NOLOCK)
            ON SPDL.IdInstalacion = I.IdInstalacion
        LEFT JOIN @AprobadoresR AS AR
            ON R.IdSolicitudPedido = AR.IdRequisicion
        LEFT JOIN @FechaAprobacion FA
            ON R.IdSolicitudPedido = FA.IdRequisicion
        LEFT JOIN @PartidaEnPedido PD
            ON SPD.IdSolicitudPedidoDetalle = PD.IdRequisicionDetalle
               AND SPD.IdSolicitudPedido = PD.IdRequisicion
    WHERE R.IdEstatusEliminado IS NULL; ---> NO ESTE ELIMINADO LA SOLICITUD DE PEDIDO

    --OBTENER NUMERO CONSECUTIVO POR SOLICITUD PEDIDO DETALLE 
    INSERT INTO @SolicitudPedidoDetalle
    (
        ID_BI_SolicitudPedido,
        IdSolicitudPedido,
        NoPartidaDetalle
    )
    SELECT ID_BI_SolicitudPedido,
           IdRequisicion,
           ROW_NUMBER() OVER (PARTITION BY IdRequisicion ORDER BY IdSolicitudPedidoDetalle)
    FROM dbo.BI_Requisicion
    GROUP BY ID_BI_SolicitudPedido,
             IdRequisicion,
             IdSolicitudPedidoDetalle
    ORDER BY IdRequisicion ASC;

    --ACTUALIZAR CONSECUTIVO DE SOLICITUD PEDIDO DETALLE 
    UPDATE R
    SET R.NoPartidaDetalle = SPD.NoPartidaDetalle
    FROM BI_Requisicion R
        JOIN @SolicitudPedidoDetalle SPD
            ON R.ID_BI_SolicitudPedido = SPD.ID_BI_SolicitudPedido;

--SE REPITE EL NO PEDIDO Y EL IDPEDIDOUNICO POR QUE PUEDE SER QUE EXISTAN MÁS DE UN PEDIDO DETALLE (PARTIDA) POR CABECERA DE PEDIDO
--EL NUMERO DE REQUISICION SE REPITE YA QUE UN PEDIDO CABECERA PUEDE TENER N PEDIDOS 
END;