IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_SC_Material_Bitacora_Grd'
)
    DROP PROCEDURE p_SC_Material_Bitacora_Grd
GO

CREATE PROCEDURE [dbo].[p_SC_Material_Bitacora_Grd]
    @pIdSubcontrato INT
AS
BEGIN
    SELECT
        m.Concepto,
        m.Descripcion,
        mb.CantidadRespaldo,
        mb.PrecioUnitario,
        FechaModificacion = mb.FechaRespaldo,
        ModificadoPor = ISNULL(u.Nombre, '')
    FROM
        SC_MaterialesBitacora (NOLOCK) mb
    INNER JOIN 
        SC_Materiales (NOLOCK) m 
        ON mb.IdSCMaterial = m.IdSCMaterial
        AND m.IdSubcontrato = @pIdSubcontrato 
    LEFT JOIN 
        AP_Usuario (NOLOCK) u 
        ON mb.ModificadoPor = u.UsuarioId
    WHERE 
        m.IdSubcontrato = @pIdSubcontrato
    ORDER BY 
        mb.FechaRespaldo DESC
END
