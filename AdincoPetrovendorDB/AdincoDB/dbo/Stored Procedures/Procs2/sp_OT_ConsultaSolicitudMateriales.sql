USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_OT_ConsultaSolicitudMateriales'
)
    DROP PROCEDURE sp_OT_ConsultaSolicitudMateriales;   
	
GO
/****** Object:  StoredProcedure [dbo].[sp_OT_ConsultaSolicitudMateriales]    Script Date: 10/07/2023 05:31:55 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--***********************************
-- ESTE SP SE ENCUENTRA TANTO EN PETROVENDOR COMO EN ADINCO, PERO TIENEN LOGICA DIFERENTE
--***********************************
-- sp_OT_ConsultaSolicitudMateriales 57,1
CREATE Proc [dbo].[sp_OT_ConsultaSolicitudMateriales]
    @pIdOTSolicitud INT,
    @pTipoUsuario INT = 1 -- 1.Contratista 2.SubContratista
As
BEGIN
SET NOCOUNT ON;
    declare @IdSubcontrato int

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

	select @idSubcontrato = IdSubcontrato
    from OT_Solicitud (NOLOCK)
    where IdOTSolicitud = @pIdOTSolicitud


    insert into #tmpCantidades
    (
        IdSubcontrato,
        IdSCMaterial,
        IdOTSM,
        CantidadSC,
        CantidadOT
    )
    select M.idSubcontrato,
           M.IdSCMaterial,
           SM.IdOTSolicitudMATERIAL,
           CantidadSC = max(M.Cantidad),
           CantidadOT = sum(SM.Cantidad)
    from SC_Materiales M (NOLOCK)
        inner join OT_SolicitudMaterial SM (NOLOCK)
            on M.IdSCMaterial = SM.IdSCMaterial  
        inner join OT_Solicitud S (NOLOCK)
            on SM.IdOTSolicitud = S.IdOTSolicitud
               and S.IdOTEstatus NOT in ( 7, 8, 12 ) --> CTES
               and isnull(S.IsActivo, 0) = 1
    where M.IdSubcontrato = @idSubcontrato
    group by M.idSubcontrato,
             M.IdSCMaterial,
             SM.IdOTSolicitudMATERIAL


    insert into #tmpCantidades
    (
        IdSubcontrato,
        IdSCMaterial,
        IdOTSM,
        CantidadSC,
        CantidadOT
    )
    select M.idSubcontrato,
           M.IdSCMaterial,
           SPC.IdOTSolicitudMATERIAL,
           CantidadSC = max(M.Cantidad),
           CantidadOT = sum(SPC.Captura)
    from SC_Materiales M (NOLOCK)
        inner join OT_SolicitudMaterial SM  (NOLOCK)
            on M.IdSCMaterial = SM.IdSCMaterial 
        inner join OT_Solicitud S (NOLOCK)
            on SM.IdOTSolicitud = S.IdOTSolicitud
               and S.IdOTEstatus = 12
               and isnull(S.IsActivo, 0) = 1
               and S.IsEliminado = 0
        inner join OT_SolicitudProgramaCaptura SPC (NOLOCK)
            on SM.IdOTSolicitudMaterial = SPC.IdOTSolicitudMaterial 
               and SPC.VoBoContratista = 1 
    where M.IdSubcontrato = @idSubcontrato
    group by M.idSubcontrato,
             M.IdSCMaterial,
             SPC.IdOTSolicitudMATERIAL


    insert into #tmpCantidades2
    select IdSubcontrato,
           IdSCMaterial,
           max(CantidadSC),
           sum(CantidadOT)
    from #tmpCantidades
    group by IdSubcontrato,
             IdSCMaterial



    select Id = ROW_NUMBER() OVER (ORDER BY SM.IdOTSolicitudMaterial ASC),
           SM.IdOTSolicitudMaterial,
           SM.IdOTSolicitud,
           M.IdSCMaterial,
           M.Concepto,
           NombreMaterial = M.Descripcion,
           SM.IdServicio,
           M.IdUnidad,
           NombreUnidad = UM.Unidad,
           Cantidad = ISNULL(SM.Cantidad, 0),
           CantidadDisponible = case
                                    when isnull(max(tmp2.CantidadSC), 0) - isnull(max(tmp2.CantidadOT), 0) < 0 then
                                        0
                                    else
                                        isnull(max(tmp2.CantidadSC), 0) - isnull(max(tmp2.CantidadOT), 0)
                                end,
           PrecioUnitario = M.PrecioUnitario,
           Importe = cast(isnull(SM.Cantidad, 0) * isnull(M.PrecioUnitario, 0) as money),
           SM.FechaProgramaInicio,
           SM.FechaProgramaFin,
           SM.CreadoPor,
           SM.CreadoEl,
           SM.ModificadoPor,
           SM.ModificadoEl,
           ModificadaPorContratista = cast(CASE
                                               WHEN SMB.IdOTSolicitudMaterial IS NOT NULL THEN
                                                   1
                                               ELSE
                                                   0
                                           END AS bit),
           Moneda = isnull(TM.TipoMonedaCorto, 'NO DEFINIDO'),
           SM.Comentarios
    from dbo.SC_Materiales M (NOLOCK)
        inner join OT_Solicitud S (NOLOCK)
            on M.IdSubContrato = S.IdSubContrato 
        inner join sc_subcontrato SB (NOLOCK)
            on S.idsubcontrato = SB.idsubcontrato  
        inner join #tmpCantidades2 tmp2 (NOLOCK)
            on M.IdSCMaterial = tmp2.IdSCMaterial 
        left join Petrovendor.dbo.MM_Pedido P (NOLOCK)
            on SB.idPedido = P.IdPedido 
        left join Petrovendor.dbo.PV_TipoMoneda TM (NOLOCK)
            on isnull(P.idMoneda, S.IdMoneda) = TM.idMoneda 
        left JOIN OT_SolicitudMaterial SM (NOLOCK)
            on S.IdOTSolicitud = SM.IdOTSolicitud
               AND M.IdSCMaterial = SM.IdSCMaterial
        left JOIN Petrovendor.dbo.PV_MM_MaterialUnidad UM (NOLOCK)
            ON M.IdUnidad = UM.IdUnidad 
        LEFT JOIN dbo.OT_SolicitudMaterialBitacora  SMB (NOLOCK)
            ON SM.IdOTSolicitudMaterial = SMB.IdOTSolicitudMaterial 
               AND SMB.IdTipoUsuario = 1
    where S.IdOTSolicitud = @pIdOTSolicitud
          AND (
                  (
                      S.IdOTEstatus in ( 5, 6 )
                      AND SM.Cantidad > 0
                      AND @pTipoUsuario = 1
                  )
                  OR (
                         S.IdOTEstatus not in ( 5, 6 )
                         AND @pTipoUsuario = 1
                     )
                  OR @pTipoUsuario = 2
              )
          -- Si se activa la captura manual, solo mostrar items con relación entre contrato y materiales de OT
          AND (
                  isnull(CapturaManual, 0) = 0
                  OR (
                         isnull(CapturaManual, 0) = 1
                         and isnull(SM.Cantidad, 0) > 0
                     )
              )
    group by SM.IdOTSolicitudMaterial,
             SM.IdOTSolicitud,
             M.IdSCMaterial,
             M.Descripcion,
             SM.IdServicio,
             M.IdUnidad,
             SM.Cantidad,
             M.Cantidad,
             M.PrecioUnitario,
             SM.Cantidad,
             M.PrecioUnitario,
             SM.FechaProgramaInicio,
             SM.FechaProgramaFin,
             SM.CreadoPor,
             SM.CreadoEl,
             SM.ModificadoPor,
             SM.ModificadoEl,
             S.IdSubContrato,
             UM.Unidad,
             SMB.IdOTSolicitudMaterial,
             TM.TipoMonedaCorto,
             SM.Comentarios,
             M.Concepto,
             tmp2.IdSCMaterial
    order by SM.Cantidad desc,
             M.Concepto

END