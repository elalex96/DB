IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ObtenBitacoraSecuenciaEstados'
    )
    DROP PROCEDURE USP_SEL_CO_ObtenBitacoraSecuenciaEstados;
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenBitacoraSecuenciaEstados]
	@IdUsuario            INT = 0,
    @IdContrato            INT

AS
    BEGIN

                SELECT 
                DISTINCT
				AP_Bitacora.Id,
                AP_Bitacora.Fecha,
                AP_Bitacora.Tipo,
                AP_Bitacora.Mensaje,
                AP_Bitacora.Detalle,
                AP_Bitacora.UsuarioId,
                AP_Bitacora.ContratoId,
                AP_Usuario.Usuario AS CreadoPor ,
                concat(Co_Contrato.NumeroContrato,' - ',CO_AreaContractual.NombreAreaContractual) AS Contrato
				FROM 
					AP_Bitacora  (NOLOCK)
                 JOIN
					AP_Usuario  (NOLOCK)
					ON	AP_Bitacora.UsuarioId	=	AP_Usuario.UsuarioId
                 JOIN
					Co_Contrato  (NOLOCK)
					ON	AP_Bitacora.ContratoId	=	Co_Contrato.IdContrato
                  JOIN
				    CO_AreaContractual(NOLOCK)
					ON	Co_Contrato.IdAreaContractual	=	CO_AreaContractual.IdAreaContractual
                WHERE 
                    Mensaje IN ('Eliminación CO_EstadoRegistroTransicion',  'Registro CO_EstadoRegistroTransicion', 'Edición CO_EstadoRegistroTransicion')
                    ORDER BY 	AP_Bitacora.Id DESC
	END;
