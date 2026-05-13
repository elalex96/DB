IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_DEL_CO_EliminarRelacionEstados'
    )
    DROP PROCEDURE USP_DEL_CO_EliminarRelacionEstados;
GO
CREATE PROCEDURE [dbo].[USP_DEL_CO_EliminarRelacionEstados]--1,1,10,10007
 @IdUsuario            INT = 0,
    @IdContrato            INT,
	@IdUsuarioSeleccion    INT,
	@IdContratoSeleccion	INT,
    @IdEstadoRegistroUsuario	INT
AS
    BEGIN

     INSERT INTO dbo.AP_Bitacora (
			Fecha
			,Tipo
			,Mensaje
			,Detalle
			,UsuarioId
			,ContratoId
			)
		SELECT DISTINCT
			GETDATE()
			,'Eliminación'
			,'Eliminación de Estado de aprobación de gasto en la página 2/Administrador/AdministracionEstadosGastos.aspx'
			,'IdEstadoRegistroUsuario: ['+CAST(@IdEstadoRegistroUsuario AS VARCHAR(20))+
			'],IdClvEstado:  ['+CAST(CO_EstadoRegistroUsuario.IdClvEstado AS VARCHAR(20))+
			'],Estado:  ['+CAST(CO_EstadoRegistro_V2.NombreEstado AS VARCHAR(20))+
			'],IdUsuario:  ['+CAST(CO_EstadoRegistroUsuario.IdUsuario AS VARCHAR(20))+
			'].' 
			,@IdUsuario
			,@IdContrato
		FROM
			CO_EstadoRegistroUsuario (NOLOCK)
		JOIN
			CO_EstadoRegistro_V2 (NOLOCK)
			ON	CO_EstadoRegistroUsuario.IdClvEstado	=	CO_EstadoRegistro_V2.IdClvEstado
			AND	CO_EstadoRegistro_V2.IdContrato	=	@IdContratoSeleccion
		WHERE
			CO_EstadoRegistroUsuario.IdEstadoRegistroUsuario	=	@IdEstadoRegistroUsuario;
				
    DELETE  CO_EstadoRegistroUsuario  WHERE IdEstadoRegistroUsuario = @IdEstadoRegistroUsuario;
	 

    END