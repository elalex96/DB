IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ObtenSecuenciaEstados'
    )
    DROP PROCEDURE USP_SEL_CO_ObtenSecuenciaEstados;
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenSecuenciaEstados]--1,1,10007
	@IdUsuario            INT = 0,
    @IdContrato            INT,
	@IdContratoSeleccion	INT

AS
    BEGIN

SELECT DISTINCT
				CO_EstadoRegistroTransicion.IdEstadoRegistroTransicion AS IdTransicion,
                CO_EstadoRegistroTransicion.IdEstadoOrigen AS IdEstadoActual,
                CO_EstadoRegistroTransicion.IdEstadoDestino AS IdEstadoSiguiente,
                Actual.NombreEstado AS NombreEstadoActual,
                Siguiente.NombreEstado AS NombreEstadoSiguiente,
                CO_EstadoRegistroTransicion.Descripcion AS NombreCambioEstado,
                CO_EstadoRegistroTransicion.CreadoEn,
                AP_Usuario.Usuario AS CreadoPor 
				FROM 
					CO_EstadoRegistroTransicion (NOLOCK)
				JOIN
					CO_EstadoRegistro_V2 AS Actual (NOLOCK)
					ON CO_EstadoRegistroTransicion.IdEstadoOrigen = Actual.IdClvEstado
                    AND Actual.IdContrato   =   @IdContratoSeleccion
				JOIN
					CO_EstadoRegistro_V2 AS Siguiente (NOLOCK)
					ON CO_EstadoRegistroTransicion.IdEstadoDestino = Siguiente.IdClvEstado
                    AND Siguiente.IdContrato   =   @IdContratoSeleccion
				LEFT JOIN
					AP_Usuario  (NOLOCK)
					ON	CO_EstadoRegistroTransicion.CreadoPor	=	AP_Usuario.UsuarioId;
	END;
