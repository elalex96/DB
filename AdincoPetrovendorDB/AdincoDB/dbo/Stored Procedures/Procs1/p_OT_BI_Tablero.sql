CREATE PROCEDURE [dbo].[p_OT_BI_Tablero]
AS
    BEGIN
        DELETE OT_BI_Tablero ;

        IF OBJECT_ID('tempdb..#tmpOTManagerNot', 'U') IS NOT NULL
            DROP TABLE #tmpOTManagerNot ;

        IF OBJECT_ID('tempdb..#tmpAprobador1', 'U') IS NOT NULL
            DROP TABLE #tmpAprobador1 ;

        IF OBJECT_ID('tempdb..#tmpAprobador2', 'U') IS NOT NULL
            DROP TABLE #tmpAprobador2 ;

        IF OBJECT_ID('tempdb..#tmpOTFechaCapturaMax', 'U') IS NOT NULL
            DROP TABLE #tmpOTFechaCapturaMax ;

        IF OBJECT_ID('tempdb..#tempAdjuntos', 'U') IS NOT NULL
            DROP TABLE #tempAdjuntos ;

        IF OBJECT_ID('tempdb..#TempFechasOT', 'U') IS NOT NULL
            DROP TABLE #TempFechasOT ;

        IF OBJECT_ID('tempdb..#tmpResultado', 'U') IS NOT NULL
            DROP TABLE #tmpResultado ;

        IF OBJECT_ID('tempdb..#tmpResultado2', 'U') IS NOT NULL
            DROP TABLE #tmpResultado2 ;

        IF OBJECT_ID('tempdb..#tmpResultado3', 'U') IS NOT NULL
            DROP TABLE #tmpResultado3 ;

        IF OBJECT_ID('tempdb..#tmpResultado4', 'U') IS NOT NULL
            DROP TABLE #tmpResultado4 ;

        IF OBJECT_ID('tempdb..#tmpResultado5', 'U') IS NOT NULL
            DROP TABLE #tmpResultado5 ;

        IF OBJECT_ID('tempdb..#DATOSACEPTACIONES', 'U') IS NOT NULL
            DROP TABLE #DATOSACEPTACIONES ;

        IF OBJECT_ID('tempdb..#tmpResumenAbiertaCerrada', 'U') IS NOT NULL
            DROP TABLE #tmpResumenAbiertaCerrada ;

        IF OBJECT_ID('tempdb..#tmpResultaFinalRep', 'U') IS NOT NULL
            DROP TABLE #tmpResultaFinalRep ;

        SELECT ot.IdOTSolicitud, u.Nombre, MIN(n.CreadoEl) AS Fecha
        INTO #tmpOTManagerNot
        FROM Adinco..OT_SolicitudBitacora sb
        INNER JOIN Adinco..OT_Solicitud   ot
            ON ot.IdOTSolicitud=sb.IdOTSolicitud
        INNER JOIN Adinco..S_Notificacion n
            ON n.Asunto LIKE '%'+ot.Folio+'%' AND n.CreadoEl>ot.CreadoEl
               AND n.Asunto LIKE '%Control de Obra%'
               AND(n.Mensaje LIKE '%La OT ha sido aprobada%'
                   OR n.Mensaje LIKE '%La OT ha sido rechazada%'
                   OR n.Mensaje LIKE '%Es necesario revisar la programacion inicial%'
                   OR n.Mensaje LIKE '%Es necesario aprobar/rechazar%')
        INNER JOIN Adinco..AP_Usuario     u
            ON u.UsuarioID=n.CreadoPor
               AND u.Usuario NOT LIKE '%smps-adinco.com%'
               AND u.Usuario NOT LIKE '%ogss.com.mx%'
               AND u.Usuario NOT LIKE '%adinco.mx%'
        GROUP BY ot.IdOTSolicitud, u.Nombre ;


        SELECT ot.IdOTSolicitud,
            CASE WHEN ot.ProgIniPorProveedor=1 THEN pv.RazonSocial ELSE
                                                                       ISNULL(
                                                                           ISNULL(
                                                                               u.Nombre,
                                                                               mana.Nombre),
                                                                           ISNULL(
                                                                               CASE WHEN ot.IdOTEstatus NOT IN (
                                                                                    1,
                                                                                    2,
                                                                                    11) THEN
                                                                                    MAX(
                                                                                    uf.Nombre)ELSE
                                                                                              '' END,
                                                                               ''))COLLATE SQL_Latin1_General_CP1_CI_AS END           AS Usuario,
            MIN(CASE WHEN ot.ProgIniPorProveedor=1 THEN sb2.CreadoEl ELSE
                                                                         ISNULL(
                                                                             sb.CreadoEl,
                                                                             ISNULL(
                                                                                 mana.Fecha,
                                                                                 CASE WHEN ot.IdOTEstatus NOT IN (
                                                                                          1,
                                                                                          2,
                                                                                          11) THEN
                                                                                          DATEADD(
                                                                                              MINUTE,
                                                                                              15,
                                                                                              ot.CreadoEl)ELSE
                                                                                                              NULL END))END)          AS Fecha,
            ot.ProgIniPorProveedor,
            MAX(CASE WHEN ot.ProgIniPorProveedor=1 THEN sb2.Descripcion ELSE
                                                                            ISNULL(
                                                                                sb.Descripcion,
                                                                                CASE WHEN mana.Nombre IS NOT NULL THEN
                                                                                         'Enviada a Subcontratista' ELSE
                                                                                                                        NULL END)END) AS Estatus
        INTO #tmpAprobador1
        FROM Adinco..OT_Solicitud                           ot
        INNER JOIN Adinco..SC_SubContrato                   sc
            ON sc.IdSubContrato=ot.IdSubContrato
        INNER JOIN Adinco..PV_Subcontratista                pv
            ON pv.IdSubcontratista=sc.IdSubContratista
        LEFT JOIN Adinco..OT_SolicitudBitacora              sb
            ON ot.IdOTSolicitud=sb.IdOTSolicitud
               AND(sb.IdTipoMovimiento IN (3)
                   OR sb.Descripcion LIKE '%Enviada%Subcontratista%')
        LEFT JOIN Adinco..OT_SolicitudBitacora              sb2
            ON ot.IdOTSolicitud=sb2.IdOTSolicitud
               AND(sb2.IdTipoMovimiento IN (5)
                   OR sb.Descripcion LIKE '%Propuesta%Subcontratista%')
        LEFT JOIN Adinco..AP_Usuario                        u
            ON u.UsuarioID=sb.UsuarioAdincoId
               AND u.Usuario NOT LIKE '%smps-adinco.com%'
               AND u.Usuario NOT LIKE '%ogss.com.mx%'
               AND u.Usuario NOT LIKE '%adinco.mx%'
        LEFT JOIN #tmpOTManagerNot                          mana
            ON mana.IdOTSolicitud=ot.IdOTSolicitud
        LEFT JOIN Adinco..AP_UsuarioCentroCosto             ucc
            ON ucc.IdCentroCosto=ot.IdCentroCosto
        LEFT JOIN Adinco..AP_FlujoAprobacionEstatusUsuarios fu
            ON fu.UsuarioId=ucc.IdUsuario AND fu.FlujoAprobacionEstatusId=2 --Manager 

        LEFT JOIN Adinco..AP_Usuario                        uf
            ON uf.UsuarioID=fu.UsuarioId
               AND uf.Usuario NOT LIKE '%smps-adinco.com%'
               AND uf.Usuario NOT LIKE '%ogss.com.mx%'
               AND uf.Usuario NOT LIKE '%adinco.mx%'
               AND uf.Usuario NOT LIKE '%ernesto.rodriguez@wintershalldea.com%'
               AND uf.Usuario NOT LIKE '%napoleon.pineiro@wintershalldea.com%'
               AND uf.Usuario NOT LIKE '%natalia.caro@wintershalldea.com%'
        GROUP BY ot.IdOTSolicitud, ot.ProgIniPorProveedor, u.Nombre,
            ot.ProgIniPorProveedor, mana.Nombre, pv.RazonSocial,
            ot.IdOTEstatus ;

        CREATE NONCLUSTERED INDEX IX_Temp1
        ON [#tmpAprobador1](IdOTSolicitud, Fecha) ;

        SELECT ot.IdOTSolicitud,
            CASE WHEN ot.ProgIniPorProveedor=1 THEN
                     ISNULL(u.Nombre, mana.Nombre)ELSE pv.RazonSocial END                       AS Usuario,
            MAX(CASE WHEN ot.ProgIniPorProveedor=1 THEN
                         ISNULL(sb.CreadoEl, mana.Fecha)ELSE sb2.CreadoEl END)                  AS Fecha,
            ot.ProgIniPorProveedor,
            MAX(CASE WHEN ot.ProgIniPorProveedor=1 THEN sb.Descripcion ELSE
                                                                           sb2.Descripcion END) AS Estatus
        INTO #tmpAprobador2
        FROM OT_Solicitud              ot
        INNER JOIN SC_SubContrato      sc
            ON sc.IdSubContrato=ot.IdSubContrato
        INNER JOIN PV_Subcontratista   pv
            ON pv.IdSubcontratista=sc.IdSubContratista
        LEFT JOIN OT_SolicitudBitacora sb
            ON ot.IdOTSolicitud=sb.IdOTSolicitud
               AND sb.IdTipoMovimiento IN (2)
        LEFT JOIN OT_SolicitudBitacora sb2
            ON ot.IdOTSolicitud=sb2.IdOTSolicitud
               AND sb2.IdTipoMovimiento IN (4)
        LEFT JOIN AP_Usuario           u
            ON u.UsuarioID=sb.UsuarioAdincoId
        --LEFT JOIN Petrovendor..S_Usuario u2
        --    ON u2.IdUsuario = sb2.UsuarioPetroId
        LEFT JOIN #tmpOTManagerNot     mana
            ON mana.IdOTSolicitud=ot.IdOTSolicitud
        GROUP BY ot.IdOTSolicitud, ot.ProgIniPorProveedor,
            --u2.Nombre,
            u.Nombre, ot.ProgIniPorProveedor, pv.RazonSocial, mana.Nombre ;

        CREATE NONCLUSTERED INDEX IX_Temp2
        ON [#tmpAprobador2](IdOTSolicitud, Fecha) ;

        SELECT ot.IdOTSolicitud, MAX(cap.Fecha)                                AS FechaCaptura,
            ISNULL(CASE WHEN MAX(cap.Fecha)>=ot.FechaFin THEN 1 ELSE 0 END, 0) AS Completada
        INTO #tmpOTFechaCapturaMax
        FROM OT_Solicitud                        ot
        INNER JOIN OT_SolicitudMaterial          otm
            ON otm.IdOTSolicitud=ot.IdOTSolicitud
        INNER JOIN [OT_SolicitudProgramaCaptura] cap
            ON cap.IdOTSolicitudMaterial=otm.IdOTSolicitudMaterial
               AND cap.FechaVoBoSubcontratista IS NOT NULL
        GROUP BY ot.IdOTSolicitud, ot.FechaFin ;


        --Obtener info adjuntos
        SELECT PRPO.ID_R_PR_PO, PRPO.PO, p.IdPedido, POAD.IdAdjuntoPO,
            POAD.CreadoEl AS FechaRegistroPO, PR.IdSolicitudPedido, PR.ID_PR,
            POAD.ID_PO
        INTO #tempAdjuntos
        FROM Petrovendor.dbo.MM_Pedido               p
        INNER JOIN Petrovendor.dbo.DEA_AdjuntoPR     AS PR
            ON PR.IdSolicitudPedido=p.IdSolicitudPedido AND PR.Activo=1
               AND ISNULL(PR.IsEliminado, 0)=0
        LEFT JOIN Petrovendor.dbo.DEA_Relacion_PR_PO AS PRPO
            ON PRPO.IdPedido=p.IdPedido AND PRPO.Activo=1
        LEFT JOIN Petrovendor.dbo.DEA_AdjuntoPO      AS POAD
            ON POAD.IdAdjuntoPO=PRPO.IdAdjuntoPO AND POAD.Activo=1 ;

        CREATE NONCLUSTERED INDEX IX_TempAdjuntos
        ON [#tempAdjuntos](IdSolicitudPedido, IdPedido) ;

        SELECT om.IdOTSolicitudMaterial, cap.Fecha,
            MAX(cap.FechaVoBoSubcontratista)                              AS FechaCargaAvance,
            MAX(cap.FechaVoBoContratista)                                 AS FechaVoBoOperadora,
            MAX(cap.QuienVoBoContratista)                                 AS ResponsableVoBoOperadora,
            MIN(cap.FechaCierre)                                          AS FechaCierreSemana,
            MAX(uCierre.Nombre)                                           AS Responsable_Cierre_Semana,
            CASE WHEN ot.FechaAprobacionSAPPR>MIN(cap.FechaCierre) THEN
                     MIN(cap.FechaCierre)ELSE ot.FechaAprobacionSAPPR END AS FechaCargaPR
        INTO #TempFechasOT
        FROM dbo.OT_Solicitud                      ot
        INNER JOIN dbo.OT_SolicitudMaterial        om
            ON om.IdOTSolicitud=ot.IdOTSolicitud AND ot.IsActivo=1
        INNER JOIN dbo.OT_SolicitudProgramaCaptura cap
            ON cap.IdOTSolicitudMaterial=om.IdOTSolicitudMaterial
               AND cap.FechaVoBoSubcontratista IS NOT NULL
        LEFT JOIN dbo.AP_Usuario                   uCierre
            ON uCierre.UsuarioID=cap.CerradoPor
        GROUP BY om.IdOTSolicitudMaterial, cap.Fecha, ot.FechaAprobacionSAPPR ;

        CREATE NONCLUSTERED INDEX IX_TempFechas
        ON [#TempFechasOT](IdOTSolicitudMaterial, Fecha) ;

        SELECT c.NumeroContrato, ot.IdOTSolicitud, ped.IdSolicitudPedido,
            ot.Folio                                  AS Folio, ot.Objeto AS Objeto,
            cc.CentroCosto                            AS CentroCosto,
            ISNULL(pv.RazonSocial, 'NO ENCONTRADO')   AS RazonSocialProv,
            CONCAT(t.id_Tarea, ' ', t.TareaPetrolera) AS Tarea,
            serv.NombreServicio                       AS SubTarea, est.Descripcion AS Estatus,
            ot.CreadoEl                               AS RegistroDeOT, uReq.Nombre AS Requisitor,
            a1.Usuario                                AS Responsable1aAprobacion,
            a1.Fecha                                  AS Fecha1aAprobacion,
            CAST(0 AS FLOAT)                          AS DiasEspera1aAprobacion,
            CASE WHEN ot.IdOTEstatus=1 THEN 'Sin iniciar 1a Aprobacion'
            WHEN ot.IdOTEstatus<>1 AND a1.Estatus IS NULL THEN
                'En Aprobación' ELSE a1.Estatus END   AS Estatus1aAprobacion,
            a2.Usuario                                AS Responsable2aAprobacion,
            a2.Fecha                                  AS Fecha2aAprobacion,
            CAST(0 AS FLOAT)                          AS DiasEspera2aAprobacion,
            CASE WHEN a1.Estatus IS NULL THEN 'En espera 1a Aprobación'
            WHEN a1.Estatus IS NOT NULL AND a2.Estatus IS NULL THEN
                'En Aprobación' ELSE a2.Estatus END   AS Estatus2aAprobacion,
            fechas.Fecha                              AS DiaProgramaTrabajo,        -- cap.Fecha,
            fechas.FechaCargaAvance                   AS FechaCargaAvance,          --MAX(cap.FechaVoBoSubcontratista),
            CAST(0 AS FLOAT)                          AS DiasCargaAvance,
            fechas.FechaVoBoOperadora                 AS FechaVoBoOperadora,        --MAX(cap.FechaVoBoContratista),
            fechas.ResponsableVoBoOperadora           AS ResponsableVoBoOperadora,  -- MAX(cap.QuienVoBoContratista),
            CAST(0 AS FLOAT)                          AS DiasVoBoOperadora,
            fechas.FechaCierreSemana                  AS FechaCierreSemana,         -- MIN(cap.FechaCierre),
            fechas.Responsable_Cierre_Semana          AS Responsable_Cierre_Semana, -- MAX(uCierre.Nombre),
            CAST(0 AS FLOAT)                          AS DiasCierreSemana,
            CAST(0 AS FLOAT)                          AS DiasAvanceSemanal,
            estima.CreadoEl                           AS FechaDeEstimacion,
            uEst.Nombre                               AS ResponsableEstimacion,
            CAST(0 AS FLOAT)                          AS DiasEstimacion,
            CAST(0 AS FLOAT)                          AS DiasTotales, fechas.FechaCargaPR,
                                                                                    --CASE
                                                                                    --    WHEN ot.FechaAprobacionSAPPR > MIN(fechas.FechaCierre) THEN
                                                                                    --        MIN(cap.FechaCierre)
                                                                                    --    ELSE
                                                                                    --        ot.FechaAprobacionSAPPR
                                                                                    --END AS FechaCargaPR,
            ISNULL(adjuntos.ID_PR, ot.SAPPR)          AS NumberPR,                  --ISNULL(PR.ID_PR, ot.SAPPR) AS NumberPR,
            adjuntos.ID_PO                            AS NumeroPO,                  --POAD.ID_PO AS NumeroPO,
            adjuntos.FechaRegistroPO                  AS FechaRegistroPO,           --POAD.CreadoEl AS FechaRegistroPO,
            CAST(0 AS FLOAT)                          AS DiasPR,
            CAST(0 AS FLOAT)                          AS DiasRegistroPR_CargaAvance,
            ISNULL(estima.IdOTEstimacion, 0)          AS IdOTEstimacion
        INTO #tmpResultado
        FROM OT_Solicitud                      ot
        INNER JOIN OT_SolicitudMaterial        om
            ON om.IdOTSolicitud=ot.IdOTSolicitud AND ot.IsActivo=1
               AND ISNULL(ot.IsEliminado, 0)=0
        INNER JOIN [dbo].[OT_LineaPresupuesto] olp
            ON olp.IdOTSolicitud=ot.IdOTSolicitud
        INNER JOIN CO_LineaPresupuestoMes      lpm
            ON lpm.IdLineaPresupuestoMes=olp.IdLineaPresupuestoMes
        INNER JOIN CO_TareaPetrolera           t
            ON t.IdTareaPetrolera=lpm.IdTareaPetrolera
        INNER JOIN CO_Servicio                 serv
            ON serv.IdServicio=lpm.IdServicio
        INNER JOIN OT_Estatus                  est
            ON est.IdOtEstatus=ot.IdOTEstatus
        INNER JOIN AP_Usuario                  uReq
            ON uReq.UsuarioID=ot.CreadoPor
        INNER JOIN Petrovendor..CC_CentroCosto cc
            ON cc.IdCentroCosto=ot.IdCentroCosto
        INNER JOIN SC_SubContrato              sc
            ON sc.IdSubContrato=ot.IdSubContrato
               AND sc.IdContrato IN (10038, 10044, 10045, 10046, 10144) -- Solo contratos DEA 

        INNER JOIN CO_Contrato                 c
            ON c.IdContrato=sc.IdContrato
        INNER JOIN PV_Subcontratista           pv
            ON pv.IdSubcontratista=sc.IdSubContratista
        LEFT JOIN #TempFechasOT                fechas
            ON fechas.IdOTSolicitudMaterial=om.IdOTSolicitudMaterial
        LEFT JOIN OT_Estimacion                estima
            ON estima.IdOTSolicitud=ot.IdOTSolicitud
               AND estima.FechaCorteInicio<=fechas.Fecha
               AND estima.FechaCorteFin>=fechas.Fecha
        LEFT JOIN AP_Usuario                   uEst
            ON uEst.UsuarioID=estima.CreadoPor
        LEFT JOIN #tmpAprobador1               a1
            ON a1.IdOTSolicitud=ot.IdOTSolicitud
        LEFT JOIN #tmpAprobador2               a2
            ON a2.IdOTSolicitud=ot.IdOTSolicitud
        LEFT JOIN Petrovendor..MM_Pedido       ped
            ON ped.IdPedido=estima.IdPedido
               AND ped.IdContrato IN (10038, 10044, 10045, 10046, 10144)
        LEFT JOIN #tempAdjuntos                adjuntos
            ON adjuntos.IdPedido=ped.IdPedido
               AND ped.IdSolicitudPedido=adjuntos.IdSolicitudPedido ;


        UPDATE #tmpResultado
        SET DiasEspera1aAprobacion=ISNULL(
                                       CAST(DATEDIFF(
                                                hh, RegistroDeOT,
                                                Fecha1aAprobacion)/ 24.0 AS DECIMAL (20, 2)),
                                       0),
            DiasEspera2aAprobacion=ISNULL(
                                       CAST(DATEDIFF(
                                                hh, Fecha1aAprobacion,
                                                Fecha2aAprobacion)/ 24.0 AS DECIMAL (20, 2)),
                                       0),
            DiasPR=ISNULL(
                       CAST(DATEDIFF(hh, Fecha2aAprobacion, FechaCargaPR)
                            / 24.0 AS DECIMAL (20, 2)), 0),
            DiasCargaAvance=ISNULL(
                                CAST(DATEDIFF(
                                         hh, Fecha2aAprobacion,
                                         FechaCargaAvance)/ 24.0 AS DECIMAL (20, 2)),
                                0),
            DiasVoBoOperadora=ISNULL(
                                  CAST(DATEDIFF(
                                           hh, FechaCargaAvance,
                                           FechaVoBoOperadora)/ 24.0 AS DECIMAL (20, 2)),
                                  0),
            DiasAvanceSemanal=ISNULL(
                                  CAST(DATEDIFF(
                                           hh, FechaCargaAvance,
                                           FechaCierreSemana)/ 24.0 AS DECIMAL (20, 2)),
                                  0),
            DiasEstimacion=ISNULL(
                               CAST(DATEDIFF(
                                        hh, FechaCierreSemana,
                                        FechaDeEstimacion)/ 24.0 AS DECIMAL (20, 2)),
                               0), DiasTotales=CAST(0 AS FLOAT) ;


        UPDATE #tmpResultado
        SET DiasRegistroPR_CargaAvance=CASE WHEN ISNULL(DiasPR, 0)>ISNULL(
                                                                       DiasCargaAvance,
                                                                       0) THEN
                                                DiasPR ELSE DiasCargaAvance END ;



        UPDATE #tmpResultado
        SET DiasTotales=ISNULL(DiasVoBoOperadora, 0)
                        +ISNULL(DiasCierreSemana, 0)
                        +ISNULL(DiasEstimacion, 0) ;


        --  AGRUPACION 1
        SELECT t2.NumeroContrato                                              AS NumeroContrato,
            t2.IdOTSolicitud                                                  AS IdOTSolicitud,
            IdSolicitudPedido                                                 AS IdSolicitudPedido, t2.Folio AS Folio,
            t2.Objeto                                                         AS Objeto, CentroCosto AS CentroCosto,
            RazonSocialProv                                                   AS RazonSocialProv, MAX(Tarea) AS Tarea,
            MAX(SubTarea)                                                     AS SubTarea, Estatus AS Estatus,
            RegistroDeOT                                                      AS RegistroDeOT, Requisitor AS Requisitor,

            Responsable1aAprobacion                                           AS Responsable1aAprobacion,
            Fecha1aAprobacion                                                 AS Fecha1aAprobacion,
            DiasEspera1aAprobacion                                            AS DiasEspera1aAprobacion,
            Estatus1aAprobacion                                               AS Estatus1aAprobacion,
            Responsable2aAprobacion                                           AS Responsable2aAprobacion,
            Fecha2aAprobacion                                                 AS Fecha2aAprobacion,
            DiasEspera2aAprobacion                                            AS DiasEspera2aAprobacion,
            Estatus2aAprobacion                                               AS Estatus2aAprobacion,

            CASE WHEN fechaCap.Completada=1
                      AND MIN(DiaProgramaTrabajo) IS NULL THEN NULL
            WHEN fechaCap.Completada=0 AND MIN(DiaProgramaTrabajo) IS NULL THEN
                fechaCap.FechaCaptura
            WHEN MIN(DiaProgramaTrabajo) IS NOT NULL THEN
                MIN(DiaProgramaTrabajo)END                                    AS ProgramaDel,
            CASE WHEN fechaCap.Completada=1
                      AND MAX(DiaProgramaTrabajo) IS NULL THEN NULL
            WHEN fechaCap.Completada=0 AND MAX(DiaProgramaTrabajo) IS NULL THEN
                ot.FechaFin
            WHEN MAX(DiaProgramaTrabajo) IS NOT NULL THEN
                MAX(DiaProgramaTrabajo)END                                    AS ProgramaAl,

            FechaCargaAvance                                                  AS FechaCargaAvance,
            CASE WHEN fechaCap.Completada=1 THEN 'Cerrada' ELSE 'Abierta' END AS VolumetriaAvance,
            DiasCargaAvance, FechaVoBoOperadora, ResponsableVoBoOperadora,
            DiasVoBoOperadora, FechaCierreSemana, Responsable_Cierre_Semana,
            DiasCierreSemana, DiasAvanceSemanal, FechaDeEstimacion,
            ResponsableEstimacion, DiasEstimacion, DiasTotales, FechaCargaPR,
            NumberPR, NumeroPO, FechaRegistroPO, MAX(DiasPR)                  AS DiasPR,
            MAX(DiasRegistroPR_CargaAvance)                                   AS DiasRegistroPR_CargaAvance,
            IdOTEstimacion                                                    AS IdOTEstimacion
        INTO #tmpResultado2
        FROM #tmpResultado              t2
        INNER JOIN OT_Solicitud         ot
            ON ot.IdOTSolicitud=t2.IdOTSolicitud
        LEFT JOIN #tmpOTFechaCapturaMax fechaCap
            ON fechaCap.IdOTSolicitud=t2.IdOTSolicitud
        GROUP BY t2.NumeroContrato, t2.IdOTSolicitud, IdSolicitudPedido,
            t2.Folio, t2.Objeto, CentroCosto, RazonSocialProv, Estatus,
            RegistroDeOT, Requisitor, Responsable1aAprobacion,
            FechaCargaAvance, DiasCargaAvance, FechaVoBoOperadora,
            ResponsableVoBoOperadora, DiasVoBoOperadora, FechaCierreSemana,
            Responsable_Cierre_Semana, DiasCierreSemana, FechaDeEstimacion,
            ResponsableEstimacion, DiasEstimacion, DiasTotales, NumeroPO,
            FechaRegistroPO, DiasAvanceSemanal, Fecha1aAprobacion,
            DiasEspera1aAprobacion, Fecha2aAprobacion,
            DiasEspera2aAprobacion, Responsable2aAprobacion,
            Estatus1aAprobacion, Estatus2aAprobacion, FechaCargaPR, NumberPR,
            IdOTEstimacion, fechaCap.FechaCaptura, ot.FechaFin,
            ot.FechaInicio, fechaCap.Completada
        ORDER BY IdOTSolicitud ;


        /***Rectificar Fecha de cierre de semana si viene null***/

        UPDATE #tmpResultado2
        SET FechaCierreSemana=s.CreadoEl,
            Responsable_Cierre_Semana=ISNULL(AP.Nombre, '')
        FROM #tmpResultado2                 tmp
        INNER JOIN OT_ProgramaSemanaCerrada s
            ON s.IdOTSolicitud=tmp.IdOTSolicitud
        LEFT JOIN AP_Usuario                AP
            ON AP.Usuario LIKE '%'+RTRIM(ISNULL(s.CreadoPor, ''))+'%'
               OR CAST(AP.UsuarioID AS VARCHAR)=s.CreadoPor
        WHERE(CONVERT(VARCHAR, tmp.ProgramaDel, 112)>=CONVERT(
                                                          VARCHAR,
                                                          s.FechaSemanaIni,
                                                          112)
              AND CONVERT(VARCHAR, tmp.ProgramaAl, 112)<=CONVERT(
                                                             VARCHAR,
                                                             s.FechaSemanaFin,
                                                             112))
             AND tmp.FechaCierreSemana IS NULL
             AND tmp.Responsable_Cierre_Semana IS NULL ;


        /***Recalcular DIas Cierre Semana***/

        UPDATE #tmpResultado
        SET DiasCierreSemana=CAST(DATEDIFF(
                                      hh,
                                      CASE WHEN FechaCargaAvance>FechaCargaPR THEN
                                               FechaCargaAvance
                                      WHEN FechaCargaAvance<FechaCargaPR THEN
                                          FechaCargaPR ELSE
                                                           ISNULL(
                                                               FechaCargaAvance,
                                                               FechaCargaPR)END,
                                      FechaCierreSemana)/ 24.0 AS DECIMAL (20, 2)) ;





        --AGRUPACION 2 

        --insert into OT_BI_Tablero 

        SELECT NumeroContrato, IdOTSolicitud, IdSolicitudPedido, Folio,
            Objeto, CentroCosto, RazonSocialProv, Tarea, SubTarea, Estatus,
            RegistroDeOT, Requisitor,

            --Fecha_De_Rechazo = MAX(Fecha_De_Rechazo),  

            MAX(Responsable1aAprobacion)                AS Responsable1aAprobacion,
            MAX(Fecha1aAprobacion)                      AS Fecha1aAprobacion,
            MAX(DiasEspera1aAprobacion)                 AS DiasEspera1aAprobacion,
            MAX(Estatus1aAprobacion)                    AS Estatus1aAprobacion,

            ------- 

            MAX(Responsable2aAprobacion)                AS Responsable2aAprobacion,
            MAX(Fecha2aAprobacion)                      AS Fecha2aAprobacion,
            MAX(DiasEspera2aAprobacion)                 AS DiasEspera2aAprobacion,
            MAX(Estatus2aAprobacion)                    AS Estatus2aAprobacion,
            MIN(ProgramaDel)                            AS ProgramaDel, MAX(ProgramaAl) AS ProgramaAl,
            MAX(FechaCargaAvance)                       AS FechaCargaAvance, VolumetriaAvance,
            MAX(DiasCargaAvance)                        AS DiasCargaAvance,
            MAX(FechaVoBoOperadora)                     AS FechaVoBoOperadora,
            MAX(ResponsableVoBoOperadora)               AS ResponsableVoBoOperadora,
            MAX(DiasVoBoOperadora)                      AS DiasVoBoOperadora,
            MAX(FechaCierreSemana)                      AS FechaCierreSemana,
            MAX(Responsable_Cierre_Semana)              AS Responsable_Cierre_Semana,
            MAX(DiasCierreSemana)                       AS DiasCierreSemana,
            MAX(DiasAvanceSemanal)                      AS DiasAvanceSemanal, FechaDeEstimacion,
            ResponsableEstimacion, MAX(DiasEstimacion)  AS DiasEstimacion,
            MAX(DiasCargaAvance)+MAX(DiasVoBoOperadora)+MAX(DiasCierreSemana)
            +MAX(DiasAvanceSemanal)+MAX(DiasEstimacion) AS DiasTotales,
            FechaCargaPR, NumberPR, NumeroPO,
            MAX(FechaRegistroPO)                        AS FechaRegistroPO, MAX(DiasPR) AS DiasPR,
            MAX(DiasRegistroPR_CargaAvance)             AS DiasRegistroPR_CargaAvance,
            IdOTEstimacion
        INTO #tmpResultado3
        FROM #tmpResultado2
        GROUP BY VolumetriaAvance, NumeroContrato, IdOTSolicitud,
            IdSolicitudPedido, Folio, Objeto, CentroCosto, RazonSocialProv,
            Tarea, SubTarea, Estatus, RegistroDeOT, Requisitor,
            ResponsableVoBoOperadora, FechaDeEstimacion,
            ResponsableEstimacion, NumeroPO, FechaCargaPR, NumberPR,
            IdOTEstimacion ;



        --Resultado Final 

        --insert into OT_BI_Tablero 

        SELECT t.NumeroContrato, t.IdOTSolicitud,
            t.IdSolicitudPedido                         AS IdSolicitudPedido, Folio, Objeto,
            CentroCosto, RazonSocialProv, Tarea, SubTarea, Estatus,
            RegistroDeOT, Requisitor,
            MAX(Responsable1aAprobacion)                AS Responsable1aAprobacion,
            MAX(Fecha1aAprobacion)                      AS Fecha1aAprobacion,
            MAX(DiasEspera1aAprobacion)                 AS DiasEspera1aAprobacion,
            MAX(Estatus1aAprobacion)                    AS Estatus1aAprobacion,
            MAX(Responsable2aAprobacion)                AS Responsable2aAprobacion,
            MAX(Fecha2aAprobacion)                      AS Fecha2aAprobacion,
            MAX(DiasEspera2aAprobacion)                 AS DiasEspera2aAprobacion,
            MAX(Estatus2aAprobacion)                    AS Estatus2aAprobacion,
            MAX(FechaCargaPR)                           AS FechaCargaPR, MAX(NumberPR) AS NumberPR,
            MAX(DiasPR)                                 AS DiasPR, MIN(ProgramaDel) AS ProgramaDel,
            MAX(ProgramaAl)                             AS ProgramaAl,
            MAX(FechaCargaAvance)                       AS FechaCargaAvance, VolumetriaAvance,
            MAX(DiasCargaAvance)                        AS DiasCargaAvance,
            MAX(DiasRegistroPR_CargaAvance)             AS DiasRegistroPR_CargaAvance,
            MAX(FechaVoBoOperadora)                     AS FechaVoBoOperadora,
            MAX(ResponsableVoBoOperadora)               AS ResponsableVoBoOperadora,
            MAX(DiasVoBoOperadora)                      AS DiasVoBoOperadora,
            MAX(FechaCierreSemana)                      AS FechaCierreSemana,
            MAX(Responsable_Cierre_Semana)              AS Responsable_Cierre_Semana,
            MAX(DiasCierreSemana)                       AS DiasCierreSemana,
            MAX(DiasAvanceSemanal)                      AS DiasAvanceSemanal,
            MAX(FechaDeEstimacion)                      AS FechaDeEstimacion,
            MAX(ResponsableEstimacion)                  AS ResponsableEstimacion,
            MAX(DiasEstimacion)                         AS DiasEstimacion,
            MAX(DiasCargaAvance)+MAX(DiasVoBoOperadora)+MAX(DiasCierreSemana)
            +MAX(DiasAvanceSemanal)+MAX(DiasEstimacion) AS DiasTotales,
            MAX(NumeroPO)                               AS NumeroPO,
            MAX(FechaRegistroPO)                        AS FechaRegistroPO, e.IdPedido AS IdPedido
        INTO #tmpResultado4
        FROM #tmpResultado3         t
        LEFT JOIN dbo.OT_Estimacion e
            ON e.IdOTEstimacion=t.IdOTEstimacion
        GROUP BY VolumetriaAvance, t.NumeroContrato, t.IdOTSolicitud, Folio,
            Objeto, CentroCosto, RazonSocialProv, Tarea, SubTarea, Estatus,
            RegistroDeOT, Requisitor, e.IdPedido, t.IdSolicitudPedido,
            e.IdPedidoGeneral ;


        -- INICIO PROCURA 

        DECLARE @ACEPTACIONESCN TABLE(IdAceptacionPedido INT,
        FechaRecepcionCN DATETIME,
        FechaEvaluacionCN DATETIME,
        EstatusCartaCN NVARCHAR (200),
        UsuarioEvaluaCN NVARCHAR (200)) ;


        INSERT INTO @ACEPTACIONESCN(IdAceptacionPedido, FechaRecepcionCN,
        FechaEvaluacionCN, EstatusCartaCN, UsuarioEvaluaCN)
        SELECT AP.IdAceptacionPedido,
            (SELECT TOP 1 CreadoEl
             FROM Petrovendor.dbo.MM_AceptacionCartaPCN
             WHERE IdAceptacionPedido=AP.IdAceptacionPedido
             ORDER BY CreadoEl DESC),
            (SELECT TOP 1 FechaEvaluacion
             FROM Petrovendor.dbo.MM_AceptacionCartaPCN
             WHERE IdAceptacionPedido=AP.IdAceptacionPedido
             ORDER BY CreadoEl DESC),
            (SELECT TOP 1 EST.Nombre
             FROM Petrovendor.dbo.MM_AceptacionCartaPCN AS APC
             LEFT JOIN Petrovendor.dbo.TA_Estatus       AS EST
                 ON EST.IdEstatus=APC.IdEstatus
             WHERE APC.IdAceptacionPedido=AP.IdAceptacionPedido
             ORDER BY APC.CreadoEl DESC),
            (SELECT TOP 1 US.Nombre
             FROM Petrovendor.dbo.MM_AceptacionCartaPCN AS APC
             LEFT JOIN Petrovendor.dbo.S_Usuario        AS US
                 ON US.IdUsuario=APC.IdUsuarioEvaluador
             WHERE APC.IdAceptacionPedido=AP.IdAceptacionPedido
             ORDER BY APC.CreadoEl DESC)
        FROM Petrovendor.dbo.MM_AceptacionPedido     AS AP
        INNER JOIN Petrovendor.dbo.MM_Pedido         AS P
            ON P.IdPedido=AP.IdPedido
        INNER JOIN #tmpResultado4                    filtro
            ON P.IdPedido=filtro.IdPedido -- se filtra la informacion que viene de la ultima tabla de la OT 
        LEFT JOIN Petrovendor.dbo.DEA_Relacion_PR_PO po
            ON po.IdPedido=P.IdPedido ;




        SELECT P.IdPedido, uPo.Nombre                                          AS UsuarioRelacionPOSAP,
            po.PO                                                              AS NumeroPOSAP, po.FechaAltaRelacion AS FechaRelacionPOSAP,
            (Petrovendor.dbo.CalcularTipoDEA(
                 filtro.FechaDeEstimacion, po.FechaAltaRelacion))              AS DiasRelacionPOSAP,         -- (FechaDeEstimacion - FechaRelacionPOSAP) 

            AP.IdAceptacionPedido                                              AS NumeroAceptacionPedido,
            APCN.FechaRecepcionCN                                              AS FechaRecepcionCartaCN,
            NULL                                                               AS DiasRecepcionCartaCartaCN, --(FechaRelacionPOSAP - FechaRecepcionCartaCN) 

            APCN.UsuarioEvaluaCN                                               AS UsuarioApruebaCartaCN,
            APCN.FechaEvaluacionCN                                             AS FechaAprobacionCartaCN,
            CAST(DATEDIFF(hh, APCN.FechaRecepcionCN, APCN.FechaEvaluacionCN)
                 / 24.0 AS DECIMAL (20, 2))                                    AS DiasAprobacionCartaCN,
                                                                                                             -- (Petrovendor.dbo.CalcularTipoDEA(APCN.FechaRecepcionCN, APCN.FechaEvaluacionCN)) AS DiasAprobacionCartaCN, 

            CASE WHEN RCP.PedirCarta=0 THEN 'Excluida' ELSE
                                                       APCN.EstatusCartaCN END AS EstatusCartaCN,
            TOF.FechaRegistro                                                  AS FechaRecepcionFactura,
            CAST(DATEDIFF(hh, APCN.FechaEvaluacionCN, TOF.FechaRegistro)
                 / 24.0 AS DECIMAL (20, 2))                                    AS DiasRecepcionFactura,
                                                                                                             --(Petrovendor.dbo.CalcularTipoDEA(APCN.FechaEvaluacionCN, TOF.FechaRegistro)) AS DiasRecepcionFactura, 

            FI.Folio                                                           AS FolioFactura, UST1.Nombre AS Responsable1aAprobacion,
            TF1.FechaCambioEstatus                                             AS Fecha1aAprobacion,
            CAST(DATEDIFF(hh, TOF.FechaRegistro, TF1.FechaCambioEstatus)
                 / 24.0 AS DECIMAL (20, 2))                                    AS DiasEspera1aAprobacion,
                                                                                                             -- (Petrovendor.dbo.CalcularTipoDEA(TOF.FechaRegistro, TF1.FechaCambioEstatus)) AS DiasEspera1aAprobacion, 

            EA1.Nombre                                                         AS Estatus1aAprobacion,
            UST2.Nombre                                                        AS Responsable2aAprobacion,
            TF2.FechaCambioEstatus                                             AS Fecha2aAprobacion,
            CAST(DATEDIFF(hh, TF1.FechaCambioEstatus, TF2.FechaCambioEstatus)
                 / 24.0 AS DECIMAL (20, 2))                                    AS DiasEspera2aAprobacion,
                                                                                                             --(Petrovendor.dbo.CalcularTipoDEA(TF1.FechaCambioEstatus, TF2.FechaCambioEstatus)) AS DiasEspera2aAprobacion, 

            EA2.Nombre                                                         AS Estatus2aAprobacion
        INTO #DATOSACEPTACIONES
        FROM Petrovendor.dbo.MM_SolicitudPedido         AS SP
        LEFT JOIN Petrovendor.dbo.MM_Pedido             AS P
            ON P.IdSolicitudPedido=SP.IdSolicitudPedido
        LEFT JOIN #tmpResultado4                        filtro
            ON filtro.IdPedido=P.IdPedido --filtro 
        LEFT JOIN Petrovendor.dbo.MM_Pedidos            AS PS
            ON PS.IdIdentificador=P.IdPedido
               AND PS.IdProveedorCliente=P.IdProveedorCompras
        LEFT JOIN Petrovendor.dbo.S_Proveedor           AS PR
            ON PR.IdProveedor=P.IdSubcontratista
        LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido   AS AP
            ON AP.IdPedido=P.IdPedido
        LEFT JOIN @ACEPTACIONESCN                       AS APCN
            ON APCN.IdAceptacionPedido=AP.IdAceptacionPedido
        LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura  AS AF
            ON AF.IdAceptacionPedido=AP.IdAceptacionPedido
        LEFT JOIN Petrovendor.dbo.TA_Operacion          AS TOF
            ON TOF.IdDocumento=AF.IdAceptacionFactura
               AND TOF.IdTipoOperacion=10
        LEFT JOIN Petrovendor.dbo.FI_Factura            AS FI
            ON FI.IdFactura=AF.IdFactura
        LEFT JOIN Petrovendor.dbo.TA_Estatus            AS ESF
            ON ESF.IdEstatus=TOF.IdEstatusOperacion
        LEFT JOIN Petrovendor.dbo.DEA_Relacion_PR_PO    AS PRPO
            ON PRPO.IdPedido=P.IdPedido
        LEFT JOIN Petrovendor.dbo.S_Usuario             AS USPR
            ON USPR.IdUsuario=AP.CreadorPor
        LEFT JOIN Petrovendor.dbo.DEA_AdjuntoPO         AS POAD
            ON POAD.IdAdjuntoPO=PRPO.IdAdjuntoPO
        LEFT JOIN Petrovendor.dbo.TA_Tarea              AS TF1
            ON TF1.IdOperacion=TOF.IdOperacion AND TF1.NoSecuencia=1
               AND TF1.IdEstatus<>12
        LEFT JOIN Petrovendor.dbo.S_Usuario             AS UST1
            ON UST1.IdUsuario=TF1.IdAprobador
        LEFT JOIN Petrovendor.dbo.TA_Tarea              AS TF2
            ON TF2.IdOperacion=TOF.IdOperacion AND TF2.NoSecuencia=2
               AND TF2.IdEstatus<>12
        LEFT JOIN Petrovendor.dbo.S_Usuario             AS UST2
            ON UST2.IdUsuario=TF2.IdAprobador
        LEFT JOIN Petrovendor.dbo.TA_Estatus            AS EA1
            ON EA1.IdEstatus=TF1.IdEstatus
        LEFT JOIN Petrovendor.dbo.TA_Estatus            AS EA2
            ON EA2.IdEstatus=TF2.IdEstatus
        LEFT JOIN Petrovendor.dbo.TA_Operacion          AS OPSP
            ON OPSP.IdDocumento=SP.IdSolicitudPedido
               AND OPSP.IdTipoOperacion=2
        LEFT JOIN Adinco.dbo.OT_Estimacion              AS ESOT
            ON ESOT.IdSolicitudPedido=SP.IdSolicitudPedido
        LEFT JOIN Petrovendor.dbo.RelacionCartaCNPedido AS RCP
            ON RCP.IdAceptacionPedido=AP.IdAceptacionPedido
        LEFT JOIN Petrovendor.dbo.DEA_Relacion_PR_PO    po
            ON po.IdPedido=P.IdPedido
        LEFT JOIN Petrovendor.dbo.S_Usuario             uPo
            ON uPo.IdUsuario=po.CreadoPor
        WHERE OPSP.IdEstatusOperacion=2 AND P.IdPedido IS NOT NULL
              AND P.RecepcionServicio=1
        GROUP BY P.IdPedido, filtro.FechaDeEstimacion, po.FechaAltaRelacion,
            APCN.FechaRecepcionCN, APCN.FechaEvaluacionCN, RCP.PedirCarta,
            APCN.EstatusCartaCN, TOF.FechaRegistro, TF1.FechaCambioEstatus,
            TF2.FechaCambioEstatus, uPo.Nombre, po.PO, po.FechaAltaRelacion,
            AP.IdAceptacionPedido, APCN.UsuarioEvaluaCN, FI.Folio,
            UST1.Nombre, EA1.Nombre, EA2.Nombre, UST2.Nombre, PS.IdPedido
        ORDER BY PS.IdPedido DESC ;



        -- FIN PROCURA 



        --Contar cuantas filas hay abiertas y cerradas pór OT 

        SELECT IdOTSolicitud,
            SUM(CASE WHEN IdSolicitudPedido IS NULL THEN 1 ELSE 0 END)     AS SinEstimacion,
            SUM(CASE WHEN IdSolicitudPedido IS NOT NULL THEN 1 ELSE 0 END) AS ConEstimacion,

            (SELECT MAX(IdSolicitudPedido)
             FROM #tmpResultado4 s1
             WHERE s1.IdOTSolicitud=t.IdOTSolicitud)                       AS MaxIdCerrada
        INTO #tmpResumenAbiertaCerrada
        FROM #tmpResultado4 t
        GROUP BY IdOTSolicitud ;



        -- Retorno a la vista 

        --insert into OT_BI_Tablero 

        SELECT CAST(infoOt.NumeroContrato AS VARCHAR (100))                                  AS NumeroContrato,
            ISNULL(infoOt.IdOTSolicitud, 0)                                                  AS IdOTSolicitud,
            infoOt.IdSolicitudPedido                                                         AS IdSolicitudPedido,
            CAST(infoOt.Folio AS VARCHAR (30))                                               AS Folio,
            CAST(infoOt.Objeto AS VARCHAR (1000))                                            AS Objeto,
            CAST(infoOt.CentroCosto AS VARCHAR (200))                                        AS CentroCosto,
            CAST(infoOt.RazonSocialProv AS VARCHAR (2000))                                   AS RazonSocialProv,
            CAST(infoOt.Tarea AS VARCHAR (350))                                              AS Tarea,
            CAST(infoOt.SubTarea AS VARCHAR (350))                                           AS SubTarea,
            CAST(infoOt.Estatus AS VARCHAR (100))                                            AS Estatus,
            infoOt.RegistroDeOT                                                              AS RegistroDeOT,
            CAST(infoOt.Requisitor AS VARCHAR (650))                                         AS Requisitor,
            CAST(infoOt.Responsable1aAprobacion AS VARCHAR (650))                            AS Responsable1aAprobacion,
            infoOt.Fecha1aAprobacion                                                         AS Fecha1aAprobacion,
            infoOt.DiasEspera1aAprobacion                                                    AS DiasEspera1aAprobacion,
            CASE WHEN infoOt.Estatus LIKE '%rechazada%operador%'
                      OR infoOt.Estatus LIKE '%Requiere%Convenio%' THEN
                     infoOt.Estatus ELSE
                                        CAST(infoOt.Estatus1aAprobacion AS VARCHAR (350))END AS Estatus1aAprobacion,
            CAST(infoOt.Responsable2aAprobacion AS VARCHAR (650))                            AS Responsable2aAprobacion,
            infoOt.Fecha2aAprobacion                                                         AS Fecha2aAprobacion,
            infoOt.DiasEspera2aAprobacion                                                    AS DiasEspera2aAprobacion,
            CASE WHEN infoOt.Estatus LIKE '%Rechazada%Subcontratista%' THEN
                     infoOt.Estatus
            WHEN infoOt.Estatus2aAprobacion NOT IN ('En Aprobación',
                'En espera 1a Aprobación')
                 AND infoOt.Estatus LIKE '%Requiere%Convenio%' THEN
                infoOt.Estatus ELSE
                                   CAST(infoOt.Estatus2aAprobacion AS VARCHAR (350))END      AS Estatus2aAprobacion,
            infoOt.FechaCargaPR                                                              AS FechaCargaPR,
            CAST(infoOt.NumberPR AS VARCHAR (100))                                           AS NumberPR,
            infoOt.DiasPR                                                                    AS DiasPR, infoOt.ProgramaDel AS ProgramaDel,
            infoOt.ProgramaAl                                                                AS ProgramaAl,
            infoOt.FechaCargaAvance                                                          AS FechaCargaAvance,
            CAST(infoOt.VolumetriaAvance AS VARCHAR (30))                                    AS VolumetriaAvance,
            infoOt.DiasCargaAvance                                                           AS DiasCargaAvance,
            infoOt.DiasRegistroPR_CargaAvance                                                AS DiasRegistroPR_CargaAvance,
            infoOt.FechaVoBoOperadora                                                        AS FechaVoBoOperadora,
            CAST(infoOt.ResponsableVoBoOperadora AS VARCHAR (650))                           AS ResponsableVoBoOperadora,
            infoOt.DiasVoBoOperadora                                                         AS DiasVoBoOperadora,
            infoOt.FechaCierreSemana,
            CAST(infoOt.Responsable_Cierre_Semana AS VARCHAR (650))                          AS Responsable_Cierre_Semana,
            infoOt.DiasCierreSemana, infoOt.DiasAvanceSemanal,
            infoOt.FechaDeEstimacion,
            CAST(infoOt.ResponsableEstimacion AS VARCHAR (650))                              AS ResponsableEstimacion,
            infoOt.DiasEstimacion, infoOt.DiasTotales,
            CAST(infoOt.NumeroPO AS VARCHAR (200))                                           AS NumeroPO,
            infoOt.FechaRegistroPO, e.IdPedidoGeneral                                        AS IdPedido,
            CAST(procura.UsuarioRelacionPOSAP AS VARCHAR (650))                              AS UsuarioRelacionPOSAP,
            CAST(procura.NumeroPOSAP AS VARCHAR (50))                                        AS NumeroPOSAP,
            procura.FechaRelacionPOSAP,
            CAST(procura.DiasRelacionPOSAP AS VARCHAR (200))                                 AS DiasRelacionPOSAP,
            procura.NumeroAceptacionPedido, procura.FechaRecepcionCartaCN,
            ISNULL(
                CAST(DATEDIFF(
                         hh, CAST(infoOt.FechaDeEstimacion AS DATETIME),
                         CAST(procura.FechaRecepcionCartaCN AS DATETIME))
                     / 24.0 AS DECIMAL (20, 2)), 0)                                          AS DiasRecepcionCartaCartaCN,
            ISNULL(
                CASE WHEN ISNULL(DiasRelacionPOSAP, 0)>(CAST(DATEDIFF(
                                                                 hh,
                                                                 CAST(infoOt.FechaDeEstimacion AS DATETIME),
                                                                 CAST(procura.FechaRecepcionCartaCN AS DATETIME))
                                                             / 24.0 AS DECIMAL (20, 2))) THEN
                         DiasRelacionPOSAP ELSE
                                               CAST(DATEDIFF(
                                                        hh,
                                                        CAST(infoOt.FechaDeEstimacion AS DATETIME),
                                                        CAST(procura.FechaRecepcionCartaCN AS DATETIME))
                                                    / 24.0 AS DECIMAL (20, 2))END,
                0)                                                                           AS DiasRelacionPO_CartaCN, procura.UsuarioApruebaCartaCN,
            procura.FechaAprobacionCartaCN, procura.DiasAprobacionCartaCN,
            ISNULL(
                CAST(DATEDIFF(
                         hh,
                         CASE WHEN procura.FechaRecepcionCartaCN>procura.FechaRelacionPOSAP THEN
                                  procura.FechaRecepcionCartaCN
                         WHEN procura.FechaRecepcionCartaCN<procura.FechaRelacionPOSAP THEN
                             procura.FechaRelacionPOSAP ELSE
                                                            ISNULL(
                                                                procura.FechaRecepcionCartaCN,
                                                                procura.FechaRelacionPOSAP)END,
                         FechaAprobacionCartaCN)/ 24.0 AS DECIMAL (20, 2)), 0)               AS DiasAprobacionCartaCN2,
            procura.EstatusCartaCN, procura.FechaRecepcionFactura,
            procura.DiasRecepcionFactura, procura.FolioFactura,
            procura.Responsable1aAprobacion                                                  AS Responsable1aAprobacion_Fac,
            procura.Fecha1aAprobacion                                                        AS Fecha1aAprobacion_Fac,
            procura.DiasEspera1aAprobacion                                                   AS DiasEspera1aAprobacionFac,
            procura.Estatus1aAprobacion                                                      AS Estatus1aAprobacion_Fac,
            procura.Responsable2aAprobacion                                                  AS Responsable2aAprobacion_Fac,
            procura.Fecha2aAprobacion                                                        AS Fecha2aAprobacion_Fac,
            procura.DiasEspera2aAprobacion                                                   AS DiasEspera2aAprobacion_Fac,
            procura.Estatus2aAprobacion                                                      AS Estatus2aAprobacion_Fac,
            ISNULL(
                CAST(DATEDIFF(
                         hh, procura.Fecha2aAprobacion,
                         procura.FechaRelacionPOSAP)/ 24.0 AS DECIMAL (20, 2)),
                0)                                                                           AS DiasRelacionPO_AprobacionFactura
        INTO #tmpResultado5
        FROM #tmpResultado4                 infoOt
        LEFT JOIN OT_Estimacion             e
            ON e.IdSolicitudPedido=infoOt.IdSolicitudPedido
        LEFT JOIN #DATOSACEPTACIONES        procura
            ON procura.IdPedido=infoOt.IdPedido
        LEFT JOIN #tmpResumenAbiertaCerrada r
            ON r.IdOTSolicitud=infoOt.IdOTSolicitud
        WHERE(infoOt.VolumetriaAvance='Abierta'
              AND infoOt.IdSolicitudPedido IS NULL)
             OR(infoOt.VolumetriaAvance='Abierta'
                AND infoOt.IdSolicitudPedido=r.MaxIdCerrada)
             OR(infoOt.VolumetriaAvance='Cerrada'
                AND infoOt.IdSolicitudPedido=r.MaxIdCerrada)
             OR(infoOt.VolumetriaAvance='Cerrada'
                AND infoOt.IdSolicitudPedido IS NULL) ;





        SELECT COUNT(1)                 AS Count, IdOTSolicitud,
            MAX(IdSolicitudPedido)      AS IdSolicitudPedido,
            MAX(NumeroAceptacionPedido) AS NumeroAceptacionPedido
        INTO #tmpResultaFinalRep
        FROM #tmpResultado5
        GROUP BY IdOTSolicitud ;


		select ot.IdOTSolicitud , Total = SUM(om.Cantidad * mat.PrecioUnitario)
		into #tmpAFOTTotales
		from OT_Solicitud ot
		inner join #tmpResultado5 res on res.IdOTSolicitud = ot.IdOTSolicitud
		inner join OT_SolicitudMaterial om on om.IdOTSolicitud = ot.IdOTSolicitud
		inner join SC_Materiales mat on mat.IdSCMaterial  = om.IdSCMaterial
		GROUP BY ot.IdOTSolicitud
		

		select ot.IdOTSolicitud , Total = SUM(e.Total)
		into #tmpAFOTEstimado
		from OT_Solicitud ot
		inner join #tmpResultado5 res on res.IdOTSolicitud = ot.IdOTSolicitud
		inner join OT_Estimacion e on e.IdOTSolicitud = ot.IdOTSolicitud AND
								isnull(e.Cancelada,0) = 0
		GROUP BY ot.IdOTSolicitud

		
		select OT.IdOTSolicitud, 
			AVANCE_FINANCIERO=case when isnull(ot.Total,0) = 0 then 0 else  (ISNULL(E.Total,0) * 100)/isnull(ot.Total,0) end
		into #tmpAF
		from #tmpAFOTTotales ot
		left join #tmpAFOTEstimado e on e.IdOTSolicitud = ot.IdOTSolicitud



        insert into OT_BI_Tablero(NumeroContrato,IdOTSolicitud,IdSolicitudPedido,Folio,
					Objeto,CentroCosto,RazonSocialProv,Tarea,
					SubTarea,Estatus,RegistroDeOT,Requisitor,Responsable1aAprobacion,Fecha1aAprobacion,
					DiasEspera1aAprobacion,Estatus1aAprobacion,Responsable2aAprobacion,Fecha2aAprobacion,DiasEspera2aAprobacion,Estatus2aAprobacion,
					FechaCargaPR,NumberPR,DiasPR,ProgramaDel,ProgramaAl,FechaCargaAvance,VolumetriaAvance,
					DiasCargaAvance,DiasRegistroPR_CargaAvance,FechaVoBoOperadora,ResponsableVoBoOperadora,DiasVoBoOperadora,FechaCierreSemana,
					Responsable_Cierre_Semana,DiasCierreSemana,DiasAvanceSemanal,FechaDeEstimacion,ResponsableEstimacion,DiasEstimacion,
					DiasTotales,NumeroPO,FechaRegistroPO,IdPedido,UsuarioRelacionPOSAP,NumeroPOSAP,
					FechaRelacionPOSAP,DiasRelacionPOSAP,NumeroAceptacionPedido,FechaRecepcionCartaCN,DiasRecepcionCartaCartaCN,DiasRelacionPO_CartaCN,
					UsuarioApruebaCartaCN,FechaAprobacionCartaCN,DiasAprobacionCartaCN,DiasAprobacionCartaCN2,EstatusCartaCN,FechaRecepcionFactura,
					DiasRecepcionFactura,FolioFactura,Responsable1aAprobacion_Fac,Fecha1aAprobacion_Fac,DiasEspera1aAprobacionFac,Estatus1aAprobacion_Fac,
					Responsable2aAprobacion_Fac,Fecha2aAprobacion_Fac,DiasEspera2aAprobacion_Fac,Estatus2aAprobacion_Fac,DiasRelacionPO_AprobacionFactura,AvanceFinanciero)
        SELECT t1.*,
				AF.AVANCE_FINANCIERO
        FROM #tmpResultado5            t1
        INNER JOIN #tmpResultaFinalRep t2
            ON t2.IdOTSolicitud=t1.IdOTSolicitud
		LEFT JOIN #tmpAF AF on AF.IdOTSolicitud = t1.IdOTSolicitud 
        WHERE(t2.Count=1
              OR(t2.Count>1 AND t1.IdSolicitudPedido IS NOT NULL
                 AND t2.IdSolicitudPedido IS NOT NULL
                 AND t1.IdSolicitudPedido=t2.IdSolicitudPedido
                 AND t1.NumeroAceptacionPedido=ISNULL(
                                                   t2.NumeroAceptacionPedido,
                                                   t1.NumeroAceptacionPedido))
              OR(t2.Count>1 AND t1.IdSolicitudPedido IS NULL
                 AND t2.IdSolicitudPedido IS NULL)) ;


    END ;


