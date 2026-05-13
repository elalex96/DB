USE Petrovendor;
-- =============================================
-- Autor: Alexander Gomez
-- Fecha: 2026-05-07
-- Descripción: Retorna el último acceso registrado de un usuario
--              (el registro anterior al acceso en curso).
--              Se consulta ANTES de llamar a sp_InsLogPantalla
--              para que devuelva el acceso previo, no el actual.
-- Retorna: NombrePantalla, FechaAcceso
-- =============================================
IF OBJECT_ID('dbo.USP_SEL_AD_ConsUltimoLogPantalla', 'P') IS NOT NULL
    DROP PROCEDURE dbo.USP_SEL_AD_ConsUltimoLogPantalla;
GO

CREATE PROCEDURE dbo.USP_SEL_AD_ConsUltimoLogPantalla
    @IdUsuario   INT,
    @IdProveedor INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        NombrePantalla,
        Fecha
    FROM dbo.AP_LogPantalla (NOLOCK)
    WHERE IdUsuario   = @IdUsuario
    ORDER BY Fecha DESC;
END
GO
