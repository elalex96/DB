-- p_OT_ConsultaOTSolicitud 10013,10038,0,1,0,0,0,0,0,0,10
CREATE Proc [dbo].[p_OT_ConsultaOTSolicitud]
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
@Desde datetime,
@Hasta datetime
as
    if(@pExcedidas = 1)
    begin
        SELECT sol.IdOTSolicitud,
            sol.IdSubContrato,
            sol.Folio,
            sol.FechaInicio,
            sol.FechaFin,
            sol.PlazoEjecucion,
            sol.CreadoPor,
            sol.CreadoEl,
            sol.ModificadoPor,
            sol.ModificadoEl,
            sol.IsActivo,
            sol.IsEliminado,
            sol.IdPresupuesto,
            sol.Objeto,
            sol.IdOTEstatus,
            sol.FechaFinExtendida, 
            NombrePresupuesto=pre.Nombre,
            Subcontratista = pv.RazonSocial,
            CentroCosto = cc.CentroCosto
        
            FROM [OT_Solicitud] sol
            inner join CO_Presupuesto pre on pre.IdPresupuesto = sol.IdPresupuesto
            inner join OT_SolicitudMaterial sm on sm.IdOTSolicitud = sol.IdOTSolicitud
            inner join SC_Subcontrato sc on sc.IdSubContrato = sol.IdSubcontrato    
            inner join PV_Subcontratista pv on pv.IdSubcontratista = sc.IdSubcontratista    
            inner join  [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = @pUsuarioId and
                                                            ucc.IdCentroCosto in (sol.IdCentroCosto)
            INNER JOIN Petrovendor..CC_CentroCosto cc on cc.IdCentroCosto = sol.IdCentroCosto
            where isnull(sol.isActivo,0) = 1 and isnull(sol.isEliminado,0) = 0 AND
                    sol.IdOTEstatus not in (7 ,8)
            and  exists (
                        select  spc.IdOTSolicitudMaterial,SUM(spc.captura) 
                        from OT_SolicitudProgramaCaptura spc
                        where spc.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial and
                                                                spc.VoBoSubcontratista = 1 and
                                                                spc.VoBoContratista = 1
                        group by spc.IdOTSolicitudMaterial
                        having SUM(spc.captura) > sm.Cantidad
                    ) 
            and sc.IdContratista = @pIdContratista 
            and sc.IdContrato = @pIdContrato
            and @pIdSubcontrato in (0,sol.IdSubContrato)
			and sol.CreadoEl between dateadd(day, -1, @Desde) and dateadd(day, 1, @Hasta)
            group by sol.IdOTSolicitud,
            sol.IdSubContrato,
            sol.Folio,
            sol.FechaInicio,
            sol.FechaFin,
            sol.PlazoEjecucion,
            sol.CreadoPor,
            sol.CreadoEl,
            sol.ModificadoPor,
            sol.ModificadoEl,
            sol.IsActivo,
            sol.IsEliminado,
            sol.IdPresupuesto,
            sol.Objeto,
            sol.IdOTEstatus,
            sol.FechaFinExtendida, 
            pre.Nombre,
            pv.RazonSocial,
            cc.CentroCosto
            Order by IdOTSolicitud desc
    end
    Else
    Begin

        select 
                sol.IdOTSolicitud
        into #tmpEstimacion
                from OT_Solicitud sol 
                inner join SC_Subcontrato sc on sc.IdSubcontrato = sol.IdSubcontrato  and 
                                                sc.IdContratista = @pIdContratista and 
                                                sc.IdContrato = @pIdContrato
                inner join OT_SolicitudMaterial sm on sm.IdOTSolicitud = sol.IdOTSolicitud
                inner join [dbo].[OT_SolicitudProgramaCaptura] spc on spc.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial AND
                                                            spc.VoBoSubcontratista = 1 and
                                                            spc.VoBoContratista = 1
                where sol.IdOTEstatus between 5 and 6 AND @pAprobadas  =1
                and isnull(sol.isActivo,0) = 1 and isnull(sol.isEliminado,0) = 0    
                and sc.IdContratista = @pIdContratista 
                and sc.IdContrato = @pIdContrato 
                group by sol.IdOTSolicitud
            
        SELECT sol.IdOTSolicitud,
            sol.IdSubContrato,
            Folio,
            sol.FechaInicio,
            sol.FechaFin,
            PlazoEjecucion,
            sol.CreadoPor,
            sol.CreadoEl,
            sol.ModificadoPor,
            sol.ModificadoEl,
            sol.IsActivo,
            sol.IsEliminado,
            sol.IdPresupuesto,
            sol.Objeto,
            IdOTEstatus,
            FechaFinExtendida,
            IdOTEstatusAnt ,
            NombrePresupuesto=pre.Nombre,
            PuedeEstimar = case when est.IdOTSolicitud is not null then 1 else 0 end,
            Excedida =0,-- cast(case when exc.IdOTSolicitud is not null then 1 else 0 end as bit),
            AFinanciero =   0/*cast((
                                (
                                    select SUM(est.Total)
                                    from OT_Estimacion est
                                    where est.IdOTSolicitud = sol.IdOTSolicitud
                                )
                                /
                                (
                                    select SUM(otm.Cantidad * scMAT.PrecioUnitario)
                                    from OT_SolicitudMaterial otm
                                    inner join SC_Materiales scMat on scMat.IdSCMaterial = otm.IdSCMaterial
                                    where otm.IdOTSolicitud = sol.IdOTSolicitud and
                                    otm.Cantidad > 0
                                )
                            ) * 100
                                as decimal(5,2)
                            )*/
                            ,
            TotalOT = (
                                    select SUM(otm.Cantidad * scMAT.PrecioUnitario)
                                    from OT_SolicitudMaterial otm
                                    inner join SC_Materiales scMat on scMat.IdSCMaterial = otm.IdSCMaterial
                                    where otm.IdOTSolicitud = sol.IdOTSolicitud
                                ),
            Moneda = isnull(mon.TipoMonedaCorto,'NO DEFINIDO'),
            Subcontratista = pv.RazonSocial,
            CentroCosto = cc.CentroCosto,
            sol.SAPPR       
        FROM [OT_Solicitud] sol
        inner join CO_Presupuesto pre on pre.IdPresupuesto = sol.IdPresupuesto
        inner join SC_Subcontrato sc on sc.IdSubContrato = sol.IdSubcontrato and
                                        sc.IdContrato = @pIdContrato
        inner join  [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = @pUsuarioId and
                                                            ucc.IdCentroCosto in (sol.IdCentroCosto)
        INNER JOIN Petrovendor..CC_CentroCosto cc on cc.IdCentroCosto = sol.IdCentroCosto
        --left join Petrovendor.dbo.MM_Pedido ped on ped.IdPedido = sc.IdPedido
        inner join PV_Subcontratista pv on pv.IdSubcontratista = sc.IdSubcontratista        
        left join Petrovendor.DBO.PV_TipoMoneda mon on mon.idMoneda = sol.IdMoneda
        --left join #tmpOTExcedida exc on exc.IdOTSolicitud = sol.IdOTSolicitud
        left join #tmpEstimacion est on est.IdOTSolicitud = sol.IdOTSolicitud
        where isnull(sol.isActivo,0) = 1 and isnull(sol.isEliminado,0) = 0  
        AND (
            ( @pAprobadas  =1 and sol.IdOTEstatus between 5 and 6 )
            OR 
            ( @pPendientes  =1 and sol.IdOTEstatus in (1,2,3,4,11)  )
            OR 
            ( @pRechazadas  =1 and sol.IdOTEstatus between 7 and 8 )
            
            OR
            (@pRequiereConvenio  =1 and sol.IdOTEstatus between 9 and 9  )
            OR
            (@pCerradas  =1 and sol.IdOTEstatus between 12 and 12  )
            OR 
            @pTodas = 1
        )
        and @pIdSubcontrato in (0,sol.IdSubContrato)   
		and sol.CreadoEl between dateadd(day, -1, @Desde) and dateadd(day, 1, @Hasta)
        group by sol.IdOTSolicitud,
            sol.IdSubContrato,
            Folio,
            sol.FechaInicio,
            sol.FechaFin,
            PlazoEjecucion,
            sol.CreadoPor,
            sol.CreadoEl,
            sol.ModificadoPor,
            sol.ModificadoEl,
            sol.IsActivo,
            sol.IsEliminado,
            sol.IdPresupuesto,
            sol.Objeto,
            IdOTEstatus,
            FechaFinExtendida,
            IdOTEstatusAnt ,
            pre.Nombre,         
        
            mon.TipoMonedaCorto,
             pv.RazonSocial,
             est.IdOTSolicitud,
             --exc.IdOTSolicitud,
             cc.CentroCosto,
             sol.SAPPR
        Order by IdOTSolicitud desc
        
    End


