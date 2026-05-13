IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ObtenEstadosRelacionados'
    )
    DROP PROCEDURE USP_SEL_CO_ObtenEstadosRelacionados;
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenEstadosRelacionados]--1,1,10,10007
 @IdUsuario            INT = 0,
    @IdContrato            INT,
	@IdUsuarioSeleccion    INT,
	@IdContratoSeleccion	INT
AS
    BEGIN
			SELECT DISTINCT 
				IdEstadoRegistroUsuario,
				CO_EstadoRegistro_V2.NombreEstado,
				CO_EstadoRegistro_V2.Descripcion,
				CO_EstadoRegistroUsuario.CreadoEn,
				ISNULL(AP_Usuario.Nombre,'')  AS	CreadoPor
				FROM 
					CO_EstadoRegistroUsuario (NOLOCK)
				JOIN
					CO_EstadoRegistro_V2(NOLOCK)
					ON CO_EstadoRegistroUsuario.IdClvEstado = CO_EstadoRegistro_V2.IdClvEstado
					AND CO_EstadoRegistro_V2.IdContrato = @IdContratoSeleccion
					AND CO_EstadoRegistroUsuario.IdUsuario = @IdUsuarioSeleccion
				LEFT JOIN
					AP_Usuario (NOLOCK)
					on	CO_EstadoRegistroUsuario.CreadoPor	=	AP_Usuario.UsuarioID
				WHERE 
					IdUsuario = @IdUsuarioSeleccion
				ORDER BY  CO_EstadoRegistro_V2.NombreEstado ASC
	END;
