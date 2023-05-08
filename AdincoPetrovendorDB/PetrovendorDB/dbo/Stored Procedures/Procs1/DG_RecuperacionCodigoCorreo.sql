-- =============================================
-- Author:		<Pedro Acu�a>
-- Create date: <23-08-2018>
-- Description:	<Se recupera el codigo de invitacion y el correo que fue utilizado>
-- =============================================

CREATE PROCEDURE DG_RecuperacionCodigoCorreo @IdSolicitudPedido INT ,
														/*--------------------parametros contrato  --------------------*/
													 @IdContrato INT = NULL, @IdUsuario INT = NULL ,
													 @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN
		SELECT	CorreoInvitacion, CodigoActivacion
		FROM	MM_InvitacionPeticionOferta
		WHERE
				IdSolicitudPedido = @IdSolicitudPedido
				AND Activo = 1
				AND IdProveedorInvitado IS NULL
	END