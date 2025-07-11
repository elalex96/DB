IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_OT_ConsultaOTSolicitud'
    )
    DROP PROCEDURE USP_SEL_OT_ConsultaOTSolicitud;
GO
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_OT_ConsultaOTSolicitud]
    @pIdContratista    int,
    @pIdContrato       int,
    @pPendientes       bit,
    @pAprobadas        bit,
    @pRechazadas       bit,
    @pExcedidas        bit,
    @pRequiereConvenio bit,
    @pCerradas         bit      = 0,
    @pTodas            bit,
    @pIdSubcontrato    int      = 0,
    @pUsuarioId        int,
    @Desde             datetime = null,
    @Hasta             datetime = null
as
    BEGIN

		IF OBJECT_ID(N'tempdb..#tmpEstimacion', N'U') IS NOT NULL   
		DROP TABLE #tmpEstimacion; 
		
        CREATE TABLE #tmpEstimacion (IdOTSolicitud INT)

		IF OBJECT_ID(N'tempdb..#tmpProgramaCaptura', N'U') IS NOT NULL   
		DROP TABLE #tmpProgramaCaptura;
        CREATE TABLE #tmpProgramaCaptura
            (
                IdOTSolicitudMaterial INT,
                SumaCaptura           DECIMAL(14, 5)
            )
		
		IF OBJECT_ID(N'tempdb..#OT_SolicitudDelContrato', N'U') IS NOT NULL   
		DROP TABLE #OT_SolicitudDelContrato;

		CREATE TABLE #OT_SolicitudDelContrato
			(
				IdOTSolicitud       INT PRIMARY KEY,
				IdOTEstatus         INT,
				IdOTEstatusAnt INT,
				IsActivo            bit,
				isEliminado bit,
				IdSubContrato       int,
				Folio               varchar(150),
				CreadoEl            datetime,
				CreadoPor INT,
				ProgIniPorProveedor bit,
				IdCentroCosto       int,
				ModificadoPor	 INT,
				ModificadoEl	DATETIME,
				FechaInicio DATETIME,
                FechaFin DATETIME,
				PlazoEjecucion	INT,
				Objeto	varchar(1000),
				FechaFinExtendida	DATETIME,
				IdMoneda	INT,
				PresupuestoNombre varchar(300),
				IdPresupuesto INT,
				Subcontrato_IdContratista INT,
				Subcontrato_IdContrato INT,
				IdSubcontratista	INT,
				SubcontratistaRazonSocial varchar(300),
				SAPPR varchar(50)
			);

		INSERT INTO #OT_SolicitudDelContrato
			(
				IdOTSolicitud ,
				IdOTEstatus,
				IdOTEstatusAnt,
				IsActivo,
				isEliminado,
				IdSubContrato,
				Folio,
				CreadoEl,
				CreadoPor,
				ProgIniPorProveedor,
				IdCentroCosto,
				ModificadoPor,
				ModificadoEl,
				FechaInicio,
                FechaFin,
				PlazoEjecucion,
				Objeto,
				FechaFinExtendida,
				IdMoneda,
				PresupuestoNombre,
				IdPresupuesto,
				Subcontrato_IdContratista,
				Subcontrato_IdContrato,
				IdSubcontratista,
				SubcontratistaRazonSocial,
				SAPPR
			)
			SELECT 
				DISTINCT OT_Solicitud.IdOTSolicitud ,
				OT_Solicitud.IdOTEstatus,
				OT_Solicitud.IdOTEstatusAnt,
				OT_Solicitud.IsActivo,
				OT_Solicitud.isEliminado,
				OT_Solicitud.IdSubContrato,
				OT_Solicitud.Folio,
				OT_Solicitud.CreadoEl,
				OT_Solicitud.CreadoPor,
				OT_Solicitud.ProgIniPorProveedor,
				OT_Solicitud.IdCentroCosto,
				OT_Solicitud.ModificadoPor,
				OT_Solicitud.ModificadoEl,
				OT_Solicitud.FechaInicio,
                OT_Solicitud.FechaFin,
				OT_Solicitud.PlazoEjecucion,
				OT_Solicitud.Objeto,
				OT_Solicitud.FechaFinExtendida,
				OT_Solicitud.IdMoneda,
				CO_Presupuesto.Nombre,
				OT_Solicitud.IdPresupuesto,
				SC_Subcontrato.IdContratista,
				SC_Subcontrato.IdContrato,
				SC_Subcontrato.IdSubcontratista,
				PV_Subcontratista.RazonSocial,
				OT_Solicitud.SAPPR
			--select *
			FROM
				OT_Solicitud (NOLOCK)
			JOIN
                    SC_Subcontrato         (NOLOCK)
                        on OT_Solicitud.IdSubcontrato	=	 SC_Subcontrato.IdSubContrato
						AND SC_Subcontrato.IdContrato = @pIdContrato
			JOIN
                    PV_Subcontratista (NOLOCK)
                        on PV_Subcontratista.IdSubcontratista = SC_Subcontrato.IdSubcontratista
			JOIN
                    CO_Presupuesto (NOLOCK)
                        on OT_Solicitud.IdPresupuesto	=	CO_Presupuesto.IdPresupuesto;


        if (@pExcedidas = 1)
            begin
                INSERT INTO #tmpProgramaCaptura
                    (
                        IdOTSolicitudMaterial,
                        SumaCaptura
                    )
                            select
                                OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial,
                                SUM(OT_SolicitudProgramaCaptura.captura)
                            from
                                #OT_SolicitudDelContrato (NOLOCK)
                                inner join
                                    OT_SolicitudMaterial (NOLOCK)
                                        on  #OT_SolicitudDelContrato.IdOTSolicitud	=	OT_SolicitudMaterial.IdOTSolicitud
										AND	#OT_SolicitudDelContrato.Subcontrato_IdContratista = @pIdContratista
                                inner join
                                    OT_SolicitudProgramaCaptura (NOLOCK)
                                        on OT_SolicitudMaterial.IdOTSolicitudMaterial	=	OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
                                           AND OT_SolicitudProgramaCaptura.VoBoSubcontratista = 1
                                           and OT_SolicitudProgramaCaptura.VoBoContratista = 1
                            where
                                (#OT_SolicitudDelContrato.CreadoEl	between dateadd(day, -1, @Desde) and dateadd(day, 1, @Hasta))
                                OR (
                                       @Desde is null
                                       AND @Hasta is null
                                   )
                            group by
                                OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial,
                                OT_SolicitudMaterial.Cantidad
                            having
                                SUM(OT_SolicitudProgramaCaptura.captura) > OT_SolicitudMaterial.Cantidad


                SELECT
                    #OT_SolicitudDelContrato.IdOTSolicitud,
                    #OT_SolicitudDelContrato.IdSubContrato,
                    #OT_SolicitudDelContrato.Folio,
                    #OT_SolicitudDelContrato.FechaInicio,
                    #OT_SolicitudDelContrato.FechaFin,
                    #OT_SolicitudDelContrato.PlazoEjecucion,
                    #OT_SolicitudDelContrato.CreadoPor,
                    #OT_SolicitudDelContrato.CreadoEl,
                    #OT_SolicitudDelContrato.ModificadoPor,
                    #OT_SolicitudDelContrato.ModificadoEl,
                    #OT_SolicitudDelContrato.IsActivo,
                    #OT_SolicitudDelContrato.IsEliminado,
                    #OT_SolicitudDelContrato.IdPresupuesto,
                    #OT_SolicitudDelContrato.Objeto,
                    #OT_SolicitudDelContrato.IdOTEstatus,
                    #OT_SolicitudDelContrato.FechaFinExtendida,
                    NombrePresupuesto = #OT_SolicitudDelContrato.PresupuestoNombre,
                    Subcontratista    = #OT_SolicitudDelContrato.SubcontratistaRazonSocial,
                    CentroCosto       = CC_CentroCosto.CentroCosto
                FROM
                    #OT_SolicitudDelContrato (NOLOCK)
                    inner join
                        OT_SolicitudMaterial (NOLOCK)
                            on #OT_SolicitudDelContrato.IdOTSolicitud	=	OT_SolicitudMaterial.IdOTSolicitud
							AND	isnull(#OT_SolicitudDelContrato.isActivo, 0) = 1
							AND isnull(#OT_SolicitudDelContrato.isEliminado, 0) = 0
							AND #OT_SolicitudDelContrato.IdOTEstatus not in (
																	7, 8
																)
							 AND #OT_SolicitudDelContrato.Subcontrato_IdContratista = @pIdContratista
                    inner join
                        AP_UsuarioCentroCosto ucc (NOLOCK)
                            on ucc.IdUsuario = @pUsuarioId
                               and ucc.IdCentroCosto in (
                                                            #OT_SolicitudDelContrato.IdCentroCosto
                                                        )
                    INNER JOIN
                        Petrovendor..CC_CentroCosto (NOLOCK)
                            on CC_CentroCosto.IdCentroCosto = #OT_SolicitudDelContrato.IdCentroCosto
                    INNER JOIN
                        #tmpProgramaCaptura
                            on #tmpProgramaCaptura.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial
                where
                    isnull(#OT_SolicitudDelContrato.isActivo, 0) = 1
                    and isnull(#OT_SolicitudDelContrato.isEliminado, 0) = 0
                    AND #OT_SolicitudDelContrato.IdOTEstatus not in (
                                                            7, 8
                                                        )
                    and #OT_SolicitudDelContrato.Subcontrato_IdContratista = @pIdContratista
                    and #OT_SolicitudDelContrato.Subcontrato_IdContrato = @pIdContrato
                    and @pIdSubcontrato in (
                                               0, #OT_SolicitudDelContrato.IdSubContrato
                                           )
                    and (
                            (#OT_SolicitudDelContrato.CreadoEl
                    between dateadd(day, -1, @Desde) and dateadd(day, 1, @Hasta)
                            )
                            OR (
                                   @Desde is null
                                   AND @Hasta is null
                               )
                        )
                group by
                    #OT_SolicitudDelContrato.IdOTSolicitud,
                    #OT_SolicitudDelContrato.IdSubContrato,
                    #OT_SolicitudDelContrato.Folio,
                    #OT_SolicitudDelContrato.FechaInicio,
                    #OT_SolicitudDelContrato.FechaFin,
                    #OT_SolicitudDelContrato.PlazoEjecucion,
                    #OT_SolicitudDelContrato.CreadoPor,
                    #OT_SolicitudDelContrato.CreadoEl,
                    #OT_SolicitudDelContrato.ModificadoPor,
                    #OT_SolicitudDelContrato.ModificadoEl,
                    #OT_SolicitudDelContrato.IsActivo,
                    #OT_SolicitudDelContrato.IsEliminado,
                    #OT_SolicitudDelContrato.IdPresupuesto,
                    #OT_SolicitudDelContrato.Objeto,
                    #OT_SolicitudDelContrato.IdOTEstatus,
                    #OT_SolicitudDelContrato.FechaFinExtendida,
                    #OT_SolicitudDelContrato.PresupuestoNombre,
                    #OT_SolicitudDelContrato.SubcontratistaRazonSocial,
                    CC_CentroCosto.CentroCosto
                Order by
                    IdOTSolicitud desc
            end
        Else
            Begin

                INSERT INTO #tmpEstimacion
                    (
                        IdOTSolicitud
                    )
                            select
                                #OT_SolicitudDelContrato.IdOTSolicitud
                            from
                                #OT_SolicitudDelContrato (NOLOCK)
                                inner join
                                    OT_SolicitudMaterial (NOLOCK)
                                        on #OT_SolicitudDelContrato.IdOTSolicitud	= OT_SolicitudMaterial.IdOTSolicitud 
										AND #OT_SolicitudDelContrato.IdOTEstatus
											between 5 and 6 AND @pAprobadas = 1
											and isnull(#OT_SolicitudDelContrato.isActivo, 0) = 1
											and isnull(#OT_SolicitudDelContrato.isEliminado, 0) = 0
											and #OT_SolicitudDelContrato.Subcontrato_IdContratista = @pIdContratista
											and #OT_SolicitudDelContrato.Subcontrato_IdContrato = @pIdContrato
                                inner join
                                    OT_SolicitudProgramaCaptura (NOLOCK)
                                        on OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial
                                           AND OT_SolicitudProgramaCaptura.VoBoSubcontratista = 1
                                           and OT_SolicitudProgramaCaptura.VoBoContratista = 1
                            where
                                #OT_SolicitudDelContrato.IdOTEstatus
                                between 5 and 6 AND @pAprobadas = 1
                                and isnull(#OT_SolicitudDelContrato.isActivo, 0) = 1
                                and isnull(#OT_SolicitudDelContrato.isEliminado, 0) = 0
                                and #OT_SolicitudDelContrato.Subcontrato_IdContratista = @pIdContratista
                                and #OT_SolicitudDelContrato.Subcontrato_IdContrato = @pIdContrato
                            group by
                                #OT_SolicitudDelContrato.IdOTSolicitud


                SELECT DISTINCT
                    #OT_SolicitudDelContrato.IdOTSolicitud,
                    #OT_SolicitudDelContrato.IdSubContrato,
                    #OT_SolicitudDelContrato.Folio,
                    #OT_SolicitudDelContrato.FechaInicio,
                    #OT_SolicitudDelContrato.FechaFin,
                    PlazoEjecucion,
                    #OT_SolicitudDelContrato.CreadoPor,
                    #OT_SolicitudDelContrato.CreadoEl,
                    #OT_SolicitudDelContrato.ModificadoPor,
                    #OT_SolicitudDelContrato.ModificadoEl,
                    #OT_SolicitudDelContrato.IsActivo,
                    #OT_SolicitudDelContrato.IsEliminado,
                    #OT_SolicitudDelContrato.IdPresupuesto,
                    #OT_SolicitudDelContrato.Objeto,
                    IdOTEstatus,
                    FechaFinExtendida,
                    #OT_SolicitudDelContrato.IdOTEstatusAnt,
                    NombrePresupuesto                = #OT_SolicitudDelContrato.PresupuestoNombre,
                    PuedeEstimar                     = case
                                                           when est.IdOTSolicitud is not null
                                                               then 1
                                                           else
                                                               0
                                                       end,
                    Excedida                         = 0,
                    ISNULL(BIOT.AvanceFinanciero, 0) AS AFinanciero,
                    TotalOT                          =
                        (
                            select
                                SUM(otm.Cantidad * scMAT.PrecioUnitario)
                            from
                                OT_SolicitudMaterial otm
                                inner join
                                    SC_Materiales    scMat
                                        on scMat.IdSCMaterial = otm.IdSCMaterial
                            where
                                otm.IdOTSolicitud = #OT_SolicitudDelContrato.IdOTSolicitud
                        ),
                    Moneda                           = isnull(mon.TipoMonedaCorto, 'NO DEFINIDO'),
                    Subcontratista                   = #OT_SolicitudDelContrato.SubcontratistaRazonSocial,
                    CentroCosto                      = cc.CentroCosto,
                    #OT_SolicitudDelContrato.SAPPR
                FROM
                    #OT_SolicitudDelContrato (NOLOCK)
                    JOIN
                        [dbo].[AP_UsuarioCentroCosto] ucc (NOLOCK)
                            ON ucc.IdUsuario = @pUsuarioId
                               and ucc.IdCentroCosto in (
                                                            #OT_SolicitudDelContrato.IdCentroCosto
                                                        )
						AND #OT_SolicitudDelContrato.Subcontrato_IdContrato = @pIdContrato
                    JOIN
                        Petrovendor..CC_CentroCosto   cc (NOLOCK)
                            ON cc.IdCentroCosto = #OT_SolicitudDelContrato.IdCentroCosto
                
                    LEFT JOIN
                        Petrovendor.DBO.PV_TipoMoneda mon (NOLOCK)
                            ON mon.idMoneda = #OT_SolicitudDelContrato.IdMoneda
                    LEFT JOIN
                        #tmpEstimacion                est
                            ON est.IdOTSolicitud = #OT_SolicitudDelContrato.IdOTSolicitud
                    LEFT JOIN
                        OT_BI_Tablero                 BIOT (NOLOCK)
                            ON est.IdOTSolicitud = BIOT.IdOTSolicitud
                where
                    isnull(#OT_SolicitudDelContrato.isActivo, 0) = 1
                    and isnull(#OT_SolicitudDelContrato.isEliminado, 0) = 0
                    AND (
                            (
                                @pAprobadas = 1
                                and #OT_SolicitudDelContrato.IdOTEstatus
                    between 5 and 6
                            )
                            OR (
                                   @pPendientes = 1
                                   and #OT_SolicitudDelContrato.IdOTEstatus in (
                                                                       1, 2, 3, 4, 11
                                                                   )
                               )
                            OR (
                                   @pRechazadas = 1
                                   and #OT_SolicitudDelContrato.IdOTEstatus
                    between 7 and 8
                               )
                            OR (
                                   @pRequiereConvenio = 1
                                   and #OT_SolicitudDelContrato.IdOTEstatus
                    between 9 and 9
                               )
                            OR (
                                   @pCerradas = 1
                                   and #OT_SolicitudDelContrato.IdOTEstatus
                    between 12 and 12
                               )
                            OR @pTodas = 1
                        )
                    and @pIdSubcontrato in (
                                               0, #OT_SolicitudDelContrato.IdSubContrato
                                           )
                    and (
                            (#OT_SolicitudDelContrato.CreadoEl
                    between dateadd(day, -1, @Desde) and dateadd(day, 1, @Hasta)
                            )
                            OR (
                                   @Desde is null
                                   OR @Hasta is null
                               )
                        )
                group by
                    #OT_SolicitudDelContrato.IdOTSolicitud,
                    #OT_SolicitudDelContrato.IdSubContrato,
                    #OT_SolicitudDelContrato.Folio,
                    #OT_SolicitudDelContrato.FechaInicio,
                    #OT_SolicitudDelContrato.FechaFin,
                    PlazoEjecucion,
                    #OT_SolicitudDelContrato.CreadoPor,
                    #OT_SolicitudDelContrato.CreadoEl,
                    #OT_SolicitudDelContrato.ModificadoPor,
                    #OT_SolicitudDelContrato.ModificadoEl,
                    #OT_SolicitudDelContrato.IsActivo,
                    #OT_SolicitudDelContrato.IsEliminado,
                    #OT_SolicitudDelContrato.IdPresupuesto,
                    #OT_SolicitudDelContrato.Objeto,
                    IdOTEstatus,
                    FechaFinExtendida,
                    #OT_SolicitudDelContrato.IdOTEstatusAnt,
                    #OT_SolicitudDelContrato.PresupuestoNombre,
                    mon.TipoMonedaCorto,
                    #OT_SolicitudDelContrato.SubcontratistaRazonSocial,
                    est.IdOTSolicitud,
                    cc.CentroCosto,
                    #OT_SolicitudDelContrato.SAPPR,
                    ISNULL(BIOT.AvanceFinanciero, 0)
                Order by
                    IdOTSolicitud desc

            End
    END
