--=======================================
-- Modificador: Neri del Angel
-- Fecha: 13 de Septiembre del 2022
-- Detalle: Se ajusta orden de joins y en los ON de los joins, 
-- se agrega el create de la tabla temporal #tmpInfoPrograma
--=======================================
CREATE Proc [dbo].[p_OT_ObtenerEstimacion]
    @pIdOTSolicitud int,
    @pIdOTEstimacion int,
    @pFechaInicioEstimacion datetime = null,
    @pFechaFinEstimacion datetime = null
as
declare @consecutivo int,
        @fechaIniCorte DateTime

CREATE TABLE #tmpInfoPrograma
(
    IdOTSolicitud INT,
    IdSCMaterial INT,
    Concepto VARCHAR(5000),
    Descripcion VARCHAR(5000),
    Unidad VARCHAR(500),
    Cantidad DECIMAL(14, 5),
    PrecioUnitario MONEY,
    Importe MONEY,
    FechaInicioSubcontratista DATETIME,
    FechaFinSubcontratista DATETIME,
    IdOTSolicitudMaterial INT
)

INSERT INTO #tmpInfoPrograma
(
    IdOTSolicitud,
    IdSCMaterial,
    Concepto,
    Descripcion,
    Unidad,
    Cantidad,
    PrecioUnitario,
    Importe,
    FechaInicioSubcontratista,
    FechaFinSubcontratista,
    IdOTSolicitudMaterial
)
select om.IdOTSolicitud,
       scm.IdSCMaterial,
       CAST(scm.COncepto AS VARCHAR(5000)),
       CAST(scm.Descripcion AS VARCHAR(5000)),
       CAST(U.Unidad AS VARCHAR(500)),
       Cantidad = sum(spc.Captura),
       PrecioUnitario = scm.PrecioUnitario,
       Importe = isnull(sum(spc.Captura), 0) * isnull(scm.PrecioUnitario, 0),
       FechaInicioSubcontratista = Min(spc.Fecha),
       FechaFinSubcontratista = Max(spc.Fecha),
       om.IdOTSolicitudMaterial
from [dbo].[OT_SolicitudProgramaCaptura] spc (NOLOCK)
    inner join OT_SolicitudMaterial om (NOLOCK)
        on spc.IdOTSolicitudMaterial = om.IdOTSolicitudMaterial
    inner join SC_Materiales scm (NOLOCK)
        on om.IdSCMaterial = scm.IdSCMaterial
    inner join Petrovendor.dbo.[PV_MM_MaterialUnidad] u (NOLOCK)
        on scm.IdUnidad = u.IdUnidad
where om.IdOTSolicitud = @pIdOTSolicitud
      and VoBoContratista = 1
      and VoBoSubcontratista = 1
      and (
              convert(varchar, spc.Fecha, 112)
      between convert(varchar, @pFechaInicioEstimacion, 112) and convert(varchar, @pFechaFinEstimacion, 112)
              Or (
                     @pFechaInicioEstimacion is null
                     and @pFechaFinEstimacion is null
                 )
          )
group by om.IdOTSolicitud,
         scm.IdSCMaterial,
         scm.COncepto,
         scm.Descripcion,
         U.Unidad,
         scm.PrecioUnitario,
         om.IdOTSolicitudMaterial


if (isnull(@pIdOTEstimacion, 0) > 0)
begin
    select *
    from vwOTEstimacion (NOLOCK)
    where IdOTEstimacion = @pIdOTEstimacion
end
Else
begin

    select @consecutivo = isnull(max(Consecutivo), 0) + 1
    from OT_Estimacion (NOLOCK)
    where IdOTSolicitud = @pIdOTSolicitud

    select @fechaIniCorte = dateadd(dd, 1, max(FechaCorteFin))
    from OT_Estimacion (NOLOCK)
    where IdOTSolicitud = @pIdOTSolicitud
          and isnull(cancelada, 0) = 0

    if (@fechaIniCorte is null)
    begin

        select @fechaIniCorte = min(Fecha)
        from [dbo].[OT_SolicitudProgramaCaptura] spc (NOLOCK)
            inner join [dbo].OT_SolicitudMaterial sp (NOLOCK)
                on spc.IdOTSolicitudMaterial = sp.IdOTSolicitudMaterial
        where sp.IdOTSolicitud = @pIdOTSolicitud
    end

    select ot.IdOTSolicitud,
           IdOTEstimacion = 0,
           FolioEstimacion = ot.Folio + '-E' + cast(@consecutivo as varchar),
           Consecutivo = 0,
           FolioOT = ot.Folio,
           FolioSC = sc.NumeroSubContrato,
           FechaIniCorte = @fechaIniCorte,
           FechaFinCorte = @fechaIniCorte,
           Instalacion = max(isnull(ins.NombreInstalacion, 'INDEFINIDA')),
           Actividad = isnull(ACT.NombreActividad, 'INDEFINIDA'),
           Presupuesto = pre.Nombre,
           Subcontratista = subc.RazonSocial,
           AreaContractual = cont.NombreContratista,
           AceptaOperador = cont.Representante,
           AceptaSubcontratista = subc.RepresentanteLegal,
           tmp.IdSCMaterial,
           tmp.COncepto,
           tmp.Descripcion,
           tmp.Unidad,
           tmp.Cantidad,
           tmp.PrecioUnitario,
           tmp.Importe,
           tmp.IdOTSolicitudMaterial,
           Moneda = isnull(mon.TipoMonedaCorto, ''),
           IdMoneda = ot.IdMOneda
    from OT_Solicitud ot (NOLOCK)
        inner join SC_Subcontrato sc (NOLOCK)
            on ot.IdOTSolicitud = @pIdOTSolicitud
               and ot.IdSubContrato = sc.IdSubcontrato
        INNER JOIN PV_Subcontratista subc (NOLOCK)
            on sc.IdSubContratista = subc.IdSubcontratista
        inner join OT_LineaPresupuesto OTlp (NOLOCK)
            on ot.IdOTSolicitud = OTlp.IdOTSolicitud
        inner join CO_LineaPresupuestoMes lp (NOLOCK)
            on OTlp.IdLineaPresupuestoMes = lp.[IdLineaPresupuestoMes]
        inner join CO_Presupuesto pre (NOLOCK)
            on lp.IdPresupuesto = pre.IdPresupuesto
        inner join [dbo].[CO_Contratista] cont (NOLOCK)
            on sc.IdContratista = cont.IdContratista
        inner join #tmpInfoPrograma tmp 
            on ot.IdOTSolicitud = tmp.IdOTSolicitud
        left join Petrovendor.dbo.MM_Pedido ped (NOLOCK)
            on sc.IdPedido = ped.IdPedido
        left JOIN Petrovendor.dbo.PV_TipoMoneda mon (NOLOCK)
            on ot.IdMOneda = mon.idMoneda
        left join OT_SolicitudInstalacion OTins (NOLOCK)
            on ot.IdOTSolicitud = OTins.idOTSolicitud
        left join CO_Instalacion ins (NOLOCK)
            on OTins.IdInstalacion = ins.IdInstalacion
        left join CO_ActividadCIEP act (NOLOCK)
            on ins.IdActividad = act.IdActividad
    where ot.IdOTSolicitud = @pIdOTSolicitud
    group by ot.IdOTSolicitud,
             ot.Folio,
             sc.NumeroSubContrato,
             ACT.NombreActividad,
             pre.Nombre,
             subc.RazonSocial,
             cont.NombreContratista,
             cont.Representante,
             subc.RepresentanteLegal,
             tmp.IdSCMaterial,
             tmp.COncepto,
             tmp.Descripcion,
             tmp.Unidad,
             tmp.Cantidad,
             tmp.PrecioUnitario,
             tmp.Importe,
             tmp.IdOTSolicitudMaterial,
             mon.TipoMonedaCorto,
             ot.IdMOneda
End