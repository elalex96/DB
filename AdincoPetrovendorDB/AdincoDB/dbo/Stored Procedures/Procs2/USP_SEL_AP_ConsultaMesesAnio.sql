IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_AP_ConsultaMesesAnio'
)
    DROP PROCEDURE USP_SEL_AP_ConsultaMesesAnio;
GO

CREATE PROCEDURE [dbo].[USP_SEL_AP_ConsultaMesesAnio]
    @ContratoId INT,
    @UsuarioId INT
AS
BEGIN
    -- 
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    DECLARE @FechaEfectiva AS DATE;

    SELECT TOP 1
        @FechaEfectiva = IdFecha
    FROM AP_Calendario (NOLOCK)
    ORDER BY IdFecha ASC;

    SELECT CAST(AP_Calendario.IdFecha AS DATE) AS IdFecha,
           CONCAT(datename(month, AP_Calendario.IdFecha), ' ', YEAR(AP_Calendario.IdFecha)) AS Fecha,
		   CONVERT( VARCHAR(50),CAST(AP_Calendario.IdFecha AS DATE)) AS FechaTexto
    FROM AP_Calendario (NOLOCK)
    WHERE AP_Calendario.Dia = 1
          AND AP_Calendario.IdFecha
          BETWEEN DATEADD(month, -1, @FechaEfectiva) AND CURRENT_TIMESTAMP
    ORDER BY AP_Calendario.IdFecha DESC;
END;