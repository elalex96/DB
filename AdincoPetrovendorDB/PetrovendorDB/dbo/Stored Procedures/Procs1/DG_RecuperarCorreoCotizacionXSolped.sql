-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <22-08-2018>
-- Description:	<Se recuperan los correos enviados en la cotizacion filtrados por la solicitud de pedido>
-- =============================================

CREATE PROCEDURE [dbo].[DG_RecuperarCorreoCotizacionXSolped] --20022
@IdSolicitudPedido INT ,
														/*--------------------parametros contrato  --------------------*/
													 @IdContrato INT = NULL, @IdUsuario INT = NULL ,
													 @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN
		--DECLARE @IdSolicitudPedido INT = 13355

		--DECLARE @TablaPeticionOferta TABLE
		--	( Fila INT IDENTITY ,
		--	  IdPeticionOferta INT )
		DECLARE @TablaCorreoRecuperado TABLE
			( Correo NVARCHAR(MAX))

		--DECLARE @Contador INT = 1, @CantidadPetOferta INT, @IdPetOfertaAux INT
		INSERT INTO @TablaCorreoRecuperado
		--			( Correo )
		SELECT		u.Correo
		FROM		dbo.S_Usuario u
		INNER JOIN	dbo.S_UsuarioProveedor uProv
			ON uProv.IdUsuario = u.IdUsuario
		INNER JOIN	dbo.MM_PeticionOferta po
			ON po.IdSubcontratista = uProv.IdProveedor
		WHERE
					u.IdTipoUsuario IN ( 4, 3 ) --ventas o administrador
					AND u.Activo = 1
					AND ISNULL ( u.IsEliminado, 0 ) = 0
					AND u.Correo != ''
					AND po.IdSolicitudPedido = @IdSolicitudPedido

		--SELECT @CantidadPetOferta  = COUNT ( * ) FROM @TablaPeticionOferta

		--WHILE ( @Contador <= @CantidadPetOferta )
		--	BEGIN
		--		SELECT	@IdPetOfertaAux = IdPeticionOferta
		--		FROM	@TablaPeticionOferta
		--		WHERE	Fila = @Contador

		--		INSERT INTO @TablaCorreoRecuperado
		--			( Correo )
		--		SELECT	Para
		--		FROM	Adinco.dbo.S_Notificacion
		--		WHERE	Asunto LIKE 'Petición Oferta ' + CONVERT ( NVARCHAR(50), @IdPetOfertaAux )

		--		SET @IdPetOfertaAux = NULL
		--		SET @Contador += 1
		--	END

		--se recupera el usuario que aun no ah sido dado de alta en petrovendor
		INSERT INTO @TablaCorreoRecuperado
			( Correo )
		SELECT	CorreoInvitacion
		FROM	MM_InvitacionPeticionOferta
		WHERE
				IdSolicitudPedido = @IdSolicitudPedido
				AND Activo = 1
				AND IdPeticionOferta IS NULL

		--update para buscar a los proveedores
		UPDATE		aux
		SET			aux.correo = aux.correo + ' - ' + ISNULL ( prov.RazonSocial, 'Proveedor aún no registrado en Petrovendor (Aparecera en la oferta cuando se registre)' )
		FROM		@TablaCorreoRecuperado aux
		LEFT JOIN	dbo.S_Usuario u
			ON u.Correo = aux.Correo
		LEFT JOIN	dbo.S_UsuarioProveedor uprov
			ON uprov.IdUsuario = u.IdUsuario
		LEFT JOIN	dbo.S_Proveedor prov
			ON prov.IdProveedor = uprov.IdProveedor
			   AND	u.Activo = 1
			   AND	ISNULL ( u.IsEliminado, 0 ) = 0

		SELECT *  FROM @TablaCorreoRecuperado  GROUP BY Correo
	END
