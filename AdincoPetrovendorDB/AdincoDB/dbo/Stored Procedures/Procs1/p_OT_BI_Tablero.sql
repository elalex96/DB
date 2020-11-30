CREATE proc [dbo].[p_OT_BI_Tablero]
as


/****** Object:  StoredProcedure [dbo].[p_OT_BI_Tablero]    Script Date: 13/08/2020 09:11:21 p. m. ******/


delete OT_BI_Tablero

-- PARA OTS SIN BITACORA, BUSCAR ACCIONES DEL MANAGER EN BASE A LAS NOTIFICACIONES
SELECT ot.IdOTSolicitud,
       u.Nombre,
       Fecha = MIN(n.CreadoEl)
INTO #tmpOTManagerNot
FROM Adinco..OT_SolicitudBitacora sb
    INNER JOIN Adinco..OT_Solicitud ot
        ON ot.IdOTSolicitud = sb.IdOTSolicitud
    INNER JOIN Adinco..S_Notificacion n
        ON n.Asunto LIKE '%' + ot.Folio + '%'
           AND n.CreadoEl > ot.CreadoEl
    INNER JOIN Adinco..AP_Usuario u
        ON u.UsuarioID = n.CreadoPor
           AND u.Usuario NOT LIKE '%smps-adinco.com%'
           AND u.Usuario NOT LIKE '%ogss.com.mx%'
           AND u.Usuario NOT LIKE '%adinco.mx%'
WHERE n.Asunto LIKE '%Control de Obra%'
      --AND NOT (sb.IdTipoMovimiento = 2 
      --		OR sb.Descripcion = 'Rechazada Operador'
      --		OR sb.Descripcion like '%Aprobada%Operador%'
      --		OR sb.Descripcion = 'Aprobada Operador'
      --		OR sb.Descripcion = 'Enviada a Subcontratista')

      AND
      (
          n.Mensaje LIKE '%La OT ha sido aprobada%'
          OR n.Mensaje LIKE '%La OT ha sido rechazada%'
          OR n.Mensaje LIKE '%Es necesario revisar la programacion inicial%'
          OR n.Mensaje LIKE '%Es necesario aprobar/rechazar%'
      )
GROUP BY ot.IdOTSolicitud,
         u.Nombre;




SELECT ot.IdOTSolicitud,
       Usuario = CASE
                     WHEN ot.ProgIniPorProveedor = 1 THEN
                         pv.RazonSocial
                     ELSE
                         ISNULL(ISNULL(u.Nombre, mana.Nombre), '') COLLATE SQL_Latin1_General_CP1_CI_AS
                 END,
       Fecha = MIN(   CASE
                          WHEN ot.ProgIniPorProveedor = 1 THEN
                              sb2.CreadoEl
                          ELSE
                              ISNULL(sb.CreadoEl, mana.Fecha)
                      END
                  ),
       ot.ProgIniPorProveedor,
       Estatus = MAX(   CASE
                            WHEN ot.ProgIniPorProveedor = 1 THEN
                                sb2.Descripcion
                            ELSE
                                ISNULL(   sb.Descripcion,
                                          CASE
                                              WHEN mana.Nombre IS NOT NULL THEN
                                                  'Enviada a Subcontratista'
                                              ELSE
                                                  NULL
                                          END
                                      )
                        END
                    )
INTO #tmpAprobador1
FROM OT_Solicitud ot
    INNER JOIN SC_SubContrato sc
        ON sc.IdSubContrato = ot.IdSubContrato
    INNER JOIN PV_Subcontratista pv
        ON pv.IdSubcontratista = sc.IdSubContratista
    LEFT JOIN OT_SolicitudBitacora sb
        ON ot.IdOTSolicitud = sb.IdOTSolicitud
           AND (
					sb.IdTipoMovimiento IN ( 3 ) OR
					sb.Descripcion like '%Enviada%Subcontratista%'
			   )
    LEFT JOIN OT_SolicitudBitacora sb2
        ON ot.IdOTSolicitud = sb2.IdOTSolicitud
           AND (
			sb2.IdTipoMovimiento IN ( 5 ) OR 
			sb.Descripcion like '%Propuesta%Subcontratista%'
		   )
    LEFT JOIN AP_Usuario u
        ON u.UsuarioID = sb.UsuarioAdincoId
           AND u.Usuario NOT LIKE '%smps-adinco.com%'
           AND u.Usuario NOT LIKE '%ogss.com.mx%'
           AND u.Usuario NOT LIKE '%adinco.mx%'
    LEFT JOIN Petrovendor..S_Usuario u2
        ON u2.IdUsuario = sb2.UsuarioPetroId
    LEFT JOIN #tmpOTManagerNot mana
        ON mana.IdOTSolicitud = ot.IdOTSolicitud
GROUP BY ot.IdOTSolicitud,
         ot.ProgIniPorProveedor,
         u2.Nombre,
         u.Nombre,
         ot.ProgIniPorProveedor,
         mana.Nombre,
         pv.RazonSocial;


SELECT ot.IdOTSolicitud,
       Usuario = CASE
                     WHEN ot.ProgIniPorProveedor = 1 THEN
                         ISNULL(u.Nombre, mana.Nombre)
                     ELSE
                         pv.RazonSocial
                 END,
       Fecha = MAX(   CASE
                          WHEN ot.ProgIniPorProveedor = 1 THEN
                              ISNULL(sb.CreadoEl, mana.Fecha)
                          ELSE
                              sb2.CreadoEl
                      END
                  ),
       ot.ProgIniPorProveedor,
       Estatus = MAX(   CASE
                            WHEN ot.ProgIniPorProveedor = 1 THEN
                                sb.Descripcion
                            ELSE
                                sb2.Descripcion
                        END
                    )
INTO #tmpAprobador2
FROM OT_Solicitud ot
    INNER JOIN SC_SubContrato sc
        ON sc.IdSubContrato = ot.IdSubContrato
    INNER JOIN PV_Subcontratista pv
        ON pv.IdSubcontratista = sc.IdSubContratista
    LEFT JOIN OT_SolicitudBitacora sb
        ON ot.IdOTSolicitud = sb.IdOTSolicitud
           AND sb.IdTipoMovimiento IN ( 2 )
    LEFT JOIN OT_SolicitudBitacora sb2
        ON ot.IdOTSolicitud = sb2.IdOTSolicitud
           AND sb2.IdTipoMovimiento IN ( 4 )
    LEFT JOIN AP_Usuario u
        ON u.UsuarioID = sb.UsuarioAdincoId
    LEFT JOIN Petrovendor..S_Usuario u2
        ON u2.IdUsuario = sb2.UsuarioPetroId
    LEFT JOIN #tmpOTManagerNot mana
        ON mana.IdOTSolicitud = ot.IdOTSolicitud
--where ot.IdOTSolicitud = 46

GROUP BY ot.IdOTSolicitud,
         ot.ProgIniPorProveedor,
         u2.Nombre,
         u.Nombre,
         ot.ProgIniPorProveedor,
         pv.RazonSocial,
         mana.Nombre;


/*****CONSULTA PARA CONOCER ULTIMA FECHA DE CAPTURA POR OT*************/
SELECT ot.IdOTSolicitud,
       FechaCaptura = MAX(cap.Fecha),
       Completada = ISNULL(   CASE
                                  WHEN MAX(cap.Fecha) >= ot.FechaFin THEN
                                      1
                                  ELSE
                                      0
                              END,
                              0
                          )
INTO #tmpOTFechaCapturaMax
FROM OT_Solicitud ot
    INNER JOIN OT_SolicitudMaterial otm
        ON otm.IdOTSolicitud = ot.IdOTSolicitud
    INNER JOIN [OT_SolicitudProgramaCaptura] cap
        ON cap.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
           AND cap.FechaVoBoSubcontratista IS NOT NULL
GROUP BY ot.IdOTSolicitud,
         ot.FechaFin;




SELECT DISTINCT
    --sc.IdContratista,
    --sc.IdContrato,
		c.NumeroContrato,
       ot.IdOTSolicitud,
       ped.IdSolicitudPedido,
       Folio = ot.Folio,
       ot.Objeto,
       cc.CentroCosto,
       RazonSocialProv = ISNULL(pv.RazonSocial, 'NO ENCONTRADO'),
       Tarea = CONCAT(t.id_Tarea, ' ', t.TareaPetrolera),
       SubTarea = serv.NombreServicio,
       Estatus = est.Descripcion,
       RegistroDeOT = ot.CreadoEl,
       Requisitor = uReq.Nombre,
       Responsable1aAprobacion = a1.Usuario,
       Fecha1aAprobacion = a1.Fecha,
       DiasEspera1aAprobacion = CAST(0 AS FLOAT),
       Estatus1aAprobacion = CASE
                                 WHEN ot.IdOTEstatus = 1 THEN
                                     'Sin iniciar 1a Aprobacion'
                                 WHEN ot.IdOTEstatus <> 1
                                      AND a1.Estatus IS NULL THEN
                                     'En Aprobación'
                                 ELSE
                                     a1.Estatus
                             END,
       ---------------
       Responsable2aAprobacion = a2.Usuario,
       Fecha2aAprobacion = a2.Fecha,
       DiasEspera2aAprobacion = CAST(0 AS FLOAT),
       Estatus2aAprobacion = CASE
                                 WHEN a1.Estatus IS NULL THEN
                                     'En espera 1a Aprobación'
                                 WHEN a1.Estatus IS NOT NULL
                                      AND a2.Estatus IS NULL THEN
                                     'En Aprobación'
                                 ELSE
                                     a2.Estatus
                             END,
       --Fecha_De_Rechazo = case when ot.IdOTEstatus in (7,8) then ot.ModificadoEl end,

       --FechaAprobacionOT = case when ot.ProgIniPorProveedor = 0 then
       --						isnull(
       --							min(bitaAprobOT.CreadoEl),		
       --							case when ot.ModificadoEl > max(cap.FechaVoBoSubcontratista) then max(cap.FechaVoBoSubcontratista)
       --								 else isnull(ot.ModificadoEl,max(cap.FechaVoBoSubcontratista))
       --							end
       --							) 
       --							when ot.ProgIniPorProveedor = 1 then
       --							isnull(
       --								min(bitaAprobOT2.CreadoEl),		
       --								case when ot.ModificadoEl > max(cap.FechaVoBoSubcontratista) then max(cap.FechaVoBoSubcontratista)
       --									 else isnull(ot.ModificadoEl,max(cap.FechaVoBoSubcontratista))
       --								end
       --								) 
       --						end ,
       DiaProgramaTrabajo = cap.Fecha,
       FechaCargaAvance = MAX(cap.FechaVoBoSubcontratista),
       DiasCargaAvance = CAST(0 AS FLOAT),
       FechaVoBoOperadora = MAX(cap.FechaVoBoContratista),
       ResponsableVoBoOperadora = MAX(cap.QuienVoBoContratista),
       DiasVoBoOperadora = CAST(0 AS FLOAT),
       FechaCierreSemana = MIN(cap.FechaCierre),
       Responsable_Cierre_Semana = MAX(uCierre.Nombre),
       DiasCierreSemana = CAST(0 AS FLOAT),
       DiasAvanceSemanal = CAST(0 AS FLOAT),
       FechaDeEstimacion = estima.CreadoEl,
       ResponsableEstimacion = uEst.Nombre,
       DiasEstimacion = CAST(0 AS FLOAT),
       DiasTotales = CAST(0 AS FLOAT),
       case when ot.FechaAprobacionSAPPR > MIN(cap.FechaCierre) then MIN(cap.FechaCierre) else ot.FechaAprobacionSAPPR end AS FechaCargaPR,
       isnull(PR.ID_PR,ot.SAPPR) AS NumberPR,
       POAD.ID_PO AS NumeroPO,
       POAD.CreadoEl AS FechaRegistroPO,
       DiasPR = CAST(0 AS FLOAT),
       DiasRegistroPR_CargaAvance = CAST(0 AS FLOAT),
	   
       IdOTEstimacion = ISNULL(estima.IdOTEstimacion, 0)
INTO #tmpResultado
FROM OT_Solicitud ot
    INNER JOIN OT_SolicitudMaterial om
        ON om.IdOTSolicitud = ot.IdOTSolicitud
    INNER JOIN [dbo].[OT_LineaPresupuesto] olp
        ON olp.IdOTSolicitud = ot.IdOTSolicitud
    INNER JOIN CO_LineaPresupuestoMes lpm
        ON lpm.IdLineaPresupuestoMes = olp.IdLineaPresupuestoMes
    INNER JOIN CO_TareaPetrolera t
        ON t.IdTareaPetrolera = lpm.IdTareaPetrolera
    INNER JOIN CO_Servicio serv
        ON serv.IdServicio = lpm.IdServicio
    INNER JOIN OT_Estatus est
        ON est.IdOtEstatus = ot.IdOTEstatus
    INNER JOIN AP_Usuario uReq
        ON uReq.UsuarioID = ot.CreadoPor
    INNER JOIN Petrovendor..CC_CentroCosto cc
        ON cc.IdCentroCosto = ot.IdCentroCosto
    INNER JOIN SC_SubContrato sc
        ON sc.IdSubContrato = ot.IdSubContrato
           AND sc.IdContrato in( 10038,10044,10045,10046,10144)  -- Solo contratos DEA
	INNER JOIN CO_Contrato c on c.IdContrato = sc.IdContrato
    INNER JOIN PV_Subcontratista pv
        ON pv.IdSubcontratista = sc.IdSubContratista
    LEFT JOIN [dbo].[OT_SolicitudProgramaCaptura] cap
        ON cap.IdOTSolicitudMaterial = om.IdOTSolicitudMaterial
           AND cap.FechaVoBoSubcontratista IS NOT NULL
    LEFT JOIN OT_Estimacion estima
        ON estima.IdOTSolicitud = ot.IdOTSolicitud
           AND estima.FechaCorteInicio <= cap.Fecha
           AND estima.FechaCorteFin >= cap.Fecha
    LEFT JOIN AP_Usuario uEst
        ON uEst.UsuarioID = estima.CreadoPor
    LEFT JOIN AP_Usuario uCierre
        ON uCierre.UsuarioID = cap.CerradoPor
    --left join [dbo].[OT_SolicitudBitacora] bitaAprobMan on bitaAprobMan.IdOTSolicitud = ot.IdOTSolicitud and  bitaAprobMan.IdTipoMovimiento =2 --Aprbada por operador
    --left join [dbo].[OT_SolicitudBitacora] bitaAprobEnviadaSC on bitaAprobEnviadaSC.IdOTSolicitud = ot.IdOTSolicitud and  bitaAprobEnviadaSC.IdTipoMovimiento = 3 --Enviada a Subcontratista
    --left join [dbo].[OT_SolicitudBitacora] bitaAprobSC on bitaAprobSC.IdOTSolicitud = ot.IdOTSolicitud and  bitaAprobSC.IdTipoMovimiento  = 4-- Aprobada Subcontratista 
    --left join [dbo].[OT_SolicitudBitacora] bitaPropSC on bitaPropSC.IdOTSolicitud = ot.IdOTSolicitud and  bitaPropSC.IdTipoMovimiento = 5--Propuesta subcontratista
    LEFT JOIN [dbo].[OT_SolicitudBitacora] bitaAprobOT
        ON bitaAprobOT.IdOTSolicitud = ot.IdOTSolicitud
           AND bitaAprobOT.IdTipoMovimiento IN ( 2, 3 )
    --and  bitaAprobOT.Descripcion in ('Enviada a Subcontratista','Aprobada Operador'/*'Aprobada Subcontratista'*/)
    LEFT JOIN [dbo].[OT_SolicitudBitacora] bitaAprobOT2
        ON bitaAprobOT2.IdOTSolicitud = ot.IdOTSolicitud
           AND bitaAprobOT.IdTipoMovimiento IN ( 4 )
    --and  bitaAprobOT2.Descripcion in ('Aprobada Subcontratista')
    --left join AP_Usuario uAdincoBita on uAdincoBita.UsuarioId = bita.UsuarioAdincoId
    --left join Petrovendor..ReporteTablero repT on repT.NumPedido = estima.IdPedidoGeneral
    LEFT JOIN Petrovendor..MM_Pedido ped
        ON ped.IdPedido = estima.IdPedido
    LEFT JOIN Petrovendor..MM_SolicitudPedido SP
        ON SP.IdSolicitudPedido = ped.IdSolicitudPedido
    LEFT JOIN Petrovendor.dbo.DEA_Relacion_PR_PO AS PRPO
        ON PRPO.IdPedido = ped.IdPedido
    LEFT JOIN Petrovendor.dbo.DEA_AdjuntoPO AS POAD
        ON POAD.IdAdjuntoPO = PRPO.IdAdjuntoPO
    LEFT JOIN #tmpAprobador1 a1
        ON a1.IdOTSolicitud = ot.IdOTSolicitud
    LEFT JOIN #tmpAprobador2 a2
        ON a2.IdOTSolicitud = ot.IdOTSolicitud
    LEFT JOIN Petrovendor.dbo.DEA_AdjuntoPR AS PR
        ON PR.IdSolicitudPedido = SP.IdSolicitudPedido
           AND PR.Activo = 1
           AND ISNULL(PR.IsEliminado, 0) = 0
WHERE ot.IsActivo = 1
      AND ISNULL(ot.IsEliminado, 0) = 0 
	  --and ot.IdOTSolicitud in (680)
GROUP BY 
		c.NumeroContrato,
		ot.ProgIniPorProveedor,
         --rept.EntregaRecepcion,
         ot.Folio,
         CONCAT(t.id_Tarea, ' ', t.TareaPetrolera),
         serv.NombreServicio,
         est.Descripcion,
         ot.CreadoEl,
         uReq.Nombre,
         ot.IdOTEstatus,
         ot.ModificadoEl,
         cap.IdAnioMesDia,
         cap.Fecha,
         estima.CreadoEl,
         uEst.Nombre,
         estima.IdPedidoGeneral,
         ot.Objeto,
         ot.FechaAprobacionSAPPR,
         ot.SAPPR,
         sc.IdContratista,
         sc.IdContrato,
         ot.IdOTSolicitud,
         ot.IdCentroCosto,
         cc.CentroCosto,
         pv.RazonSocial,
         ped.IdSolicitudPedido,
         POAD.ID_PO,
         POAD.CreadoEl,
         a1.Usuario,
         a1.Fecha,
         a2.Usuario,
         a2.Fecha,
         a1.Estatus,
         a2.Estatus,
         PR.CreadoEl,
         PR.ID_PR,
         estima.IdOTEstimacion
ORDER BY ot.CreadoEl DESC;



UPDATE #tmpResultado
SET DiasEspera1aAprobacion = Petrovendor.dbo.CalcularTipoDEA(RegistroDeOT, Fecha1aAprobacion),
    DiasEspera2aAprobacion = Petrovendor.dbo.CalcularTipoDEA(Fecha1aAprobacion, Fecha2aAprobacion),
    DiasPR = Petrovendor.dbo.CalcularTipoDEA(Fecha2aAprobacion, FechaCargaPR),
    DiasCargaAvance = Petrovendor.dbo.CalcularTipoDEA(Fecha2aAprobacion, FechaCargaAvance),
    DiasVoBoOperadora = Petrovendor.dbo.CalcularTipoDEA(FechaCargaAvance, FechaVoBoOperadora),
    DiasCierreSemana = Petrovendor.dbo.CalcularTipoDEA(
														case when FechaCargaAvance > FechaCargaPR then FechaCargaAvance
															 when FechaCargaAvance < FechaCargaPR then FechaCargaPR
															 else isnull(FechaCargaAvance,FechaCargaPR)
														end,
														FechaCierreSemana
														),
    DiasAvanceSemanal = Petrovendor.dbo.CalcularTipoDEA(   /*CASE
                                                               WHEN FechaCargaAvance > FechaCargaPR
                                                                    AND FechaCargaAvance IS NOT NULL
                                                                    AND FechaCargaPR IS NOT NULL THEN
                                                                   FechaCargaAvance
                                                               WHEN FechaCargaAvance < FechaCargaPR
                                                                    AND FechaCargaAvance IS NOT NULL
                                                                    AND FechaCargaPR IS NOT NULL THEN
                                                                   FechaCargaPR
                                                               WHEN FechaCargaAvance > FechaCargaPR THEN
                                                                   FechaCargaAvance
                                                               WHEN FechaCargaPR > FechaCargaAvance THEN
                                                                   FechaCargaPR
                                                               ELSE
                                                                   ISNULL(FechaCargaAvance, FechaCargaPR)
                                                           END*/
														   FechaCargaAvance,
                                                           FechaCierreSemana
                                                       ),
    DiasEstimacion = Petrovendor.dbo.CalcularTipoDEA(FechaCierreSemana, FechaDeEstimacion),
                                    --DiasAceptacion = petrovendor.dbo.CalcularTipoDEA(FechaDeEstimacion,FechaAceptacionPedido),
    DiasTotales = CAST(0 AS FLOAT); --DiasRegistroPR_CargaAvance


UPDATE #tmpResultado
SET DiasRegistroPR_CargaAvance = CASE
                                     WHEN ISNULL(DiasPR, 0) > ISNULL(DiasCargaAvance, 0) THEN
                                         DiasPR
                                     ELSE
                                         DiasCargaAvance
                                 END;

UPDATE #tmpResultado
SET DiasTotales = -- isnull(DiasCargaAvance,0) + 
    ISNULL(DiasVoBoOperadora, 0) + ISNULL(DiasCierreSemana, 0) + ISNULL(DiasEstimacion, 0);
--select * from #tmpResultado
--order by IdOTSolicitud,FechaAprobacionOT



--AGRUPACIÓN I
SELECT 
		t2.NumeroContrato,
		t2.IdOTSolicitud,
       IdSolicitudPedido,
       t2.Folio,
       t2.Objeto,
       CentroCosto,
       RazonSocialProv,
       Tarea = MAX(Tarea),
       SubTarea = MAX(SubTarea),
       Estatus,
       RegistroDeOT,
       Requisitor,
       --Fecha_De_Rechazo,	
       Responsable1aAprobacion,
       Fecha1aAprobacion,
       DiasEspera1aAprobacion,
       Estatus1aAprobacion,
       ----
       Responsable2aAprobacion,
       Fecha2aAprobacion,
       DiasEspera2aAprobacion,
       Estatus2aAprobacion,
       --FechaAprobacionOT,	
       ProgramaDel = CASE
                         WHEN fechaCap.Completada = 1
                              AND MIN(DiaProgramaTrabajo) IS NULL THEN
                             NULL
                         WHEN fechaCap.Completada = 0
                              AND MIN(DiaProgramaTrabajo) IS NULL THEN
                             fechaCap.FechaCaptura
                         WHEN MIN(DiaProgramaTrabajo) IS NOT NULL THEN
                             MIN(DiaProgramaTrabajo)
                     END,
       ProgramaAl = CASE
                        WHEN fechaCap.Completada = 1
                             AND MAX(DiaProgramaTrabajo) IS NULL THEN
                            NULL
                        WHEN fechaCap.Completada = 0
                             AND MAX(DiaProgramaTrabajo) IS NULL THEN
                            ot.FechaFin
                        WHEN MAX(DiaProgramaTrabajo) IS NOT NULL THEN
                            MAX(DiaProgramaTrabajo)
                    END,
       --DiaProgramaTrabajo,	
       FechaCargaAvance,
	   VolumetriaAvance = case when fechaCap.Completada = 1 then 'Cerrada' else 'Abierta' end,
       DiasCargaAvance,
       FechaVoBoOperadora,
       ResponsableVoBoOperadora,
       DiasVoBoOperadora,
       FechaCierreSemana,
       Responsable_Cierre_Semana,
       DiasCierreSemana,
       DiasAvanceSemanal,
       FechaDeEstimacion,
       ResponsableEstimacion,
       DiasEstimacion,
       DiasTotales,
       FechaCargaPR,
       NumberPR,
       NumeroPO,
       FechaRegistroPO,
       DiasPR = MAX(DiasPR),
       DiasRegistroPR_CargaAvance = MAX(DiasRegistroPR_CargaAvance),
       IdOTEstimacion = IdOTEstimacion
INTO #tmpResultado2
FROM #tmpResultado t2
    INNER JOIN OT_Solicitud ot
        ON ot.IdOTSolicitud = t2.IdOTSolicitud
    LEFT JOIN #tmpOTFechaCapturaMax fechaCap
        ON fechaCap.IdOTSolicitud = t2.IdOTSolicitud
GROUP BY t2.NumeroContrato,
		t2.IdOTSolicitud,
         IdSolicitudPedido,
         t2.Folio,
         t2.Objeto,
         CentroCosto,
         RazonSocialProv,
         --Tarea,	
         --SubTarea,	
         Estatus,
         RegistroDeOT,
         Requisitor,
         --Fecha_De_Rechazo,	
         Responsable1aAprobacion,
         --FechaAprobacionOT,	
         --DiaProgramaTrabajo,	
         FechaCargaAvance,
         DiasCargaAvance,
         FechaVoBoOperadora,
         ResponsableVoBoOperadora,
         DiasVoBoOperadora,
         FechaCierreSemana,
         Responsable_Cierre_Semana,
         DiasCierreSemana,
         FechaDeEstimacion,
         ResponsableEstimacion,
         DiasEstimacion,
         DiasTotales,
         NumeroPO,
         FechaRegistroPO,
         DiasAvanceSemanal,
         Fecha1aAprobacion,
         DiasEspera1aAprobacion,
         Fecha2aAprobacion,
         DiasEspera2aAprobacion,
         Responsable2aAprobacion,
         Estatus1aAprobacion,
         Estatus2aAprobacion,
         FechaCargaPR,
         NumberPR,
         IdOTEstimacion,
         fechaCap.FechaCaptura,
         ot.FechaFin,
         ot.FechaInicio,
         fechaCap.Completada
ORDER BY IdOTSolicitud; --,FechaAprobacionOT



--AGRUPACION 2
--insert into OT_BI_Tablero
SELECT 
		NumeroContrato,
		IdOTSolicitud,
       IdSolicitudPedido,
       Folio,
       Objeto,
       CentroCosto,
       RazonSocialProv,
       Tarea,
       SubTarea,
       Estatus,
       RegistroDeOT,
       Requisitor,
       --Fecha_De_Rechazo = MAX(Fecha_De_Rechazo),	
       Responsable1aAprobacion = MAX(Responsable1aAprobacion),
       Fecha1aAprobacion = MAX(Fecha1aAprobacion),
       DiasEspera1aAprobacion = MAX(DiasEspera1aAprobacion),
       Estatus1aAprobacion = MAX(Estatus1aAprobacion),
       -------
       Responsable2aAprobacion = MAX(Responsable2aAprobacion),
       Fecha2aAprobacion = MAX(Fecha2aAprobacion),
       DiasEspera2aAprobacion = MAX(DiasEspera2aAprobacion),
       Estatus2aAprobacion = MAX(Estatus2aAprobacion),
       --
       --FechaAprobacionOT = MAX(FechaAprobacionOT),
       ProgramaDel = MIN(ProgramaDel),
       ProgramaAl = MAX(ProgramaAl),
       --DiaProgramaTrabajo,	
       FechaCargaAvance = MAX(FechaCargaAvance),
	   VolumetriaAvance,
       DiasCargaAvance = MAX(DiasCargaAvance),
       FechaVoBoOperadora = MAX(FechaVoBoOperadora),
       ResponsableVoBoOperadora = MAX(ResponsableVoBoOperadora),
       DiasVoBoOperadora = MAX(DiasVoBoOperadora),
       FechaCierreSemana = MAX(FechaCierreSemana),
       Responsable_Cierre_Semana = MAX(Responsable_Cierre_Semana),
       DiasCierreSemana = MAX(DiasCierreSemana),
       DiasAvanceSemanal = MAX(DiasAvanceSemanal),
       FechaDeEstimacion,
       ResponsableEstimacion,
       DiasEstimacion = MAX(DiasEstimacion),
       DiasTotales = MAX(DiasCargaAvance) + MAX(DiasVoBoOperadora) + MAX(DiasCierreSemana) + MAX(DiasAvanceSemanal)
                     + MAX(DiasEstimacion),
       FechaCargaPR,
       NumberPR,
       NumeroPO,
       FechaRegistroPO = MAX(FechaRegistroPO),
       DiasPR = MAX(DiasPR),
       DiasRegistroPR_CargaAvance = MAX(DiasRegistroPR_CargaAvance),
       IdOTEstimacion
INTO #tmpResultado3
FROM #tmpResultado2
/*WHERE DiasCargaAvance >= 0
      AND DiasVoBoOperadora >= 0
      AND DiasCierreSemana >= 0
      AND DiasAvanceSemanal >= 0
      AND DiasEstimacion >= 0*/
GROUP BY
	VolumetriaAvance,
		NumeroContrato,
		IdOTSolicitud,
         IdSolicitudPedido,
         Folio,
         Objeto,
         CentroCosto,
         RazonSocialProv,
         Tarea,
         SubTarea,
         Estatus,
         RegistroDeOT,
         Requisitor,
         ResponsableVoBoOperadora,
         FechaDeEstimacion,
         ResponsableEstimacion,
         NumeroPO,
         FechaCargaPR,
         NumberPR,
         IdOTEstimacion;

		 


--Resultado Final
--insert into OT_BI_Tablero
SELECT 
		t.NumeroContrato,
		t.IdOTSolicitud,
       IdSolicitudPedido =t.IdSolicitudPedido,
       Folio,
       Objeto,
       CentroCosto,
       RazonSocialProv,
       Tarea,
       SubTarea,
       Estatus,
       RegistroDeOT,
       Requisitor,
       --Fecha_De_Rechazo = MAX(Fecha_De_Rechazo),	
       Responsable1aAprobacion = MAX(Responsable1aAprobacion),
       Fecha1aAprobacion = MAX(Fecha1aAprobacion),
       DiasEspera1aAprobacion = MAX(DiasEspera1aAprobacion),
       Estatus1aAprobacion = MAX(Estatus1aAprobacion),
       -------
       Responsable2aAprobacion = MAX(Responsable2aAprobacion),
       Fecha2aAprobacion = MAX(Fecha2aAprobacion),
       DiasEspera2aAprobacion = MAX(DiasEspera2aAprobacion),
       Estatus2aAprobacion = MAX(Estatus2aAprobacion),
       FechaCargaPR = MAX(FechaCargaPR),
       NumberPR = MAX(NumberPR),
       DiasPR = MAX(DiasPR),
       --
       --FechaAprobacionOT = MAX(FechaAprobacionOT),
       ProgramaDel = MIN(ProgramaDel),
       ProgramaAl = MAX(ProgramaAl),
       --DiaProgramaTrabajo,	
       FechaCargaAvance = MAX(FechaCargaAvance),
	   VolumetriaAvance,
       DiasCargaAvance = MAX(DiasCargaAvance),
       DiasRegistroPR_CargaAvance = MAX(DiasRegistroPR_CargaAvance),
       FechaVoBoOperadora = MAX(FechaVoBoOperadora),
       ResponsableVoBoOperadora = MAX(ResponsableVoBoOperadora),
       DiasVoBoOperadora = MAX(DiasVoBoOperadora),
       FechaCierreSemana = MAX(FechaCierreSemana),
       Responsable_Cierre_Semana = MAX(Responsable_Cierre_Semana),
       DiasCierreSemana = MAX(DiasCierreSemana),
       DiasAvanceSemanal = MAX(DiasAvanceSemanal),
       FechaDeEstimacion = MAX(FechaDeEstimacion),
       ResponsableEstimacion = MAX(ResponsableEstimacion),
       DiasEstimacion = MAX(DiasEstimacion),
       DiasTotales = MAX(DiasCargaAvance) + MAX(DiasVoBoOperadora) + MAX(DiasCierreSemana) + MAX(DiasAvanceSemanal)
                     + MAX(DiasEstimacion),
       NumeroPO = MAX(NumeroPO),
       FechaRegistroPO = MAX(FechaRegistroPO),
      IdPedido = e.IdPedido
INTO #tmpResultado4
FROM #tmpResultado3 t
    left JOIN dbo.OT_Estimacion e
        ON e.IdOTEstimacion = t.IdOTEstimacion
/*WHERE DiasCargaAvance >= 0
      AND DiasVoBoOperadora >= 0
      AND DiasCierreSemana >= 0
      AND DiasAvanceSemanal >= 0
      AND DiasEstimacion >= 0*/
--and IdOTSolicitud = 82
GROUP BY
		VolumetriaAvance,
		t.NumeroContrato,
		t.IdOTSolicitud,
         Folio,
         Objeto,
         CentroCosto,
         RazonSocialProv,
         Tarea,
         SubTarea,
         Estatus,
         RegistroDeOT,
         Requisitor,
         e.IdPedido,
		 t.IdSolicitudPedido,
		 e.IdPedidoGeneral

	

		

-- INICIO PROCURA

DECLARE @ACEPTACIONESCN TABLE
(
    IdAceptacionPedido INT,
    FechaRecepcionCN DATETIME,
    FechaEvaluacionCN DATETIME,
    EstatusCartaCN NVARCHAR(200),
    UsuarioEvaluaCN NVARCHAR(200)
);



INSERT INTO @ACEPTACIONESCN
(
    IdAceptacionPedido,
    FechaRecepcionCN,
    FechaEvaluacionCN,
    EstatusCartaCN,
    UsuarioEvaluaCN
)
SELECT AP.IdAceptacionPedido,
       (
           SELECT TOP 1
                  CreadoEl
           FROM Petrovendor.dbo.MM_AceptacionCartaPCN
           WHERE IdAceptacionPedido = AP.IdAceptacionPedido
           ORDER BY CreadoEl DESC
       ),
       (
           SELECT TOP 1
                  FechaEvaluacion
           FROM Petrovendor.dbo.MM_AceptacionCartaPCN
           WHERE IdAceptacionPedido = AP.IdAceptacionPedido
           ORDER BY CreadoEl DESC
       ),
       (
           SELECT TOP 1
                  EST.Nombre
           FROM Petrovendor.dbo.MM_AceptacionCartaPCN AS APC
               LEFT JOIN Petrovendor.dbo.TA_Estatus AS EST
                   ON EST.IdEstatus = APC.IdEstatus
           WHERE APC.IdAceptacionPedido = AP.IdAceptacionPedido
           ORDER BY APC.CreadoEl DESC
       ),
       (
           SELECT TOP 1
                  US.Nombre
           FROM Petrovendor.dbo.MM_AceptacionCartaPCN AS APC
               LEFT JOIN Petrovendor.dbo.S_Usuario AS US
                   ON US.IdUsuario = APC.IdUsuarioEvaluador
           WHERE APC.IdAceptacionPedido = AP.IdAceptacionPedido
           ORDER BY APC.CreadoEl DESC
       )
FROM Petrovendor.dbo.MM_AceptacionPedido AS AP
    INNER JOIN Petrovendor.dbo.MM_Pedido AS P
        ON P.IdPedido = AP.IdPedido
	 INNER JOIN #tmpResultado4 filtro
        ON P.IdPedido = filtro.IdPedido -- se filtra la informacion que viene de la ultima tabla de la OT
    LEFT JOIN Petrovendor.dbo.DEA_Relacion_PR_PO po
        ON po.IdPedido = P.IdPedido
   


SELECT P.IdPedido,
       uPo.Nombre AS UsuarioRelacionPOSAP,
       po.PO AS NumeroPOSAP,
       po.FechaAltaRelacion AS FechaRelacionPOSAP,
       (Petrovendor.dbo.CalcularTipoDEA(filtro.FechaDeEstimacion, po.FechaAltaRelacion)) AS DiasRelacionPOSAP, -- (FechaDeEstimacion - FechaRelacionPOSAP)
       AP.IdAceptacionPedido AS NumeroAceptacionPedido,
       APCN.FechaRecepcionCN AS FechaRecepcionCartaCN,
       NULL AS DiasRecepcionCartaCartaCN,                                                                         --(FechaRelacionPOSAP - FechaRecepcionCartaCN)
       APCN.UsuarioEvaluaCN AS UsuarioApruebaCartaCN,
       APCN.FechaEvaluacionCN AS FechaAprobacionCartaCN,
       (Petrovendor.dbo.CalcularTipoDEA(APCN.FechaRecepcionCN, APCN.FechaEvaluacionCN)) AS DiasAprobacionCartaCN,
       CASE
           WHEN RCP.PedirCarta = 0 THEN
               'Excluida'
           ELSE
               APCN.EstatusCartaCN
       END AS EstatusCartaCN,
       TOF.FechaRegistro AS FechaRecepcionFactura,
       (Petrovendor.dbo.CalcularTipoDEA(APCN.FechaEvaluacionCN, TOF.FechaRegistro)) AS DiasRecepcionFactura,
       FI.Folio AS FolioFactura,
       UST1.Nombre AS Responsable1aAprobacion,
       TF1.FechaCambioEstatus AS Fecha1aAprobacion,
       (Petrovendor.dbo.CalcularTipoDEA(TOF.FechaRegistro, TF1.FechaCambioEstatus)) AS DiasEspera1aAprobacion,
       EA1.Nombre AS Estatus1aAprobacion,
       UST2.Nombre AS Responsable2aAprobacion,
       TF2.FechaCambioEstatus AS Fecha2aAprobacion,
       (Petrovendor.dbo.CalcularTipoDEA(TF1.FechaCambioEstatus, TF2.FechaCambioEstatus)) AS DiasEspera2aAprobacion,
       EA2.Nombre AS Estatus2aAprobacion
INTO #DATOSACEPTACIONES
FROM Petrovendor.dbo.MM_SolicitudPedido AS SP
	
    LEFT JOIN Petrovendor.dbo.MM_Pedido AS P
        ON P.IdSolicitudPedido = SP.IdSolicitudPedido
	LEFT JOIN #tmpResultado4 filtro
        ON filtro.IdPedido = P.IdPedido --filtro
    LEFT JOIN Petrovendor.dbo.MM_Pedidos AS PS
        ON PS.IdIdentificador = P.IdPedido
           AND PS.IdProveedorCliente = P.IdProveedorCompras
    LEFT JOIN Petrovendor.dbo.S_Proveedor AS PR
        ON PR.IdProveedor = P.IdSubcontratista
    LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP
        ON AP.IdPedido = P.IdPedido
    LEFT JOIN @ACEPTACIONESCN AS APCN
        ON APCN.IdAceptacionPedido = AP.IdAceptacionPedido
    LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF
        ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
    LEFT JOIN Petrovendor.dbo.TA_Operacion AS TOF
        ON TOF.IdDocumento = AF.IdAceptacionFactura
           AND TOF.IdTipoOperacion = 10
    LEFT JOIN Petrovendor.dbo.FI_Factura AS FI
        ON FI.IdFactura = AF.IdFactura
    LEFT JOIN Petrovendor.dbo.TA_Estatus AS ESF
        ON ESF.IdEstatus = TOF.IdEstatusOperacion
    LEFT JOIN Petrovendor.dbo.DEA_Relacion_PR_PO AS PRPO
        ON PRPO.IdPedido = P.IdPedido
    LEFT JOIN Petrovendor.dbo.S_Usuario AS USPR
        ON USPR.IdUsuario = AP.CreadorPor
    LEFT JOIN Petrovendor.dbo.DEA_AdjuntoPO AS POAD
        ON POAD.IdAdjuntoPO = PRPO.IdAdjuntoPO
    LEFT JOIN Petrovendor.dbo.TA_Tarea AS TF1
        ON TF1.IdOperacion = TOF.IdOperacion
           AND TF1.NoSecuencia = 1
           AND TF1.IdEstatus <> 12
    LEFT JOIN Petrovendor.dbo.S_Usuario AS UST1
        ON UST1.IdUsuario = TF1.IdAprobador
    LEFT JOIN Petrovendor.dbo.TA_Tarea AS TF2
        ON TF2.IdOperacion = TOF.IdOperacion
           AND TF2.NoSecuencia = 2
           AND TF2.IdEstatus <> 12
    LEFT JOIN Petrovendor.dbo.S_Usuario AS UST2
        ON UST2.IdUsuario = TF2.IdAprobador
    LEFT JOIN Petrovendor.dbo.TA_Estatus AS EA1
        ON EA1.IdEstatus = TF1.IdEstatus
    LEFT JOIN Petrovendor.dbo.TA_Estatus AS EA2
        ON EA2.IdEstatus = TF2.IdEstatus
    LEFT JOIN Petrovendor.dbo.TA_Operacion AS OPSP
        ON OPSP.IdDocumento = SP.IdSolicitudPedido
           AND OPSP.IdTipoOperacion = 2
    LEFT JOIN Adinco.dbo.OT_Estimacion AS ESOT
        ON ESOT.IdSolicitudPedido = SP.IdSolicitudPedido
    LEFT JOIN Petrovendor.dbo.RelacionCartaCNPedido AS RCP
        ON RCP.IdAceptacionPedido = AP.IdAceptacionPedido
    LEFT JOIN Petrovendor.dbo.DEA_Relacion_PR_PO po
        ON po.IdPedido = P.IdPedido
    LEFT JOIN Petrovendor.dbo.S_Usuario uPo
        ON uPo.IdUsuario = po.CreadoPor
   
WHERE OPSP.IdEstatusOperacion = 2
      AND P.IdPedido IS NOT NULL
      AND P.RecepcionServicio = 1
GROUP BY p.IdPedido,
filtro.FechaDeEstimacion,
         po.FechaAltaRelacion,
         APCN.FechaRecepcionCN,
         APCN.FechaEvaluacionCN,
         RCP.PedirCarta,
         APCN.EstatusCartaCN,
         TOF.FechaRegistro,
         TF1.FechaCambioEstatus,
         TF2.FechaCambioEstatus,
         uPo.Nombre,
         po.PO,
         po.FechaAltaRelacion,
         AP.IdAceptacionPedido,
		 APCN.UsuarioEvaluaCN,
		 FI.Folio,
		 UST1.Nombre,
		 EA1.Nombre,
		 EA2.Nombre,
		 UST2.Nombre,
		 ps.IdPedido
ORDER BY PS.IdPedido DESC;

-- FIN PROCURA


--Contar cuantawss filas hay abiertas y cerradas pór OT


select IdOTSolicitud,
	SinEstimacion =sum(case when IdSolicitudPedido is null then 1 else 0 end),
	ConEstimacion = sum(case when IdSolicitudPedido is not null then 1 else 0 end),
	MaxIdCerrada = (select max(IdSolicitudPedido) from #tmpResultado4 s1 where s1.IdOTSolicitud = t.IdOTSolicitud)
into #tmpResumenAbiertaCerrada
from #tmpResultado4 t
group by IdOTSolicitud



-- Retorno a la vista
--insert into OT_BI_Tablero
SELECT 
		
		NumeroContrato = cast(infoOT.NumeroContrato as varchar(100)),
	  IdOTSolicitud = isnull(infoOt.IdOTSolicitud,0),
       IdSolicitudPedido = infoOt.IdSolicitudPedido,
       Folio = cast(infoOt.Folio as varchar(30)),
       Objeto = cast(infoOt.Objeto as varchar(1000)),
       CentroCosto = cast(infoOt.CentroCosto as varchar(200)),
       RazonSocialProv = cast(infoOt.RazonSocialProv as varchar(2000)),
       Tarea=cast(infoOt.Tarea as varchar(350)) ,
       SubTarea = cast(infoOt.SubTarea as varchar(350)),
       Estatus = cast(infoOt.Estatus as varchar(100)),
       RegistroDeOT = infoOt.RegistroDeOT,
       Requisitor = cast(infoOt.Requisitor as varchar(650)),
       Responsable1aAprobacion = cast(infoOt.Responsable1aAprobacion as varchar(650)),
       Fecha1aAprobacion = infoOt.Fecha1aAprobacion,
       DiasEspera1aAprobacion = infoOt.DiasEspera1aAprobacion,
       Estatus1aAprobacion = case when infoOt.Estatus like '%rechazada%operador%' or infoOt.Estatus like '%Requiere%Convenio%' then  infoOt.Estatus
								 else cast(infoOt.Estatus1aAprobacion as varchar(350))
						     end,
      Responsable2aAprobacion = cast(infoOt.Responsable2aAprobacion as varchar(650)),
       Fecha2aAprobacion = infoOt.Fecha2aAprobacion,
       DiasEspera2aAprobacion = infoOt.DiasEspera2aAprobacion,
      Estatus2aAprobacion =  case when infoOt.Estatus like '%Rechazada%Subcontratista%' then  infoOt.Estatus
								 else  cast(infoOt.Estatus2aAprobacion as varchar(350))
						     end
	 ,
       FechaCargaPR = infoOt.FechaCargaPR,
	   
      NumberPR = cast(infoOt.NumberPR as varchar(100)),
       DiasPR = infoOt.DiasPR,
       ProgramaDel=infoOt.ProgramaDel,
       ProgramaAl = infoOt.ProgramaAl,
       FechaCargaAvance = infoOt.FechaCargaAvance,
	   VolumetriaAvance =cast(infoOT.VolumetriaAvance as varchar(30)),
      DiasCargaAvance = infoOt.DiasCargaAvance,

    DiasRegistroPR_CargaAvance =  infoOt.DiasRegistroPR_CargaAvance,
      FechaVoBoOperadora = infoOt.FechaVoBoOperadora,
       ResponsableVoBoOperadora =cast(infoOt.ResponsableVoBoOperadora as varchar(650)),
       DiasVoBoOperadora = infoOt.DiasVoBoOperadora,
       infoOt.FechaCierreSemana,
       Responsable_Cierre_Semana = cast(infoOt.Responsable_Cierre_Semana as varchar(650)),
       infoOt.DiasCierreSemana,
       infoOt.DiasAvanceSemanal,
       infoOt.FechaDeEstimacion,
      ResponsableEstimacion = cast(infoOt.ResponsableEstimacion as varchar(650)),
       infoOt.DiasEstimacion,
       infoOt.DiasTotales,
       NumeroPO = cast(infoOt.NumeroPO as varchar(200)),
       infoOt.FechaRegistroPO,
		IdPedido = e.IdPedidoGeneral,
       UsuarioRelacionPOSAP = cast(procura.UsuarioRelacionPOSAP as varchar(650)),
       NumeroPOSAP = cast(procura.NumeroPOSAP as varchar(50)),
       procura.FechaRelacionPOSAP,
       DiasRelacionPOSAP = cast(procura.DiasRelacionPOSAP as varchar(200)),
       procura.NumeroAceptacionPedido,
       procura.FechaRecepcionCartaCN,
       (Petrovendor.dbo.CalcularTipoDEA(CAST(infoOt.FechaDeEstimacion AS DATETIME) , CAST(procura.FechaRecepcionCartaCN AS DATETIME))) AS DiasRecepcionCartaCartaCN, --(FechaRelacionPOSAP - FechaRecepcionCartaCN)
	   DiasRelacionPO_CartaCN = CASE
                                     WHEN ISNULL(DiasRelacionPOSAP, 0) > (Petrovendor.dbo.CalcularTipoDEA(CAST(infoOt.FechaDeEstimacion AS DATETIME) , CAST(procura.FechaRecepcionCartaCN AS DATETIME))) THEN
                                         DiasRelacionPOSAP
                                     ELSE
                                         (Petrovendor.dbo.CalcularTipoDEA(CAST(infoOt.FechaDeEstimacion AS DATETIME) , CAST(procura.FechaRecepcionCartaCN AS DATETIME)))
                                 END,
       procura.UsuarioApruebaCartaCN,
       procura.FechaAprobacionCartaCN,
       procura.DiasAprobacionCartaCN,
	   DiasAprobacionCartaCN2 = Petrovendor.dbo.CalcularTipoDEA(
																case when procura.FechaRecepcionCartaCN > procura.FechaRelacionPOSAP then procura.FechaRecepcionCartaCN
																	when procura.FechaRecepcionCartaCN < procura.FechaRelacionPOSAP then procura.FechaRelacionPOSAP
																	else isnull( procura.FechaRecepcionCartaCN, procura.FechaRelacionPOSAP)
																end,
																FechaAprobacionCartaCN
																),
       procura.EstatusCartaCN,
       procura.FechaRecepcionFactura,
       procura.DiasRecepcionFactura,
       procura.FolioFactura,
       Responsable1aAprobacion_Fac=procura.Responsable1aAprobacion,
       Fecha1aAprobacion_Fac = procura.Fecha1aAprobacion,
       DiasEspera1aAprobacionFac = procura.DiasEspera1aAprobacion,
       Estatus1aAprobacion_Fac = procura.Estatus1aAprobacion,
       Responsable2aAprobacion_Fac=procura.Responsable2aAprobacion,
       Fecha2aAprobacion_Fac=procura.Fecha2aAprobacion,
       DiasEspera2aAprobacion_Fac = procura.DiasEspera2aAprobacion,
       Estatus2aAprobacion_Fac = procura.Estatus2aAprobacion,
	   DiasRelacionPO_AprobacionFactura = Petrovendor.dbo.CalcularTipoDEA(
																 procura.Fecha2aAprobacion,
																 procura.FechaRelacionPOSAP
																)
into #tmpResultado5
FROM #tmpResultado4 infoOt
	LEFT JOIN OT_Estimacion e on e.IdSolicitudPedido = infoOt.IdSolicitudPedido
    LEFT JOIN #DATOSACEPTACIONES procura
        ON procura.IdPedido = infoOt.IdPedido
	LEFT JOIN #tmpResumenAbiertaCerrada r on r.IdOTSolicitud = infoOt.IdOTSolicitud
where (infoOT.VolumetriaAvance = 'Abierta' and infoOt.IdSolicitudPedido is null)
OR (infoOT.VolumetriaAvance = 'Abierta'  AND infoOt.IdSolicitudPedido = R.MaxIdCerrada)
OR (infoOT.VolumetriaAvance = 'Cerrada' AND infoOt.IdSolicitudPedido = R.MaxIdCerrada)
OR (infoOT.VolumetriaAvance = 'Cerrada' AND infoOt.IdSolicitudPedido  IS NULL)


select  Count = count(*),
		idOTSolicitud,
		IdSolicitudPedido = MAX(IdSolicitudPedido),
		NumeroAceptacionPedido = max(NumeroAceptacionPedido)
into #tmpResultaFinalRep
from #tmpResultado5
group by IdOTSolicitud 

insert into OT_BI_Tablero
select T1.*
from #tmpResultado5  t1
inner join #tmpResultaFinalRep  t2 on t2.IdOTSOlicitud = t1.IdOTSOlicitud
where (t2.Count = 1 
OR (	
	t2.Count > 1 and t1.IdSolicitudPedido is not null AND T2.IdSolicitudPedido IS NOT NULL and t1.IdSolicitudPedido = T2.IdSolicitudPedido 
	AND T1.NumeroAceptacionPedido = ISNULL(T2.NumeroAceptacionPedido,T1.NumeroAceptacionPedido)
)
OR (t2.Count > 1 and t1.IdSolicitudPedido is null AND T2.IdSolicitudPedido IS NULL)
)






fin:
DROP TABLE #tmpOTManagerNot;
DROP TABLE #tmpResultado;
DROP TABLE #tmpResultado2;
DROP TABLE #tmpResultado3;
DROP TABLE #tmpAprobador1;
DROP TABLE #tmpAprobador2;
DROP TABLE #tmpOTFechaCapturaMax;
DROP TABLE #DATOSACEPTACIONES
DROP TABLE #tmpResultado4
drop table #tmpResumenAbiertaCerrada




