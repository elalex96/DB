USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_ActualizarObjetoPedidoSolped]    Script Date: 10/08/2021 01:30:11 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Creacion: Alexander Gomez
-- Update date: 10/08/2021
-- Description:	actualizacion del campos solicitante
-- =============================================
-- Creacion: Luis David
-- Update date: 27/09/2021
-- Description:	Se agrega la validación del solicitante null para la comparación del solicitante nuevo vs anterior
-- =============================================
DROP PROCEDURE IF EXISTS SP_ActualizarSolicitanteSolped
GO
CREATE PROCEDURE [dbo].[SP_ActualizarSolicitanteSolped]
    @IdSolicitudPedido INT,
    @IdSolicitnate INT,
    @IdUsuario INT
AS
BEGIN


    DECLARE @SolicitanteAnterior NVARCHAR(MAX) = (SELECT TOP 1
														US.Nombre
													FROM S_Usuario AS US
													JOIN MM_SolicitudPedido AS SP 
														ON SP.Solicitante = US.IdUsuario 
														AND SP.IdSolicitudPedido = @IdSolicitudPedido);

	DECLARE @SolicitanteNuevo NVARCHAR(MAX) = (SELECT TOP 1
														US.Nombre
													FROM S_Usuario AS US
													WHERE IdUsuario = @IdSolicitnate);

	IF ISNULL(@SolicitanteAnterior,'') != ISNULL(@SolicitanteNuevo,'')
	BEGIN

		IF (ISNULL(@IdSolicitudPedido, 0) <> 0)
		BEGIN
			UPDATE dbo.MM_SolicitudPedido
			SET Solicitante = @IdSolicitnate
			WHERE IdSolicitudPedido = @IdSolicitudPedido
		END

		INSERT INTO dbo.HistorialObjetoDelPedido
		(
			IdSolicitudPedido,
			IdUsuarioModifico,
			MotivoAnterior,
			FechaModificado
		)
		SELECT @IdSolicitudPedido,
			   @IdUsuario,
			   'Se cambia el solicitante ' + isnull(@SolicitanteAnterior,'') + ' a ' + isnull(@SolicitanteNuevo,''),
			   GETDATE();

	END
	
	SET @SolicitanteNuevo = (SELECT top 1 S.Nombre
	FROM MM_SolicitudPedido SP
	join s_usuario S 
	on SP.Solicitante = S.IdUsuario
	WHERE IdSolicitudPedido = @IdSolicitudPedido)

	SELECT 'TRUE',@SolicitanteNuevo

END
