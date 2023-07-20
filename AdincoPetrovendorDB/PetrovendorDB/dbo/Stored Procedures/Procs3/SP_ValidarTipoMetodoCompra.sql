USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ValidarTipoMetodoCompra'
)
    DROP PROCEDURE SP_ValidarTipoMetodoCompra;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <01-10-2018>
-- Description:	<validar si esta habilitado o no el radiobutton>
-- =============================================
-- Author:		<Alexander Gomez>
-- Update date: <13/02/2020>
-- Description:	<se contemplan tambien las invitaciones>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarTipoMetodoCompra] @IdSolicitudPedido INT, @TipoAdjPantalla INT
AS
	BEGIN
		DECLARE @CantidadProveedores INT

		IF ( @TipoAdjPantalla = 2 )
			BEGIN
				--si tiene mas de un proveedor entonces NO puede cambiar a adj directa
				SELECT	@CantidadProveedores = COUNT ( IdPeticionOferta )
				FROM	dbo.MM_PeticionOferta (NOLOCK)
				WHERE
						IdSolicitudPedido = @IdSolicitudPedido
						AND ISNULL ( IdEstatusEliminado, 0 ) = 0;

				SET @CantidadProveedores = @CantidadProveedores +  (SELECT COUNT(1) FROM dbo.MM_InvitacionPeticionOferta (NOLOCK) WHERE IdSolicitudPedido = @IdSolicitudPedido AND ISNULL(InvitacionPorCorreo,0) = 1);

				IF ( @CantidadProveedores <= 1 )
					BEGIN
						IF NOT EXISTS
							(	SELECT		1
								FROM		dbo.MM_Pedido p (NOLOCK)
								INNER JOIN	dbo.MM_SolicitudPedido solPed (NOLOCK)
									ON p.IdSolicitudPedido = solPed.IdSolicitudPedido
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
						FROM		dbo.MM_Pedido p (NOLOCK)
						INNER JOIN	dbo.MM_SolicitudPedido solPed (NOLOCK)
							ON p.IdSolicitudPedido = solPed.IdSolicitudPedido
						WHERE
									p.IdSolicitudPedido = @IdSolicitudPedido
									AND ISNULL ( p.IdEstatusEliminado, 0 ) = 0 )
					BEGIN
						SELECT 1 --mostrar
					END
				ELSE SELECT 0 -- no mostrar
			END
	END