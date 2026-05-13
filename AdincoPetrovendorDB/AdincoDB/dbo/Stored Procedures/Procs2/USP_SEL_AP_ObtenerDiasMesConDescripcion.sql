IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_AP_ObtenerDiasMesConDescripcion'
)
    DROP PROCEDURE USP_SEL_AP_ObtenerDiasMesConDescripcion;
GO

CREATE PROCEDURE [dbo].[USP_SEL_AP_ObtenerDiasMesConDescripcion]
    @ContratoId INT = 0,
    @UsuarioId INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MesActual DATE = GETDATE();

    CREATE TABLE #FechasBanner
    (
        IdRow INT,
        Anio VARCHAR(10),
        Mes VARCHAR(10),
        Dia VARCHAR(10),
        Descripcion VARCHAR(1500)
    )

    INSERT INTO #FechasBanner
    (
        IdRow,
        Anio,
        Mes,
        Dia,
        Descripcion
    )
    SELECT ROW_NUMBER() OVER (ORDER BY [Dia] ASC) AS IdRow,
           CONVERT(VARCHAR(10), Anio) Anio,
           NombreMes AS Mes,
           CASE
               WHEN Dia < 10 THEN
                   CONCAT('0', CONVERT(VARCHAR(10), Dia))
               ELSE
                   CONVERT(VARCHAR(10), Dia)
           END AS Dia,
           LTRIM(RTRIM(Descripcion)) AS Descripcion
    FROM AP_Calendario (NOLOCK)
    WHERE MONTH(IdFecha) = MONTH(@MesActual)
          AND YEAR(IdFecha) = YEAR(@MesActual)
          AND ISNULL(LTRIM(RTRIM(Descripcion)), '') <> ''   

    SELECT IdRow,
           Anio,
           Mes,
           Dia,
           Descripcion           
    FROM #FechasBanner
	ORDER BY IdRow ASC
END