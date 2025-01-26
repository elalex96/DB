IF OBJECT_ID('[dbo].[p_SC_Subcontrato_Cmb]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[p_SC_Subcontrato_Cmb]
GO

CREATE PROCEDURE [dbo].[p_SC_Subcontrato_Cmb]
AS
BEGIN
    SELECT 
        IdSubcontratista,
        RFC,
        RazonSocial,
        NombreComercial
    FROM 
        Adinco..PV_Subcontratista (NOLOCK)
    WHERE 
        IsActivo = 1
END
