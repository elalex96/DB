-- =============================================
-- Author: <Alexander Gomez>
-- Create date: <22/07/2020>
-- Description:	<Consulta de las aceptaciones referentes a dea>
-- =============================================
-- =============================================
-- Author: <Daniel AC>
-- Update date: <23/09/2020>
-- Description:	<Se agrego tabla de contratos, mejoras en las consultas>
-- =============================================
CREATE PROCEDURE [dbo].[SP_VIEW_DEA_ConsultaProcesoAceptaciones_Estatus]
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
    --(3),   --> MEXICO PRUEBAS
    (10038), --> CNH-A4.OGARRIO/2018
    (10044), --> CNH-R03-L01-G-TMV-02/2018
    (10045), --> CNH-R03-L01-G-TMV-03/2018
    (10046), --> CNH-R03-L01-AS-CS-14/2018
    (10144), --> CNH-DEMMA
	(10145); --> CNH-WD ADMIN

    DECLARE @SolicitudContrato AS TABLE
    (
        IdSolicitudPedido INT,
        ContratoId INT,
        Contrato NVARCHAR(MAX),
        AreaContractual NVARCHAR(MAX)
    );

    DECLARE @CENTROSCOSTOS TABLE
    (
        IdSolicitudPedido INT,
        CentroCosto NVARCHAR(100)
    );
    DECLARE @ACEPTACIONESCN TABLE
    (
        IdAceptacionPedido INT,
        FechaRecepcionCN DATETIME,
        FechaEvaluacionCN DATETIME,
        EstatusCartaCN NVARCHAR(100),
        UsuarioEvaluaCN NVARCHAR(100)
    );

	DECLARE @CN_ACTUAL TABLE
    (
        IdAceptacionPedido INT,
        IdAceptacionCartaPCN INT
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
            ON SPD.IdSolicitudPedidoDetalle = SPLP.IdSolicitudPedidoDetalle
        LEFT JOIN dbo.CC_CentroCosto AS CC (NOLOCK)
            ON SPLP.IdCentroCosto = CC.IdCentroCosto
    WHERE 
          (
              CC.CentroCosto IS NOT NULL
              OR CC.CentroCosto <> ''
          );

	
	 -- OBTENER ESTATUS DE LA ULTIMA CARTA DE CN DE LAS ACEPTACIONES REALIZADAS
    INSERT INTO @CN_ACTUAL
    (
        IdAceptacionPedido,
        IdAceptacionCartaPCN
    )
    SELECT AP.IdAceptacionPedido,
           MAX(ACN.IdAceptacionCartaPCN)
    FROM MM_AceptacionPedido AP (NOLOCK)
		JOIN dbo.MM_Pedido P (NOLOCK)
		ON AP.IdPedido=P.IdPedido
		JOIN @Contratos C 
		ON C.ContratoId=P.IdContrato
        JOIN dbo.MM_AceptacionCartaPCN ACN (NOLOCK)
            ON AP.IdAceptacionPedido = ACN.IdAceptacionPedido
    GROUP BY AP.IdAceptacionPedido;

	INSERT INTO @ACEPTACIONESCN
	(
	    IdAceptacionPedido,
	    FechaRecepcionCN,
	    FechaEvaluacionCN,
	    EstatusCartaCN,
	    UsuarioEvaluaCN
	)
	
	SELECT 
	CA.IdAceptacionPedido,
	CCN.CreadoEl,
	CCN.FechaEvaluacion,
	EST.TipoValidacion,
	US.Nombre
    FROM @CN_ACTUAL CA
	JOIN dbo.MM_AceptacionCartaPCN CCN (NOLOCK)
	ON CA.IdAceptacionCartaPCN=CCN.IdAceptacionCartaPCN
	AND CA.IdAceptacionPedido=CCN.IdAceptacionPedido
	LEFT JOIN dbo.S_TipoValidacionDoc AS EST (NOLOCK)
                      ON CCN.IdEstatus = EST.IdTipoValidacionDoc
	LEFT JOIN dbo.S_Usuario AS US (NOLOCK)
                      ON CCN.IdUsuarioEvaluador = US.IdUsuario   
					  
    SELECT SP.IdSolicitudPedido,
           ISNULL(ESOT.FolioEstimacion, 'N/A') AS Folio,
           SP.MotivoUrgencia AS Descripcion,
           CC.CentroCosto,
           SP.FechaAlta AS FechaRegistroSolicitudPedido,
           PS.IdPedido,
           PR.RazonSocial + '(' + PR.RFC + ')' AS Proveeedor,           
           CASE
               WHEN ESOT.FolioEstimacion IS NOT NULL THEN
                   P.CreadoEl
               ELSE
                   P.FechaRecepcionServicio
           END AS FechaPedido,
           CASE
               WHEN SP.UnaSolaEntregaRequerida = 1 THEN
                   'Unica'
               ELSE
                   'Parcial'
           END AS TipoEntrega,
           USPR.Nombre AS UsuarioAceptaPedido,
           AP.Creado AS FechaAceptacionPedido,
           (CASE
                WHEN ESOT.FolioEstimacion IS NOT NULL THEN
           (dbo.CalcularTipoDEA(P.CreadoEl, AP.Creado))
                ELSE
           (dbo.CalcularTipoDEA(PRPO.FechaAltaRelacion, AP.Creado))
            END
           ) AS DiasAceptacionPedido,
           AP.IdAceptacionPedido AS NumeroAceptacionPedido,
           APCN.FechaRecepcionCN AS FechaRecepcionCartaCN,
           (dbo.CalcularTipoDEA(AP.Creado, APCN.FechaRecepcionCN)) AS DiasRecepcionCartaCartaCN,
           APCN.UsuarioEvaluaCN AS UsuarioApruebaCartaCN,
           APCN.FechaEvaluacionCN AS FechaAprobacionCartaCN,
           (dbo.CalcularTipoDEA(APCN.FechaRecepcionCN, APCN.FechaEvaluacionCN)) AS DiasAprobacionCartaCN,
           CASE
               WHEN RCP.PedirCarta = 0 THEN
                   'Excluida'
               ELSE
                   APCN.EstatusCartaCN
           END AS EstatusCartaCN,
           TOF.FechaRegistro AS FechaRecepcionFactura,
           (dbo.CalcularTipoDEA(APCN.FechaEvaluacionCN, TOF.FechaRegistro)) AS DiasRecepcionFactura,
           FI.Folio AS FolioFactura,
           UST1.Nombre AS Responsable1aAprobacion,
           TF1.FechaCambioEstatus AS Fecha1aAprobacion,
           (dbo.CalcularTipoDEA(TOF.FechaRegistro, TF1.FechaCambioEstatus)) AS DiasEspera1aAprobacion,
           EA1.Nombre AS Estatus1aAprobacion,
           UST2.Nombre AS Responsable2aAprobacion,
           TF2.FechaCambioEstatus AS Fecha2aAprobacion,
           (dbo.CalcularTipoDEA(TF1.FechaCambioEstatus, TF2.FechaCambioEstatus)) AS DiasEspera2aAprobacion,
           EA2.Nombre AS Estatus2aAprobacion,
           (dbo.CalcularTipoDEA(PRPO.FechaAltaRelacion, ISNULL(TF2.FechaCambioEstatus, TF1.FechaCambioEstatus))) AS DiasTotal,
           ESF.Nombre AS EstatusAprobacionFactura,
           POAD.ID_PO AS NumeroPO,
           POAD.CreadoEl AS FechaRegistroPO,
           SP.IdContrato
    INTO #DATOSACEPTACIONES
    FROM @Contratos C
		JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
		ON C.ContratoId=SP.IdContrato
        LEFT JOIN dbo.TA_Operacion AS OPSP (NOLOCK)
            ON SP.IdSolicitudPedido = OPSP.IdDocumento
               AND OPSP.IdTipoOperacion = 2 --> APROBACIÓN DE SOLICITUD DE PEDIDO
        LEFT JOIN @CENTROSCOSTOS AS CC
            ON SP.IdSolicitudPedido = CC.IdSolicitudPedido
        LEFT JOIN dbo.MM_Pedido AS P (NOLOCK)
            ON SP.IdSolicitudPedido = P.IdSolicitudPedido
        LEFT JOIN dbo.MM_Pedidos AS PS (NOLOCK)
            ON P.IdPedido = PS.IdIdentificador
               AND P.IdProveedorCompras = PS.IdProveedorCliente
               AND PS.IdTipoPedido NOT IN ( 1, 7 ) --> EXCLUIR COMPRAS DIRECTAS 1 Y COMPROBANTE EXTRANJERO 7 
        LEFT JOIN dbo.S_Proveedor AS PR (NOLOCK)
            ON P.IdSubcontratista = PR.IdProveedor
        LEFT JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
            ON P.IdPedido = AP.IdPedido
        LEFT JOIN @ACEPTACIONESCN AS APCN
            ON AP.IdAceptacionPedido = APCN.IdAceptacionPedido
        LEFT JOIN dbo.MM_AceptacionFactura AS AF (NOLOCK)
            ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
        LEFT JOIN dbo.TA_Operacion AS TOF (NOLOCK)
            ON AF.IdAceptacionFactura = TOF.IdDocumento
               AND TOF.IdTipoOperacion = 10 --> APROBACIÓN DE TIPO APROBACIÓN DE FACTURA
			   AND ISNULL(TOF.IdFlujoTarea,0)<>0 --> PARA EVITAR SE DUPLIQUEN LOS DATOS (YA QUE EXISTEN OPERACIONES LIGADAS A LA ACEPTACIÓN FACTURA SIN FLUJO)
        LEFT JOIN dbo.FI_Factura AS FI (NOLOCK)
            ON AF.IdFactura = FI.IdFactura
        LEFT JOIN dbo.TA_Estatus AS ESF (NOLOCK)
            ON TOF.IdEstatusOperacion = ESF.IdEstatus
        LEFT JOIN dbo.DEA_Relacion_PR_PO AS PRPO (NOLOCK)
            ON P.IdPedido = PRPO.IdPedido
        LEFT JOIN dbo.S_Usuario AS USPR (NOLOCK)
            ON AP.CreadorPor = USPR.IdUsuario
        LEFT JOIN dbo.DEA_AdjuntoPO AS POAD (NOLOCK)
            ON PRPO.IdAdjuntoPO = POAD.IdAdjuntoPO
        --LEFT JOIN dbo.S_Usuario AS USCN
        --	ON USCN.IdUsuario = APCN.IdUsuarioEvaluador
        LEFT JOIN dbo.TA_Tarea AS TF1 (NOLOCK)
            ON TOF.IdOperacion = TF1.IdOperacion
               AND TF1.NoSecuencia = 1
               AND TF1.IdEstatus <> 12 -->ESTATUS ELIMINADO?			  
        LEFT JOIN dbo.S_Usuario AS UST1 (NOLOCK)
            ON TF1.IdAprobador = UST1.IdUsuario
        LEFT JOIN dbo.TA_Tarea AS TF2 (NOLOCK)
            ON TOF.IdOperacion = TF2.IdOperacion
               AND TF2.NoSecuencia = 2
               AND TF2.IdEstatus <> 12-->ESTATUS ELIMINADO?			 
        LEFT JOIN dbo.S_Usuario AS UST2 (NOLOCK)
            ON TF2.IdAprobador = UST2.IdUsuario
        LEFT JOIN dbo.TA_Estatus AS EA1 (NOLOCK)
            ON TF1.IdEstatus = EA1.IdEstatus
        LEFT JOIN dbo.TA_Estatus AS EA2 (NOLOCK)
            ON TF2.IdEstatus = EA2.IdEstatus
        LEFT JOIN Adinco.dbo.OT_Estimacion AS ESOT (NOLOCK)
            ON SP.IdSolicitudPedido = ESOT.IdSolicitudPedido
        LEFT JOIN dbo.RelacionCartaCNPedido AS RCP (NOLOCK)
            ON AP.IdAceptacionPedido = RCP.IdAceptacionPedido
        LEFT JOIN Adinco.dbo.OT_Estimacion estima (NOLOCK)
            ON SP.IdSolicitudPedido = estima.IdSolicitudPedido
    WHERE OPSP.IdEstatusOperacion = 2 -->ESTATUS APROBADO
          AND P.IdPedido IS NOT NULL
          AND P.RecepcionServicio = 1     --> QUE EL PEDIDO ESTE RECEPCIONADO    
          AND ISNULL(SP.IdEstatusEliminado, 0) = 0 --> QUE LA SOLICITUD NO ESTE ELIMINADA
          AND ISNULL(P.IdEstatusEliminado, 0) = 0 --> QUE EL PEDIDO NO ESTE ELIMINADO
          AND ISNULL(AP.IdEstatusEliminado, 0) = 0 --> QUE ACEPTACIÓN DE PEDIDO NO ESTE ELIMINADA
          AND estima.IdOTEstimacion IS NULL -- QUE NO VENGA DE UNA OT
    GROUP BY PR.RazonSocial,
             PR.RFC,
             SP.UnaSolaEntregaRequerida,
             PRPO.FechaAltaRelacion,
             AP.Creado,
             TOF.FechaRegistro,
             SP.IdSolicitudPedido,
             SP.MotivoUrgencia,
             CC.CentroCosto,
             PS.IdPedido,
             P.Comentarios,
             PRPO.FechaAltaRelacion,
             USPR.Nombre,
             AP.Creado,
             AP.IdAceptacionPedido,            
             TOF.FechaRegistro,
             FI.Folio,
             ESF.Nombre,
             TF2.FechaCambioEstatus,
             USPR.Nombre,
             UST1.Nombre,            
             UST2.Nombre,
             EA1.Nombre,
             EA2.Nombre,
             FechaRecepcionCN,
             FechaEvaluacionCN,
             EstatusCartaCN,
             UsuarioEvaluaCN,            
             P.FechaRecepcionServicio,
             ESOT.FolioEstimacion,
             TF1.FechaCambioEstatus,
             P.CreadoEl,
             POAD.ID_PO,
             POAD.CreadoEl,
             RCP.PedirCarta,
             SP.FechaAlta,
             SP.IdContrato
    ORDER BY PS.IdPedido DESC;

    INSERT INTO @SolicitudContrato
    (
        IdSolicitudPedido,
        ContratoId
    )
    SELECT IdSolicitudPedido,
           IdContrato
    FROM #DATOSACEPTACIONES
    GROUP BY IdSolicitudPedido,
             IdContrato;

    UPDATE S
    SET S.Contrato = C.NumeroContrato,
        S.AreaContractual = AC.NombreAreaContractual
    FROM @SolicitudContrato S
JOIN Adinco..CO_Contrato C (NOLOCK)
            ON S.ContratoId = C.IdContrato
        JOIN Adinco..CO_AreaContractual AC (NOLOCK)
            ON C.IdAreaContractual = AC.IdAreaContractual;

    TRUNCATE TABLE dbo.DEA_ProcesoAceptaciones_Estatus;

    INSERT INTO dbo.DEA_ProcesoAceptaciones_Estatus
    (
        IdSolicitudPedido,
        Folio,
        Descripcion,
        CentroCosto,
        FechaRegistroSolicitudPedido,
        NumeroPedido,
        Proveedor,
        FechaPedidoFechaConfirmacion,
        TipoEntrega,
        UsuarioAceptaPedido,
        FechaAceptacionPedido,
        DiasAceptacionPedido,
        NumeroAceptacionPedido,
        FechaRecepcionCartaCN,
        DiasRecepcionCartaCN,
        UsuarioApruebaCartaCN,
        FechaAprobacionCartaCN,
        DiasAprobacionCartaCN,
        EstatusCartaCN,
        FechaRecepcionFactura,
        DiasRecepcionFactura,
        FolioFactura,
        Responsable1aAprobacion,
        Fecha1aAprobacion,
        DiasEspera1aAprobacion,
        Estatus1aAprobacion,
        Responsable2aAprobacion,
        Fecha2aAprobacion,
        DiasEspera2aAprobacion,
        Estatus2aAprobacion,
        DiasEnAprobacion,
        DiasTotal,
        EstatusAprobacionFactura,
        NumeroPO,
        FechaRegistroPO
    )
    SELECT CAST(T.IdSolicitudPedido AS NVARCHAR(100)) AS IdSolicitudPedido,
           ISNULL(Folio, '') AS Folio,
           ISNULL(Descripcion, '') AS Descripcion,
           ISNULL(CentroCosto, '') AS CentroCosto,
           FechaRegistroSolicitudPedido AS FechaRegistroSolicitudPedido,
           ISNULL(CAST(T.IdPedido AS NVARCHAR(100)), '') AS NumeroPedido,
           ISNULL(Proveeedor, '') AS Proveedor,
           FechaPedido AS FechaPedidoFechaConfirmacionPedido,
           ISNULL(TipoEntrega, '') AS TipoEntrega,
           ISNULL(UsuarioAceptaPedido, '') AS UsuarioAceptaPedido,
           FechaAceptacionPedido AS FechaAceptacionPedido,
           CASE
               WHEN FechaAceptacionPedido IS NULL THEN
                   ''
               ELSE
                   CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), DiasAceptacionPedido), 0))
           END AS DiasAceptacionPedido,
           ISNULL(CAST(NumeroAceptacionPedido AS NVARCHAR(100)), '') AS NumeroAceptacionPedido,
           FechaRecepcionCartaCN AS FechaRecepcionCartaCN,
           CASE
               WHEN FechaRecepcionCartaCN IS NULL THEN
                   ''
               ELSE
                   CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), DiasRecepcionCartaCartaCN), 0))
           END AS DiasRecepcionCartaCartaCN,
           ISNULL(UsuarioApruebaCartaCN, '') AS UsuarioApruebaCartaCN,
           FechaAprobacionCartaCN AS FechaAprobacionCartaCN,
           CASE
               WHEN FechaAprobacionCartaCN IS NULL THEN
                   ''
               ELSE
                   CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), DiasAprobacionCartaCN), 0))
           END AS DiasAprobacionCartaCN,
           ISNULL(EstatusCartaCN, '') AS EstatusCartaCN,
           FechaRecepcionFactura AS FechaRecepcionFactura,
           CASE
               WHEN FechaRecepcionFactura IS NULL THEN
                   ''
               ELSE
                   CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), DiasRecepcionFactura), 0))
           END AS DiasRecepcionFactura,
           ISNULL(FolioFactura, '') AS FolioFactura,
           ISNULL(Responsable1aAprobacion, '') AS Responsable1aAprobacion,
           Fecha1aAprobacion AS Fecha1aAprobacion,
           CASE
               WHEN Fecha1aAprobacion IS NULL THEN
                   ''
               ELSE
                   CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), DiasEspera1aAprobacion), 0))
           END AS DiasEspera1aAprobacion,
           ISNULL(Estatus1aAprobacion, '') AS Estatus1aAprobacion,
           ISNULL(Responsable2aAprobacion, '') AS Responsable2aAprobacion,
           Fecha2aAprobacion AS Fecha2aAprobacion,
           CASE
               WHEN Fecha2aAprobacion IS NULL THEN
                   ''
               ELSE
                   CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), DiasEspera2aAprobacion), 0))
           END AS DiasEspera2aAprobacion,
           ISNULL(Estatus2aAprobacion, '') AS Estatus2aAprobacion,
           CONVERT(
                      VARCHAR,
                      (ISNULL(CONVERT(DECIMAL(5, 2), DiasRecepcionFactura), 0)
                       + ISNULL(CONVERT(DECIMAL(5, 2), DiasEspera1aAprobacion), 0)
                       + ISNULL(CONVERT(DECIMAL(5, 2), DiasEspera2aAprobacion), 0)
                      )
                  ) AS DiasEnAprobacion,
           CONVERT(
                      VARCHAR,
                      (ISNULL(CONVERT(DECIMAL(5, 2), DiasAceptacionPedido), 0)
                       + ISNULL(CONVERT(DECIMAL(5, 2), DiasRecepcionCartaCartaCN), 0)
                       + ISNULL(CONVERT(DECIMAL(5, 2), DiasAprobacionCartaCN), 0)
                       + ISNULL(CONVERT(DECIMAL(5, 2), DiasRecepcionFactura), 0)
                       + ISNULL(CONVERT(DECIMAL(5, 2), DiasEspera1aAprobacion), 0)
                       + ISNULL(CONVERT(DECIMAL(5, 2), DiasEspera2aAprobacion), 0)
                      )
                  ) AS DiasTotal,
           ISNULL(EstatusAprobacionFactura, '') AS EstatusAprobacionFactura,
           ISNULL(NumeroPO, '') AS NumeroPO,
           FechaRegistroPO AS FechaRegistroPO
    FROM #DATOSACEPTACIONES	T
	LEFT JOIN Adinco.dbo.OT_Estimacion	OT
		 ON T.IdSolicitudPedido = OT.IdSolicitudPedido
	WHERE OT.IdSolicitudPedido IS NULL
    --WHERE #DATOSACEPTACIONES.IdSolicitudPedido NOT IN
    --      (
    --          SELECT IdSolicitudPedido FROM Adinco.dbo.OT_Estimacion
    --      )
    ORDER BY T.IdSolicitudPedido DESC;

    UPDATE A
    SET A.Contrato = SC.Contrato,
        A.AreaContractual = SC.AreaContractual
    FROM DEA_ProcesoAceptaciones_Estatus A
        LEFT JOIN @SolicitudContrato SC
            ON A.IdSolicitudPedido = SC.IdSolicitudPedido;

    DROP TABLE #DATOSACEPTACIONES;

END;
