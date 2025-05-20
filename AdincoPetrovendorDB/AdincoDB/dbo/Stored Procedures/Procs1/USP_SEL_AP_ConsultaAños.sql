IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_AP_ConsultaAños'
    )
    DROP PROCEDURE USP_SEL_AP_ConsultaAños;
GO
CREATE PROCEDURE [dbo].[USP_SEL_AP_ConsultaAños]
@IdContrato INT = 0, 
@IdUsuario  INT = 0
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT DISTINCT Anio FROM AP_CALENDARIO (NOLOCK) WHERE Anio <= YEAR(DATEADD(YEAR,1,GETDATE())) ORDER BY ANIO DESC
     END;
