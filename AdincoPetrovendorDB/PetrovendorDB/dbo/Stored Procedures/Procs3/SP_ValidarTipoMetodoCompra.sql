-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <01-10-2018>
-- Description:	<validar si esta habilitado o no el radiobutton>
-- =============================================
-- Author:		<Alexander Gomez>
-- Update date: <13/02/2020>
-- Description:	<se contemplan tambien las invitaciones>
-- =============================================

CREATE PROCEDURE [dbo].[SP_ValidarTipoMetodoCompra] @IdSolicitudPedido INT, @TipoAdjPantalla INT
AS
	BEGIN
		DECLARE @CantidadProveedores INT

		IF ( @TipoAdjPantalla = 2 )
			BEGIN
				--si tiene mas de un proveedor entonces NO puede cambiar a adj directa
				SELECT	@CantidadProveedores = COUNT ( IdPeticionOferta )
				FROM	dbo.MM_PeticionOferta
				WHERE
						IdSolicitudPedido = @IdSolicitudPedido
						AND ISNULL ( IdEstatusEliminado, 0 ) = 0;

				SET @CantidadProveedores = @CantidadProveedores +  (SELECT COUNT(1) FROM dbo.MM_InvitacionPeticionOferta WHERE IdSolicitudPedido = @IdSolicitudPedido AND ISNULL(InvitacionPorCorreo,0) = 1);

				IF ( @CantidadProveedores <= 1 )
					BEGIN
						IF NOT EXISTS
							(	SELECT		1
								FROM		dbo.MM_Pedido p
								INNER JOIN	dbo.MM_SolicitudPedido solPed
									ON solPed.IdSolicitudPedido = p.IdSolicitudPedido
								WHERE		p.IdSolicitudPedido = @IdSolicitudPedido )
							BEGIN
								SELECT 1	--mostrar
							END
						ELSE SELECT 0	--no mostrar
					END
				ELSE SELECT 0	--no mostrar	 
			END

		IF ( @TipoAdjPantalla = 4 )
			BEGIN
				IF NOT EXISTS
					(	SELECT		1
						FROM		dbo.MM_Pedido p
						INNER JOIN	dbo.MM_SolicitudPedido solPed
							ON solPed.IdSolicitudPedido = p.IdSolicitudPedido
						WHERE
									p.IdSolicitudPedido = @IdSolicitudPedido
									AND ISNULL ( p.IdEstatusEliminado, 0 ) = 0 )
					BEGIN
						SELECT 1 --mostrar
					END
				ELSE SELECT 0 -- no mostrar
			END
	END