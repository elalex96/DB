DROP PROCEDURE IF EXISTS dbo.USP_SEL_ADM_Preferencias;
GO
CREATE PROCEDURE dbo.USP_SEL_ADM_Preferencias
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.Id,
        p.Nombre,
        p.EsDeContratista,
        p.Descripcion,
        p.RequiereValor,
        u.Nombre AS CreadoPor,
        p.CreadoEl,
        um.Nombre AS ModificadoPor,
        p.ModificadoEl
    FROM dbo.APP_PREFERENCIAS AS p WITH (NOLOCK)
	LEFT JOIN AP_Usuario u
		ON p.CreadoPor = u.UsuarioID
	LEFT JOIN AP_Usuario um
		ON p.ModificadoPor = um.UsuarioID
    ORDER BY p.Nombre ASC;
END
GO

