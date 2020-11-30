-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <30-09-2018>
-- Description:	<Cambiar el metodo de compra entre adj directa y mercadeo
-- =============================================

CREATE PROCEDURE [dbo].[SP_CambiarMetodoCompra] @IdSolicitudPedido INT, @TipoAdjPantalla INT
AS
	BEGIN
		DECLARE @CantidadProveedores INT

		--falta revisar antes de actualizar
		IF ( @TipoAdjPantalla = 2 )
			BEGIN
				--si tiene mas de un proveedor entonces NO puede cambiar a adj directa
				SELECT	@CantidadProveedores = COUNT ( IdPeticionOferta )
				FROM	dbo.MM_PeticionOferta
				WHERE
						IdSolicitudPedido = @IdSolicitudPedido
						AND ISNULL ( IdEstatusEliminado, 0 ) = 0

				IF ( @CantidadProveedores <= 1 )
					BEGIN
						IF NOT EXISTS
							(	SELECT		1
								FROM		dbo.MM_Pedido p
								INNER JOIN	dbo.MM_SolicitudPedido solPed
									ON solPed.IdSolicitudPedido = p.IdSolicitudPedido
								WHERE		p.IdSolicitudPedido = @IdSolicitudPedido )
							BEGIN
								UPDATE	dbo.MM_SolicitudPedido
								SET		IdTipoProceso = 4	--Adj directa
								WHERE	IdSolicitudPedido = @IdSolicitudPedido

								SELECT 'AdjDirecta'
							END
						ELSE BEGIN
								SELECT 'ExistePedido'
							END
					END
				ELSE BEGIN
						SELECT 'ProveedorMayor'
					END
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
						UPDATE	dbo.MM_SolicitudPedido
						SET		IdTipoProceso = 2	--Mercadeo
						WHERE	IdSolicitudPedido = @IdSolicitudPedido

						SELECT 'Mercadeo'
					END
				ELSE BEGIN
						SELECT 'ExistePedido'
					END
			END
	END