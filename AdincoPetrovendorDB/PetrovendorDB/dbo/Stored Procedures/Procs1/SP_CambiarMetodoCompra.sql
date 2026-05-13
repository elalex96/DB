USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_CambiarMetodoCompra'
)
    DROP PROCEDURE SP_CambiarMetodoCompra;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <30-09-2018>
-- Description:	<Cambiar el metodo de compra entre adj directa y mercadeo
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
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
				FROM	dbo.MM_PeticionOferta (NOLOCK)
				WHERE
						IdSolicitudPedido = @IdSolicitudPedido
						AND ISNULL ( IdEstatusEliminado, 0 ) = 0

				IF ( @CantidadProveedores <= 1 )
					BEGIN
						IF NOT EXISTS
							(	SELECT		1
								FROM		dbo.MM_Pedido p (NOLOCK)
								INNER JOIN	dbo.MM_SolicitudPedido solPed (NOLOCK)
									ON p.IdSolicitudPedido = solPed.IdSolicitudPedido
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
						FROM		dbo.MM_Pedido p (NOLOCK)
						INNER JOIN	dbo.MM_SolicitudPedido solPed (NOLOCK)
							ON p.IdSolicitudPedido = solPed.IdSolicitudPedido
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