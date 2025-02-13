IF OBJECT_ID('[dbo].[p_SC_Subcontrato_Grd]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[p_SC_Subcontrato_Grd]
GO

CREATE PROCEDURE [dbo].[p_SC_Subcontrato_Grd]
(
    @pIdContratista INT
)
AS
BEGIN
    SELECT      t1.IdSubContrato,
                t1.IdSubContratista,
                SubContratista = ISNULL(t2.RazonSocial, t2.RFC),
                t1.IdContratista,
                t1.NumeroSubContrato,
                t1.Objeto,
                t1.IdPedido,
                t1.PrefijoOT,
                t1.IdMoneda,
                TipoMoneda = m.TipoMonedaCorto,
                t1.IdContrato,
                IdCC = ISNULL(t1.IdCentroCosto, 0),
                cc.CentroCosto,
                t1.FechaInicio,
                t1.FechaFin
    FROM        SC_Subcontrato (NOLOCK) t1
    INNER JOIN  Adinco..PV_Subcontratista (NOLOCK) t2
    ON          t1.IdSubContratista = t2.IdSubContratista
    LEFT JOIN   Petrovendor..PV_TipoMoneda (NOLOCK) m
    ON          t1.IdMoneda = m.IdMoneda
    LEFT JOIN   Petrovendor..Cc_centrocosto (NOLOCK) cc
    ON          cc.IdCentroCosto = t1.IdCentroCosto
    WHERE       t1.IdContratista = @pIdContratista
    AND         ISNULL(t1.IsEliminado, 0) = 0
    ORDER BY    t1.IdSubContrato DESC
END
