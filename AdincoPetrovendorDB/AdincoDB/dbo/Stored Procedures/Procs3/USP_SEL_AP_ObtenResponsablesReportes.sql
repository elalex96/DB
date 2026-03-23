IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_AP_ObtenResponsablesReportes'
    )
    DROP PROCEDURE USP_SEL_AP_ObtenResponsablesReportes;
GO
CREATE PROCEDURE [dbo].[USP_SEL_AP_ObtenResponsablesReportes]--1,2,10007
	@IdUsuario            INT = 0,
    @IdContrato            INT,
	@IdContratoSeleccion	INT

AS
    BEGIN


SELECT DISTINCT
				AP_ResponsablesReportes.Id AS Id,
                AP_ResponsablesReportes.TipoReporteId AS TipoReporteId,
                AP_TipoReportesSistema.NombreReporte AS TipoReporte,
                AP_ResponsablesReportes.Tipo,
                AP_ResponsablesReportes.NombrePersona,
                AP_ResponsablesReportes.FichaPersona,
                AP_ResponsablesReportes.PuestoPersona,
                AP_ResponsablesReportes.Activo,
                AP_ResponsablesReportes.CreadoEn,
                AP_Usuario.Usuario AS CreadoPor 
				FROM 
				    AP_ResponsablesReportes (NOLOCK)
                JOIN
                    AP_TipoReportesSistema (NOLOCK)
                    ON  AP_ResponsablesReportes.TipoReporteId   =  AP_TipoReportesSistema.Id 
                    AND AP_ResponsablesReportes.ContratoId   =   @IdContratoSeleccion
				LEFT JOIN
					AP_Usuario  (NOLOCK)
					ON	AP_ResponsablesReportes.CreadoPor	=	AP_Usuario.UsuarioId
                 WHERE  AP_ResponsablesReportes.ContratoId   =   @IdContratoSeleccion;
	END;

