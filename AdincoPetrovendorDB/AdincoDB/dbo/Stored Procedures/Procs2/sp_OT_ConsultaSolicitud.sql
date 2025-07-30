IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'sp_OT_ConsultaSolicitud'
    )
    DROP PROCEDURE sp_OT_ConsultaSolicitud;
GO
CREATE PROCEDURE [dbo].[sp_OT_ConsultaSolicitud] 
	@pIdOTSolicitud int
AS
    BEGIN
        SELECT
            sol.IdOTSolicitud,
            sol.IdSubContrato,
            sc.NumeroSubContrato,
            NombreContratista          = c.NombreContratista,
            NombreSubContratista       = psc.RazonSocial,
            sol.IdPresupuesto,
            FolioOT                    = sol.Folio,
            sol.FechaInicio,
            sol.FechaFin,
            sol.PlazoEjecucion,
            sol.CreadoPor,
            sol.CreadoEl,
            sol.ModificadoPor,
            sol.ModificadoEl,
            sol.IsActivo,
            sol.IsEliminado,
            Objeto                     = ISNULL(sol.Objeto, ''),
            Estatus                    = est.Descripcion,
            est.IdOTEstatus,
            PSC.IdSubcontratista,
            sc.IdContratista,
            FechaFinExtendida,
            ProgarmaInicialPorOperador = CAST(ISNULL(   CASE
                                                            WHEN sol.ProgIniPorProveedor = 1
                                                                THEN 0
                                                            ELSE
                                                                1
                                                        END, 0
                                                    ) AS BIT),
            Moneda                     = ISNULL([TipoMoneda], 'NO DEFINIDO'),
            sol.IdCentroCosto,
            CentroCosto                = CentroCosto,
            sol.CapturaManual,
            SAPPR                      = ISNULL(sol.SAPPR, ''),
            sol.IdTerminos,
            t.Documento,
            PermitirAprobarProv        = ISNULL(conf.PermitirAprobarSubcontratista, 0),
            Decimales                  = ISNULL(conf.Decimales, 0)
        FROM
            OT_Solicitud                                  sol (NOLOCK)
            JOIN
                SC_SubContrato                            sc (NOLOCK)
                    on sol.IdSubContrato	=	sc.idSubContrato
                       AND sol.IdOTSolicitud = @pIdOTSolicitud
            JOIN
                Petrovendor..CC_CentroCosto               cc (NOLOCK)
                    on	 sol.IdCentroCosto	=	cc.IdCentroCosto
            JOIN
                CO_Contratista                            c (NOLOCK)
                    on sc.IdContratista = c.idContratista
            JOIN
                PV_Subcontratista                         psc (NOLOCK)
                    on sc.IdSubcontratista = psc.IdSubcontratista
            JOIN
                OT_Estatus                                est (NOLOCK)
                    ON sol.IdOTEstatus = est.IdOTEstatus
            LEFT JOIN
                Petrovendor.dbo.MM_Pedido                 ped (NOLOCK)
                    on sc.idPedido = ped.IdPedido
            LEFT JOIN
                Petrovendor.dbo.[PV_TipoMoneda]           mon (NOLOCK)
                    on sc.idMoneda = mon.IdMOneda
            LEFT JOIN
                OT_Configurador                           conf (NOLOCK)
                    on sc.IdContratista = conf.IdContratista
                       and sc.IdContrato = conf.IdContrato
            LEFT JOIN
                PEtrovendor..TC_TerminosYCondicionesDocV2 t (NOLOCK)
                    on sol.IdTerminos = t.IdTerminosYCondiciones
        WHERE
            sol.IdOTSolicitud = @pIdOTSolicitud;

    END

