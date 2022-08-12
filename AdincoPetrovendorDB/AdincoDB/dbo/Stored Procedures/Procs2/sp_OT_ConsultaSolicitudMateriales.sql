--***********************************
-- ESTE SP SE ENCUENTRA TANTO EN PETROVENDOR COMO EN ADINCO, PERO TIENEN LOGICA DIFERENTE
--***********************************
-- sp_OT_ConsultaSolicitudMateriales 57,1
CREATE Proc [dbo].[sp_OT_ConsultaSolicitudMateriales]
    @pIdOTSolicitud INT,
    @pTipoUsuario INT = 1 -- 1.Contratista 2.SubContratista
As
BEGIN
    declare @IdSubcontrato int



    select @idSubcontrato = IdSubcontrato
    from OT_Solicitud
    where IdOTSolicitud = @pIdOTSolicitud


    create table #tmpCantidades
    (
        IdSubcontrato int,
        IdSCMaterial int,
        IdOTSM int,
        CantidadSC float,
        CantidadOT float
    )
    create table #tmpCantidades2
    (
        IdSubcontrato int,
        IdSCMaterial int,
        --IdOTSM int,
        CantidadSC float,
        CantidadOT float
    )

    insert into #tmpCantidades
    (
        IdSubcontrato,
        IdSCMaterial,
        IdOTSM,
        CantidadSC,
        CantidadOT
    )
    select SC_Materiales.idSubcontrato,
           SC_Materiales.IdSCMaterial,
           OT_SolicitudMaterial.IdOTSolicitudMATERIAL,
           CantidadSC = max(SC_Materiales.Cantidad),
           CantidadOT = sum(OT_SolicitudMaterial.Cantidad)
    from SC_Materiales (NOLOCK)
        inner join OT_SolicitudMaterial (NOLOCK)
            on OT_SolicitudMaterial.IdSCMaterial = SC_Materiales.IdSCMaterial
        inner join OT_Solicitud (NOLOCK)
            on OT_Solicitud.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
               and OT_Solicitud.IdOTEstatus NOT in ( 7, 8, 12 )
               and isnull(OT_Solicitud.IsActivo, 0) = 1
    where SC_Materiales.IdSubcontrato = @idSubcontrato
    group by SC_Materiales.idSubcontrato,
             SC_Materiales.IdSCMaterial,
             OT_SolicitudMaterial.IdOTSolicitudMATERIAL


    insert into #tmpCantidades
    (
        IdSubcontrato,
        IdSCMaterial,
        IdOTSM,
        CantidadSC,
        CantidadOT
    )
    select SC_Materiales.idSubcontrato,
           SC_Materiales.IdSCMaterial,
           OT_SolicitudProgramaCaptura.IdOTSolicitudMATERIAL,
           CantidadSC = max(SC_Materiales.Cantidad),
           CantidadOT = sum(OT_SolicitudProgramaCaptura.Captura)
    from SC_Materiales (NOLOCK)
        inner join OT_SolicitudMaterial (NOLOCK)
            on OT_SolicitudMaterial.IdSCMaterial = SC_Materiales.IdSCMaterial
        inner join OT_Solicitud (NOLOCK)
            on OT_Solicitud.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
               and OT_Solicitud.IdOTEstatus = 12
               and isnull(OT_Solicitud.IsActivo, 0) = 1
               and OT_Solicitud.IsEliminado = 0
        inner join OT_SolicitudProgramaCaptura (NOLOCK)
            on OT_SolicitudProgramaCaptura.VoBoContratista = 1
               and OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial
    where SC_Materiales.IdSubcontrato = @idSubcontrato
    group by SC_Materiales.idSubcontrato,
             SC_Materiales.IdSCMaterial,
             OT_SolicitudProgramaCaptura.IdOTSolicitudMATERIAL


    insert into #tmpCantidades2
    select IdSubcontrato,
           IdSCMaterial,
           max(CantidadSC),
           sum(CantidadOT)
    from #tmpCantidades
    group by IdSubcontrato,
             IdSCMaterial



    select Id = ROW_NUMBER() OVER (ORDER BY OT_SolicitudMaterial.IdOTSolicitudMaterial ASC),
           OT_SolicitudMaterial.IdOTSolicitudMaterial,
           OT_SolicitudMaterial.IdOTSolicitud,
           SC_Materiales.IdSCMaterial,
           SC_Materiales.Concepto,
           NombreMaterial = SC_Materiales.Descripcion,
           OT_SolicitudMaterial.IdServicio,
           SC_Materiales.IdUnidad,
           NombreUnidad = PV_MM_MaterialUnidad.Unidad,
           Cantidad = ISNULL(OT_SolicitudMaterial.Cantidad, 0),
           CantidadDisponible = case
                                    when isnull(max(tmp2.CantidadSC), 0) - isnull(max(tmp2.CantidadOT), 0) < 0 then
                                        0
                                    else
                                        isnull(max(tmp2.CantidadSC), 0) - isnull(max(tmp2.CantidadOT), 0)
                                end,
           PrecioUnitario = SC_Materiales.PrecioUnitario,
           Importe = cast(isnull(OT_SolicitudMaterial.Cantidad, 0) * isnull(SC_Materiales.PrecioUnitario, 0) as money),
           OT_SolicitudMaterial.FechaProgramaInicio,
           OT_SolicitudMaterial.FechaProgramaFin,
           OT_SolicitudMaterial.CreadoPor,
           OT_SolicitudMaterial.CreadoEl,
           OT_SolicitudMaterial.ModificadoPor,
           OT_SolicitudMaterial.ModificadoEl,
           ModificadaPorContratista = cast(CASE
                                               WHEN OT_SolicitudMaterialBitacora.IdOTSolicitudMaterial IS NOT NULL THEN
                                                   1
                                               ELSE
                                                   0
                                           END AS bit),
           Moneda = isnull(PV_TipoMoneda.TipoMonedaCorto, 'NO DEFINIDO'),
           OT_SolicitudMaterial.Comentarios
    from dbo.SC_Materiales (NOLOCK)
        --inner join petrovendor..MM_Material 				(NOLOCK) on MM_Material.IdMaterial = SC_Materiales.IdMaestro
        inner join OT_Solicitud (NOLOCK)
            on OT_Solicitud.IdSubContrato = SC_Materiales.IdSubContrato
        inner join sc_subcontrato (NOLOCK)
            on sc_subcontrato.idsubcontrato = OT_Solicitud.idsubcontrato
        inner join #tmpCantidades2 tmp2 (NOLOCK)
            on tmp2.IdSCMaterial = SC_Materiales.IdSCMaterial
        left join Petrovendor.dbo.MM_Pedido (NOLOCK)
            on MM_Pedido.IdPedido = sc_subcontrato.idPedido
        left join Petrovendor.dbo.PV_TipoMoneda (NOLOCK)
            on PV_TipoMoneda.idMoneda = isnull(MM_Pedido.idMoneda, OT_Solicitud.IdMoneda)
        left JOIN OT_SolicitudMaterial (NOLOCK)
            on OT_Solicitud.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
               AND OT_SolicitudMaterial.IdSCMaterial = SC_Materiales.IdSCMaterial
        left JOIN Petrovendor.dbo.PV_MM_MaterialUnidad (NOLOCK)
            ON PV_MM_MaterialUnidad.IdUnidad = SC_Materiales.IdUnidad
        LEFT JOIN dbo.OT_SolicitudMaterialBitacora (NOLOCK)
            ON OT_SolicitudMaterialBitacora.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial
               AND OT_SolicitudMaterialBitacora.IdTipoUsuario = 1
    where OT_Solicitud.IdOTSolicitud = @pIdOTSolicitud
          AND (
                  (
                      OT_Solicitud.IdOTEstatus in ( 5, 6 )
                      AND OT_SolicitudMaterial.Cantidad > 0
                      AND @pTipoUsuario = 1
                  )
                  OR (
                         OT_Solicitud.IdOTEstatus not in ( 5, 6 )
                         AND @pTipoUsuario = 1
                     )
                  OR @pTipoUsuario = 2
              )
          -- Si se activa la captura manual, solo mostrar items con relación entre contrato y materiales de OT
          AND (
                  isnull(CapturaManual, 0) = 0
                  OR (
                         isnull(CapturaManual, 0) = 1
                         and isnull(OT_SolicitudMaterial.Cantidad, 0) > 0
                     )
              )
    group by OT_SolicitudMaterial.IdOTSolicitudMaterial,
             OT_SolicitudMaterial.IdOTSolicitud,
             SC_Materiales.IdSCMaterial,
             SC_Materiales.Descripcion,
             OT_SolicitudMaterial.IdServicio,
             SC_Materiales.IdUnidad,
             OT_SolicitudMaterial.Cantidad,
             SC_Materiales.Cantidad,
             SC_Materiales.PrecioUnitario,
             OT_SolicitudMaterial.Cantidad,
             SC_Materiales.PrecioUnitario,
             OT_SolicitudMaterial.FechaProgramaInicio,
             OT_SolicitudMaterial.FechaProgramaFin,
             OT_SolicitudMaterial.CreadoPor,
             OT_SolicitudMaterial.CreadoEl,
             OT_SolicitudMaterial.ModificadoPor,
             OT_SolicitudMaterial.ModificadoEl,
             OT_Solicitud.IdSubContrato,
             PV_MM_MaterialUnidad.Unidad,
             OT_SolicitudMaterialBitacora.IdOTSolicitudMaterial,
             PV_TipoMoneda.TipoMonedaCorto,
             OT_SolicitudMaterial.Comentarios,
             SC_Materiales.Concepto,
             tmp2.IdSCMaterial
    order by OT_SolicitudMaterial.Cantidad desc,
             SC_Materiales.Concepto

END


