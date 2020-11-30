-- =============================================
-- Author:		<Pedro Acu�a>
-- Create date: <23-08-2018>
-- Description:	<Se actualiza el correo de invitacion de la recuperacion de la cotizacion>
-- =============================================

CREATE PROCEDURE DG_ModificarCorreoRecuperacion @Correo NVARCHAR(MAX), @IdSolicitudPedido INT , @CorreoAnterior NVARCHAR(MAX),
												/*--------------------parametros contrato  --------------------*/
												@IdContrato INT = NULL, @IdUsuario INT = NULL ,
												@FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN
		IF EXISTS
			(	SELECT	1
				FROM	MM_InvitacionPeticionOferta
				WHERE
						IdSolicitudPedido = @IdSolicitudPedido
						AND Activo = 1
						AND IdProveedorInvitado IS NULL
						AND UPPER ( CorreoInvitacion ) LIKE UPPER ( @CorreoAnterior ))
			BEGIN
				UPDATE	MM_InvitacionPeticionOferta
				SET		CorreoInvitacion = @Correo, FechaActualizacion = GETDATE()
				WHERE
						IdSolicitudPedido = @IdSolicitudPedido
						AND Activo = 1
						AND IdProveedorInvitado IS NULL
						AND UPPER ( CorreoInvitacion ) LIKE UPPER ( @CorreoAnterior )
			END
	END