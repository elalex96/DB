USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DG_RecuperarCorreoCotizacionXSolped'
)
    DROP PROCEDURE DG_RecuperarCorreoCotizacionXSolped;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <22-08-2018>
-- Description:	<Se recuperan los correos enviados en la cotizacion filtrados por la solicitud de pedido>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
-- =============================================

CREATE PROCEDURE [dbo].[DG_RecuperarCorreoCotizacionXSolped] 
@IdSolicitudPedido INT ,
/*--------------------parametros contrato  --------------------*/
	@IdContrato INT = NULL, 
	@IdUsuario INT = NULL ,
	@FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN

		DECLARE @TablaCorreoRecuperado TABLE
			( Correo NVARCHAR(MAX))

		INSERT INTO @TablaCorreoRecuperado
		SELECT		u.Correo
		FROM		dbo.S_Usuario u (NOLOCK)
		JOIN	dbo.S_UsuarioProveedor uProv (NOLOCK)
			ON u.IdUsuario = uProv.IdUsuario
		INNER JOIN	dbo.MM_PeticionOferta po (NOLOCK)
			ON uProv.IdProveedor = po.IdSubcontratista
		WHERE
					u.IdTipoUsuario IN ( 4, 3 ) --ventas o administrador
					AND u.Activo = 1
					AND ISNULL ( u.IsEliminado, 0 ) = 0
					AND u.Correo != ''
					AND po.IdSolicitudPedido = @IdSolicitudPedido

		--se recupera el usuario que aun no ah sido dado de alta en petrovendor
		INSERT INTO @TablaCorreoRecuperado
			( Correo )
		SELECT	CorreoInvitacion
		FROM	MM_InvitacionPeticionOferta (NOLOCK)
		WHERE
				@IdSolicitudPedido = IdSolicitudPedido
				AND Activo = 1
				AND IdPeticionOferta IS NULL

		--update para buscar a los proveedores
		UPDATE		aux
		SET			aux.correo = aux.correo + ' - ' + ISNULL ( prov.RazonSocial, 'Proveedor aún no registrado en Petrovendor (Aparecera en la oferta cuando se registre)' )
		FROM		@TablaCorreoRecuperado aux
		LEFT JOIN	dbo.S_Usuario u (NOLOCK)
			ON aux.Correo = u.Correo
		LEFT JOIN	dbo.S_UsuarioProveedor uprov (NOLOCK)
			ON u.IdUsuario = uprov.IdUsuario 
		LEFT JOIN	dbo.S_Proveedor prov (NOLOCK)
			ON uprov.IdProveedor = prov.IdProveedor
			   AND	u.Activo = 1
			   AND	ISNULL ( u.IsEliminado, 0 ) = 0

		SELECT *  FROM @TablaCorreoRecuperado  GROUP BY Correo
	END
