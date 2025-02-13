IF EXISTS (
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_PV_TipoMoneda_cmb'
)
    DROP PROCEDURE [dbo].[sp_PV_TipoMoneda_cmb]
GO

CREATE PROCEDURE [dbo].[sp_PV_TipoMoneda_cmb]
AS
BEGIN
    SELECT
        tm.IdMoneda,
        tm.TipoMoneda,
        tm.TipoMonedaCorto
    FROM
        PV_TipoMoneda tm WITH (NOLOCK);
END
