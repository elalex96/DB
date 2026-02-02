IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_CO_RegistraEstadosUsuarios'
    )
    DROP PROCEDURE USP_INS_CO_RegistraEstadosUsuarios;
GO
CREATE PROCEDURE [dbo].[USP_INS_CO_RegistraEstadosUsuarios]
@IdUsuario            INT = 0,
@IdContrato            INT,
@IdUsuarioSeleccion    INT,
@IdContratoSeleccion	INT,
@IdClvEstados CO_Type_IdClvEstados READONLY
AS
BEGIN

	INSERT INTO CO_EstadoRegistroUsuario
	(
	IdClvEstado,
	IdUsuario,
	CreadoPor,
	CreadoEn)
	SELECT 
		IdClvEstado,
		@IdUsuarioSeleccion,
		@IdUsuario,
		GETDATE()
    FROM @IdClvEstados;

	  INSERT INTO dbo.AP_Bitacora (
			Fecha
			,Tipo
			,Mensaje
			,Detalle
			,UsuarioId
			,ContratoId
			)
	SELECT
			GETDATE()
			,'Creación'
			,'Registro de estado de aprobación de gasto a usuario en la página 2/Administrador/AdministracionEstadosGastos.aspx'
			,'IdUsuario:  ['+CAST(@IdUsuarioSeleccion AS VARCHAR(20))+'], IdContrato: [' + CAST(@IdContratoSeleccion AS VARCHAR(20)) + 
			'], IdClvEstado: [' + CONVERT(VARCHAR(19), ClvEstados.IdClvEstado, 120) + 
			'],Estado:  ['+CAST(CO_EstadoRegistro_V2.NombreEstado AS VARCHAR(20))+
			'].'
			,@IdUsuario
			,@IdContrato
			FROM @IdClvEstados AS ClvEstados
			JOIN
			CO_EstadoRegistro_V2 (NOLOCK)
			ON	ClvEstados.IdClvEstado	=	CO_EstadoRegistro_V2.IdClvEstado
			AND	CO_EstadoRegistro_V2.IdContrato	=	@IdContratoSeleccion;

	SELECT * FROM CO_EstadoRegistroUsuario (NOLOCK) WHERE IdUsuario = @IdUsuarioSeleccion;
END;