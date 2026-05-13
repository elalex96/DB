IF EXISTS (
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_ConsultaSubContrato'
)
    DROP PROCEDURE [dbo].[sp_SC_ConsultaSubContrato]
GO

CREATE PROCEDURE [dbo].[sp_SC_ConsultaSubContrato]
    @pIdSubContrato INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        sc.IdSubContrato,
        sc.IdSubContratista,
        sc.IdContratista,
        sc.NumeroSubContrato,
        c.NombreContratista,
        NombreSubContratista = pv.RazonSocial,
        FechaRegistro = sc.CreadoEl,
        sc.Objeto,
        IdPedido = ISNULL(sc.IdPedido, 0),
        PrefijoOT = ISNULL(sc.PrefijoOT, ''),
        FolioOTSig = ISNULL(sc.PrefijoOT, '') + '-' + CAST(ISNULL(COUNT(DISTINCT ot.IdOTSolicitud), 0) + 1 AS VARCHAR),
        IdPresupuesto = ISNULL(sp.IdPresupuesto, 0),
        IdProveedor = p.IdProveedor,
        FolioPedido = mp.IdPedido,
        sc.FechaInicio,
        sc.FechaFin,
        sc.IdCentroCosto,
        sc.IdMoneda
    FROM 
        SC_Subcontrato sc WITH (NOLOCK)
    INNER JOIN 
        CO_Contratista c WITH (NOLOCK)
        ON sc.IdContratista = c.IdContratista
        AND sc.IdSubContrato = @pIdSubContrato
    INNER JOIN 
        pv_Subcontratista pv WITH (NOLOCK)
        ON sc.IdSubContratista = pv.IdSubContratista
    LEFT JOIN 
        dbo.SC_Presupuesto sp WITH (NOLOCK)
        ON sc.IdSubContrato = sp.IdSubContrato
    LEFT JOIN 
        dbo.OT_Solicitud ot WITH (NOLOCK)
        ON sc.IdSubContrato = ot.IdSubContrato
    LEFT JOIN 
        Petrovendor.dbo.S_Proveedor p WITH (NOLOCK)
        ON pv.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = p.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
    LEFT JOIN 
        Petrovendor.dbo.MM_Pedidos mp WITH (NOLOCK)
        ON sc.IdPedido = mp.IdIdentificador
    WHERE 
        sc.IdSubContrato = @pIdSubContrato
    GROUP BY 
        sc.IdSubContrato,
        sc.IdSubContratista,
        sc.IdContratista,
        sc.NumeroSubContrato,
        c.NombreContratista,
        pv.RazonSocial,
        sc.CreadoEl,
        sc.Objeto,
        sc.IdPedido,
        sc.PrefijoOT,
        sp.IdPresupuesto,
        p.IdProveedor,
        mp.IdPedido,
        sc.FechaInicio,
        sc.FechaFin,
        sc.IdCentroCosto,
        sc.IdMoneda
END
GO
