IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_AP_ObtenTipoReportes'
    )
    DROP PROCEDURE USP_SEL_AP_ObtenTipoReportes;
GO
 CREATE PROCEDURE [dbo].[USP_SEL_AP_ObtenTipoReportes]
 @IdUsuario            INT = 0,
    @IdContrato            INT,
    @Id	INT = 0         
AS
    BEGIN
    
			SELECT DISTINCT 
                Id,  
                NombreReporte,    
                Activo 
                FROM    
                    AP_TipoReportesSistema
                    WHERE Activo = 1 -- SOLO ACTIVOS
            UNION ALL
            SELECT  
                Id,  
                NombreReporte,    
                Activo 
                FROM    
                    AP_TipoReportesSistema
                    WHERE Activo = 0 AND Id = @Id -- SI ES EDICION EN UN REPORTE DESACTIVADO
				ORDER BY  AP_TipoReportesSistema.NombreReporte ASC
	END;
