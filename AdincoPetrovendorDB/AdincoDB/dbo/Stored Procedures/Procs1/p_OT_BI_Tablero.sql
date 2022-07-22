CREATE PROCEDURE [dbo].[p_OT_BI_Tablero]
AS
BEGIN
    DELETE OT_BI_Tablero;
    IF OBJECT_ID('tempdb..#tmpOTManagerNot', 'U') IS NOT NULL
        DROP TABLE #tmpOTManagerNot;
    IF OBJECT_ID('tempdb..#tmpAprobador1', 'U') IS NOT NULL
        DROP TABLE #tmpAprobador1;
    IF OBJECT_ID('tempdb..#tmpAprobador2', 'U') IS NOT NULL
        DROP TABLE #tmpAprobador2;
    IF OBJECT_ID('tempdb..#tmpOTFechaCapturaMax', 'U') IS NOT NULL
        DROP TABLE #tmpOTFechaCapturaMax;
    IF OBJECT_ID('tempdb..#tempAdjuntos', 'U') IS NOT NULL
        DROP TABLE #tempAdjuntos;
    IF OBJECT_ID('tempdb..#TempFechasOT', 'U') IS NOT NULL
        DROP TABLE #TempFechasOT;
    IF OBJECT_ID('tempdb..#tmpResultado', 'U') IS NOT NULL
        DROP TABLE #tmpResultado;
    IF OBJECT_ID('tempdb..#tmpResultado2', 'U') IS NOT NULL
        DROP TABLE #tmpResultado2;
    IF OBJECT_ID('tempdb..#tmpResultado3', 'U') IS NOT NULL
        DROP TABLE #tmpResultado3;
    IF OBJECT_ID('tempdb..#tmpResultado4', 'U') IS NOT NULL
        DROP TABLE #tmpResultado4;
    IF OBJECT_ID('tempdb..#tmpResultado5', 'U') IS NOT NULL
        DROP TABLE #tmpResultado5;
    IF OBJECT_ID('tempdb..#DATOSACEPTACIONES', 'U') IS NOT NULL
        DROP TABLE #DATOSACEPTACIONES;
    IF OBJECT_ID('tempdb..#tmpResultaFinalRep', 'U') IS NOT NULL
        DROP TABLE #tmpResultaFinalRep;
    IF OBJECT_ID('tempdb..#tmpAF', 'U') IS NOT NULL
        DROP TABLE #tmpAF;

	IF OBJECT_ID('tempdb..#TEMPAceptacionPedido', 'U') IS NOT NULL
    DROP TABLE #TEMPAceptacionPedido;
	IF OBJECT_ID('tempdb..#TEMPFechaEvaluacionCN', 'U') IS NOT NULL
    DROP TABLE #TEMPFechaEvaluacionCN;
	IF OBJECT_ID('tempdb..#TEMPFechaRecepcionCNEnMaxCN', 'U') IS NOT NULL
    DROP TABLE #TEMPFechaRecepcionCNEnMaxCN;
	IF OBJECT_ID('tempdb..#TEMPEstatusCartaCN', 'U') IS NOT NULL
    DROP TABLE #TEMPEstatusCartaCN;

    CREATE TABLE #tmpOTManagerNot
    (
        IdOTSolicitud INT,
        Nombre VARCHAR(500),
        Fecha DATETIME
    );
    CREATE TABLE #tmpAprobador1
    (
        IdOTSolicitud INT,
        Usuario VARCHAR(500),
        Fecha DATETIME,
        ProgIniPorProveedor BIT,
        Estatus VARCHAR(150)
    );
    CREATE TABLE #tmpAprobador2
    (
        IdOTSolicitud INT,
        Usuario VARCHAR(500),
        Fecha DATETIME,
        ProgIniPorProveedor BIT,
        Estatus VARCHAR(150)
    );
    CREATE TABLE #tmpOTFechaCapturaMax
    (
        IdOTSolicitud INT,
        FechaCaptura DATETIME,
        Completada BIT
    );
    CREATE TABLE #tempAdjuntos
    (
        ID_R_PR_PO INT,
        PO VARCHAR(500),
        IdPedido INT,
        IdAdjuntoPO INT,
        FechaRegistroPO DATETIME,
        IdSolicitudPedido INT,
        ID_PR VARCHAR(1000),
        ID_PO VARCHAR(1000)
    );

    CREATE TABLE #TempFechasOT
    (
        IdOTSolicitudMaterial INT,
        Fecha DATETIME,
        FechaCargaAvance DATETIME,
        FechaVoBoOperadora DATETIME,
        ResponsableVoBoOperadora VARCHAR(500),
        FechaCierreSemana DATETIME,
        Responsable_Cierre_Semana VARCHAR(500),
        FechaCargaPR DATETIME
    );

    CREATE TABLE #tmpResultado
    (
        NumeroContrato	VARCHAR(50),
        IdOTSolicitud	INT,
        IdSolicitudPedido	INT,
        Folio	VARCHAR(30),
        Objeto	VARCHAR(600),
        CentroCosto VARCHAR(300),
        RazonSocialProv	VARCHAR(500),
        Tarea	VARCHAR(1000),
        SubTarea	VARCHAR(8000),
        Estatus	VARCHAR(50),
        RegistroDeOT	DATETIME,
        Requisitor	VARCHAR(1000),
        Responsable1aAprobacion	VARCHAR(1000),
        Fecha1aAprobacion	DATETIME,
        DiasEspera1aAprobacion	FLOAT,
        Estatus1aAprobacion	VARCHAR(150),
        Responsable2aAprobacion	VARCHAR(1000),
        Fecha2aAprobacion	DATETIME,
        DiasEspera2aAprobacion	FLOAT,
        Estatus2aAprobacion	VARCHAR(150),
        DiaProgramaTrabajo	DATETIME,
        FechaCargaAvance	DATETIME,
        DiasCargaAvance	FLOAT,
        FechaVoBoOperadora	DATETIME,
        ResponsableVoBoOperadora	VARCHAR(1000),
        DiasVoBoOperadora	FLOAT,
        FechaCierreSemana	DATETIME,
        Responsable_Cierre_Semana	VARCHAR(1000),
        DiasCierreSemana	FLOAT,
        DiasAvanceSemanal	FLOAT,
        FechaDeEstimacion	DATETIME,
        ResponsableEstimacion	VARCHAR(1000),
        DiasEstimacion	FLOAT,
        DiasTotales	FLOAT,
        FechaCargaPR	DATETIME,
        NumberPR	VARCHAR(1000),
        NumeroPO	VARCHAR(1000),
        FechaRegistroPO	DATETIME,
        DiasPR	FLOAT,
        DiasRegistroPR_CargaAvance	FLOAT,
        IdOTEstimacion	INT
    )

    CREATE TABLE #tmpResultado2
    (
        NumeroContrato	VARCHAR(50),
        IdOTSolicitud	INT,
        IdSolicitudPedido	INT,
        Folio	VARCHAR(30),
        Objeto	VARCHAR(600),
        CentroCosto	VARCHAR(300),
        RazonSocialProv	VARCHAR(3000),
        Tarea	VARCHAR(3000),
        SubTarea	VARCHAR(8000),
        Estatus	VARCHAR(50),
        RegistroDeOT	DATETIME,
        Requisitor	VARCHAR(1000),
        Responsable1aAprobacion	VARCHAR(3000),
        Fecha1aAprobacion	DATETIME,
        DiasEspera1aAprobacion	FLOAT,
        Estatus1aAprobacion	VARCHAR(150),
        Responsable2aAprobacion	VARCHAR(3000),
        Fecha2aAprobacion	DATETIME,
        DiasEspera2aAprobacion	FLOAT,
        Estatus2aAprobacion	VARCHAR(150),
        ProgramaDel	DATETIME,
        ProgramaAl	DATETIME,
        FechaCargaAvance	DATETIME,
        VolumetriaAvance	VARCHAR(50),
        DiasCargaAvance	FLOAT,
        FechaVoBoOperadora	DATETIME,
        ResponsableVoBoOperadora	VARCHAR(3000),
        DiasVoBoOperadora	FLOAT,
        FechaCierreSemana	DATETIME,
        Responsable_Cierre_Semana	VARCHAR(3000),
        DiasCierreSemana	FLOAT,
        DiasAvanceSemanal	FLOAT,
        FechaDeEstimacion	DATETIME,
        ResponsableEstimacion	VARCHAR(3000),
        DiasEstimacion	FLOAT,
        DiasTotales	FLOAT,
        FechaCargaPR	DATETIME,
        NumberPR	VARCHAR(3000),
        NumeroPO	VARCHAR(3000),
        FechaRegistroPO	DATETIME,
        DiasPR	FLOAT,
        DiasRegistroPR_CargaAvance	FLOAT,
        IdOTEstimacion	INT
    );
    --AGRUPACION 2   
    CREATE TABLE #tmpResultado3
    (
        NumeroContrato NVARCHAR(50),
        IdOTSolicitud INT,
        IdSolicitudPedido INT,
        Folio VARCHAR(30),
        Objeto VARCHAR(600),
        CentroCosto NVARCHAR(300),
        RazonSocialProv  VARCHAR(3000),
        Tarea  VARCHAR(3000),
        SubTarea VARCHAR(8000),
        Estatus VARCHAR(50),
        RegistroDeOT DATETIME,
        Requisitor  VARCHAR(3000),
        Responsable1aAprobacion  VARCHAR(3000),
        Fecha1aAprobacion DATETIME,
        DiasEspera1aAprobacion FLOAT,
        Estatus1aAprobacion VARCHAR(150),
        Responsable2aAprobacion  VARCHAR(3000),
        Fecha2aAprobacion DATETIME,
        DiasEspera2aAprobacion FLOAT,
        Estatus2aAprobacion VARCHAR(150),
        ProgramaDel DATETIME,
        ProgramaAl DATETIME,
        FechaCargaAvance DATETIME,
        VolumetriaAvance NVARCHAR(50),
        DiasCargaAvance FLOAT,
        FechaVoBoOperadora DATETIME,
        ResponsableVoBoOperadora  VARCHAR(3000),
        DiasVoBoOperadora FLOAT,
        FechaCierreSemana DATETIME,
        Responsable_Cierre_Semana  VARCHAR(3000),
        DiasCierreSemana FLOAT,
        DiasAvanceSemanal FLOAT,
        FechaDeEstimacion DATETIME,
        ResponsableEstimacion  VARCHAR(3000),
        DiasEstimacion FLOAT,
        DiasTotales FLOAT,
        FechaCargaPR DATETIME,
        NumberPR  VARCHAR(3000),
        NumeroPO  VARCHAR(3000),
        FechaRegistroPO DATETIME,
        DiasPR FLOAT,
        DiasRegistroPR_CargaAvance FLOAT,
        IdOTEstimacion INT
    )

    CREATE TABLE #tmpResultado4
    (
        NumeroContrato NVARCHAR(50),
        IdOTSolicitud INT,
        IdSolicitudPedido INT,
        Folio VARCHAR(30),
        Objeto VARCHAR(600),
        CentroCosto NVARCHAR(300),
        RazonSocialProv  VARCHAR(3000),
        Tarea  VARCHAR(3000),
        SubTarea VARCHAR(8000),
        Estatus VARCHAR(50),
        RegistroDeOT DATETIME,
        Requisitor  VARCHAR(3000),
        Responsable1aAprobacion  VARCHAR(3000),
        Fecha1aAprobacion DATETIME,
        DiasEspera1aAprobacion FLOAT,
        Estatus1aAprobacion VARCHAR(150),
        Responsable2aAprobacion  VARCHAR(3000),
        Fecha2aAprobacion DATETIME,
        DiasEspera2aAprobacion FLOAT,
        Estatus2aAprobacion VARCHAR(150),
        FechaCargaPR DATETIME,
        NumberPR  VARCHAR(3000),
        DiasPR FLOAT,
        ProgramaDel DATETIME,
        ProgramaAl DATETIME,
        FechaCargaAvance DATETIME,
        VolumetriaAvance NVARCHAR(50),
        DiasCargaAvance FLOAT,
        DiasRegistroPR_CargaAvance FLOAT,
        FechaVoBoOperadora DATETIME,
        ResponsableVoBoOperadora  VARCHAR(3000),
        DiasVoBoOperadora FLOAT,
        FechaCierreSemana DATETIME,
        Responsable_Cierre_Semana  VARCHAR(3000),
        DiasCierreSemana FLOAT,
        DiasAvanceSemanal FLOAT,
        FechaDeEstimacion DATETIME,
        ResponsableEstimacion  VARCHAR(3000),
        DiasEstimacion FLOAT,
        DiasTotales FLOAT,
        NumeroPO  VARCHAR(3000),
        FechaRegistroPO DATETIME,
        IdPedido INT
    );
    -- INICIO PROCURA   
    CREATE TABLE #ACEPTACIONESCN
    (
        IdAceptacionPedido	INT,
        FechaRecepcionCN	DATETIME,
        FechaEvaluacionCN	DATETIME,
        EstatusCartaCN	VARCHAR(200),
        UsuarioEvaluaCN	VARCHAR(200)
    );

    CREATE TABLE #DATOSACEPTACIONES
    (
        IdPedido	INT,
        UsuarioRelacionPOSAP	 VARCHAR(3000),
        NumeroPOSAP	 VARCHAR(3000),
        FechaRelacionPOSAP	DATETIME,
        DiasRelacionPOSAP	FLOAT,
        NumeroAceptacionPedido	INT,
        FechaRecepcionCartaCN	DATETIME,
        DiasRecepcionCartaCartaCN	FLOAT,
        UsuarioApruebaCartaCN	 VARCHAR(3000),
        FechaAprobacionCartaCN	DATETIME,
        DiasAprobacionCartaCN	FLOAT,
        EstatusCartaCN	VARCHAR(200),
        FechaRecepcionFactura	DATETIME,
        DiasRecepcionFactura	FLOAT,
        FolioFactura	VARCHAR(30),
        Responsable1aAprobacion	 VARCHAR(3000),
        Fecha1aAprobacion	DATETIME,
        DiasEspera1aAprobacion	FLOAT,
        Estatus1aAprobacion	VARCHAR(150),
        Responsable2aAprobacion	 VARCHAR(3000),
        Fecha2aAprobacion	DATETIME,
        DiasEspera2aAprobacion	FLOAT,
        Estatus2aAprobacion	VARCHAR(150)
    )
    --      -- FIN PROCURA  
    CREATE TABLE #tmpAFOTTotales
    (
        IdOTSolicitud	INT,
        Total	DECIMAL(20, 2)
    );
    CREATE TABLE #tmpAFOTEstimado
    (
        IdOTSolicitud	INT,
        Total	DECIMAL(20, 2)
    );
    CREATE TABLE #tmpAF
    (
        IdOTSolicitud	INT,
        AVANCE_FINANCIERO	DECIMAL(20, 2)
    );
	CREATE TABLE #TEMPAceptacionPedido(IdAceptacionPedido INT);
	CREATE TABLE #TEMPFechaEvaluacionCN(IdAceptacionPedido INT, FechaEvaluacionCN DATETIME);
	CREATE TABLE #TEMPFechaRecepcionCNEnMaxCN(IdAceptacionPedido INT, CreadoEl DATETIME);
	CREATE TABLE #TEMPEstatusCartaCN(IdAceptacionPedido INT, Estatus varchar(100), UsuarioEvaluaCN varchar(100));

    CREATE NONCLUSTERED INDEX IX_Temp1
    ON [#tmpAprobador1]
    (
        IdOTSolicitud,
        Fecha
    );
    CREATE NONCLUSTERED INDEX IX_Temp2
    ON [#tmpAprobador2]
    (
        IdOTSolicitud,
        Fecha
    );
    CREATE NONCLUSTERED INDEX IX_TempAdjuntos
    ON [#tempAdjuntos]
    (
        IdSolicitudPedido,
        IdPedido
    );
    CREATE NONCLUSTERED INDEX IX_TempFechas
    ON [#TempFechasOT]
    (
        IdOTSolicitudMaterial,
        Fecha
    );
    CREATE NONCLUSTERED INDEX IX_TempResultado
    ON [#tmpResultado]
    (
        NumeroContrato,
        IdOTSolicitud,
        Folio,
        RegistroDeOT
    );

    CREATE NONCLUSTERED INDEX IX_TempResultado2
    ON [#tmpResultado2]
    (
        NumeroContrato,
        IdOTSolicitud,
        Folio,
        RegistroDeOT
    );

    CREATE NONCLUSTERED INDEX IX_TempResultado3
    ON [#tmpResultado3]
    (
        NumeroContrato,
        IdOTSolicitud,
        Folio,
        RegistroDeOT
    );

    CREATE NONCLUSTERED INDEX IX_TempResultado4
    ON [#tmpResultado4]
    (
        NumeroContrato,
        IdOTSolicitud,
        Folio,
        RegistroDeOT
    );

    CREATE NONCLUSTERED INDEX IX_DatosAceptaciones
    ON [#DATOSACEPTACIONES]
    (
        IdPedido,
        NumeroAceptacionPedido
    );
	DECLARE	
		@IdAceptacionPedidoTop INT = 0,
        @FechaRecepcionCN DATE,
        @FechaEvaluacionCN DATE,
        @EstatusCartaCN VARCHAR(200),
        @UsuarioEvaluaCN VARCHAR(200);

    INSERT INTO #tmpOTManagerNot
    (
        IdOTSolicitud,
        Nombre,
        Fecha
    )
    SELECT OT_Solicitud.IdOTSolicitud,
           AP_Usuario.Nombre,
           MIN(S_Notificacion.CreadoEl) AS Fecha
    FROM 
			OT_SolicitudBitacora (NOLOCK)
        INNER JOIN 
			OT_Solicitud (NOLOCK)
            ON	OT_SolicitudBitacora.IdOTSolicitud	=	OT_Solicitud.IdOTSolicitud
        INNER JOIN 
			S_Notificacion (NOLOCK)
            ON --Se agregó un filtro de fechas ya que solo se ocuparán notificaciones a partir de Oct-2019  
				S_Notificacion.CreadoEl >= '20191015'
				and S_Notificacion.CreadoEl <= '20200401'
				and S_Notificacion.Asunto LIKE '%Control de Obra%'
				and S_Notificacion.Asunto LIKE '%' + OT_Solicitud.Folio + '%'
				AND S_Notificacion.CreadoEl > OT_Solicitud.CreadoEl
				AND (
						S_Notificacion.Mensaje LIKE '%La OT ha sido aprobada%'
						OR S_Notificacion.Mensaje LIKE '%La OT ha sido rechazada%'
						OR S_Notificacion.Mensaje LIKE '%Es necesario revisar la programacion inicial%'
						OR S_Notificacion.Mensaje LIKE '%Es necesario aprobar/rechazar%'
					)
        INNER JOIN 
			AP_Usuario (NOLOCK)
            ON	S_Notificacion.CreadoPor	=	AP_Usuario.UsuarioID 
               AND AP_Usuario.Usuario NOT LIKE '%smps-adinco.com%'
               AND AP_Usuario.Usuario NOT LIKE '%ogss.com.mx%'
               AND AP_Usuario.Usuario NOT LIKE '%adinco.mx%'
    GROUP BY 
			OT_Solicitud.IdOTSolicitud,
             AP_Usuario.Nombre;

    INSERT INTO #tmpAprobador1
    (
        IdOTSolicitud,
        Usuario,
        Fecha,
        ProgIniPorProveedor,
        Estatus
    )
    SELECT OT_Solicitud.IdOTSolicitud,
           CASE
               WHEN OT_Solicitud.ProgIniPorProveedor = 1 THEN
                   PV_Subcontratista.RazonSocial
               ELSE
                   ISNULL(
                             ISNULL(AP_Usuario.Nombre, #tmpOTManagerNot.Nombre),
                             ISNULL(   CASE
                                           WHEN OT_Solicitud.IdOTEstatus NOT IN ( 1, 2, 11 ) THEN
                                               MAX(uf.Nombre)
                                           ELSE
                                               ''
                                       END,
                                       ''
                                   )
                         ) COLLATE SQL_Latin1_General_CP1_CI_AS
           END AS Usuario,
           MIN(   CASE
                      WHEN OT_Solicitud.ProgIniPorProveedor = 1 THEN
                          sb2.CreadoEl
                      ELSE
                          ISNULL(
                                    OT_SolicitudBitacora.CreadoEl,
                                    ISNULL(
                                              #tmpOTManagerNot.Fecha,
                                              CASE
                                                  WHEN OT_Solicitud.IdOTEstatus NOT IN ( 1, 2, 11 ) THEN
                                                      DATEADD(MINUTE, 15, OT_Solicitud.CreadoEl)
                                                  ELSE
                                                      NULL
                                              END
                                          )
                                )
                  END
              ) AS Fecha,
           OT_Solicitud.ProgIniPorProveedor,
           MAX(   CASE
                      WHEN OT_Solicitud.ProgIniPorProveedor = 1 THEN
                          sb2.Descripcion
                      ELSE
                          ISNULL(   OT_SolicitudBitacora.Descripcion,
                                    CASE
                                        WHEN #tmpOTManagerNot.Nombre IS NOT NULL THEN
                                            'Enviada a Subcontratista'
                                        ELSE
                                            NULL
                                    END
                                )
                  END
              ) AS Estatus
    FROM 
		OT_Solicitud	(NOLOCK)
        INNER JOIN 
			SC_SubContrato	(NOLOCK)
            ON  OT_Solicitud.IdSubContrato	=	SC_SubContrato.IdSubContrato
        INNER JOIN 
			PV_Subcontratista (NOLOCK)
            ON	SC_SubContrato.IdSubContratista	=	PV_Subcontratista.IdSubcontratista
        LEFT JOIN 
			OT_SolicitudBitacora (NOLOCK)
            ON	OT_Solicitud.IdOTSolicitud	=	OT_SolicitudBitacora.IdOTSolicitud
               AND (
                       OT_SolicitudBitacora.IdTipoMovimiento IN ( 3 )
                       OR OT_SolicitudBitacora.Descripcion LIKE '%Enviada%Subcontratista%'
                   )
        LEFT JOIN 
			OT_SolicitudBitacora	sb2	(NOLOCK)
            ON	OT_Solicitud.IdOTSolicitud	=	sb2.IdOTSolicitud
               AND (
                       sb2.IdTipoMovimiento IN ( 5 )
                       OR OT_SolicitudBitacora.Descripcion LIKE '%Propuesta%Subcontratista%'
                   )
        LEFT	JOIN 
			Adinco..AP_Usuario (NOLOCK)
            ON AP_Usuario.UsuarioID = OT_SolicitudBitacora.UsuarioAdincoId
               AND AP_Usuario.Usuario NOT LIKE '%smps-adinco.com%'
               AND AP_Usuario.Usuario NOT LIKE '%ogss.com.mx%'
               AND AP_Usuario.Usuario NOT LIKE '%adinco.mx%'
        LEFT	JOIN 
			#tmpOTManagerNot
            ON #tmpOTManagerNot.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
        LEFT	JOIN 
			AP_UsuarioCentroCosto (NOLOCK)
            ON AP_UsuarioCentroCosto.IdCentroCosto = OT_Solicitud.IdCentroCosto
        LEFT	JOIN 
			AP_FlujoAprobacionEstatusUsuarios (NOLOCK)
            ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_UsuarioCentroCosto.IdUsuario
               AND AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId = 2 --Manager   
        LEFT	JOIN 
			AP_Usuario uf (NOLOCK)
            ON uf.UsuarioID = AP_FlujoAprobacionEstatusUsuarios.UsuarioId
               AND uf.Usuario NOT LIKE '%smps-adinco.com%'
               AND uf.Usuario NOT LIKE '%ogss.com.mx%'
               AND uf.Usuario NOT LIKE '%adinco.mx%'
               AND uf.Usuario NOT LIKE '%ernesto.rodriguez@wintershalldea.com%'
               AND uf.Usuario NOT LIKE '%napoleon.pineiro@wintershalldea.com%'
               AND uf.Usuario NOT LIKE '%natalia.caro@wintershalldea.com%'
    GROUP BY OT_Solicitud.IdOTSolicitud,
             OT_Solicitud.ProgIniPorProveedor,
             AP_Usuario.Nombre,
             OT_Solicitud.ProgIniPorProveedor,
             #tmpOTManagerNot.Nombre,
             PV_Subcontratista.RazonSocial,
             OT_Solicitud.IdOTEstatus;

    INSERT INTO #tmpAprobador2
    (
        IdOTSolicitud,
        Usuario,
        Fecha,
        ProgIniPorProveedor,
        Estatus
    )
    SELECT OT_Solicitud.IdOTSolicitud,
           CASE
               WHEN OT_Solicitud.ProgIniPorProveedor = 1 THEN
                   ISNULL(AP_Usuario.Nombre, #tmpOTManagerNot.Nombre)
               ELSE
                   PV_Subcontratista.RazonSocial
           END AS Usuario,
           MAX(   CASE
                      WHEN OT_Solicitud.ProgIniPorProveedor = 1 THEN
                          ISNULL(OT_SolicitudBitacora.CreadoEl, #tmpOTManagerNot.Fecha)
                      ELSE
                          sb2.CreadoEl
                  END
              ) AS Fecha,
           OT_Solicitud.ProgIniPorProveedor,
           MAX(   CASE
                      WHEN OT_Solicitud.ProgIniPorProveedor = 1 THEN
                          OT_SolicitudBitacora.Descripcion
                      ELSE
                          sb2.Descripcion
                  END
              ) AS Estatus
    FROM 
		OT_Solicitud (NOLOCK)
        INNER JOIN 
			SC_SubContrato (NOLOCK)
            ON	OT_Solicitud.IdSubContrato	=	SC_SubContrato.IdSubContrato
        INNER JOIN 
			PV_Subcontratista (NOLOCK)
            ON SC_SubContrato.IdSubContratista	=	 PV_Subcontratista.IdSubcontratista
        LEFT JOIN 
			OT_SolicitudBitacora (NOLOCK)
            ON OT_Solicitud.IdOTSolicitud = OT_SolicitudBitacora.IdOTSolicitud
            AND OT_SolicitudBitacora.IdTipoMovimiento IN ( 2 )
        LEFT JOIN 
			OT_SolicitudBitacora sb2 (NOLOCK)
            ON OT_Solicitud.IdOTSolicitud = sb2.IdOTSolicitud
            AND sb2.IdTipoMovimiento IN ( 4 )
        LEFT JOIN 
			AP_Usuario (NOLOCK)
            ON AP_Usuario.UsuarioID = OT_SolicitudBitacora.UsuarioAdincoId
        LEFT JOIN 
			#tmpOTManagerNot
            ON #tmpOTManagerNot.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
    GROUP BY 
			 OT_Solicitud.IdOTSolicitud,
             OT_Solicitud.ProgIniPorProveedor,
             AP_Usuario.Nombre,
             OT_Solicitud.ProgIniPorProveedor,
             PV_Subcontratista.RazonSocial,
             #tmpOTManagerNot.Nombre;

    INSERT INTO #tmpOTFechaCapturaMax
    (
        IdOTSolicitud,
        FechaCaptura,
        Completada
    )
    SELECT OT_Solicitud.IdOTSolicitud,
           MAX(OT_SolicitudProgramaCaptura.Fecha) AS FechaCaptura,
           ISNULL(   CASE
                         WHEN MAX(OT_SolicitudProgramaCaptura.Fecha) >= OT_Solicitud.FechaFin THEN
                             1
                         ELSE
                             0
                     END,
                     0
                 ) AS Completada
    FROM 
		OT_Solicitud	(NOLOCK)
        INNER JOIN 
			OT_SolicitudMaterial	(NOLOCK)
            ON	OT_Solicitud.IdOTSolicitud	=	OT_SolicitudMaterial.IdOTSolicitud
        INNER JOIN 
			OT_SolicitudProgramaCaptura	(NOLOCK)
            ON	OT_SolicitudMaterial.IdOTSolicitudMaterial	=	OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
            AND	OT_SolicitudProgramaCaptura.FechaVoBoSubcontratista	IS	NOT	NULL
    GROUP BY OT_Solicitud.IdOTSolicitud,
             OT_Solicitud.FechaFin;

    --Obtener info adjuntos  
    INSERT INTO #tempAdjuntos
    (
        ID_R_PR_PO,
        PO,
        IdPedido,
        IdAdjuntoPO,
        FechaRegistroPO,
        IdSolicitudPedido,
        ID_PR,
        ID_PO
    )
    SELECT DEA_Relacion_PR_PO.ID_R_PR_PO,
           DEA_Relacion_PR_PO.PO,
           MM_Pedido.IdPedido,
           DEA_AdjuntoPO.IdAdjuntoPO,
           DEA_AdjuntoPO.CreadoEl AS FechaRegistroPO,
           DEA_AdjuntoPR.IdSolicitudPedido,
           DEA_AdjuntoPR.ID_PR,
           DEA_AdjuntoPO.ID_PO
    FROM 
		Petrovendor.dbo.MM_Pedido (NOLOCK)
        INNER JOIN 
			Petrovendor.dbo.DEA_AdjuntoPR (NOLOCK)
            ON	MM_Pedido.IdSolicitudPedido	=	DEA_AdjuntoPR.IdSolicitudPedido	
               AND	DEA_AdjuntoPR.Activo = 1
               AND	ISNULL(DEA_AdjuntoPR.IsEliminado, 0) = 0
               AND	MM_Pedido.IdContrato IN ( 10038, 10044, 10045, 10046, 10144 )
        LEFT JOIN	Petrovendor.dbo.DEA_Relacion_PR_PO (NOLOCK)
            ON	DEA_Relacion_PR_PO.IdPedido = MM_Pedido.IdPedido
            AND DEA_Relacion_PR_PO.Activo = 1
        LEFT JOIN 
			Petrovendor.dbo.DEA_AdjuntoPO	(NOLOCK)
            ON DEA_AdjuntoPO.IdAdjuntoPO	=	DEA_Relacion_PR_PO.IdAdjuntoPO
            AND DEA_AdjuntoPO.Activo	=	1;

    INSERT INTO #TempFechasOT
    (
        IdOTSolicitudMaterial,
        Fecha,
        FechaCargaAvance,
        FechaVoBoOperadora,
        ResponsableVoBoOperadora,
        FechaCierreSemana,
        Responsable_Cierre_Semana,
        FechaCargaPR
    )
    SELECT OT_SolicitudMaterial.IdOTSolicitudMaterial,
           OT_SolicitudProgramaCaptura.Fecha,
           MAX(OT_SolicitudProgramaCaptura.FechaVoBoSubcontratista) AS FechaCargaAvance,
           MAX(OT_SolicitudProgramaCaptura.FechaVoBoContratista) AS FechaVoBoOperadora,
           MAX(OT_SolicitudProgramaCaptura.QuienVoBoContratista) AS ResponsableVoBoOperadora,
           MIN(OT_SolicitudProgramaCaptura.FechaCierre) AS FechaCierreSemana,
           MAX(AP_Usuario.Nombre) AS Responsable_Cierre_Semana,
           CASE
               WHEN OT_Solicitud.FechaAprobacionSAPPR > MIN(OT_SolicitudProgramaCaptura.FechaCierre) THEN
                   MIN(OT_SolicitudProgramaCaptura.FechaCierre)
               ELSE
                   OT_Solicitud.FechaAprobacionSAPPR
           END AS FechaCargaPR
    FROM dbo.OT_Solicitud (NOLOCK)
        INNER JOIN 
			dbo.OT_SolicitudMaterial (NOLOCK)
            ON	OT_Solicitud.IdOTSolicitud	=	OT_SolicitudMaterial.IdOTSolicitud
            AND	OT_Solicitud.IsActivo = 1
        INNER JOIN	
			dbo.OT_SolicitudProgramaCaptura	(NOLOCK)
            ON OT_SolicitudMaterial.IdOTSolicitudMaterial	=	OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
               AND OT_SolicitudProgramaCaptura.FechaVoBoSubcontratista IS NOT NULL
        LEFT JOIN	
			dbo.AP_Usuario	(NOLOCK)
            ON	AP_Usuario.UsuarioID	=	OT_SolicitudProgramaCaptura.CerradoPor
    GROUP BY OT_SolicitudMaterial.IdOTSolicitudMaterial,
             OT_SolicitudProgramaCaptura.Fecha,
             OT_Solicitud.FechaAprobacionSAPPR;

    INSERT INTO #tmpResultado
    (
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
        Responsable1aAprobacion,
        Fecha1aAprobacion,
        DiasEspera1aAprobacion,
        Estatus1aAprobacion,
        Responsable2aAprobacion,
        Fecha2aAprobacion,
        DiasEspera2aAprobacion,
        Estatus2aAprobacion,
        DiaProgramaTrabajo,
        FechaCargaAvance,
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
        DiasPR,
        DiasRegistroPR_CargaAvance,
        IdOTEstimacion
    )
    SELECT CO_Contrato.NumeroContrato,
           OT_Solicitud.IdOTSolicitud,
           MM_Pedido.IdSolicitudPedido,
           OT_Solicitud.Folio AS Folio,
           OT_Solicitud.Objeto AS Objeto,
           CC_CentroCosto.CentroCosto AS CentroCosto,
           ISNULL(PV_Subcontratista.RazonSocial, 'NO ENCONTRADO') AS RazonSocialProv,
           CONCAT(CO_TareaPetrolera.id_Tarea, ' ', CO_TareaPetrolera.TareaPetrolera) AS Tarea,
           CO_Servicio.NombreServicio AS SubTarea,
           OT_Estatus.Descripcion AS Estatus,
           OT_Solicitud.CreadoEl AS RegistroDeOT,
           AP_Usuario.Nombre AS Requisitor,
           #tmpAprobador1.Usuario AS Responsable1aAprobacion,
           #tmpAprobador1.Fecha AS Fecha1aAprobacion,
           CAST(0 AS FLOAT) AS DiasEspera1aAprobacion,
           CASE
               WHEN OT_Solicitud.IdOTEstatus = 1 THEN
                   'Sin iniciar 1a Aprobacion'
               WHEN OT_Solicitud.IdOTEstatus <> 1
                    AND #tmpAprobador1.Estatus IS NULL THEN
                   'En Aprobación'
               ELSE
                   #tmpAprobador1.Estatus
           END AS Estatus1aAprobacion,
           #tmpAprobador2.Usuario AS Responsable2aAprobacion,
           #tmpAprobador2.Fecha AS Fecha2aAprobacion,
           CAST(0 AS FLOAT) AS DiasEspera2aAprobacion,
           CASE
               WHEN #tmpAprobador1.Estatus IS NULL THEN
                   'En espera 1a Aprobación'
               WHEN #tmpAprobador1.Estatus IS NOT NULL
                    AND #tmpAprobador2.Estatus IS NULL THEN
                   'En Aprobación'
               ELSE
                   #tmpAprobador2.Estatus
           END AS Estatus2aAprobacion,
           #TempFechasOT.Fecha AS DiaProgramaTrabajo,
           #TempFechasOT.FechaCargaAvance AS FechaCargaAvance,
           CAST(0 AS FLOAT) AS DiasCargaAvance,
           #TempFechasOT.FechaVoBoOperadora AS FechaVoBoOperadora,
           #TempFechasOT.ResponsableVoBoOperadora AS ResponsableVoBoOperadora,
           CAST(0 AS FLOAT) AS DiasVoBoOperadora,
           #TempFechasOT.FechaCierreSemana AS FechaCierreSemana,
           #TempFechasOT.Responsable_Cierre_Semana AS Responsable_Cierre_Semana,
           CAST(0 AS FLOAT) AS DiasCierreSemana,
           CAST(0 AS FLOAT) AS DiasAvanceSemanal,
           OT_Estimacion.CreadoEl AS FechaDeEstimacion,
           uEst.Nombre AS ResponsableEstimacion,
           CAST(0 AS FLOAT) AS DiasEstimacion,
           CAST(0 AS FLOAT) AS DiasTotales,
           #TempFechasOT.FechaCargaPR,
           ISNULL(#tempAdjuntos.ID_PR, OT_Solicitud.SAPPR) AS NumberPR,
           #tempAdjuntos.ID_PO AS NumeroPO,
           #tempAdjuntos.FechaRegistroPO AS FechaRegistroPO,
           CAST(0 AS FLOAT) AS DiasPR,
           CAST(0 AS FLOAT) AS DiasRegistroPR_CargaAvance,
           ISNULL(OT_Estimacion.IdOTEstimacion, 0) AS IdOTEstimacion
    FROM 
		OT_Solicitud	(NOLOCK)
    INNER JOIN 
		OT_SolicitudMaterial	(NOLOCK)
        ON OT_Solicitud.IdOTSolicitud	=	OT_SolicitudMaterial.IdOTSolicitud
            AND OT_Solicitud.IsActivo = 1
            AND ISNULL(OT_Solicitud.IsEliminado, 0) = 0
    INNER JOIN 
		OT_LineaPresupuesto (NOLOCK)
        ON OT_Solicitud.IdOTSolicitud	=	OT_LineaPresupuesto.IdOTSolicitud 
    INNER JOIN 
		CO_LineaPresupuestoMes (NOLOCK)
        ON OT_LineaPresupuesto.IdLineaPresupuestoMes	=	CO_LineaPresupuestoMes.IdLineaPresupuestoMes 
    INNER JOIN 
		CO_TareaPetrolera (NOLOCK)
        ON CO_LineaPresupuestoMes.IdTareaPetrolera	=	CO_TareaPetrolera.IdTareaPetrolera 
    INNER JOIN 
		CO_Servicio (NOLOCK)
        ON CO_LineaPresupuestoMes.IdServicio	=	CO_Servicio.IdServicio
    INNER JOIN 
		OT_Estatus (NOLOCK)
        ON OT_Solicitud.IdOTEstatus	=	OT_Estatus.IdOtEstatus
    INNER JOIN 
		AP_Usuario (NOLOCK)
        ON  OT_Solicitud.CreadoPor	=	AP_Usuario.UsuarioID
    INNER JOIN 
		Petrovendor..CC_CentroCosto (NOLOCK)
        ON	OT_Solicitud.IdCentroCosto	=	CC_CentroCosto.IdCentroCosto
    INNER JOIN 
		SC_SubContrato (NOLOCK)
        ON OT_Solicitud.IdSubContrato	=	SC_SubContrato.IdSubContrato
        AND SC_SubContrato.IdContratista IN ( 10013, 10060 ) -- Solo contratos DEA   
    INNER JOIN 
		CO_Contrato (NOLOCK)
        ON SC_SubContrato.IdContrato	=	CO_Contrato.IdContrato
    INNER JOIN 
		PV_Subcontratista (NOLOCK)
        ON	SC_SubContrato.IdSubContratista	=	PV_Subcontratista.IdSubcontratista
    LEFT JOIN 
		#TempFechasOT (NOLOCK)
        ON #TempFechasOT.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial
    LEFT JOIN 
		OT_Estimacion (NOLOCK)
        ON OT_Estimacion.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
            AND OT_Estimacion.FechaCorteInicio <= #TempFechasOT.Fecha
            AND OT_Estimacion.FechaCorteFin >= #TempFechasOT.Fecha
    LEFT JOIN 
		AP_Usuario uEst (NOLOCK)
        ON uEst.UsuarioID = OT_Estimacion.CreadoPor
    LEFT JOIN 
		#tmpAprobador1
        ON #tmpAprobador1.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
    LEFT JOIN 
		#tmpAprobador2
        ON #tmpAprobador2.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
    LEFT JOIN 
		Petrovendor..MM_Pedido (NOLOCK)
        ON MM_Pedido.IdPedido = OT_Estimacion.IdPedido
            AND MM_Pedido.IdContrato IN ( 10038, 10044, 10045, 10046, 10144 )
    LEFT JOIN 
		#tempAdjuntos
        ON #tempAdjuntos.IdPedido = MM_Pedido.IdPedido
            AND MM_Pedido.IdSolicitudPedido = #tempAdjuntos.IdSolicitudPedido;

    UPDATE #tmpResultado
    SET DiasEspera1aAprobacion = ISNULL(CAST(DATEDIFF(hh, RegistroDeOT, Fecha1aAprobacion) / 24.0 AS DECIMAL(20, 2)), 0),
        DiasEspera2aAprobacion = ISNULL(
                                           CAST(DATEDIFF(hh, Fecha1aAprobacion, Fecha2aAprobacion) / 24.0 AS DECIMAL(20, 2)),
                                           0
                                       ),
        DiasPR = ISNULL(CAST(DATEDIFF(hh, Fecha2aAprobacion, FechaCargaPR) / 24.0 AS DECIMAL(20, 2)), 0),
        DiasCargaAvance = ISNULL(CAST(DATEDIFF(hh, Fecha2aAprobacion, FechaCargaAvance) / 24.0 AS DECIMAL(20, 2)), 0),
        DiasVoBoOperadora = ISNULL(CAST(DATEDIFF(hh, FechaCargaAvance, FechaVoBoOperadora) / 24.0 AS DECIMAL(20, 2)), 0),
        DiasAvanceSemanal = ISNULL(CAST(DATEDIFF(hh, FechaCargaAvance, FechaCierreSemana) / 24.0 AS DECIMAL(20, 2)), 0),
        DiasEstimacion = ISNULL(CAST(DATEDIFF(hh, FechaCierreSemana, FechaDeEstimacion) / 24.0 AS DECIMAL(20, 2)), 0),
        DiasTotales = CAST(0 AS FLOAT);

    UPDATE #tmpResultado
    SET DiasRegistroPR_CargaAvance = CASE
                                         WHEN ISNULL(DiasPR, 0) > ISNULL(DiasCargaAvance, 0) THEN
                                             DiasPR
                                         ELSE
                                             DiasCargaAvance
                                     END;

    UPDATE #tmpResultado
    SET DiasTotales = ISNULL(DiasVoBoOperadora, 0) + ISNULL(DiasCierreSemana, 0) + ISNULL(DiasEstimacion, 0);

    --  AGRUPACION 1 
    INSERT INTO #tmpResultado2
    (
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
        Responsable1aAprobacion,
        Fecha1aAprobacion,
        DiasEspera1aAprobacion,
        Estatus1aAprobacion,
        Responsable2aAprobacion,
        Fecha2aAprobacion,
        DiasEspera2aAprobacion,
        Estatus2aAprobacion,
        ProgramaDel,
        ProgramaAl,
        FechaCargaAvance,
        VolumetriaAvance,
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
        DiasPR,
        DiasRegistroPR_CargaAvance,
        IdOTEstimacion
    )
    SELECT #tmpResultado.NumeroContrato AS NumeroContrato,
           #tmpResultado.IdOTSolicitud AS IdOTSolicitud,
           #tmpResultado.IdSolicitudPedido AS IdSolicitudPedido,
           #tmpResultado.Folio AS Folio,
           #tmpResultado.Objeto AS Objeto,
           CentroCosto AS CentroCosto,
           #tmpResultado.RazonSocialProv AS RazonSocialProv,
           MAX(Tarea) AS Tarea,
           MAX(#tmpResultado.SubTarea) AS SubTarea,
           #tmpResultado.Estatus AS Estatus,
           #tmpResultado.RegistroDeOT AS RegistroDeOT,
           #tmpResultado.Requisitor AS Requisitor,
           #tmpResultado.Responsable1aAprobacion AS Responsable1aAprobacion,
           #tmpResultado.Fecha1aAprobacion AS Fecha1aAprobacion,
           #tmpResultado.DiasEspera1aAprobacion AS DiasEspera1aAprobacion,
           #tmpResultado.Estatus1aAprobacion AS Estatus1aAprobacion,
           #tmpResultado.Responsable2aAprobacion AS Responsable2aAprobacion,
           #tmpResultado.Fecha2aAprobacion AS Fecha2aAprobacion,
           #tmpResultado.DiasEspera2aAprobacion AS DiasEspera2aAprobacion,
           #tmpResultado.Estatus2aAprobacion AS Estatus2aAprobacion,
           CASE
               WHEN #tmpOTFechaCapturaMax.Completada = 1
                    AND MIN(#tmpResultado.DiaProgramaTrabajo) IS NULL THEN
                   NULL
               WHEN #tmpOTFechaCapturaMax.Completada = 0
                    AND MIN(#tmpResultado.DiaProgramaTrabajo) IS NULL THEN
                   #tmpOTFechaCapturaMax.FechaCaptura
               WHEN MIN(#tmpResultado.DiaProgramaTrabajo) IS NOT NULL THEN
                   MIN(#tmpResultado.DiaProgramaTrabajo)
           END AS ProgramaDel,
           CASE
               WHEN #tmpOTFechaCapturaMax.Completada = 1
                    AND MAX(#tmpResultado.DiaProgramaTrabajo) IS NULL THEN
                   NULL
               WHEN #tmpOTFechaCapturaMax.Completada = 0
                    AND MAX(DiaProgramaTrabajo) IS NULL THEN
                   OT_Solicitud.FechaFin
               WHEN MAX(#tmpResultado.DiaProgramaTrabajo) IS NOT NULL THEN
                   MAX(#tmpResultado.DiaProgramaTrabajo)
           END AS ProgramaAl,
           #tmpResultado.FechaCargaAvance AS FechaCargaAvance,
           CASE
               WHEN #tmpOTFechaCapturaMax.Completada = 1 THEN
                   'Cerrada'
               ELSE
                   'Abierta'
           END AS VolumetriaAvance,
           #tmpResultado.DiasCargaAvance,
           #tmpResultado.FechaVoBoOperadora,
           #tmpResultado.ResponsableVoBoOperadora,
           #tmpResultado.DiasVoBoOperadora,
           #tmpResultado.FechaCierreSemana,
           #tmpResultado.Responsable_Cierre_Semana,
           #tmpResultado.DiasCierreSemana,
           #tmpResultado.DiasAvanceSemanal,
           #tmpResultado.FechaDeEstimacion,
           #tmpResultado.ResponsableEstimacion,
           #tmpResultado.DiasEstimacion,
           #tmpResultado.DiasTotales,
           #tmpResultado.FechaCargaPR,
           #tmpResultado.NumberPR,
           #tmpResultado.NumeroPO,
           #tmpResultado.FechaRegistroPO,
           MAX(#tmpResultado.DiasPR) AS DiasPR,
           MAX(#tmpResultado.DiasRegistroPR_CargaAvance) AS DiasRegistroPR_CargaAvance,
           #tmpResultado.IdOTEstimacion AS IdOTEstimacion
    FROM #tmpResultado
        INNER JOIN 
			OT_Solicitud (NOLOCK)
            ON  #tmpResultado.IdOTSolicitud	=	OT_Solicitud.IdOTSolicitud
        LEFT JOIN 
			#tmpOTFechaCapturaMax
            ON #tmpOTFechaCapturaMax.IdOTSolicitud = #tmpResultado.IdOTSolicitud
    GROUP BY #tmpResultado.NumeroContrato,
             #tmpResultado.IdOTSolicitud,
             IdSolicitudPedido,
             #tmpResultado.Folio,
             #tmpResultado.Objeto,
             CentroCosto,
             RazonSocialProv,
             Estatus,
             RegistroDeOT,
             Requisitor,
             Responsable1aAprobacion,
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
             #tmpOTFechaCapturaMax.FechaCaptura,
             OT_Solicitud.FechaFin,
             OT_Solicitud.FechaInicio,
             #tmpOTFechaCapturaMax.Completada
    ORDER BY IdOTSolicitud;

    /***Rectificar Fecha de cierre de semana si viene null***/
    UPDATE #tmpResultado2
    SET FechaCierreSemana = OT_ProgramaSemanaCerrada.CreadoEl,
        Responsable_Cierre_Semana = ISNULL(AP_Usuario.Nombre, '')
    FROM 
		#tmpResultado2
        INNER JOIN 
			OT_ProgramaSemanaCerrada	(NOLOCK)
            ON #tmpResultado2.IdOTSolicitud	=	OT_ProgramaSemanaCerrada.IdOTSolicitud
        LEFT JOIN AP_Usuario	(NOLOCK)
            ON AP_Usuario.Usuario LIKE '%' + RTRIM(ISNULL(OT_ProgramaSemanaCerrada.CreadoPor, '')) + '%'
               OR CAST(AP_Usuario.UsuarioID AS VARCHAR) = OT_ProgramaSemanaCerrada.CreadoPor
    WHERE (
              CONVERT(VARCHAR, #tmpResultado2.ProgramaDel, 112) >= CONVERT(
                                                                              VARCHAR,
                                                                              OT_ProgramaSemanaCerrada.FechaSemanaIni,
                                                                              112
                                                                          )
              AND CONVERT(VARCHAR, #tmpResultado2.ProgramaAl, 112) <= CONVERT(
                                                                                 VARCHAR,
                                                                                 OT_ProgramaSemanaCerrada.FechaSemanaFin,
                                                                                 112
                                                                             )
          )
          AND #tmpResultado2.FechaCierreSemana IS NULL
          AND #tmpResultado2.Responsable_Cierre_Semana IS NULL;

    /***Recalcular DIas Cierre Semana***/
    UPDATE #tmpResultado
    SET DiasCierreSemana = CAST(DATEDIFF(   hh,
                                            CASE
                                                WHEN FechaCargaAvance > FechaCargaPR THEN
                                                    FechaCargaAvance
                                                WHEN FechaCargaAvance < FechaCargaPR THEN
                                                    FechaCargaPR
                                                ELSE
                                                    ISNULL(FechaCargaAvance, FechaCargaPR)
                                            END,
                                            FechaCierreSemana
                                        ) / 24.0 AS DECIMAL(20, 2));

    INSERT INTO #tmpResultado3
    (
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
        Responsable1aAprobacion,
        Fecha1aAprobacion,
        DiasEspera1aAprobacion,
        Estatus1aAprobacion,
        Responsable2aAprobacion,
        Fecha2aAprobacion,
        DiasEspera2aAprobacion,
        Estatus2aAprobacion,
        ProgramaDel,
        ProgramaAl,
        FechaCargaAvance,
        VolumetriaAvance,
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
        DiasPR,
        DiasRegistroPR_CargaAvance,
        IdOTEstimacion
    )
    SELECT NumeroContrato,
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
           MAX(Responsable1aAprobacion) AS Responsable1aAprobacion,
           MAX(Fecha1aAprobacion) AS Fecha1aAprobacion,
           MAX(DiasEspera1aAprobacion) AS DiasEspera1aAprobacion,
           MAX(Estatus1aAprobacion) AS Estatus1aAprobacion,
           -------   
           MAX(Responsable2aAprobacion) AS Responsable2aAprobacion,
           MAX(Fecha2aAprobacion) AS Fecha2aAprobacion,
           MAX(DiasEspera2aAprobacion) AS DiasEspera2aAprobacion,
           MAX(Estatus2aAprobacion) AS Estatus2aAprobacion,
           MIN(ProgramaDel) AS ProgramaDel,
           MAX(ProgramaAl) AS ProgramaAl,
           MAX(FechaCargaAvance) AS FechaCargaAvance,
           VolumetriaAvance,
           MAX(DiasCargaAvance) AS DiasCargaAvance,
           MAX(FechaVoBoOperadora) AS FechaVoBoOperadora,
           MAX(ResponsableVoBoOperadora) AS ResponsableVoBoOperadora,
           MAX(DiasVoBoOperadora) AS DiasVoBoOperadora,
           MAX(FechaCierreSemana) AS FechaCierreSemana,
           MAX(Responsable_Cierre_Semana) AS Responsable_Cierre_Semana,
           MAX(DiasCierreSemana) AS DiasCierreSemana,
           MAX(DiasAvanceSemanal) AS DiasAvanceSemanal,
           FechaDeEstimacion as FechaDeEstimacion,
           ResponsableEstimacion as ResponsableEstimacion,
           MAX(DiasEstimacion) AS DiasEstimacion,
           MAX(DiasCargaAvance) + MAX(DiasVoBoOperadora) + MAX(DiasCierreSemana) + MAX(DiasAvanceSemanal)
           + MAX(DiasEstimacion) AS DiasTotales,
           FechaCargaPR,
           NumberPR,
           NumeroPO,
           MAX(FechaRegistroPO) AS FechaRegistroPO,
           MAX(DiasPR) AS DiasPR,
           MAX(DiasRegistroPR_CargaAvance) AS DiasRegistroPR_CargaAvance,
           IdOTEstimacion
    FROM #tmpResultado2
    GROUP BY VolumetriaAvance,
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
    INSERT INTO #tmpResultado4
    (
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
        Responsable1aAprobacion,
        Fecha1aAprobacion,
        DiasEspera1aAprobacion,
        Estatus1aAprobacion,
        Responsable2aAprobacion,
        Fecha2aAprobacion,
        DiasEspera2aAprobacion,
        Estatus2aAprobacion,
        FechaCargaPR,
        NumberPR,
        DiasPR,
        ProgramaDel,
        ProgramaAl,
        FechaCargaAvance,
        VolumetriaAvance,
        DiasCargaAvance,
        DiasRegistroPR_CargaAvance,
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
        NumeroPO,
        FechaRegistroPO,
        IdPedido
    )
    SELECT #tmpResultado3.NumeroContrato,
           #tmpResultado3.IdOTSolicitud,
           #tmpResultado3.IdSolicitudPedido AS IdSolicitudPedido,
           Folio,
           Objeto,
           CentroCosto,
           RazonSocialProv,
           Tarea,
           SubTarea,
           Estatus,
           RegistroDeOT,
           Requisitor,
           MAX(Responsable1aAprobacion) AS Responsable1aAprobacion,
           MAX(Fecha1aAprobacion) AS Fecha1aAprobacion,
           MAX(DiasEspera1aAprobacion) AS DiasEspera1aAprobacion,
           MAX(Estatus1aAprobacion) AS Estatus1aAprobacion,
           MAX(Responsable2aAprobacion) AS Responsable2aAprobacion,
           MAX(Fecha2aAprobacion) AS Fecha2aAprobacion,
           MAX(DiasEspera2aAprobacion) AS DiasEspera2aAprobacion,
           MAX(Estatus2aAprobacion) AS Estatus2aAprobacion,
           MAX(FechaCargaPR) AS FechaCargaPR,
           MAX(NumberPR) AS NumberPR,
           MAX(DiasPR) AS DiasPR,
           MIN(ProgramaDel) AS ProgramaDel,
           MAX(ProgramaAl) AS ProgramaAl,
           MAX(FechaCargaAvance) AS FechaCargaAvance,
           VolumetriaAvance,
           MAX(DiasCargaAvance) AS DiasCargaAvance,
           MAX(DiasRegistroPR_CargaAvance) AS DiasRegistroPR_CargaAvance,
           MAX(FechaVoBoOperadora) AS FechaVoBoOperadora,
           MAX(ResponsableVoBoOperadora) AS ResponsableVoBoOperadora,
           MAX(DiasVoBoOperadora) AS DiasVoBoOperadora,
           MAX(FechaCierreSemana) AS FechaCierreSemana,
           MAX(Responsable_Cierre_Semana) AS Responsable_Cierre_Semana,
           MAX(DiasCierreSemana) AS DiasCierreSemana,
           MAX(DiasAvanceSemanal) AS DiasAvanceSemanal,
           MAX(FechaDeEstimacion) AS FechaDeEstimacion,
           MAX(ResponsableEstimacion) AS ResponsableEstimacion,
           MAX(DiasEstimacion) AS DiasEstimacion,
           MAX(DiasCargaAvance) + MAX(DiasVoBoOperadora) + MAX(DiasCierreSemana) + MAX(DiasAvanceSemanal)
           + MAX(DiasEstimacion) AS DiasTotales,
           MAX(NumeroPO) AS NumeroPO,
           MAX(FechaRegistroPO) AS FechaRegistroPO,
           OT_Estimacion.IdPedido AS IdPedido
    FROM 
		#tmpResultado3
        LEFT JOIN 
			dbo.OT_Estimacion	(NOLOCK)
            ON	OT_Estimacion.IdOTEstimacion	=	#tmpResultado3.IdOTEstimacion
    GROUP BY VolumetriaAvance,
             #tmpResultado3.NumeroContrato,
             #tmpResultado3.IdOTSolicitud,
             Folio,
             Objeto,
             CentroCosto,
             RazonSocialProv,
             Tarea,
             SubTarea,
             Estatus,
             RegistroDeOT,
             Requisitor,
             OT_Estimacion.IdPedido,
             #tmpResultado3.IdSolicitudPedido,
             OT_Estimacion.IdPedidoGeneral;

	INSERT INTO #TEMPAceptacionPedido(IdAceptacionPedido)
    SELECT 	
		MM_AceptacionPedido.IdAceptacionPedido
    FROM 
		Petrovendor.dbo.MM_AceptacionPedido (NOLOCK)
	INNER JOIN 
		Petrovendor.dbo.MM_Pedido (NOLOCK)
		ON MM_Pedido.IdPedido = MM_AceptacionPedido.IdPedido
	INNER JOIN 
		#tmpResultado4 --filtrado de informacion                     
		ON MM_Pedido.IdPedido = #tmpResultado4.IdPedido -- se filtra la informacion que viene de la ultima tabla de la OT   
	LEFT JOIN 
		Petrovendor.dbo.DEA_Relacion_PR_PO (NOLOCK)
		ON DEA_Relacion_PR_PO.IdPedido = MM_Pedido.IdPedido;

	INSERT INTO #TEMPFechaRecepcionCNEnMaxCN(CreadoEl,IdAceptacionPedido)
	SELECT 
        MAX(ACPCN.CreadoEl), PT.IdAceptacionPedido
    FROM 
		#TEMPAceptacionPedido PT
	JOIN
		Petrovendor.dbo.MM_AceptacionCartaPCN AS ACPCN
		ON PT.IdAceptacionPedido   = ACPCN.IdAceptacionPedido
	GROUP BY PT.IdAceptacionPedido
    ORDER BY PT.IdAceptacionPedido;
		
	INSERT INTO #TEMPFechaEvaluacionCN(FechaEvaluacionCN,IdAceptacionPedido)
		SELECT 
        MAX(ACPCN.FechaEvaluacion), PT.IdAceptacionPedido
    FROM 
		#TEMPAceptacionPedido PT
	JOIN
		Petrovendor.dbo.MM_AceptacionCartaPCN AS ACPCN
		ON PT.IdAceptacionPedido   = ACPCN.IdAceptacionPedido
	GROUP BY PT.IdAceptacionPedido
    ORDER BY PT.IdAceptacionPedido;

	INSERT INTO #TEMPEstatusCartaCN(IdAceptacionPedido,Estatus,UsuarioEvaluaCN)
	SELECT ESPT.IdAceptacionPedido,EST.Nombre, us.Nombre
	FROM 
		#TEMPFechaRecepcionCNEnMaxCN ESPT
	JOIN
		Petrovendor.dbo.MM_AceptacionCartaPCN AS APC	(NOLOCK)
		ON	ESPT.IdAceptacionPedido	=APC.IdAceptacionPedido
		AND ESPT.CreadoEl	=	APC.CreadoEl
    LEFT JOIN 
		Petrovendor.dbo.TA_Estatus AS EST	(NOLOCK)
        ON EST.IdEstatus = APC.IdEstatus
		LEFT JOIN 
		Petrovendor.dbo.S_Usuario AS US	(NOLOCK)
        ON US.IdUsuario = APC.IdUsuarioEvaluador;
			
    INSERT INTO #ACEPTACIONESCN
    (
        IdAceptacionPedido,
        FechaRecepcionCN,
        FechaEvaluacionCN,
        EstatusCartaCN,
        UsuarioEvaluaCN
    )
	SELECT AP.IdAceptacionPedido,FR.CreadoEl,FE.FechaEvaluacionCN,ECN.Estatus,ECN.UsuarioEvaluaCN
	FROM
		#TEMPAceptacionPedido	AP
	LEFT JOIN
		#TEMPFechaRecepcionCNEnMaxCN FR
		ON	AP.IdAceptacionPedido	=	FR.IdAceptacionPedido
	LEFT JOIN
		#TEMPFechaEvaluacionCN	FE
		ON	AP.IdAceptacionPedido	=	FE.IdAceptacionPedido
	LEFT JOIN
		#TEMPEstatusCartaCN	ECN
		ON	AP.IdAceptacionPedido	=	ECN.IdAceptacionPedido
ORDER BY  AP.IdAceptacionPedido;

    INSERT INTO #DATOSACEPTACIONES
    (
        IdPedido,
        UsuarioRelacionPOSAP,
        NumeroPOSAP,
        FechaRelacionPOSAP,
        DiasRelacionPOSAP,
        NumeroAceptacionPedido,
        FechaRecepcionCartaCN,
        DiasRecepcionCartaCartaCN,
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
        Estatus2aAprobacion
    )
    SELECT MM_Pedido.IdPedido,
           uPo.Nombre AS UsuarioRelacionPOSAP,
           DEA_Relacion_PR_PO.PO AS NumeroPOSAP,
           DEA_Relacion_PR_PO.FechaAltaRelacion AS FechaRelacionPOSAP,
           (Petrovendor.dbo.CalcularTipoDEA(#tmpResultado4.FechaDeEstimacion, DEA_Relacion_PR_PO.FechaAltaRelacion)) AS DiasRelacionPOSAP,
           MM_AceptacionPedido.IdAceptacionPedido AS NumeroAceptacionPedido,
           #ACEPTACIONESCN.FechaRecepcionCN AS FechaRecepcionCartaCN,
           NULL AS DiasRecepcionCartaCartaCN,
           #ACEPTACIONESCN.UsuarioEvaluaCN AS UsuarioApruebaCartaCN,
           #ACEPTACIONESCN.FechaEvaluacionCN AS FechaAprobacionCartaCN,
           CAST(DATEDIFF(hh, #ACEPTACIONESCN.FechaRecepcionCN, #ACEPTACIONESCN.FechaEvaluacionCN) / 24.0 AS DECIMAL(20, 2)) AS DiasAprobacionCartaCN,
           CASE
               WHEN RelacionCartaCNPedido.PedirCarta = 0 THEN
                   'Excluida'
               ELSE
                   #ACEPTACIONESCN.EstatusCartaCN
           END AS EstatusCartaCN,
           TA_Operacion.FechaRegistro AS FechaRecepcionFactura,
           CAST(DATEDIFF(hh, #ACEPTACIONESCN.FechaEvaluacionCN, TA_Operacion.FechaRegistro) / 24.0 AS DECIMAL(20, 2)) AS DiasRecepcionFactura,
           FI_Factura.Folio AS FolioFactura,
           UST1.Nombre AS Responsable1aAprobacion,
           TA_Tarea.FechaCambioEstatus AS Fecha1aAprobacion,
           CAST(DATEDIFF(hh, TA_Operacion.FechaRegistro, TA_Tarea.FechaCambioEstatus) / 24.0 AS DECIMAL(20, 2)) AS DiasEspera1aAprobacion,
           EA1.Nombre AS Estatus1aAprobacion,
           UST2.Nombre AS Responsable2aAprobacion,
           TF2.FechaCambioEstatus AS Fecha2aAprobacion,
           CAST(DATEDIFF(hh, TA_Tarea.FechaCambioEstatus, TF2.FechaCambioEstatus) / 24.0 AS DECIMAL(20, 2)) AS DiasEspera2aAprobacion,
           EA2.Nombre AS Estatus2aAprobacion
    FROM 
		Petrovendor.dbo.MM_SolicitudPedido	(NOLOCK)
	INNER JOIN 
		Petrovendor.dbo.MM_Pedido	(NOLOCK)
		ON	MM_Pedido.IdSolicitudPedido	=	MM_SolicitudPedido.IdSolicitudPedido
		AND	MM_Pedido.IdContrato	IN	( 10038, 10044, 10045, 10046, 10144 )
	LEFT JOIN 
		#tmpResultado4 --se utiliza para filtrar la informacion  
		ON	#tmpResultado4.IdPedido	=	MM_Pedido.IdPedido
	INNER JOIN 
		Petrovendor.dbo.MM_Pedidos	(NOLOCK)
		ON	MM_Pedidos.IdIdentificador	=	MM_Pedido.IdPedido
		AND	MM_Pedidos.IdProveedorCliente	=	MM_Pedido.IdProveedorCompras
	INNER JOIN 
		Petrovendor.dbo.S_Proveedor	(NOLOCK)
		ON	S_Proveedor.IdProveedor	=	MM_Pedido.IdSubcontratista
	LEFT JOIN 
		Petrovendor.dbo.MM_AceptacionPedido	(NOLOCK)
		ON	MM_AceptacionPedido.IdPedido	=	MM_Pedido.IdPedido
	LEFT JOIN 
		#ACEPTACIONESCN
		ON	#ACEPTACIONESCN.IdAceptacionPedido	=	MM_AceptacionPedido.IdAceptacionPedido
	LEFT JOIN 
		Petrovendor.dbo.MM_AceptacionFactura	(NOLOCK)
		ON MM_AceptacionFactura.IdAceptacionPedido = MM_AceptacionPedido.IdAceptacionPedido
	LEFT JOIN 
		Petrovendor.dbo.TA_Operacion	(NOLOCK)
		ON	TA_Operacion.IdDocumento	=	MM_AceptacionFactura.IdAceptacionFactura
			AND	TA_Operacion.IdTipoOperacion	=	10
	LEFT JOIN 
		Petrovendor.dbo.FI_Factura (NOLOCK)
		ON FI_Factura.IdFactura = MM_AceptacionFactura.IdFactura
	LEFT JOIN 
		Petrovendor.dbo.TA_Estatus (NOLOCK)
		ON TA_Estatus.IdEstatus = TA_Operacion.IdEstatusOperacion
	LEFT JOIN 
		Petrovendor.dbo.DEA_Relacion_PR_PO (NOLOCK)
		ON DEA_Relacion_PR_PO.IdPedido = MM_Pedido.IdPedido
	LEFT JOIN 
		Petrovendor.dbo.TA_Tarea	(NOLOCK)
		ON	TA_Tarea.IdOperacion	=	TA_Operacion.IdOperacion
			AND	TA_Tarea.NoSecuencia	=	1
			AND	TA_Tarea.IdEstatus	<>	12
	LEFT JOIN 
		Petrovendor.dbo.S_Usuario (NOLOCK) AS UST1
		ON UST1.IdUsuario = TA_Tarea.IdAprobador
	LEFT JOIN 
		Petrovendor.dbo.TA_Tarea (NOLOCK) AS TF2
		ON TF2.IdOperacion = TA_Operacion.IdOperacion
			AND TF2.NoSecuencia = 2
			AND TF2.IdEstatus <> 12
	LEFT JOIN 
		Petrovendor.dbo.S_Usuario	(NOLOCK)	AS UST2
		ON	UST2.IdUsuario	=	TF2.IdAprobador
	LEFT JOIN 
		Petrovendor.dbo.TA_Estatus	(NOLOCK) AS EA1
		ON	EA1.IdEstatus	=	TA_Tarea.IdEstatus
	LEFT JOIN 
		Petrovendor.dbo.TA_Estatus (NOLOCK)	AS	EA2
		ON	EA2.IdEstatus	=	TF2.IdEstatus
	LEFT JOIN 
		Petrovendor.dbo.TA_Operacion	(NOLOCK)	AS OPSP
		ON	OPSP.IdDocumento	=	MM_SolicitudPedido.IdSolicitudPedido
			AND OPSP.IdTipoOperacion = 2
	LEFT JOIN 
		Petrovendor.dbo.RelacionCartaCNPedido (NOLOCK)
		ON RelacionCartaCNPedido.IdAceptacionPedido = MM_AceptacionPedido.IdAceptacionPedido
	LEFT JOIN 
		Petrovendor.dbo.S_Usuario (NOLOCK) uPo
		ON uPo.IdUsuario = DEA_Relacion_PR_PO.CreadoPor
    WHERE 
		   OPSP.IdEstatusOperacion = 2
          AND MM_Pedido.IdPedido IS NOT NULL
          AND MM_Pedido.RecepcionServicio = 1
    GROUP BY MM_Pedido.IdPedido,
             #tmpResultado4.FechaDeEstimacion,
             DEA_Relacion_PR_PO.FechaAltaRelacion,
             #ACEPTACIONESCN.FechaRecepcionCN,
             #ACEPTACIONESCN.FechaEvaluacionCN,
             RelacionCartaCNPedido.PedirCarta,
             #ACEPTACIONESCN.EstatusCartaCN,
             TA_Operacion.FechaRegistro,
             TA_Tarea.FechaCambioEstatus,
             TF2.FechaCambioEstatus,
             uPo.Nombre,
             DEA_Relacion_PR_PO.PO,
             DEA_Relacion_PR_PO.FechaAltaRelacion,
             MM_AceptacionPedido.IdAceptacionPedido,
             #ACEPTACIONESCN.UsuarioEvaluaCN,
             FI_Factura.Folio,
             UST1.Nombre,
             EA1.Nombre,
             EA2.Nombre,
             UST2.Nombre,
             MM_Pedidos.IdPedido
    ORDER BY MM_Pedidos.IdPedido DESC;

    /*CALCULO AVANCE FINANCIERO*/
    INSERT INTO #tmpAFOTTotales
    (
        IdOTSolicitud,
        Total
    )
    SELECT OT_Solicitud.IdOTSolicitud,
           Total = SUM(OT_SolicitudMaterial.Cantidad * SC_Materiales.PrecioUnitario)
    FROM OT_Solicitud (NOLOCK)
        INNER JOIN 
			#tmpResultado4
            ON #tmpResultado4.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
        INNER JOIN 
			OT_SolicitudMaterial (NOLOCK)
            ON	OT_Solicitud.IdOTSolicitud	=	OT_SolicitudMaterial.IdOTSolicitud
        INNER JOIN 
			SC_Materiales (NOLOCK)
            ON OT_SolicitudMaterial.IdSCMaterial	=	SC_Materiales.IdSCMaterial
    GROUP BY OT_Solicitud.IdOTSolicitud

    INSERT INTO #tmpAFOTEstimado
    (
        IdOTSolicitud,
        Total
    )
    SELECT OT_Solicitud.IdOTSolicitud,
           Total = SUM(OT_Estimacion.Total)
    FROM OT_Solicitud	(NOLOCK)
        INNER JOIN 
			#tmpResultado4
            ON	#tmpResultado4.IdOTSolicitud	=	OT_Solicitud.IdOTSolicitud
        INNER JOIN 
			OT_Estimacion	(NOLOCK)
            ON	OT_Estimacion.IdOTSolicitud	=	OT_Solicitud.IdOTSolicitud
               AND	ISNULL(OT_Estimacion.Cancelada, 0)	=	0
    GROUP BY OT_Solicitud.IdOTSolicitud;

    INSERT INTO #tmpAF
    (
        IdOTSolicitud,
        AVANCE_FINANCIERO
    )
    SELECT OT.IdOTSolicitud,
           AVANCE_FINANCIERO = CASE
                                   WHEN ISNULL(ot.Total, 0) = 0 THEN
                                       0
                                   ELSE
           (ISNULL(E.Total, 0) * 100) / ISNULL(ot.Total, 0)
                               END
    FROM 
		#tmpAFOTTotales	ot
    LEFT JOIN 
		#tmpAFOTEstimado	e
        ON	e.IdOTSolicitud	=	ot.IdOTSolicitud
    -- Retorno a la vista   
    INSERT INTO OT_BI_Tablero
    (
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
        Responsable1aAprobacion,
        Fecha1aAprobacion,
        DiasEspera1aAprobacion,
        Estatus1aAprobacion,
        Responsable2aAprobacion,
        Fecha2aAprobacion,
        DiasEspera2aAprobacion,
        Estatus2aAprobacion,
        FechaCargaPR,
        NumberPR,
        DiasPR,
        ProgramaDel,
        ProgramaAl,
        FechaCargaAvance,
        VolumetriaAvance,
        DiasCargaAvance,
        DiasRegistroPR_CargaAvance,
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
        NumeroPO,
        FechaRegistroPO,
        IdPedido,
        UsuarioRelacionPOSAP,
        NumeroPOSAP,
        FechaRelacionPOSAP,
        DiasRelacionPOSAP,
        NumeroAceptacionPedido,
        FechaRecepcionCartaCN,
        DiasRecepcionCartaCartaCN,
        DiasRelacionPO_CartaCN,
        UsuarioApruebaCartaCN,
        FechaAprobacionCartaCN,
        DiasAprobacionCartaCN,
        DiasAprobacionCartaCN2,
        EstatusCartaCN,
        FechaRecepcionFactura,
        DiasRecepcionFactura,
        FolioFactura,
        Responsable1aAprobacion_Fac,
        Fecha1aAprobacion_Fac,
        DiasEspera1aAprobacionFac,
        Estatus1aAprobacion_Fac,
        Responsable2aAprobacion_Fac,
        Fecha2aAprobacion_Fac,
        DiasEspera2aAprobacion_Fac,
        Estatus2aAprobacion_Fac,
        DiasRelacionPO_AprobacionFactura,
        AvanceFinanciero
    )
    SELECT CAST(#tmpResultado4.NumeroContrato AS VARCHAR(100)) AS NumeroContrato,
           ISNULL(#tmpResultado4.IdOTSolicitud, 0) AS IdOTSolicitud,
           #tmpResultado4.IdSolicitudPedido AS IdSolicitudPedido,
           CAST(#tmpResultado4.Folio AS VARCHAR(30)) AS Folio,
           CAST(#tmpResultado4.Objeto AS VARCHAR(1000)) AS Objeto,
           CAST(#tmpResultado4.CentroCosto AS VARCHAR(200)) AS CentroCosto,
           CAST(#tmpResultado4.RazonSocialProv AS VARCHAR(2000)) AS RazonSocialProv,
           CAST(#tmpResultado4.Tarea AS VARCHAR(350)) AS Tarea,
           CAST(#tmpResultado4.SubTarea AS VARCHAR(350)) AS SubTarea,
           CAST(#tmpResultado4.Estatus AS VARCHAR(100)) AS Estatus,
           #tmpResultado4.RegistroDeOT AS RegistroDeOT,
           CAST(#tmpResultado4.Requisitor AS VARCHAR(650)) AS Requisitor,
           CAST(#tmpResultado4.Responsable1aAprobacion AS VARCHAR(650)) AS Responsable1aAprobacion,
           #tmpResultado4.Fecha1aAprobacion AS Fecha1aAprobacion,
           #tmpResultado4.DiasEspera1aAprobacion AS DiasEspera1aAprobacion,
           CASE
               WHEN #tmpResultado4.Estatus LIKE '%rechazada%operador%'
                    OR #tmpResultado4.Estatus LIKE '%Requiere%Convenio%' THEN
                   #tmpResultado4.Estatus
               ELSE
                   CAST(#tmpResultado4.Estatus1aAprobacion AS VARCHAR(350))
           END AS Estatus1aAprobacion,
           CAST(#tmpResultado4.Responsable2aAprobacion AS VARCHAR(650)) AS Responsable2aAprobacion,
           #tmpResultado4.Fecha2aAprobacion AS Fecha2aAprobacion,
           #tmpResultado4.DiasEspera2aAprobacion AS DiasEspera2aAprobacion,
           CASE
               WHEN #tmpResultado4.Estatus LIKE '%Rechazada%Subcontratista%' THEN
                   #tmpResultado4.Estatus
               WHEN #tmpResultado4.Estatus2aAprobacion NOT IN ( 'En Aprobación', 'En espera 1a Aprobación' )
                    AND #tmpResultado4.Estatus LIKE '%Requiere%Convenio%' THEN
                   #tmpResultado4.Estatus
               ELSE
                   CAST(#tmpResultado4.Estatus2aAprobacion AS VARCHAR(350))
           END AS Estatus2aAprobacion,
           #tmpResultado4.FechaCargaPR AS FechaCargaPR,
           CAST(#tmpResultado4.NumberPR AS VARCHAR(100)) AS NumberPR,
           #tmpResultado4.DiasPR AS DiasPR,
           #tmpResultado4.ProgramaDel AS ProgramaDel,
           #tmpResultado4.ProgramaAl AS ProgramaAl,
           #tmpResultado4.FechaCargaAvance AS FechaCargaAvance,
           CAST(#tmpResultado4.VolumetriaAvance AS VARCHAR(30)) AS VolumetriaAvance,
           #tmpResultado4.DiasCargaAvance AS DiasCargaAvance,
           #tmpResultado4.DiasRegistroPR_CargaAvance AS DiasRegistroPR_CargaAvance,
           #tmpResultado4.FechaVoBoOperadora AS FechaVoBoOperadora,
           CAST(#tmpResultado4.ResponsableVoBoOperadora AS VARCHAR(650)) AS ResponsableVoBoOperadora,
           #tmpResultado4.DiasVoBoOperadora AS DiasVoBoOperadora,
           #tmpResultado4.FechaCierreSemana,
           CAST(#tmpResultado4.Responsable_Cierre_Semana AS VARCHAR(650)) AS Responsable_Cierre_Semana,
           #tmpResultado4.DiasCierreSemana,
           #tmpResultado4.DiasAvanceSemanal,
           #tmpResultado4.FechaDeEstimacion,
           CAST(#tmpResultado4.ResponsableEstimacion AS VARCHAR(650)) AS ResponsableEstimacion,
           #tmpResultado4.DiasEstimacion,
           #tmpResultado4.DiasTotales,
           CAST(#tmpResultado4.NumeroPO AS VARCHAR(200)) AS NumeroPO,
           #tmpResultado4.FechaRegistroPO,
           OT_Estimacion.IdPedidoGeneral AS IdPedido,
           CAST(#DATOSACEPTACIONES.UsuarioRelacionPOSAP AS VARCHAR(650)) AS UsuarioRelacionPOSAP,
           CAST(#DATOSACEPTACIONES.NumeroPOSAP AS VARCHAR(50)) AS NumeroPOSAP,
           #DATOSACEPTACIONES.FechaRelacionPOSAP,
           CAST(#DATOSACEPTACIONES.DiasRelacionPOSAP AS VARCHAR(200)) AS DiasRelacionPOSAP,
           #DATOSACEPTACIONES.NumeroAceptacionPedido,
           #DATOSACEPTACIONES.FechaRecepcionCartaCN,
           ISNULL(
                     CAST(DATEDIFF(
                                      hh,
                                      CAST(#tmpResultado4.FechaDeEstimacion AS DATETIME),
                                      CAST(#DATOSACEPTACIONES.FechaRecepcionCartaCN AS DATETIME)
                                  ) / 24.0 AS DECIMAL(20, 2)),
                     0
                 ) AS DiasRecepcionCartaCartaCN,
           ISNULL(
                     CASE
                         WHEN ISNULL(DiasRelacionPOSAP, 0) > (CAST(DATEDIFF(
                                                                               hh,
                                                                               CAST(#tmpResultado4.FechaDeEstimacion AS DATETIME),
                                                                               CAST(#DATOSACEPTACIONES.FechaRecepcionCartaCN AS DATETIME)
                                                                           ) / 24.0 AS DECIMAL(20, 2))
                                                             ) THEN
                             DiasRelacionPOSAP
                         ELSE
                             CAST(DATEDIFF(
                                              hh,
                                              CAST(#tmpResultado4.FechaDeEstimacion AS DATETIME),
                                              CAST(#DATOSACEPTACIONES.FechaRecepcionCartaCN AS DATETIME)
                                          ) / 24.0 AS DECIMAL(20, 2))
                     END,
                     0
                 ) AS DiasRelacionPO_CartaCN,
           #DATOSACEPTACIONES.UsuarioApruebaCartaCN,
           #DATOSACEPTACIONES.FechaAprobacionCartaCN,
           #DATOSACEPTACIONES.DiasAprobacionCartaCN,
           ISNULL(
                     CAST(DATEDIFF(
                                      hh,
                                      CASE
                                          WHEN #DATOSACEPTACIONES.FechaRecepcionCartaCN > #DATOSACEPTACIONES.FechaRelacionPOSAP THEN
                                              #DATOSACEPTACIONES.FechaRecepcionCartaCN
                                          WHEN #DATOSACEPTACIONES.FechaRecepcionCartaCN < #DATOSACEPTACIONES.FechaRelacionPOSAP THEN
                                              #DATOSACEPTACIONES.FechaRelacionPOSAP
                                          ELSE
                                              ISNULL(
                                                        #DATOSACEPTACIONES.FechaRecepcionCartaCN,
                                                        #DATOSACEPTACIONES.FechaRelacionPOSAP
                                                    )
                                      END,
                                      FechaAprobacionCartaCN
                                  ) / 24.0 AS DECIMAL(20, 2)),
                     0
                 ) AS DiasAprobacionCartaCN2,
           #DATOSACEPTACIONES.EstatusCartaCN,
           #DATOSACEPTACIONES.FechaRecepcionFactura,
           #DATOSACEPTACIONES.DiasRecepcionFactura,
           #DATOSACEPTACIONES.FolioFactura,
           #DATOSACEPTACIONES.Responsable1aAprobacion AS Responsable1aAprobacion_Fac,
           #DATOSACEPTACIONES.Fecha1aAprobacion AS Fecha1aAprobacion_Fac,
           #DATOSACEPTACIONES.DiasEspera1aAprobacion AS DiasEspera1aAprobacionFac,
           #DATOSACEPTACIONES.Estatus1aAprobacion AS Estatus1aAprobacion_Fac,
           #DATOSACEPTACIONES.Responsable2aAprobacion AS Responsable2aAprobacion_Fac,
           #DATOSACEPTACIONES.Fecha2aAprobacion AS Fecha2aAprobacion_Fac,
           #DATOSACEPTACIONES.DiasEspera2aAprobacion AS DiasEspera2aAprobacion_Fac,
           #DATOSACEPTACIONES.Estatus2aAprobacion AS Estatus2aAprobacion_Fac,
           ISNULL(
                     CAST(DATEDIFF(hh, #DATOSACEPTACIONES.Fecha2aAprobacion, #DATOSACEPTACIONES.FechaRelacionPOSAP)
                          / 24.0 AS DECIMAL(20, 2)),
                     0
                 ) AS DiasRelacionPO_AprobacionFactura,
           #tmpAF.AVANCE_FINANCIERO
    FROM 
		#tmpResultado4
    LEFT JOIN 
		OT_Estimacion	(NOLOCK)
        ON	OT_Estimacion.IdSolicitudPedido	=	#tmpResultado4.IdSolicitudPedido
    LEFT JOIN 
		#DATOSACEPTACIONES
        ON	#DATOSACEPTACIONES.IdPedido	=	#tmpResultado4.IdPedido
    LEFT JOIN 
		#tmpAF
        on	#tmpAF.IdOTSolicitud	=	#tmpResultado4.IdOTSolicitud
END;
