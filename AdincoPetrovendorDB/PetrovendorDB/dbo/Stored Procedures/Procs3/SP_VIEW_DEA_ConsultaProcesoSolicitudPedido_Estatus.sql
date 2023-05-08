CREATE PROC SP_VIEW_DEA_ConsultaProcesoSolicitudPedido_Estatus
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --DECLARE @IDCONTRATO INT = (3);
    --DECLARE @IDCONTRATO INT = (10038);
    DECLARE @Contratos TABLE(ContratoId INT NOT NULL)
	DECLARE @CENTROSCOSTOS TABLE(IdSolicitudPedido INT, CentroCosto NVARCHAR(100));
	DECLARE @USUARIOAPROBADOR1 TABLE
    (
        TareaId INT,
        IdSolicitudPedido INT,
        Nombre NVARCHAR(100),
        FechaRegistro DATETIME,
        FechaCambioEstatus DATETIME,
        Dias INT,
        Estatus NVARCHAR(100)
    );
    DECLARE @USUARIOAPROBADOR2 TABLE
    (
        TareaId INT,
        IdSolicitudPedido INT,
        Nombre NVARCHAR(100),
        FechaRegistro DATETIME,
        FechaCambioEstatus DATETIME,
        Dias INT,
        Estatus NVARCHAR(100),
        IdEstatus INT
    );

    DECLARE @USUARIOREASIGNADO TABLE
    (
        TareaId INT,
        IdSolicitudPedido INT,
        Nombre NVARCHAR(100),
        FechaRegistro DATETIME,
        FechaCambioEstatus DATETIME,
        Dias INT,
        Estatus NVARCHAR(100)
    );

    DECLARE @USUARIOREASIGNADO2 TABLE
    (
        TareaId INT,
        IdSolicitudPedido INT,
        Nombre NVARCHAR(100),
        FechaRegistro DATETIME,
        FechaCambioEstatus DATETIME,
        Dias INT,
        Estatus NVARCHAR(100)
    );

    DECLARE @PROCESOSOLPED TABLE
    (
        IdSolicitudPedido INT,
        Folio NVARCHAR(100),
        Descripcion NVARCHAR(MAX),
        CentroCosto NVARCHAR(500),
        Requisitor NVARCHAR(500),
        FechaRegistro DATETIME,
        Responsable1aAprobacion NVARCHAR(500),
        Fecha1aAprobacion DATETIME,
        Estatus1aAprobacion NVARCHAR(100),
        ResponsableReasignado NVARCHAR(500),
        FechaAprobacionReasignado DATETIME,
        EstatusAprobacionReasignado NVARCHAR(300),
        Responsable2aAprobacion NVARCHAR(500),
        Fecha2aAprobacion DATETIME,
        Estatus2aAprobacion NVARCHAR(300),
        Responsable2daReasigacion NVARCHAR(500),
        FechaAprobacion2daReasignacion DATETIME,
        EstatusAprobacion2daReasignacion NVARCHAR(300),
        UsuarioCargaPR NVARCHAR(500),
        FechaCargaPR DATETIME,
        NumeroPR NVARCHAR(100),
        EstatusFinal NVARCHAR(100),
        FechaRegistroTareaReasignado DATETIME,
        ContratoId INT
    );

    DECLARE @DATOSSOLPEDFIN TABLE
    (
        IdSolicitudPedido INT,
        Folio NVARCHAR(100),
        Descripcion NVARCHAR(MAX),
        CentroCosto NVARCHAR(500),
        Requisitor NVARCHAR(500),
        FechaRegistro DATETIME,
        Responsable1aAprobacion NVARCHAR(500),
        Fecha1aAprobacion DATETIME,
        Estatus1aAprobacion NVARCHAR(300),
        Dias1apro NVARCHAR(100),
        ResponsableReasignado NVARCHAR(500),
        FechaAprobacionReasignado DATETIME,
        EstatusAprobacionReasignado NVARCHAR(300),
        Dias1asig NVARCHAR(100),
        Responsable2aAprobacion NVARCHAR(500),
        Fecha2aAprobacion DATETIME,
        Estatus2aAprobacion NVARCHAR(300),
        Dias2aprob NVARCHAR(100),
        Responsable2daReasigacion NVARCHAR(500),
        FechaAprobacion2daReasignacion DATETIME,
        EstatusAprobacion2daReasignacion NVARCHAR(300),
        Dias2aprobreasig NVARCHAR(100),
        UsuarioCargaPR NVARCHAR(500),
        FechaCargaPR DATETIME,
        NumeroPR NVARCHAR(100),
        DiasCargaPR NVARCHAR(100),
        DiasAprobGral NVARCHAR(100),
        EstatusFinal NVARCHAR(100),
        FechaRegistroTareaReasignado DATETIME,
        ContratoId INT,
        Contrato NVARCHAR(max),
        AreaContractual NVARCHAR(max)
    );

    DECLARE @IDSOLITUDOT2 TABLE
    (
		Id INT IDENTITY(1,1),
        IdSolicitud INT,
        Responsable2aAprobacion NVARCHAR(500),
        Fecha2aAprobacion DATETIME,
        Estatus2aAprobacion NVARCHAR(100)
    );

    DECLARE @IDSOLITUDOT1 TABLE
    (
		Id INT IDENTITY(1,1),
        IdSolicitud INT,
        Responsable1aAprobacion NVARCHAR(500),
        Fecha1aAprobacion DATETIME,
        Estatus1aAprobacion NVARCHAR(100)
    );

	DECLARE @Aprobador1 AS TABLE
    (
        IdSolicitudPedido INT NOT NULL,
        TareaId INT NOT NULL
    );

	DECLARE @UsuarioOT2 AS TABLE
	(
	  IdConsecutivo INT,
	  IdSolicitudPedido INT,
	  Id INT
	)

	DECLARE @UsuarioOT1 AS TABLE
	(
	  IdConsecutivo INT,
	  IdSolicitudPedido INT,
	  Id INT
	)

	DECLARE @AprobadorFinal1 AS TABLE
    (
        IdSolicitudPedido INT NOT NULL,
        FechaRegistro DATETIME NULL
    );

	DECLARE @Aprobador2 AS TABLE
    (
        IdSolicitudPedido INT NOT NULL,
        TareaId INT NOT NULL
    );

	DECLARE @Reasingado2 AS TABLE
    (
        IdSolicitudPedido INT NOT NULL,
        TareaId INT NOT NULL
    );
	DECLARE @Reasingado1 AS TABLE
    (
        IdSolicitudPedido INT NOT NULL,
        TareaId INT NOT NULL
    );
		DROP TABLE IF EXISTS #tmpOTManagerNot
	CREATE TABLE #tmpOTManagerNot
	(
		IdOTSolicitud INT PRIMARY KEY NOT NULL,
		Usuario VARCHAR(500),
		Fecha DATETIME
	)
	DROP TABLE IF EXISTS #PROCESOSOLPED2
	CREATE TABLE #PROCESOSOLPED2
	(
		IdSolicitudPedido Int null,
		Folio varchar(300),
		Descripcion varchar(max),
		CentroCosto varchar(300),
		Requisitor varchar(500),
		FechaRegistro datetime,
		Responsable1aAprobacion varchar(500),
		Fecha1aAprobacion datetime,
		Estatus1aAprobacion varchar(300),
		ResponsableReasignado varchar(500),
		FechaAprobacionReasignado datetime,
		EstatusAprobacionReasignado varchar(500),
		Responsable2aAprobacion varchar(500),
		Fecha2aAprobacion datetime,
		Estatus2aAprobacion varchar(500),
		Responsable2daReasigacion varchar(500),
		FechaAprobacion2daReasignacion datetime,
		EstatusAprobacion2daReasignacion varchar(500),
		FechaUltimaAprobacion datetime,
		UsuarioCargaPR varchar(500),
		FechaCargaPR datetime,
		NumeroPR varchar(100),
		EstatusFinal varchar(500),
		ContratoId int
	)
    INSERT INTO @Contratos
    (
        ContratoId
    )
    VALUES
    --(3),   --> MEXICO PRUEBAS
    (10038),--, --> CNH-A4.OGARRIO/2018
    (10044), --> CNH-R03-L01-G-TMV-02/2018
    (10045), --> CNH-R03-L01-G-TMV-03/2018
    (10046), --> CNH-R03-L01-AS-CS-14/2018
    (10144), --> CNH-DEMMA
	(10145); --> CNH-WD ADMIN
	INSERT INTO #tmpOTManagerNot
	(
		IdOTSolicitud,
		Usuario,
		Fecha 
	)
    SELECT ot.IdOTSolicitud,
           u.Usuario,
           Fecha = MIN(n.CreadoEl)
    FROM Adinco..OT_SolicitudBitacora sb (NOLOCK)
        INNER JOIN Adinco..OT_Solicitud ot (NOLOCK)
            ON sb.IdOTSolicitud = ot.IdOTSolicitud
        INNER JOIN Adinco..S_Notificacion n (NOLOCK)
            ON n.Asunto LIKE '%' + ot.Folio + '%'
        INNER JOIN Adinco..AP_Usuario u (NOLOCK)
            ON n.CreadoPor = u.UsuarioID
    WHERE n.Asunto LIKE '%Control de Obra%'
          AND
          (
              n.Mensaje LIKE '%La OT ha sido aprobada%'
              OR n.Mensaje LIKE '%La OT ha sido rechazada%'
              OR n.Mensaje LIKE '%Es necesario revisar la programacion inicial%'
              OR n.Mensaje LIKE '%Es necesario aprobar/rechazar%'
          )
    GROUP BY ot.IdOTSolicitud,
             u.Usuario;

    
    --SE OBTIENEN LOS CC POR CONTRATO Y SOLPED
    INSERT INTO @CENTROSCOSTOS
    SELECT 
           SPC.IdSolicitudPedido,
           CC.CentroCosto
    FROM @Contratos C
        JOIN dbo.MM_SolicitudPedido AS SPC (NOLOCK)
            ON C.ContratoId = SPC.IdContrato
        LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
            ON SPC.IdSolicitudPedido = SPD.IdSolicitudPedido
        LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP (NOLOCK)
            ON SPD.IdSolicitudPedidoDetalle = SPLP.IdSolicitudPedidoDetalle
        LEFT JOIN dbo.CC_CentroCosto AS CC (NOLOCK)
            ON SPLP.IdCentroCosto = CC.IdCentroCosto
    WHERE (
              CC.CentroCosto IS NOT NULL
              OR CC.CentroCosto <> ''
          )
		  GROUP BY SPC.IdSolicitudPedido,
           CC.CentroCosto

    --SE OBTIENE LA INFORMACIÓN DEL 1 ER APROBADOR 
    INSERT INTO @USUARIOAPROBADOR1
    SELECT T.IdTarea,
           SP.IdSolicitudPedido,
           USFA.Nombre,
           T.FechaRegistro,
           T.FechaCambioEstatus,
           DATEDIFF(DAY, SP.FechaAlta, T.FechaCambioEstatus),
           ET1.Nombre
    FROM @Contratos C
        JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
            ON C.ContratoId = SP.IdContrato
        JOIN dbo.TA_Operacion AS OP (NOLOCK)
            ON SP.IdSolicitudPedido = OP.IdDocumento
               AND OP.IdProveedor = SP.IdProveedor
               AND 2 = OP.IdTipoOperacion --> APROBACIÓN DE SOLICITUD DE PEDIDO 		
        JOIN dbo.TA_Tarea AS T (NOLOCK)
            ON OP.IdOperacion = T.IdOperacion
               AND 1 = T.NoSecuencia
        LEFT JOIN dbo.S_Usuario AS USFA (NOLOCK)
            ON T.IdAprobador = USFA.IdUsuario
        LEFT JOIN dbo.TA_Estatus AS ET1 (NOLOCK)
            ON T.IdEstatus = ET1.IdEstatus;

    --SE OBTIENE LA INFORMACIÓN DEL 2DO APROBADOR 
    INSERT INTO @USUARIOAPROBADOR2
    SELECT T.IdTarea,
           SP.IdSolicitudPedido,
           USFA.Nombre,
           T.FechaRegistro,
           T.FechaCambioEstatus,
           DATEDIFF(DAY, SP.FechaAlta, T.FechaCambioEstatus),
           ET1.Nombre,
           T.IdEstatus
    FROM @Contratos C
        JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
            ON C.ContratoId = SP.IdContrato
        JOIN dbo.TA_Operacion AS OP (NOLOCK)
            ON SP.IdSolicitudPedido = OP.IdDocumento
               AND SP.IdProveedor = OP.IdProveedor
               AND 2 = OP.IdTipoOperacion  --> APROBACIÓN DE SOLICITUD DE PEDIDO			
        JOIN dbo.TA_Tarea AS T (NOLOCK)
            ON OP.IdOperacion = T.IdOperacion
               AND 2 = T.NoSecuencia
        LEFT JOIN dbo.S_Usuario AS USFA (NOLOCK)
            ON T.IdAprobador = USFA.IdUsuario
        LEFT JOIN dbo.TA_Estatus AS ET1 (NOLOCK)
            ON T.IdEstatus = ET1.IdEstatus;

    --OBTENER LOS USUARIOS REASIGNADOS CON NO SECUENCIA 1
    INSERT INTO @USUARIOREASIGNADO
    SELECT T.IdTarea,
           SP.IdSolicitudPedido,
           USFA.Nombre,
           T.FechaRegistro,
           T.FechaCambioEstatus,
           DATEDIFF(DAY, SP.FechaAlta, T.FechaCambioEstatus),
           ET1.Nombre
    FROM @Contratos C
        JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
            ON C.ContratoId = SP.IdContrato
        JOIN dbo.TA_Operacion AS OP (NOLOCK)
            ON SP.IdSolicitudPedido = OP.IdDocumento
               AND SP.IdProveedor = OP.IdProveedor
               AND 2 = OP.IdTipoOperacion--> APROBACIÓN DE SOLICITUD DE PEDIDO		
        JOIN dbo.TA_Tarea AS T (NOLOCK)
            ON OP.IdOperacion = T.IdOperacion
               AND 1 = T.NoSecuencia
               AND 7 <> T.IdEstatus--> QUE NO ESTE RESIGNADO
        LEFT JOIN dbo.S_Usuario AS USFA (NOLOCK)
            ON T.IdAprobador = USFA.IdUsuario
        LEFT JOIN dbo.TA_Estatus AS ET1 (NOLOCK)
            ON T.IdEstatus = ET1.IdEstatus
		LEFT JOIN @USUARIOAPROBADOR2 UAP
			ON USFA.Nombre <> UAP.Nombre
			AND SP.IdSolicitudPedido = UAP.IdSolicitudPedido --Y QUE NO SEA EL APROBADOR NO 2
		GROUP BY T.IdTarea,
           SP.IdSolicitudPedido,
           USFA.Nombre,
           T.FechaRegistro,
           T.FechaCambioEstatus,
           SP.FechaAlta, 
		   T.FechaCambioEstatus,
           ET1.Nombre


    --OBTENER REASIGNADOS CON NUMERO DE SECUENCIA 2
    INSERT INTO @USUARIOREASIGNADO2
    SELECT T.IdTarea,
           SP.IdSolicitudPedido,
           USFA.Nombre,
           T.FechaRegistro,
           T.FechaCambioEstatus,
           DATEDIFF(DAY, SP.FechaAlta, T.FechaCambioEstatus),
           ET1.Nombre
    FROM @Contratos C
        JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
			ON C.ContratoId = SP.IdContrato
        JOIN dbo.TA_Operacion AS OP (NOLOCK)
            ON SP.IdSolicitudPedido = OP.IdDocumento
               AND SP.IdProveedor = OP.IdProveedor
               AND 2 = OP.IdTipoOperacion --> APROBACIÓN DE SOLICITUD DE PEDIDO	
        JOIN dbo.TA_Tarea AS T (NOLOCK)
            ON OP.IdOperacion = T.IdOperacion
               AND 2 = T.NoSecuencia
               AND 7 <> T.IdEstatus --> QUE NO ESTE REASIGNADO ES PARA TENER REGISTRO DEL ULTIMO APROBADOR CON SECUENCIA NO 2
               AND 1 = T.Activo --> QUE ESTE ACTIVO
        LEFT JOIN dbo.S_Usuario AS USFA (NOLOCK)
            ON T.IdAprobador = USFA.IdUsuario
        LEFT JOIN dbo.TA_Estatus AS ET1 (NOLOCK)
            ON T.IdEstatus = ET1.IdEstatus;


    INSERT INTO @IDSOLITUDOT2
    (
        IdSolicitud,
        Responsable2aAprobacion,
        Fecha2aAprobacion,
        Estatus2aAprobacion
    )
    SELECT ST.IdOTSolicitud,
           CASE
               WHEN ST.ProgIniPorProveedor = 1 THEN /*ISNULL(AP1.Nombre,'') +*/
                   ' (' +
                   (
                       SELECT STUFF(
                              (
                                  SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(   CASE
                                                                                   WHEN US.Nombre = AP1.Nombre THEN
                                                                                       ''
                                                                                   ELSE
                                                                                       US.Nombre
                                                                               END,
                                                                               ''
                                                                           )
                                  FROM Adinco.dbo.OT_Solicitud AS OTSI (NOLOCK)
                                      LEFT JOIN Adinco.dbo.AP_FlujoAprobacion AS FA (NOLOCK)
                                          ON FA.TipoFlujoAprobacionId = 1
                                      LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatus AS FAE (NOLOCK)
                                          ON FAE.FlujoAprobacionEstatusId = 2
                                      LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatusUsuarios AS FAEU (NOLOCK)
                                          ON FAE.FlujoAprobacionEstatusId = FAEU.FlujoAprobacionEstatusId
                                      LEFT JOIN Adinco.dbo.AP_Usuario AS US (NOLOCK)
                                          ON FAEU.UsuarioId = US.UsuarioID
                                             AND US.IsActivo = 1
                                  WHERE OTSI.IdOTSolicitud = ST.IdOTSolicitud
                                  GROUP BY US.Nombre
                                  FOR XML PATH('')
                              ),
                              1,
                              1,
                              ''
                                   )
                   ) + ')'
               WHEN ST.ProgIniPorProveedor = 0 THEN
                   SUCIT.RazonSocial + '(' + SUCIT.RFC + ')'
           END,
           CASE
               WHEN ST.ProgIniPorProveedor = 1 THEN
                   SBO.CreadoEl
               WHEN ST.ProgIniPorProveedor = 0 THEN
                   SBP.CreadoEl
           END,
           CASE
               WHEN ST.ProgIniPorProveedor = 1 THEN
 SBO.Descripcion
         WHEN ST.ProgIniPorProveedor = 0 THEN
                   SBP.Descripcion
           END
    FROM Adinco.dbo.OT_Solicitud AS ST (NOLOCK)
        LEFT JOIN Adinco.dbo.OT_SolicitudBitacora AS SBO (NOLOCK)
            ON ST.IdOTSolicitud = SBO.IdOTSolicitud
               AND
               (
                   2 = SBO.IdTipoMovimiento
                   OR 'Rechazada Operador' = SBO.Descripcion 
                   OR SBO.Descripcion LIKE '%Aprobada%Operador%'
                   OR 'Aprobada Operador' = SBO.Descripcion
                   OR 'Enviada a Subcontratista' = SBO.Descripcion
               )
        LEFT JOIN Adinco.dbo.OT_SolicitudBitacora AS SBP (NOLOCK)
            ON ST.IdOTSolicitud = SBP.IdOTSolicitud
               AND
               (
                   4 = SBP.IdTipoMovimiento
                   OR 'Rechazada Subcontratista' = SBP.Descripcion 
                   OR 'Propuesta por Subcontratista' = SBP.Descripcion
               )
        LEFT JOIN Adinco.dbo.SC_SubContrato AS SUBOT (NOLOCK)
            ON ST.IdSubContrato = SUBOT.IdSubContrato
        LEFT JOIN Adinco.dbo.PV_Subcontratista AS SUCIT
            ON SUBOT.IdSubContratista = SUCIT.IdSubcontratista
        LEFT JOIN Adinco.dbo.AP_Usuario AS AP1 (NOLOCK)
            ON SBO.UsuarioAdincoId = AP1.UsuarioID
		JOIN @Contratos AS TC
			ON SUBOT.IdContrato = TC.ContratoId
    GROUP BY ST.IdOTSolicitud,
             SBP.Descripcion,
             SBO.Descripcion,
             SBO.CreadoEl,
             SBP.CreadoEl,
             AP1.Nombre,
             ST.ProgIniPorProveedor,
             SUCIT.RazonSocial,
             SUCIT.RFC;

    INSERT INTO @IDSOLITUDOT1
    (
        IdSolicitud,
        Responsable1aAprobacion,
        Fecha1aAprobacion,
        Estatus1aAprobacion
    )
    SELECT ST.IdOTSolicitud,
           CASE
               WHEN ST.ProgIniPorProveedor = 1 THEN
                   SUCIT.RazonSocial + '(' + SUCIT.RFC + ')'
               WHEN ST.ProgIniPorProveedor = 0 THEN
                   ISNULL(AP1.Nombre, ISNULL(otN1.Usuario, '')) + ' ('
                   + ISNULL(
                     (
                         SELECT STUFF(
                                (
                                    SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(US.Nombre, '')
                                    FROM Adinco.dbo.OT_Solicitud AS OTSI (NOLOCK)
                                        LEFT JOIN Adinco.dbo.AP_FlujoAprobacion AS FA (NOLOCK)
                                            ON FA.TipoFlujoAprobacionId = 1
                                        LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatus AS FAE (NOLOCK)
                                            ON FAE.FlujoAprobacionEstatusId = 2
                                        LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatusUsuarios AS FAEU (NOLOCK)
                                            ON FAE.FlujoAprobacionEstatusId = FAEU.FlujoAprobacionEstatusId
                                        LEFT JOIN Adinco.dbo.AP_Usuario AS US (NOLOCK)
                                            ON FAEU.UsuarioId = US.UsuarioID
                                               AND US.IsActivo = 1
                                    WHERE OTSI.IdOTSolicitud = ST.IdOTSolicitud
                                          AND US.UsuarioID <> AP1.UsuarioID
                                          AND US.Usuario NOT LIKE '%@adinco.mx%'
                                          AND US.Usuario NOT LIKE '%@ogss.com.mx%'
                                          AND US.Usuario NOT LIKE '%@smps-sp.com%'
        GROUP BY US.Nombre
            FOR XML PATH('')
                                ),
                                1,
                                1,
                                ''
                                     )
                     ),
                     ''
                           ) + ')'
           END,
           CASE
               WHEN ST.ProgIniPorProveedor = 1 THEN
                   SBP.CreadoEl
               WHEN ST.ProgIniPorProveedor = 0 THEN
                   ISNULL(SBO.CreadoEl, otN1.Fecha)
           END,
           CASE
               WHEN ST.ProgIniPorProveedor = 1 THEN
                   SBP.Descripcion
               WHEN ST.ProgIniPorProveedor = 0 THEN
                   SBO.Descripcion
           END
    FROM Adinco.dbo.OT_Solicitud AS ST (NOLOCK)
        LEFT JOIN Adinco.dbo.OT_SolicitudBitacora AS SBO (NOLOCK)
            ON ST.IdOTSolicitud = SBO.IdOTSolicitud
               AND
               (
                   2 = SBO.IdTipoMovimiento 
                   OR 'Rechazada Operador' = SBO.Descripcion
                   OR SBO.Descripcion LIKE '%Aprobada%Operador%'
                   OR 'Aprobada Operador' = SBO.Descripcion
                   OR 'Enviada a Subcontratista' = SBO.Descripcion
               )
        LEFT JOIN Adinco.dbo.OT_SolicitudBitacora AS SBP
            ON ST.IdOTSolicitud = SBP.IdOTSolicitud
               AND
               (
                   4 = SBP.IdTipoMovimiento
                   OR 'Rechazada Subcontratista' = SBP.Descripcion
                   OR 'Propuesta por Subcontratista' = SBP.Descripcion
               )
        LEFT JOIN Adinco.dbo.SC_SubContrato AS SUBOT (NOLOCK)
            ON ST.IdSubContrato = SUBOT.IdSubContrato
        LEFT JOIN Adinco.dbo.PV_Subcontratista AS SUCIT (NOLOCK)
            ON SUBOT.IdSubContratista = SUCIT.IdSubcontratista
        LEFT JOIN Adinco.dbo.AP_Usuario AS AP1 (NOLOCK)
            ON SBO.UsuarioAdincoId = AP1.UsuarioID
        LEFT JOIN #tmpOTManagerNot otN1
            ON ST.IdOTSolicitud = otN1.IdOTSolicitud
		JOIN @Contratos AS TC
			ON SUBOT.IdContrato = TC.ContratoId
    GROUP BY ST.IdOTSolicitud,
             SBP.Descripcion,
             SBO.Descripcion,
             SBO.CreadoEl,
             SBP.CreadoEl,
             AP1.Nombre,
             ST.ProgIniPorProveedor,
             SUCIT.RazonSocial,
             SUCIT.RFC,
             AP1.UsuarioID,
             otN1.Usuario,
             otN1.Fecha;

    --INSERTA SOLPEDS DE PROCURA 
    INSERT INTO @PROCESOSOLPED
    (
        IdSolicitudPedido,
        Descripcion,
        CentroCosto,
        Requisitor,
        FechaRegistro,
        Responsable1aAprobacion,
        Fecha1aAprobacion,
        Estatus1aAprobacion,
        ResponsableReasignado,
        FechaAprobacionReasignado,
        EstatusAprobacionReasignado,
        Responsable2aAprobacion,
        Fecha2aAprobacion,
        Estatus2aAprobacion,
        Responsable2daReasigacion,
        FechaAprobacion2daReasignacion,
        EstatusAprobacion2daReasignacion,
        UsuarioCargaPR,
        FechaCargaPR,
        NumeroPR,
        EstatusFinal,
        FechaRegistroTareaReasignado,
        ContratoId
    )
    SELECT --TOP 20
        SP.IdSolicitudPedido,
        SP.MotivoUrgencia AS Descripcion,
        CC2.CentroCosto,
        US.Nombre AS Requisitor,
        SP.FechaAlta AS FechaRegistro,       
		NULL,   --Responsable1Aprobacion        
		NULL,   --Fecha1Aprobacion        
		NULL,   --Estatus1Aprobacion        
		NULL,   --ResponsableReasignacion        
		NULL,   --FechaAprobacionReasignacion        
		NULL,   --EstatusReasignacion        
		NULL,   --Responsable2Aprobacion        
		NULL, --Fecha2Aprobacion        
		NULL,   --Estatus2Aprobacion       
		NULL,--Responsable2daReasigacion        
		NULL,--FechaAprobacion2daReasignacion        
		NULL,--EstatusAprobacion2daReasignacion
        USPR.Nombre AS UsuarioCargaPR,
        PR.CreadoEl AS FechaCargaPR,
        PR.ID_PR AS NumberPR,
        EG.Nombre AS EstatusGeneral,        
		NULL,   --FechaRegistroTareaReasignado
        SP.IdContrato
    FROM @Contratos C
        JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
            ON C.ContratoId = SP.IdContrato
        LEFT JOIN dbo.S_Usuario AS US (NOLOCK)
            ON SP.IdUsuarioSolicitante = US.IdUsuario
        -- SE LIGA A CENTROS DE COSTO POR SOLPED
        LEFT JOIN @CENTROSCOSTOS AS CC2
            ON SP.IdSolicitudPedido = CC2.IdSolicitudPedido
        LEFT JOIN dbo.TA_Operacion AS OP (NOLOCK)
            ON SP.IdSolicitudPedido = OP.IdDocumento
               AND SP.IdProveedor = OP.IdProveedor
               AND OP.IdTipoOperacion = 2 -->APROBACIÓN DE SOLICITUD DE PEDIDO
        LEFT JOIN dbo.TA_FlujoTarea AS FT (NOLOCK)
            ON OP.IdFlujoTarea = FT.IdFlujoTarea
        --ESTATUS GENERAL DE LA OPERACION
        LEFT JOIN dbo.TA_Estatus AS EG (NOLOCK)
            ON OP.IdEstatusOperacion = EG.IdEstatus
        --CARGA DE PR 
        LEFT JOIN dbo.DEA_AdjuntoPR AS PR (NOLOCK)
            ON SP.IdSolicitudPedido = PR.IdSolicitudPedido
               AND 1 = PR.Activo
               AND 0 = ISNULL(PR.IsEliminado, 0)
        LEFT JOIN dbo.S_Usuario AS USPR (NOLOCK)
            ON PR.CreadoPor = USPR.IdUsuario
        LEFT JOIN Adinco.dbo.OT_Estimacion estima (NOLOCK)
            ON SP.IdSolicitudPedido = estima.IdSolicitudPedido
    WHERE SP.IdUsuarioSolicitante IS NOT NULL
          AND OP.IdFlujoTarea IS NOT NULL
          AND ISNULL(SP.IdEstatusEliminado, 0) = 0
          AND estima.IdOTEstimacion IS NULL -- que no venga de un OT		 
    GROUP BY SP.IdSolicitudPedido,
             SP.MotivoUrgencia,
             CC2.CentroCosto,
             US.Nombre,
             SP.FechaAlta,
             PR.ID_PR,
             PR.CreadoEl,
             USPR.Nombre,
             EG.Nombre,
             SP.IdContrato
    ORDER BY SP.IdSolicitudPedido DESC;

    /*OBTENER EL PRIMER APROBADOR DE LA REQUISICIÓN*/
    /*EN TEORIA EL IdTarea TIENE LA FECHA DE REGISTRO MENOR*/

    /*OBTENER EL ULTIMO APROBADOR REASIGNADO DE LA REQUISICIÓN*/
    /*EN TEORIA EL IdTarea TIENE LA FECHA DE REGISTRO MENOR*/
    INSERT INTO @Aprobador1
    (
        IdSolicitudPedido,
        TareaId
    )
    SELECT IdSolicitudPedido,
           MIN(TareaId)
    FROM @USUARIOAPROBADOR1
    GROUP BY IdSolicitudPedido;

    INSERT INTO @Reasingado1
    (
        IdSolicitudPedido,
        TareaId
    )
    SELECT IdSolicitudPedido,
           MAX(TareaId)
    FROM @USUARIOREASIGNADO
    GROUP BY IdSolicitudPedido;

    -----UPDATES DE LA INFO DEL APROBADOR 1

    UPDATE SP
    SET SP.Responsable1aAprobacion = APUS1.Nombre,
        SP.Fecha1aAprobacion = APUS1.FechaCambioEstatus,
        SP.Estatus1aAprobacion = APUS1.Estatus
    FROM @PROCESOSOLPED SP
        JOIN @Aprobador1 A
            ON SP.IdSolicitudPedido = A.IdSolicitudPedido
        JOIN @USUARIOAPROBADOR1 APUS1
            ON A.TareaId = APUS1.TareaId;

    -----UPDATES DE LA INFO DEL REASIGNADO 1

    UPDATE SP
    SET SP.ResponsableReasignado = APUS1.Nombre,
        SP.FechaAprobacionReasignado = APUS1.FechaCambioEstatus,
        SP.EstatusAprobacionReasignado = APUS1.Estatus
    FROM @PROCESOSOLPED SP
        JOIN @Reasingado1 R
            ON SP.IdSolicitudPedido = R.IdSolicitudPedido
        JOIN @USUARIOREASIGNADO AS APUS1
            ON R.TareaId = APUS1.TareaId;

    /*OBTENER EL SEGUNDO APROBADOR DE LA REQUISICIÓN*/
    /*EN TEORIA EL IdTarea TIENE LA FECHA DE REGISTRO MENOR PARA OBTENER EL PRIMER APROBADOR CON SECUENCIA NO.2*/

    /*OBTENER EL ULTIMO APROBADOR REASIGNADO 2 DE LA REQUISICIÓN*/
    /*EN TEORIA EL IdTarea TIENE LA FECHA DE REGISTRO MENOR PARA OBTENER EL ULTIMO REASINGADO CON EL NO DE SECUENCIA NO.2*/

    INSERT INTO @Aprobador2
    (
        IdSolicitudPedido,
        TareaId
    )
    SELECT IdSolicitudPedido,
           MIN(TareaId)
    FROM @USUARIOAPROBADOR2
    GROUP BY IdSolicitudPedido;

	INSERT INTO @Reasingado2
	(
	    IdSolicitudPedido,
	    TareaId
	)
	SELECT 
	IdSolicitudPedido,
	MAX(TareaId)
	FROM @USUARIOREASIGNADO2
	GROUP BY IdSolicitudPedido

    -----UPDATES DE LA INFO DEL APROBADOR 2

    UPDATE SP
    SET SP.Responsable2aAprobacion = APUS2.Nombre,
        SP.Fecha2aAprobacion = CASE
                                   WHEN APUS2.IdEstatus = 7 THEN  -->ESTATUS 'CANCELADO POR REASIGNACION'
                                       USR2.FechaRegistro --> TOMA LA FECHA DEL ULTIMO REASIGNADOR
                                   ELSE
                                       APUS2.FechaCambioEstatus
                               END,
        SP.Estatus2aAprobacion = APUS2.Estatus,
        Responsable2daReasigacion = CASE
                                        WHEN APUS2.IdEstatus = 7 THEN -->ESTATUS 'CANCELADO POR REASIGNACION'
                                            USR2.Nombre
                                        ELSE
                                            NULL
                                    END,
        FechaAprobacion2daReasignacion = CASE
                                        WHEN APUS2.IdEstatus = 7 THEN -->ESTATUS 'CANCELADO POR REASIGNACION'
                                            USR2.FechaCambioEstatus
                                        ELSE
                                            NULL
                                    END,
        EstatusAprobacion2daReasignacion = CASE
                                        WHEN APUS2.IdEstatus = 7 THEN -->ESTATUS 'CANCELADO POR REASIGNACION'
                                            USR2.Estatus
                                        ELSE
                                            NULL
                                    END
    FROM @PROCESOSOLPED SP
        JOIN @Aprobador2 A2
            ON SP.IdSolicitudPedido = A2.IdSolicitudPedido
        JOIN @USUARIOAPROBADOR2 APUS2
            ON A2.TareaId = APUS2.TareaId
        LEFT JOIN @Reasingado2 R2
            ON SP.IdSolicitudPedido = R2.IdSolicitudPedido
        LEFT JOIN @USUARIOREASIGNADO2 USR2
            ON R2.IdSolicitudPedido = USR2.IdSolicitudPedido
               AND R2.TareaId = USR2.TareaId;
	
	/*OBTENER LA ULTIMA FECHA DE REGISTRO DEL APROBADOR 1 Y ACTUALIZAR LA FECHA FechaRegistroTareaReasignado*/
	INSERT INTO @AprobadorFinal1
	(
	    IdSolicitudPedido,
	    FechaRegistro
	)

	SELECT IdSolicitudPedido,
	MAX(FechaRegistro) 
	FROM @USUARIOAPROBADOR1 
	GROUP BY IdSolicitudPedido
		
	UPDATE SP
	SET FechaRegistroTareaReasignado=A2.FechaRegistro
	FROM @PROCESOSOLPED SP
	JOIN @AprobadorFinal1 A2 ON 
	SP.IdSolicitudPedido= A2.IdSolicitudPedido
	

    --INSERTA SOLPEDS DE OT 
    INSERT INTO @PROCESOSOLPED
    (
        IdSolicitudPedido,
        Folio,
        Descripcion,
        CentroCosto,
        Requisitor,
        FechaRegistro,
        Responsable1aAprobacion,
        Fecha1aAprobacion,
        Estatus1aAprobacion,
        ResponsableReasignado,
        FechaAprobacionReasignado,
        EstatusAprobacionReasignado,
        Responsable2aAprobacion,
        Fecha2aAprobacion,
        Estatus2aAprobacion,
        UsuarioCargaPR,
        FechaCargaPR,
        NumeroPR,
        EstatusFinal,
        ContratoId
    )
    SELECT SPOT.IdSolicitudPedido,
           SOOT.Folio,
           SPOT.MotivoUrgencia,
           CCOT.CentroCosto,
           CASE
               WHEN USOT.Nombre = 'Tareas automáticas Control de Obra' THEN
                   'Usuario (Sistema)'
               ELSE
                   USOT.Nombre
           END,
		   SOOT.CreadoEl,
           NULL,-->Responsable1aAprobacion
           NULL,-->Fecha1aAprobacion
           NULL,-->Estatus1aAprobacion
           NULL,-->ResponsableReasignado
           NULL,-->FechaAprobacionReasignado
           NULL,-->EstatusAprobacionReasignado
           NULL,-->Responsable2aAprobacion
           NULL,-->Fecha2aAprobacion
           NULL,-->Estatus2aAprobacion
           CASE
               WHEN SOOT.IsActivo = 0
                    OR SOOT.IsEliminado = 1 THEN
                   NULL
               WHEN PR.IdAjuntoPr IS NOT NULL THEN
                   USPROT.Nombre
               ELSE
                   APPR.Nombre
           END AS UsuarioCargaPR,
           CASE
               WHEN SOOT.IsActivo = 0
                    OR SOOT.IsEliminado = 1 THEN
                   NULL
               WHEN PR.IdAjuntoPr IS NOT NULL THEN
                   PR.CreadoEl
               ELSE
                   ISNULL(SOOT.FechaAprobacionSAPPR, SOOT.ModificadoEl)
           END AS FechaCargaPR,
           ISNULL(SOOT.SAPPR, PR.ID_PR) AS NumeroPR,
           CASE
               WHEN SOOT.IsActivo = 0
                    OR SOOT.IsEliminado = 1 THEN
                   'Baja de OT'
               ELSE
                   OTE.Descripcion
           END,
           SUBOT.IdContrato
    FROM Adinco.dbo.OT_Solicitud AS SOOT (NOLOCK)
        LEFT JOIN Adinco.dbo.OT_Estimacion AS ESOT (NOLOCK)
            ON SOOT.IdOTSolicitud = ESOT.IdOTSolicitud
        LEFT JOIN dbo.MM_Pedido AS POT (NOLOCK)
            ON ESOT.IdPedido = POT.IdPedido
        LEFT JOIN dbo.MM_SolicitudPedido AS SPOT (NOLOCK)
            ON ESOT.IdSolicitudPedido = SPOT.IdSolicitudPedido
        LEFT JOIN dbo.CC_CentroCosto AS CCOT (NOLOCK)
            ON SOOT.IdCentroCosto = CCOT.IdCentroCosto
        LEFT JOIN Petrovendor.dbo.S_Usuario AS USOT (NOLOCK)
            ON SPOT.IdUsuarioSolicitante = USOT.IdUsuario
        LEFT JOIN Adinco.dbo.OT_Estatus AS OTE (NOLOCK)
            ON SOOT.IdOTEstatus = OTE.IdOtEstatus
        LEFT JOIN Adinco.dbo.SC_SubContrato AS SUBOT (NOLOCK)
            ON SOOT.IdSubContrato = SUBOT.IdSubContrato
        LEFT JOIN Adinco.dbo.PV_Subcontratista AS SUCIT (NOLOCK)
            ON SUBOT.IdSubContratista = SUCIT.IdSubcontratista
        LEFT JOIN Adinco.dbo.AP_Usuario AS APPR (NOLOCK)
            ON SOOT.ModificadoPor = APPR.UsuarioID
        LEFT JOIN dbo.DEA_AdjuntoPR AS PR (NOLOCK)
            ON SPOT.IdSolicitudPedido = PR.IdSolicitudPedido
               AND 1 = PR.Activo
        LEFT JOIN dbo.S_Usuario AS USPROT (NOLOCK)
            ON PR.CreadoPor = USPROT.IdUsuario
		JOIN @Contratos AS TC 
			ON SUBOT.IdContrato = TC.ContratoId
    GROUP BY SPOT.IdSolicitudPedido,
             SOOT.Folio,
             SPOT.MotivoUrgencia,
             CCOT.CentroCosto,
             USOT.Nombre,
             OTE.Descripcion,             
             APPR.Nombre,
             SOOT.FechaAprobacionSAPPR,
             SOOT.SAPPR,
             SOOT.IsActivo,
             SOOT.CreadoEl,
             SOOT.IdOTSolicitud,
             SOOT.ProgIniPorProveedor,
             SUCIT.RazonSocial,
             SUCIT.RFC,
             SOOT.IsEliminado,
             SOOT.ModificadoEl,
             PR.IdAjuntoPr,
             USPROT.Nombre,
             PR.CreadoEl,
             PR.ID_PR,
             SUBOT.IdContrato;

	/*REALIZAR ACTUALIZACIÓN DE APROBADOR 1 DE OTS
	OBTENER UN ENUMERADO POR REQUISICION, POR LA FECHA APROBACIÓN DESC Y TOMAR 
	EL ENUMERADO COMO EL APROBADOR MAS RECIENTE*/
		
	INSERT INTO @UsuarioOT1
	(
	    IdConsecutivo,
	    IdSolicitudPedido,
	    Id
	)
	SELECT ROW_NUMBER() OVER (PARTITION BY IdSolicitud ORDER BY Fecha1aAprobacion DESC),
	IdSolicitud,
	Id
	FROM @IDSOLITUDOT1
	

	UPDATE  SP 
	SET SP.Responsable1aAprobacion=US1.Responsable1aAprobacion,
	SP.Fecha1aAprobacion=US1.Fecha1aAprobacion,	
	SP.Estatus1aAprobacion=US1.Estatus1aAprobacion
	FROM @PROCESOSOLPED SP
	JOIN @UsuarioOT1 UTO1
	ON SP.IdSolicitudPedido=UTO1.IdSolicitudPedido
	AND 1 = UTO1.IdConsecutivo--> TOMAR POR DEFAULT EL PRIMER REGISTRO CON LA FECHA MÁS RECIENTE 
	JOIN @IDSOLITUDOT1 US1 
	ON UTO1.Id = US1.Id

	/*REALIZAR ACTUALIZACIÓN DE APROBADOR 2 DE OTS
	OBTENER UN ENUMERADO POR REQUISICION, POR LA FECHA APROBACIÓN DESC Y TOMAR 
	EL ENUMERADO COMO EL APROBADOR MAS RECIENTE*/
		
	INSERT INTO @UsuarioOT2
	(
	    IdConsecutivo,
	    IdSolicitudPedido,
	    Id
	)
	SELECT ROW_NUMBER() OVER (PARTITION BY IdSolicitud ORDER BY Fecha2aAprobacion DESC),
	IdSolicitud,
	Id
	FROM @IDSOLITUDOT2
	
	UPDATE  SP 
	SET SP.Responsable1aAprobacion=US2.Responsable2aAprobacion,
	SP.Fecha1aAprobacion=US2.Fecha2aAprobacion,	
	SP.Estatus1aAprobacion=US2.Estatus2aAprobacion
	FROM @PROCESOSOLPED SP
	JOIN @UsuarioOT2 UTO2
	ON SP.IdSolicitudPedido=UTO2.IdSolicitudPedido
	AND 1 = UTO2.IdConsecutivo--> TOMAR POR DEFAULT EL PRIMER REGISTRO
	JOIN @IDSOLITUDOT2 US2 
	ON UTO2.Id = US2.Id;
	INSERT INTO #PROCESOSOLPED2(
	IdSolicitudPedido ,
	Folio ,
	Descripcion ,
	CentroCosto ,
	Requisitor ,
	FechaRegistro ,
	Responsable1aAprobacion ,
	Fecha1aAprobacion ,
	Estatus1aAprobacion ,
	ResponsableReasignado ,
	FechaAprobacionReasignado ,
	EstatusAprobacionReasignado ,
	Responsable2aAprobacion ,
    Fecha2aAprobacion ,
    Estatus2aAprobacion ,
	Responsable2daReasigacion ,
	FechaAprobacion2daReasignacion ,
	EstatusAprobacion2daReasignacion ,
	FechaUltimaAprobacion ,
    UsuarioCargaPR ,
    FechaCargaPR ,
    NumeroPR ,
    EstatusFinal,
	ContratoId)
    SELECT IdSolicitudPedido,
           ISNULL(Folio, 'N/A') AS Folio,
           Descripcion,
           CentroCosto,
           Requisitor,
           FechaRegistro,
           Responsable1aAprobacion,
           CASE
               WHEN Estatus1aAprobacion = 'Cancelado por Reasignacion' THEN
                   FechaRegistroTareaReasignado
               ELSE
                   Fecha1aAprobacion
           END AS Fecha1aAprobacion,
           Estatus1aAprobacion,
           CASE
               WHEN Estatus1aAprobacion <> 'Cancelado por Reasignacion' THEN
                   NULL
               ELSE
                   ResponsableReasignado
           END AS ResponsableReasignado,
           CASE
               WHEN Estatus1aAprobacion <> 'Cancelado por Reasignacion' THEN
                   NULL
               ELSE
                   FechaAprobacionReasignado
           END AS FechaAprobacionReasignado,
           CASE
               WHEN Estatus1aAprobacion <> 'Cancelado por Reasignacion' THEN
                   NULL
               ELSE
                   EstatusAprobacionReasignado
           END AS EstatusAprobacionReasignado,
           Responsable2aAprobacion,
           Fecha2aAprobacion,
           Estatus2aAprobacion,
           Responsable2daReasigacion,
           FechaAprobacion2daReasignacion,
           EstatusAprobacion2daReasignacion,
           CASE
               WHEN FechaAprobacion2daReasignacion IS NOT NULL THEN
                   FechaAprobacion2daReasignacion
               WHEN Fecha2aAprobacion IS NOT NULL THEN
                   Fecha2aAprobacion
               WHEN FechaAprobacionReasignado IS NOT NULL THEN
                   FechaAprobacionReasignado
               WHEN Fecha1aAprobacion IS NOT NULL THEN
                   Fecha1aAprobacion
               WHEN Folio IS NOT NULL
                    AND Fecha1aAprobacion IS NOT NULL THEN
                   Fecha1aAprobacion
           END AS FechaUltimaAprobacion,
           UsuarioCargaPR,
           FechaCargaPR,
           NumeroPR,
           EstatusFinal,
           ContratoId
    FROM @PROCESOSOLPED
    ORDER BY IdSolicitudPedido DESC;

    INSERT INTO @DATOSSOLPEDFIN
    (
        IdSolicitudPedido,
        Folio,
        Descripcion,
        CentroCosto,
        Requisitor,
        FechaRegistro,
        Responsable1aAprobacion,
        Fecha1aAprobacion,
        Estatus1aAprobacion,
        Dias1apro,
        ResponsableReasignado,
        FechaAprobacionReasignado,
        EstatusAprobacionReasignado,
        Dias1asig,
        Responsable2aAprobacion,
        Fecha2aAprobacion,
        Estatus2aAprobacion,
        Dias2aprob,
        Responsable2daReasigacion,
        FechaAprobacion2daReasignacion,
        EstatusAprobacion2daReasignacion,
        Dias2aprobreasig,
        UsuarioCargaPR,
        FechaCargaPR,
        NumeroPR,
        DiasCargaPR,
        DiasAprobGral,
        EstatusFinal,
        ContratoId
    )
    SELECT IdSolicitudPedido,
           Folio,
           Descripcion,
           CentroCosto,
           Requisitor,
           FechaRegistro,
           Responsable1aAprobacion,
           Fecha1aAprobacion,
           Estatus1aAprobacion,
           dbo.CalcularTipoDEA(FechaRegistro, Fecha1aAprobacion),
           ResponsableReasignado,
           FechaAprobacionReasignado,
           EstatusAprobacionReasignado,
           dbo.CalcularTipoDEA(Fecha1aAprobacion, FechaAprobacionReasignado),
           Responsable2aAprobacion,
           Fecha2aAprobacion,
           Estatus2aAprobacion,
           (CASE
                WHEN FechaAprobacionReasignado IS NOT NULL THEN
                    dbo.CalcularTipoDEA(FechaAprobacionReasignado, Fecha2aAprobacion)
                ELSE
                    dbo.CalcularTipoDEA(Fecha1aAprobacion, Fecha2aAprobacion)
            END
           ),
           Responsable2daReasigacion,
           FechaAprobacion2daReasignacion,
           EstatusAprobacion2daReasignacion,
           dbo.CalcularTipoDEA(Fecha2aAprobacion, FechaAprobacion2daReasignacion),
           UsuarioCargaPR,
           FechaCargaPR,
           NumeroPR,
           dbo.CalcularTipoDEA(FechaUltimaAprobacion, FechaCargaPR),
           dbo.CalcularTipoDEA(FechaRegistro, FechaUltimaAprobacion),
           EstatusFinal,
           ContratoId
    FROM #PROCESOSOLPED2
    ORDER BY IdSolicitudPedido DESC;

    --ACTUALIZAR COLUMNA DE NUMERO DE CONTRATO 
    UPDATE SPF
    SET SPF.Contrato = C.NumeroContrato,
        SPF.AreaContractual = AC.NombreAreaContractual
    FROM @DATOSSOLPEDFIN SPF
        JOIN Adinco..CO_Contrato C (NOLOCK)
            ON SPF.ContratoId = C.IdContrato
        JOIN Adinco..CO_AreaContractual AC (NOLOCK)
            ON C.IdAreaContractual = AC.IdAreaContractual;

    TRUNCATE TABLE dbo.DEA_ProcesoSolicitudPedido_Estatus;
    INSERT INTO dbo.DEA_ProcesoSolicitudPedido_Estatus
    (
        IdSolicitudPedido,
        Folio,
        Descripcion,
        CentroCosto,
        Requisitor,
        FechaRegistro,
        Responsable1aAprobacion,
        Fecha1aAprobacion,
        DiasEspera1aAprobacion,
        Estatus1aAprobacion,
        Responsable1aReasignacion,
        FechaAprobacion1aReasignacion,
        DiasEspera1aReasignacion,
        EstatusAprobacion1aReasignacionn,
        Responsable2aAprobacion,
        Fecha2aAprobacion,
        DiasEspera2aAprobacion,
        Estatus2aAprobacion,
        Responsable2aReasignacion,
        FechaAprobacion2aReasignacion,
        DiasEspera2aReasignacion,
        EstatusAprobacion2aReasignacion,
        DiasEnAprobacionGeneral,
        UsuarioCargaPR,
        FechaCargaPR,
        DiasCargaPR,
        NumeroPR,
        DiasTotal,
        EstatusFinal,
        Contrato,
        AreaContractual
    )
    SELECT ISNULL(CAST(T.IdSolicitudPedido AS NVARCHAR(100)), '') AS IdSolicitudPedido,
           ISNULL(Folio, '') AS Folio,
           ISNULL(Descripcion, '') AS Descripcion,
           ISNULL(CentroCosto, '') AS CentroCosto,
           ISNULL(Requisitor, '') AS Requisitor,
           FechaRegistro AS FechaRegistro,
           REPLACE(ISNULL(Responsable1aAprobacion, ''), '()', '') AS Responsable1aAprobacion,
           Fecha1aAprobacion AS Fecha1aAprobacion,
           CASE
               WHEN Estatus1aAprobacion = 'En Aprobación'
                    OR Estatus1aAprobacion IS NULL THEN
                   ''
               ELSE
                   CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), Dias1apro), 0))
           END AS DiasEspera1aAprobacion,
           ISNULL(Estatus1aAprobacion, '') AS Estatus1aAprobacion,
           ISNULL(ResponsableReasignado, '') AS Responsable1aReasignacion,
           FechaAprobacionReasignado AS FechaAprobacionReasignado,
           CASE
               WHEN EstatusAprobacionReasignado = 'En Aprobación'
                    OR EstatusAprobacionReasignado IS NULL THEN
                   ''
               ELSE
                   CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), Dias1asig), 0))
           END AS DiasEspera1aReasignacion,
           ISNULL(EstatusAprobacionReasignado, '') AS EstatusAprobacion1aReasignacion,
           CASE
               WHEN Estatus1aAprobacion = 'Rechazada'
                    OR EstatusAprobacionReasignado = 'Rechazada' THEN
                   ''
               ELSE
                   ISNULL(Responsable2aAprobacion, '')
           END AS Responsable2aAprobacion,
           Fecha2aAprobacion AS Fecha2aAprobacion,
           CASE
               WHEN Estatus2aAprobacion = 'En Aprobación'
                    OR Estatus2aAprobacion IS NULL THEN
                   ''
               WHEN Estatus1aAprobacion = 'Rechazada'
                    OR EstatusAprobacionReasignado = 'Rechazada' THEN
                   ''
               ELSE
                   CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), Dias2aprob), 0))
           END AS DiasEspera2aAprobacion,
           CASE
               WHEN Estatus2aAprobacion = 'Cancelado por Rechazo' THEN
                   ''
               ELSE
                   ISNULL(Estatus2aAprobacion, '')
           END AS Estatus2aAprobacion,
           ISNULL(Responsable2daReasigacion, '') AS Responsable2aReasignacion,
           FechaAprobacion2daReasignacion AS FechaAprobacion2daReasignacion,
           CASE
               WHEN EstatusAprobacion2daReasignacion = 'En Aprobación'
                    OR EstatusAprobacion2daReasignacion IS NULL THEN
                   ''
               ELSE
                   CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), Dias2aprobreasig), 0))
           END AS DiasEspera2aReasignacion,
           ISNULL(EstatusAprobacion2daReasignacion, '') AS EstatusAprobacion2aReasignacion,
           CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), DiasAprobGral), 0)) AS DiasEnAprobacionGeneral,
           ISNULL(UsuarioCargaPR, '') AS UsuarioCargaPR,
           FechaCargaPR AS FechaCargaPR,
           CASE
               WHEN UsuarioCargaPR IS NULL THEN
                   ''
               ELSE
                   CONVERT(VARCHAR, ISNULL(CONVERT(DECIMAL(5, 2), DiasCargaPR), 0))
           END AS DiasCargaPR,
           ISNULL(NumeroPR, '') AS NumeroPR,
           CONVERT(
                      VARCHAR,
                      ISNULL(CONVERT(DECIMAL(5, 2), DiasAprobGral), 0) + ISNULL(CONVERT(DECIMAL(5, 2), DiasCargaPR), 0)
                  ) AS DiasTotal,
           ISNULL(EstatusFinal, '') AS EstatusFinal,
           Contrato,
           AreaContractual
    FROM @DATOSSOLPEDFIN	T
	LEFT JOIN Adinco.dbo.OT_Estimacion	OT
		 ON T.IdSolicitudPedido = OT.IdSolicitudPedido
WHERE OT.IdSolicitudPedido IS NULL
    ORDER BY T.IdSolicitudPedido DESC;
END;