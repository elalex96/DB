IF OBJECT_ID('[dbo].[p_SC_Materiales_Grd]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[p_SC_Materiales_Grd]
GO

CREATE PROCEDURE [dbo].[p_SC_Materiales_Grd]
(
    @pIdSubContrato INT
)
AS
BEGIN
    SELECT
        m.IdSCMaterial,
        m.IdSubContrato,
        m.Concepto,
        m.IdMaestro,
        m.IdUnidad,
        mu.Unidad,
        m.Cantidad,
        m.PrecioUnitario,
        m.Importe,
        m.Descripcion,
        m.DescripcionCorta,
        m.IdServicio
    FROM
        SC_Materiales (NOLOCK) m
    INNER JOIN
        Petrovendor..PV_MM_MaterialUnidad (NOLOCK) mu
        ON mu.IdUnidad = m.IdUnidad
    WHERE
        m.IdSubContrato = @pIdSubContrato
END
