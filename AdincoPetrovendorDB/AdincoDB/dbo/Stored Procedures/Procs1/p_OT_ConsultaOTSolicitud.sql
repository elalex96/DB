
create Proc p_OT_ConsultaOTSolicitud --10013,10038,0,1,0,1,0,0,1,0,10,'20190101','20220810'
@pIdContratista int,
@pIdContrato int,
@pPendientes bit,
@pAprobadas bit,
@pRechazadas bit,
@pExcedidas bit,
@pRequiereConvenio bit,
@pCerradas bit = 0,
@pTodas bit,
@pIdSubcontrato int=0,
@pUsuarioId int,
@Desde datetime=null,
@Hasta datetime=null
as
BEGIN

	CREATE TABLE #tmpEstimacion(IdOTSolicitud INT)
	CREATE TABLE #tmpProgramaCaptura(IdOTSolicitudMaterial INT, SumaCaptura DECIMAL(14,5))

    if(@pExcedidas = 1)
    begin
		INSERT INTO #tmpProgramaCaptura(IdOTSolicitudMaterial, SumaCaptura)
		select OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial, SUM(OT_SolicitudProgramaCaptura.captura) 
		from  OT_Solicitud (NOLOCK)
                inner join SC_Subcontrato (NOLOCK) on SC_Subcontrato.IdSubcontrato = OT_Solicitud.IdSubcontrato  and 
                                                SC_Subcontrato.IdContratista = @pIdContratista and 
                                                SC_Subcontrato.IdContrato = @pIdContrato
                inner join OT_SolicitudMaterial (NOLOCK) on OT_SolicitudMaterial.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
				inner join OT_SolicitudProgramaCaptura (NOLOCK) on OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial AND
                                                            OT_SolicitudProgramaCaptura.VoBoSubcontratista = 1 and
															OT_SolicitudProgramaCaptura.VoBoContratista = 1
				where
					(OT_Solicitud.CreadoEl between dateadd(day, -1, @Desde) and dateadd(day, 1, @Hasta))
					OR
					(@Desde is null AND @Hasta is null)
				group by OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial, OT_SolicitudMaterial.Cantidad
                having SUM(OT_SolicitudProgramaCaptura.captura) > OT_SolicitudMaterial.Cantidad


        SELECT OT_Solicitud.IdOTSolicitud,
            OT_Solicitud.IdSubContrato,
            OT_Solicitud.Folio,
            OT_Solicitud.FechaInicio,
            OT_Solicitud.FechaFin,
            OT_Solicitud.PlazoEjecucion,
            OT_Solicitud.CreadoPor,
            OT_Solicitud.CreadoEl,
            OT_Solicitud.ModificadoPor,
            OT_Solicitud.ModificadoEl,
            OT_Solicitud.IsActivo,
            OT_Solicitud.IsEliminado,
            OT_Solicitud.IdPresupuesto,
            OT_Solicitud.Objeto,
            OT_Solicitud.IdOTEstatus,
            OT_Solicitud.FechaFinExtendida, 
            NombrePresupuesto=CO_Presupuesto.Nombre,
            Subcontratista = PV_Subcontratista.RazonSocial,
            CentroCosto = CC_CentroCosto.CentroCosto
        
            FROM OT_Solicitud (NOLOCK)
            inner join CO_Presupuesto (NOLOCK) on CO_Presupuesto.IdPresupuesto = OT_Solicitud.IdPresupuesto
            inner join OT_SolicitudMaterial (NOLOCK) on OT_SolicitudMaterial.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
            inner join SC_Subcontrato sc (NOLOCK) on sc.IdSubContrato = OT_Solicitud.IdSubcontrato    
            inner join PV_Subcontratista (NOLOCK) on PV_Subcontratista.IdSubcontratista = sc.IdSubcontratista    
            inner join AP_UsuarioCentroCosto ucc (NOLOCK) on ucc.IdUsuario = @pUsuarioId and
                                                            ucc.IdCentroCosto in (OT_Solicitud.IdCentroCosto)
            INNER JOIN Petrovendor..CC_CentroCosto (NOLOCK) on CC_CentroCosto.IdCentroCosto = OT_Solicitud.IdCentroCosto
			INNER JOIN #tmpProgramaCaptura on #tmpProgramaCaptura.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial
            where isnull(OT_Solicitud.isActivo,0) = 1 and isnull(OT_Solicitud.isEliminado,0) = 0 AND
                    OT_Solicitud.IdOTEstatus not in (7 ,8)
            and sc.IdContratista = @pIdContratista 
            and sc.IdContrato = @pIdContrato
            and @pIdSubcontrato in (0,OT_Solicitud.IdSubContrato)
			and (
					(OT_Solicitud.CreadoEl between dateadd(day, -1, @Desde) and dateadd(day, 1, @Hasta))
					OR
					(@Desde is null AND @Hasta is null)
				)
            group by OT_Solicitud.IdOTSolicitud,
            OT_Solicitud.IdSubContrato,
            OT_Solicitud.Folio,
            OT_Solicitud.FechaInicio,
            OT_Solicitud.FechaFin,
            OT_Solicitud.PlazoEjecucion,
            OT_Solicitud.CreadoPor,
            OT_Solicitud.CreadoEl,
            OT_Solicitud.ModificadoPor,
            OT_Solicitud.ModificadoEl,
            OT_Solicitud.IsActivo,
            OT_Solicitud.IsEliminado,
            OT_Solicitud.IdPresupuesto,
            OT_Solicitud.Objeto,
            OT_Solicitud.IdOTEstatus,
            OT_Solicitud.FechaFinExtendida, 
            CO_Presupuesto.Nombre,
            PV_Subcontratista.RazonSocial,
            CC_CentroCosto.CentroCosto
            Order by IdOTSolicitud desc
    end
    Else
    Begin
		
		INSERT INTO #tmpEstimacion(IdOTSolicitud)
        select 
                OT_Solicitud.IdOTSolicitud
                from OT_Solicitud (NOLOCK)
                inner join SC_Subcontrato (NOLOCK) on SC_Subcontrato.IdSubcontrato = OT_Solicitud.IdSubcontrato  and 
                                                SC_Subcontrato.IdContratista = @pIdContratista and 
                                                SC_Subcontrato.IdContrato = @pIdContrato
                inner join OT_SolicitudMaterial (NOLOCK) on OT_SolicitudMaterial.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
                inner join OT_SolicitudProgramaCaptura (NOLOCK) on OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial AND
                                                            OT_SolicitudProgramaCaptura.VoBoSubcontratista = 1 and
															OT_SolicitudProgramaCaptura.VoBoContratista = 1
                where OT_Solicitud.IdOTEstatus between 5 and 6 AND @pAprobadas = 1
                and isnull(OT_Solicitud.isActivo,0) = 1 and isnull(OT_Solicitud.isEliminado,0) = 0    
                and SC_Subcontrato.IdContratista = @pIdContratista 
                and SC_Subcontrato.IdContrato = @pIdContrato 
                group by OT_Solicitud.IdOTSolicitud
            

        SELECT
			DISTINCT
			OT_Solicitud.IdOTSolicitud,
            OT_Solicitud.IdSubContrato,
            OT_Solicitud.Folio,
            OT_Solicitud.FechaInicio,
            OT_Solicitud.FechaFin,
            PlazoEjecucion,
            OT_Solicitud.CreadoPor,
            OT_Solicitud.CreadoEl,
            OT_Solicitud.ModificadoPor,
            OT_Solicitud.ModificadoEl,
            OT_Solicitud.IsActivo,
            OT_Solicitud.IsEliminado,
            OT_Solicitud.IdPresupuesto,
            OT_Solicitud.Objeto,
            IdOTEstatus,
            FechaFinExtendida,
            IdOTEstatusAnt ,
            NombrePresupuesto=pre.Nombre,
            PuedeEstimar = case when est.IdOTSolicitud is not null then 1 else 0 end,
            Excedida = 0,
			ISNULL(BIOT.AvanceFinanciero,0) AS AFinanciero,
            TotalOT = (
                                    select SUM(otm.Cantidad * scMAT.PrecioUnitario)
                                    from OT_SolicitudMaterial otm
                                    inner join SC_Materiales scMat on scMat.IdSCMaterial = otm.IdSCMaterial
                                    where otm.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
                                ),
            Moneda = isnull(mon.TipoMonedaCorto,'NO DEFINIDO'),
            Subcontratista = pv.RazonSocial,
            CentroCosto = cc.CentroCosto,
            OT_Solicitud.SAPPR       
        FROM OT_Solicitud (NOLOCK)
		JOIN 
			CO_Presupuesto pre (NOLOCK) 
			ON pre.IdPresupuesto = OT_Solicitud.IdPresupuesto
        JOIN 
			SC_Subcontrato sc (NOLOCK) 
			ON sc.IdSubContrato = OT_Solicitud.IdSubcontrato and
                                        sc.IdContrato = @pIdContrato
        JOIN
			[dbo].[AP_UsuarioCentroCosto] ucc (NOLOCK) 
			ON ucc.IdUsuario = @pUsuarioId and
                                                            ucc.IdCentroCosto in (OT_Solicitud.IdCentroCosto)
        JOIN 
			Petrovendor..CC_CentroCosto cc (NOLOCK)
			ON cc.IdCentroCosto = OT_Solicitud.IdCentroCosto
        JOIN 
			PV_Subcontratista pv 
			ON pv.IdSubcontratista = sc.IdSubcontratista        
        LEFT JOIN 
			Petrovendor.DBO.PV_TipoMoneda mon (NOLOCK)
			ON mon.idMoneda = OT_Solicitud.IdMoneda
        LEFT JOIN 
			#tmpEstimacion est 
			ON est.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
		LEFT JOIN
			OT_BI_Tablero	BIOT (NOLOCK)
			ON	est.IdOTSolicitud	=	BIOT.IdOTSolicitud			
        where isnull(OT_Solicitud.isActivo,0) = 1 and isnull(OT_Solicitud.isEliminado,0) = 0  
        AND (
            ( @pAprobadas  =1 and OT_Solicitud.IdOTEstatus between 5 and 6 )
            OR 
            ( @pPendientes  =1 and OT_Solicitud.IdOTEstatus in (1,2,3,4,11)  )
            OR 
            ( @pRechazadas  =1 and OT_Solicitud.IdOTEstatus between 7 and 8 )
            
        OR
            (@pRequiereConvenio  =1 and OT_Solicitud.IdOTEstatus between 9 and 9  )
            OR
            (@pCerradas  =1 and OT_Solicitud.IdOTEstatus between 12 and 12  )
            OR 
            @pTodas = 1
        )
        and @pIdSubcontrato in (0,OT_Solicitud.IdSubContrato)   
		and		
			(
				(OT_Solicitud.CreadoEl between dateadd(day, -1, @Desde) and dateadd(day, 1, @Hasta))
				OR
				(@Desde is null OR @Hasta is null)
			)
        group by OT_Solicitud.IdOTSolicitud,
            OT_Solicitud.IdSubContrato,
            OT_Solicitud.Folio,
            OT_Solicitud.FechaInicio,
            OT_Solicitud.FechaFin,
            PlazoEjecucion,
            OT_Solicitud.CreadoPor,
            OT_Solicitud.CreadoEl,
            OT_Solicitud.ModificadoPor,
            OT_Solicitud.ModificadoEl,
            OT_Solicitud.IsActivo,
            OT_Solicitud.IsEliminado,
            OT_Solicitud.IdPresupuesto,
            OT_Solicitud.Objeto,
            IdOTEstatus,
            FechaFinExtendida,
            IdOTEstatusAnt ,
            pre.Nombre,         
            mon.TipoMonedaCorto,
            pv.RazonSocial,
            est.IdOTSolicitud,
            cc.CentroCosto,
            OT_Solicitud.SAPPR,
			ISNULL(BIOT.AvanceFinanciero,0)
        Order by IdOTSolicitud desc
        
    End
END


