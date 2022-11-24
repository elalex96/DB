-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <25/05/2020>
-- Description:	<Consulta de proceso de oferta para DEA>
-- =============================================
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <24/09/2020>
-- Description:	<Se agrego tabla de @Contratos, y columnas Contrato, AreaContractual>
-- =============================================
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <25/01/2021>
-- Description:	<Se cambio referencia de fecha de cotización de pet oferda a ta_operacion donde sea de tipo cotización>
-- =============================================
CREATE PROCEDURE [dbo].[SP_VIEW_DEA_ConsultaProcesoOferta_Estatus]
-- Add the parameters for the stored procedure here

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	DECLARE @Contratos TABLE
    (
        ContratoId INT NOT NULL
    );
    INSERT INTO @Contratos
    (
        ContratoId
    )
    VALUES
--    (3),   --> MEXICO PRUEBAS
--	(10005),-->TECOLUTLA
    (10038), --> CNH-A4.OGARRIO/2018
    (10044), --> CNH-R03-L01-G-TMV-02/2018
    (10045), --> CNH-R03-L01-G-TMV-03/2018
    (10046), --> CNH-R03-L01-AS-CS-14/2018
    (10144), --> CNH-DEMMA
	(10145); --> CNH-WD ADMIN  

    --DECLARE @IDCONTRATO INT = (10038);
    --DECLARE @IDCONTRATO INT = (3);

    DECLARE @CENTROSCOSTOS TABLE
    (
        IdSolicitudPedido INT,
        CentroCosto NVARCHAR(100)
    );
    DECLARE @COMPRADORASIGNADO1 TABLE
    (
        IdSolicitudPedido INT,
        CompradorAsignado NVARCHAR(100),
        IdAsigando INT,
        FechaAsignado DATETIME
    );
    DECLARE @PROCURA TABLE
    (
        IdSolicitudPedido INT,
        Folio NVARCHAR(MAX),
        Descripcion NVARCHAR(MAX),
        CentroCosto NVARCHAR(MAX),
        FechaRegistroSolicitudPedido DATETIME,
        CompradorAsignado1 NVARCHAR(MAX),
        Fecha1raAsignacion DATETIME,
        Comprador NVARCHAR(100),
        NumeroProveedores INT,
        FechaEnvioCotizacion NVARCHAR(100),
        FechaVigenciaCotizacion DATETIME,
        FechaRecepcion1raCotizacion DATETIME,
        FechaRecepcionUltimaCotizacion DATETIME,
        UsuarioEnviaPedido NVARCHAR(100),
        FechaEnvioPedido DATETIME,
        FechaConfirmacionPedido DATETIME,
        AprobadorPedido NVARCHAR(100),
        FechaAprobacionPedido DATETIME,
        EstatusAprobacionPedido NVARCHAR(100),
        NumeroPedido INT,
        FechaRecepcionPOSAP DATETIME,
        NumeroPOSAP NVARCHAR(100),
        FechaRelacionPOSAP DATETIME,
        EstatusFinal NVARCHAR(100),
        FechaRegistroAprobacion DATETIME,
        NumeroProveedoresCotizaron INT,
        UsuarioRelacionPOSAP NVARCHAR(100),
        Requisitor NVARCHAR(100),
		ContratoId INT,
		Contrato NVARCHAR(MAX),
		AreaContractual NVARCHAR(MAX)
    );

    DECLARE @CENTROSCOSTOSOT TABLE
    (
        IdSolicitudPedido INT,
        CentroCosto NVARCHAR(100)
    );
    INSERT INTO @CENTROSCOSTOSOT
    SELECT DISTINCT
           SPC.IdSolicitudPedido,
           CC.CentroCosto
    FROM  @Contratos C  
		JOIN dbo.MM_SolicitudPedido AS SPC (NOLOCK)
		ON C.ContratoId=SPC.IdContrato
        LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD  (NOLOCK)
            ON SPC.IdSolicitudPedido = SPD.IdSolicitudPedido 
        LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP (NOLOCK)
            ON SPD.IdSolicitudPedidoDetalle = SPLP.IdSolicitudPedidoDetalle 
        LEFT JOIN dbo.CC_CentroCosto AS CC (NOLOCK)
            ON  SPLP.IdCentroCosto =CC.IdCentroCosto 
    WHERE          
          (
              CC.CentroCosto IS NOT NULL
              OR CC.CentroCosto <> ''
          );

    --SE OBTIENEN LOS CC POR CONTRATO Y SOLPED
    INSERT INTO @CENTROSCOSTOS
    SELECT DISTINCT
           SPC.IdSolicitudPedido,
           CC.CentroCosto
    FROM @Contratos C 
		JOIN dbo.MM_SolicitudPedido AS SPC (NOLOCK)
		ON C.ContratoId=SPC.IdContrato
        LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
            ON SPC.IdSolicitudPedido = SPD.IdSolicitudPedido 
        LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP (NOLOCK)
            ON SPD.IdSolicitudPedidoDetalle= SPLP.IdSolicitudPedidoDetalle
        LEFT JOIN dbo.CC_CentroCosto AS CC (NOLOCK)
            ON SPLP.IdCentroCosto = CC.IdCentroCosto 
    WHERE (
              CC.CentroCosto IS NOT NULL
              OR CC.CentroCosto <> ''
          );

    INSERT INTO @COMPRADORASIGNADO1
    SELECT SP.IdSolicitudPedido,
           U.Nombre,
           SPC.IdSolicitudPedidoComprador,
           SPC.CreadoEl
    FROM dbo.MM_SolicitudPedidoComprador SPC (NOLOCK)
		JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
            ON  SPC.IdSolicitudPedido= SP.IdSolicitudPedido
		JOIN @Contratos C
		ON SP.IdContrato=C.ContratoId
        JOIN dbo.S_Usuario U (NOLOCK)
            ON SPC.IdAsignadoA = U.IdUsuario 
    ORDER BY SPC.IdSolicitudPedidoComprador ASC;

    INSERT INTO @PROCURA
    (
        IdSolicitudPedido,
        Descripcion,
        CentroCosto,
        FechaRegistroSolicitudPedido,
        CompradorAsignado1,
        Fecha1raAsignacion,
        Comprador,
        NumeroProveedores,
        FechaEnvioCotizacion,        
        FechaRecepcion1raCotizacion,
        FechaRecepcionUltimaCotizacion,
        UsuarioEnviaPedido,
        FechaEnvioPedido,
        AprobadorPedido,
        FechaAprobacionPedido,
        EstatusAprobacionPedido,
        NumeroPedido,
        FechaRecepcionPOSAP,
        NumeroPOSAP,
        FechaRelacionPOSAP,
        EstatusFinal,
        FechaRegistroAprobacion,
        NumeroProveedoresCotizaron,
        FechaConfirmacionPedido,
        FechaVigenciaCotizacion,
        UsuarioRelacionPOSAP,
        Requisitor,
		ContratoId
    )
    SELECT SP.IdSolicitudPedido,
           Descripcion=SP.MotivoUrgencia,
           CentroCosto=CC.CentroCosto,
           FechaRegistroSolicitudPedido=SP.FechaAlta,
           CompradorAsignado1=ISNULL(
           (
               SELECT TOP 1
                      CompradorAsignado
               FROM @COMPRADORASIGNADO1
               WHERE IdSolicitudPedido = SP.IdSolicitudPedido
               ORDER BY IdAsigando ASC
           ),
           USPED.Nombre),
           Fecha1raAsignacion=ISNULL(   PRA.CreadoEl,
           (
               SELECT TOP 1
                      Fecha
               FROM dbo.TA_HistorialFlujoTarea (NOLOCK)
               WHERE IdOperacion = OPPR.IdOperacion
                     AND IdEstadoFlujo = 7
               ORDER BY Fecha DESC
           )
                 ),
           Comprador=USPED.Nombre,
           NumeroProveedores=(
               SELECT COUNT(IdPeticionOferta)
               FROM dbo.MM_PeticionOferta  (NOLOCK)
               WHERE IdSolicitudPedido = SP.IdSolicitudPedido
                     AND ISNULL(IdEliminado, 0) = 0
           ),
           FechaEnvioCotizacion=OPF.FechaRegistro, --> FECHA DE ENVIO DE COTIZACIÓN		             
           FechaRecepcion1raCotizacion=(
               SELECT TOP 1
                      FechaFinalizado
               FROM dbo.MM_PeticionOferta  (NOLOCK)
               WHERE IdSolicitudPedido = SP.IdSolicitudPedido
                     AND ISNULL(IdEliminado, 0) = 0
                     AND Cotizado = 1
               ORDER BY FechaFinalizado ASC
           ),
           FechaRecepcionUltimaCotizacion=(
               SELECT TOP 1
                      FechaFinalizado
               FROM dbo.MM_PeticionOferta  (NOLOCK)
               WHERE IdSolicitudPedido = SP.IdSolicitudPedido
                     AND ISNULL(IdEliminado, 0) = 0
                     AND Cotizado = 1
               ORDER BY FechaFinalizado DESC
           ),
           UsuarioEnviaPedido=USEP.Nombre,
           FechaEnvioPedido=P.CreadoEl,
           AprobadorPedido=(
               SELECT TOP 1
                      USI.Nombre
               FROM dbo.TA_Tarea AS TI  (NOLOCK)
				LEFT JOIN dbo.S_Usuario AS USI  (NOLOCK)
                       ON TI.IdAprobador=USI.IdUsuario 
               WHERE TI.IdOperacion = OP.IdOperacion
                     AND TI.IdEstatus <> 1
               ORDER BY TI.FechaCambioEstatus DESC
           ),
           FechaAprobacionPedido=(
               SELECT TOP 1
                      Fecha
               FROM dbo.TA_HistorialFlujoTarea  (NOLOCK)
               WHERE IdOperacion = OP.IdOperacion
                     AND IdEstadoFlujo = 2
               ORDER BY Fecha DESC
           ),
           EstatusAprobacionPedido=(
               SELECT TOP 1
                      EST.Nombre
               FROM dbo.TA_Tarea AS TS  (NOLOCK)
                   LEFT JOIN dbo.TA_Estatus AS EST  (NOLOCK)
                       ON TS.IdEstatus = EST.IdEstatus  
               WHERE TS.IdOperacion = OP.IdOperacion --AND TS.IdEstadoFlujo = 2 
               ORDER BY TS.FechaCambioEstatus DESC
           ),
           NumeroPedido=PS.IdPedido,
           FechaRecepcionPOSAP=PO.CreadoEl,
           NumeroPOSAP=PO.ID_PO,
           FechaRelacionPOSAP=PRPO.FechaAltaRelacion,
           EstatusFinal=ES.Nombre,
           FechaRegistroAprobacion=OP.FechaRegistro,
           NumeroProveedoresCotizaron=(
               SELECT COUNT(IdPeticionOferta)
               FROM dbo.MM_PeticionOferta  (NOLOCK)
               WHERE IdSolicitudPedido = SP.IdSolicitudPedido
                     AND ISNULL(IdEliminado, 0) = 0
                     AND Cotizado = 1
           ),
           FechaConfirmacionPedido=P.FechaRecepcionServicio,
           FechaVigenciaCotizacion=OPF.FechaFinalizacion,
           UsuarioRelacionPOSAP=USRPO.Nombre,
           Requisitor=USR.Nombre,
		   ContratoId=SP.IdContrato
    FROM @Contratos C  
		JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
		ON C.ContratoId=SP.IdContrato
        LEFT JOIN dbo.DEA_AdjuntoPR AS PRA (NOLOCK)
            ON SP.IdSolicitudPedido = PRA.IdSolicitudPedido 
        LEFT JOIN dbo.TA_Operacion AS OPPR (NOLOCK)
            ON SP.IdSolicitudPedido = OPPR.IdDocumento
               AND SP.IdProveedor=OPPR.IdProveedor 
               AND OPPR.IdTipoOperacion = 2 --> APROBACIÓN DE SOLICITUD DE PEDIDO
               AND OPPR.IdEstatusOperacion = 2 --> APROBACIÓN CON ESTATUS APROBADA
        LEFT JOIN @CENTROSCOSTOS AS CC
            ON SP.IdSolicitudPedido = CC.IdSolicitudPedido 
        LEFT JOIN dbo.MM_PeticionOferta AS POF (NOLOCK)
            ON SP.IdSolicitudPedido=POF.IdSolicitudPedido
        LEFT JOIN dbo.TA_Operacion AS OPF (NOLOCK)
            ON SP.IdSolicitudPedido=OPF.IdDocumento 
               AND OPF.IdTipoOperacion = 6 --> OPERACION DE COTIZACION
        LEFT JOIN dbo.MM_Pedido AS P (NOLOCK)
            ON SP.IdSolicitudPedido=P.IdSolicitudPedido 
               AND ISNULL(P.IdEstatusEliminado, 0) = 0
        LEFT JOIN dbo.TA_Operacion AS OP (NOLOCK)
            ON SP.IdSolicitudPedido=OP.IdDocumento
               AND OP.IdTipoOperacion = 9  --> APROBACIÓN DE PEDIDO
               AND OP.NoVersion = P.Version  --> MISMO NUMERO DE VERSION DEL PEDIDO Y LA APROBACIÓN
        LEFT JOIN dbo.TA_Estatus AS ES (NOLOCK)
            ON OP.IdEstatusOperacion=ES.IdEstatus 
        LEFT JOIN dbo.MM_Pedidos AS PS (NOLOCK)
            ON P.IdPedido = PS.IdIdentificador
               AND P.IdProveedorCompras = PS.IdProveedorCliente 
        LEFT JOIN dbo.DEA_Relacion_PR_PO AS PRPO (NOLOCK)
            ON P.IdPedido=PRPO.IdPedido 
               AND PRPO.Activo = 1
        LEFT JOIN dbo.DEA_AdjuntoPO AS PO (NOLOCK)
            ON PRPO.IdAdjuntoPO = PO.IdAdjuntoPO 
        LEFT JOIN dbo.S_Usuario AS USPED (NOLOCK)
            ON  P.CreadoPor = USPED.IdUsuario 
        --LEFT JOIN dbo.TA_Operacion AS OPSP
        --	ON OPSP.IdDocumento = SP.IdSolicitudPedido
        --	AND OPSP.IdTipoOperacion = 2
        LEFT JOIN dbo.S_Usuario AS USRE (NOLOCK)
            ON SP.IdUsuarioSolicitante=USRE.IdUsuario 
        LEFT JOIN dbo.S_Usuario AS USEP (NOLOCK)
            ON  P.CreadoPor=USEP.IdUsuario
        LEFT JOIN dbo.S_Usuario AS USRPO (NOLOCK)
            ON PRPO.CreadoPor = USRPO.IdUsuario 
        LEFT JOIN dbo.S_Usuario AS USR (NOLOCK)
            ON SP.IdUsuarioSolicitante=USR.IdUsuario 
        LEFT JOIN Adinco.dbo.OT_Estimacion estima (NOLOCK)
            ON P.IdPedido=estima.IdPedido 
    WHERE --SP.IdContrato = @IDCONTRATO
          --AND POF.IdPeticionOferta IS NOT NULL AND
          ISNULL(SP.IdEstatusEliminado, 0) = 0
          AND ISNULL(P.IdEstatusEliminado, 0) = 0
          AND estima.IdOTEstimacion IS NULL; -- que no venga de una OT

	
	--ACTUALIZAR COLUMNA DE NUMERO DE CONTRATO 
	UPDATE PRO
	SET PRO.Contrato=C.NumeroContrato,
	PRO.AreaContractual=AC.NombreAreaContractual
	FROM @PROCURA PRO
	JOIN Adinco..CO_Contrato C (NOLOCK)
	ON PRO.ContratoId=C.IdContrato
	JOIN Adinco..CO_AreaContractual AC (NOLOCK)
	ON C.IdAreaContractual=AC.IdAreaContractual

    SELECT PROCU.IdSolicitudPedido,
           Folio=ISNULL(PROCU.Folio, 'N/A'),
           PROCU.Descripcion,
           PROCU.CentroCosto,
           PROCU.FechaRegistroSolicitudPedido,
           PROCU.Requisitor,
           PROCU.CompradorAsignado1,
           PROCU.Fecha1raAsignacion AS Fecha1aAsignacion,
           CompradorAsignado2=(
               SELECT STUFF(
                      (
                          SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre, '') --+ CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA )
                          FROM dbo.MM_SolicitudPedidoComprador SPC (NOLOCK)
                              INNER JOIN dbo.S_Usuario U (NOLOCK)
                                  ON SPC.IdAsignadoA=U.IdUsuario 
                              LEFT JOIN dbo.S_TipoUsuario TU (NOLOCK)
                                  ON U.IdTipoUsuario=TU.IdTipoUsuario
                          WHERE SPC.IdSolicitudPedido = PROCU.IdSolicitudPedido
                                AND U.Nombre <> CompradorAsignado1
                                AND SPC.Activo = 1
                          GROUP BY U.Nombre,
                                   TU.NombreTipoUsuario
                          FOR XML PATH('')
                      ),
                      1,
                      1,
                      ''
                           )
           ),
           Fecha2Asignacion=(
               SELECT TOP 1
                      FechaAsignado
               FROM @COMPRADORASIGNADO1
               WHERE IdSolicitudPedido = PROCU.IdSolicitudPedido
                     AND CompradorAsignado <> PROCU.CompradorAsignado1
               ORDER BY IdAsigando ASC
           ),
           PROCU.Comprador,
           PROCU.NumeroProveedores,
           PROCU.FechaEnvioCotizacion,
           PROCU.NumeroProveedoresCotizaron,
           PROCU.FechaRecepcion1raCotizacion,
           FechaRecepcionUltimaCotizacion=CASE
               WHEN PROCU.NumeroProveedores = 1
                    AND PROCU.FechaRecepcion1raCotizacion IS NOT NULL THEN
                   FechaRecepcion1raCotizacion
               ELSE
                   PROCU.FechaRecepcionUltimaCotizacion
           END,
           DiasRecepcionCotizacion=(CASE
                WHEN FechaRecepcionUltimaCotizacion IS NOT NULL THEN
                    CONVERT(DECIMAL(5, 2), dbo.CalcularTipoDEA(FechaEnvioCotizacion, FechaRecepcionUltimaCotizacion))
                ELSE
                    0
            END
           ),
           PROCU.UsuarioEnviaPedido,
           PROCU.FechaEnvioPedido,
           PROCU.NumeroPedido,
           ISNULL(PROCU.AprobadorPedido, '') AS AprobadorPedido,
           PROCU.FechaAprobacionPedido,
           DiasAprobacionPedido=(CASE
                WHEN FechaAprobacionPedido IS NOT NULL THEN
                    CONVERT(DECIMAL(5, 2), dbo.CalcularTipoDEA(FechaEnvioPedido, FechaAprobacionPedido))
                ELSE
                    0
            END
           ),
           PROCU.FechaConfirmacionPedido,
           DiasConfirmacionPedido=(CASE
                WHEN FechaConfirmacionPedido IS NOT NULL THEN
                    CONVERT(DECIMAL(5, 2), dbo.CalcularTipoDEA(FechaAprobacionPedido, FechaConfirmacionPedido))
                ELSE
                    0
            END
           ),
           PROCU.EstatusAprobacionPedido,
           PROCU.FechaRecepcionPOSAP,
           NumeroPOSAP=REPLACE(
                      (REPLACE((REPLACE(PROCU.NumeroPOSAP, 'Fwd: Orden de Compra', '')), 'SAP PO ', '')),
                      'FW: Orden de Compra  ',
                      ''
                  ),
           DiasRecepcionPOSAP=(CASE
                WHEN FechaRecepcionPOSAP IS NOT NULL THEN
                    CONVERT(DECIMAL(5, 2), dbo.CalcularTipoDEA(FechaRecepcionPOSAP, FechaAprobacionPedido))
                ELSE
                    0
            END
           ),
           PROCU.FechaRelacionPOSAP,
           DiasRelacionPOSAP=(CASE
                WHEN FechaRelacionPOSAP IS NOT NULL THEN
                    CONVERT(DECIMAL(5, 2), dbo.CalcularTipoDEA(FechaRecepcionPOSAP, FechaRelacionPOSAP))
                ELSE
                    0
            END
           ),
           DiasTotal=(CASE
                WHEN FechaRelacionPOSAP IS NOT NULL THEN
                    CONVERT(DECIMAL(5, 2), dbo.CalcularTipoDEA(FechaEnvioCotizacion, FechaRelacionPOSAP))
                ELSE
                    0
            END
           ),
           PROCU.EstatusFinal,
           PROCU.FechaVigenciaCotizacion,
           PROCU.UsuarioRelacionPOSAP,
		   PROCU.ContratoId,
		   PROCU.Contrato,
		   PROCU.AreaContractual
    INTO #DATOSOFERTA
    FROM @PROCURA AS PROCU
    ORDER BY PROCU.IdSolicitudPedido DESC;
	
    TRUNCATE TABLE dbo.DEA_ProcesoOferta_Estatus;

    INSERT INTO dbo.DEA_ProcesoOferta_Estatus
    (
        IdSolicitudPedido,
        Folio,
        Descripcion,
        CentroCosto,
        Requisitor,
        FechaRegistroSolicitudPedido,
        Fecha1aAsignacionFechaCargaPR,
        CompradorAsignado1,
        Fecha2aAsignacion,
        CompradorAsignado2,
        Dias2aAsignacion,
        Comprador,
        NumeroProveedores,
        FechaEnvioCotizacion,
        DiasEnvioCotizacion,
        DiasSolicitudOferta,
        NumeroProveedoresCotizaron,
        FechaRecepcionUltimaCotizacion,
        DiasRecepcionUltimaCotizacion,
        UsuarioEnviaPedido,
        FechaEnvioPedido,
        NumeroPedido,
        DiasEnvioPedido,
        AprobadorPedido,
        FechaAprobacionPedido,
        DiasAprobacionPedido,
        EstatusAprobacionPedido,
        DiasAsignacionProveedor,
        UsuarioRelacionPOSAP,
        NumeroPOSAP,
        FechaRelacionPOSAP,
        DiasRelacionPOSAP,
        FechaConfirmacionPedido,
        DiasConfirmacionPedido,
        DiasTotal,
        EstatusFinal,
		Contrato,
		AreaContractual
    )
    SELECT IdSolicitudPedido=ISNULL(CAST(T.IdSolicitudPedido AS NVARCHAR(100)), ''),
           Folio=ISNULL(Folio, ''),
           Descripcion=ISNULL(Descripcion, ''),
           CentroCosto=ISNULL(CentroCosto, ''),
           Requisitor=ISNULL(Requisitor, ''),
           FechaRegistroSolicitudPedido=FechaRegistroSolicitudPedido,
           Fecha1aAsignacionFechaCargaPR=Fecha1aAsignacion,
           CompradorAsignado1=ISNULL(CompradorAsignado1, ''),
           Fecha2aAsignacion=Fecha2Asignacion,
           CompradorAsignado2=ISNULL(CompradorAsignado2, ''),
           Dias2aAsignacion=(CASE
                WHEN Fecha2Asignacion IS NOT NULL THEN
           (dbo.CalcularTipoDEA(Fecha1aAsignacion, Fecha2Asignacion))
                ELSE
                    ''
            END
           ),
           Comprador=ISNULL(Comprador, ''),
           NumeroProveedores=REPLACE(ISNULL(CONVERT(INT, NumeroProveedores), 0), '0', ''),
           FechaEnvioCotizacion=FechaEnvioCotizacion,
           DiasEnvioCotizacion=(CASE
                WHEN FechaEnvioCotizacion IS NOT NULL THEN
           (dbo.CalcularTipoDEA(Fecha2Asignacion, FechaEnvioCotizacion))
                ELSE
                    ''
            END
           ), --
           DiasSolicitudOferta=(CASE
                WHEN FechaEnvioCotizacion IS NOT NULL THEN
           (dbo.CalcularTipoDEA(Fecha1aAsignacion, FechaEnvioCotizacion))
                ELSE
                    ''
            END
           ),
           NumeroProveedoresCotizaron=REPLACE(ISNULL(CONVERT(INT, NumeroProveedoresCotizaron), 0), '0', ''),
           FechaRecepcionUltimaCotizacion=CASE
               WHEN FechaVigenciaCotizacion < GETDATE() THEN
                   CONVERT(VARCHAR, FechaRecepcionUltimaCotizacion, 20)
               WHEN NumeroProveedores = NumeroProveedoresCotizaron THEN
                   CONVERT(VARCHAR, FechaRecepcionUltimaCotizacion, 20)
               WHEN FechaVigenciaCotizacion > GETDATE()
                    AND FechaRecepcionUltimaCotizacion IS NOT NULL THEN
                   NULL
           END,
           DiasRecepcionCotizacion=(CASE
                WHEN FechaRecepcionUltimaCotizacion IS NULL THEN
                    ''
                WHEN FechaVigenciaCotizacion < GETDATE() THEN
           (dbo.CalcularTipoDEA(FechaEnvioCotizacion, FechaRecepcionUltimaCotizacion))
                WHEN NumeroProveedores = NumeroProveedoresCotizaron THEN
           (dbo.CalcularTipoDEA(FechaEnvioCotizacion, FechaRecepcionUltimaCotizacion))
                WHEN FechaVigenciaCotizacion > GETDATE() THEN
                    ''
            END
           ),
           UsuarioEnviaPedido=ISNULL(UsuarioEnviaPedido, ''),
           FechaEnvioPedido=FechaEnvioPedido,
           NumeroPedido=ISNULL(CAST(NumeroPedido AS NVARCHAR(100)), ''),
           DiasEnvioPedido=(CASE
                WHEN FechaEnvioPedido IS NOT NULL THEN
           (dbo.CalcularTipoDEA(FechaRecepcionUltimaCotizacion, FechaEnvioPedido))
                ELSE
                    ''
            END
           ),
           AprobadorPedido,
           FechaAprobacionPedido=FechaAprobacionPedido,
           DiasAprobacionPedido=(CASE
                WHEN FechaAprobacionPedido IS NOT NULL THEN
           (dbo.CalcularTipoDEA(FechaEnvioPedido, FechaAprobacionPedido))
                ELSE
                    ''
            END
           ),
           EstatusAprobacionPedido=ISNULL(EstatusAprobacionPedido, ''),
           DiasAsignacionProveedor=CASE
               WHEN FechaEnvioPedido IS NOT NULL
                    AND FechaAprobacionPedido IS NOT NULL THEN
                   CONVERT(
                              VARCHAR,
                              (CASE
                                   WHEN FechaEnvioPedido IS NOT NULL THEN
                                       CONVERT(
                                                  DECIMAL(5, 2),
                                                  dbo.CalcularTipoDEA(FechaRecepcionUltimaCotizacion, FechaEnvioPedido)
                                              )
                                   ELSE
                                       0.00
                               END
                              )
                              + (CASE
                                     WHEN FechaAprobacionPedido IS NOT NULL THEN
                                         CONVERT(
                                                    DECIMAL(5, 2),
                                                    dbo.CalcularTipoDEA(FechaEnvioPedido, FechaAprobacionPedido)
                                                )
                                     ELSE
                                         0.00
                                 END
                                )
                          )
               ELSE
                   ''
           END,
           UsuarioRelacionPOSAP=ISNULL(UsuarioRelacionPOSAP, ''),
           NumeroPOSAP=ISNULL(NumeroPOSAP, ''),
           FechaRelacionPOSAP=FechaRelacionPOSAP,
           DiasRelacionPOSAP=(CASE
                WHEN FechaRelacionPOSAP IS NOT NULL THEN
           (dbo.CalcularTipoDEA(FechaAprobacionPedido, FechaRelacionPOSAP))
                ELSE
                    ''
            END
           ),
           FechaConfirmacionPedido=FechaConfirmacionPedido,
           DiasConfirmacionPedido=(CASE
                WHEN FechaConfirmacionPedido IS NOT NULL THEN
           (dbo.CalcularTipoDEA(FechaAprobacionPedido, FechaConfirmacionPedido))
                ELSE
                    ''
            END
           ),
           DiasTotal=(ISNULL(CONVERT(DECIMAL(5, 2), DiasRecepcionCotizacion), 0)
            + ISNULL(CONVERT(DECIMAL(5, 2), DiasAprobacionPedido), 0)
            + ISNULL(CONVERT(DECIMAL(5, 2), DiasConfirmacionPedido), 0)
            + ISNULL(CONVERT(DECIMAL(5, 2), DiasRelacionPOSAP), 0)
            + ISNULL(CONVERT(DECIMAL(5, 2), DiasRecepcionPOSAP), 0)
           ),
           EstatusFinal=ISNULL(EstatusFinal, ''),
		   Contrato,
		   AreaContractual
    FROM #DATOSOFERTA	T
		LEFT JOIN Adinco.dbo.OT_Estimacion	OT
		 ON T.IdSolicitudPedido = OT.IdSolicitudPedido
	WHERE OT.IdSolicitudPedido IS NULL
    GROUP BY T.IdSolicitudPedido,
             Folio,
             Descripcion,
             CentroCosto,
             Requisitor,
             CompradorAsignado1,
             CompradorAsignado2,
             Comprador,
             Fecha2Asignacion,
             Fecha1aAsignacion,
             NumeroProveedores,
             NumeroProveedoresCotizaron,
             FechaEnvioCotizacion,
             FechaVigenciaCotizacion,
             UsuarioEnviaPedido,
             NumeroPedido,
             FechaRecepcionUltimaCotizacion,
             FechaEnvioPedido,
             UsuarioRelacionPOSAP,
             NumeroPOSAP,
             FechaRelacionPOSAP,
             FechaAprobacionPedido,
             FechaConfirmacionPedido,
             DiasRecepcionCotizacion,
             DiasAprobacionPedido,
             DiasConfirmacionPedido,
             DiasRelacionPOSAP,
             EstatusFinal,
             AprobadorPedido,
             FechaRegistroSolicitudPedido,
             EstatusAprobacionPedido,
             DiasRecepcionPOSAP,
			 Contrato,
			 AreaContractual
    ORDER BY T.IdSolicitudPedido DESC;

    DROP TABLE #DATOSOFERTA;

END;
