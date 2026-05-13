IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_AA_ObtenTipoReporte'
)
    DROP PROCEDURE USP_SEL_AA_ObtenTipoReporte;
GO

CREATE PROCEDURE [dbo].[USP_SEL_AA_ObtenTipoReporte]
    @ContratoId INT,
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT IdTipoReporte,
           LTRIM(RTRIM(ISNULL(NombreReporte, ''))) AS TipoReporte
    FROM AA_TipoReporte (NOLOCK)
    ORDER BY NombreReporte ASC;
END;