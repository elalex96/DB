-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <03/03/2020>
-- Description:	<Consulta del detalle del historial>
-- =============================================
create PROCEDURE [dbo].[SP_HistorialSecundarioProceso] --3,12
	-- Add the parameters for the stored procedure here
	@IdDocumento INT,
	@IdProceso INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @HISTORIALSEC TABLE (
		IdDocumento INT,
		Descripcion NVARCHAR(1000),
		Fecha DATETIME,
		IdEstatus INT,
		tieneHistorial BIT,
		IsRedireccion BIT,
		Url NVARCHAR(1000),
		IsEncriptado BIT
	);

	IF @IdProceso = 1 --HISTORIAL DE APROBACION DE SOLICITUD DE PEDIDO
	BEGIN

		--INSERT INTO @HISTORIALSEC
		--(
		--	IdDocumento,
		--	Descripcion,
		--	Fecha,
		--	IdEstatus
		--)
		--SELECT 
		--	OP.IdOperacion,
		--	US.Nombre + ' registro la solicitud de pedido N.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)) + ' para que sea evaluada.',
		--	OP.FechaRegistro,
		--	2
		--FROM dbo.MM_SolicitudPedido AS SP
		--	LEFT JOIN dbo.TA_Operacion AS OP
		--		ON OP.IdDocumento = SP.IdSolicitudPedido
		--		AND OP.IdTipoOperacion = 2
		--	LEFT JOIN dbo.S_Usuario AS US
		--		ON US.IdUsuario = OP.IdAsignador
		--WHERE SP.IdSolicitudPedido = @IdDocumento
		--	AND SP.IdEstatusEliminado IS NULL;

	    INSERT INTO @HISTORIALSEC
		(
			IdDocumento,
			Descripcion,
			Fecha,
			IdEstatus
		)
		SELECT
			T.IdTarea,
			CASE 
				WHEN T.IdEstatus = 2 THEN US.Nombre + ' aprobo la solicitud de pedido N.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 3 THEN US.Nombre + ' rechazo la solicitud de pedido N.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 6 THEN US.Nombre + '(Asignador) cancelo la solicitud de pedido N.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 7 THEN US.Nombre + ' reasigno la solicitud de pedido N.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)) + '.'
			END,
			T.FechaCambioEstatus,
			CASE 
				WHEN T.IdEstatus = 2 THEN 2
				ELSE 3
			END
		FROM dbo.MM_SolicitudPedido AS SP
			LEFT JOIN dbo.TA_Operacion AS OP
				ON OP.IdDocumento = SP.IdSolicitudPedido
				AND OP.IdTipoOperacion = 2
			LEFT JOIN dbo.TA_Tarea AS T
				ON T.IdOperacion = OP.IdOperacion
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = T.IdAprobador
		WHERE SP.IdSolicitudPedido = @IdDocumento
			AND T.IdEstatus <> 1
			AND SP.IdEstatusEliminado IS NULL;

		INSERT INTO @HISTORIALSEC
		(
			IdDocumento,
			Descripcion,
			Fecha,
			IdEstatus
		)
		SELECT TOP 1
			HF.IdHistorial,
			'Finalizó la evaluación de la requisición.<br>' + 'La solicitud de pedido N.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(10)) + ' fue ' + TA.Nombre + '.',
			HF.Fecha,
			TA.IdEstatus
		FROM dbo.MM_SolicitudPedido AS SP
			LEFT JOIN dbo.TA_Operacion AS OP
				ON OP.IdDocumento = SP.IdSolicitudPedido
				AND OP.IdTipoOperacion = 2
			LEFT JOIN dbo.TA_HistorialFlujoTarea AS HF
				ON HF.IdOperacion = OP.IdOperacion
			LEFT JOIN dbo.TA_Estatus AS TA
				ON TA.IdEstatus = OP.IdEstatusOperacion 
		WHERE SP.IdSolicitudPedido = 20271
			AND HF.IdEstadoFlujo = 7
			AND SP.IdEstatusEliminado IS NULL
		ORDER BY HF.Fecha DESC;

	END;

	IF @IdProceso = 2 --HISTORIAL DE ENVIO DE LA PETICION OFERTA
	BEGIN
	    
		INSERT INTO @HISTORIALSEC
		(
			IdDocumento,
			Descripcion,
			Fecha,
			IdEstatus
		)
		SELECT
			TOPA.IdOperacion,
			CASE
				WHEN SP.IdTipoProceso = 2 THEN REPLACE(CONCAT(US.Nombre , ' envio una solicitud de cotización bajo el metodo de mercadeo, a los Proveedores : ' , (SELECT '| -' + PR.RazonSocial
																																							FROM dbo.MM_PeticionOferta AS PO
																																							INNER JOIN dbo.S_Proveedor AS PR
																																								ON PR.IdProveedor = PO.IdSubcontratista
																																							WHERE PO.IdSolicitudPedido = TOPA.IdDocumento
																																							FOR XML PATH (''))),'|','<br>')
				WHEN SP.IdTipoProceso = 4 THEN REPLACE(CONCAT(US.Nombre , ' envio una solicitud de cotización bajo el metodo de adjudciación directa, al Proveedor : ' , (SELECT '| -' + PR.RazonSocial
																																							FROM dbo.MM_PeticionOferta AS PO
																																							INNER JOIN dbo.S_Proveedor AS PR
																																								ON PR.IdProveedor = PO.IdSubcontratista
																																							WHERE PO.IdSolicitudPedido = TOPA.IdDocumento
																																							FOR XML PATH (''))),'|','<br>')

				WHEN SP.IdTipoProceso = 6 THEN REPLACE(CONCAT(US.Nombre , ' envio una solicitud de cotización bajo el metodo de adjudciación directa, al Proveedor : ' , (SELECT '| -' + PR.RazonSocial
																																							FROM dbo.MM_PeticionOferta AS PO
																																							INNER JOIN dbo.S_Proveedor AS PR
																																								ON PR.IdProveedor = PO.IdSubcontratista
																																							WHERE PO.IdSolicitudPedido = TOPA.IdDocumento
																																							FOR XML PATH (''))),'|','<br>')
			END,
			TOPA.FechaRegistro,
			2
		FROM dbo.MM_SolicitudPedido AS SP
			LEFT JOIN dbo.TA_Operacion AS TOPA
				ON TOPA.IdDocumento = SP.IdSolicitudPedido
				AND TOPA.IdTipoOperacion = 6
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = TOPA.IdAsignador
		WHERE SP.IdSolicitudPedido = @IdDocumento
			AND SP.IdEstatusEliminado IS NULL;

	END

	IF @IdProceso = 3 --HISTORIAL DE LA COTIZACION
	BEGIN

		INSERT INTO @HISTORIALSEC
		(
			IdDocumento,
			Descripcion,
			Fecha,
			IdEstatus
		)
		SELECT
			PO.IdPeticionOferta,
			US.Nombre + ' de ' + PR.RazonSocial + ' envio su cotización.',
			PO.FechaFinalizado,
			2
		FROM dbo.MM_SolicitudPedido AS SP
			LEFT JOIN dbo.MM_PeticionOferta AS PO
				ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PR.IdProveedor = PO.IdSubcontratista
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = PO.ModificadoPor
		WHERE SP.IdSolicitudPedido = @IdDocumento
			AND PO.FechaFinalizado IS NOT NULL
			AND SP.IdEstatusEliminado IS NULL;
	    
		INSERT INTO @HISTORIALSEC
		(
			IdDocumento,
			Descripcion,
			Fecha,
			IdEstatus
		)
		SELECT
			HC.Id_Historial,
			US.Nombre + ' cambio la fecha limite de cotización a ' + CONVERT(VARCHAR,HC.FechaNueva,22)  + '.',
			HC.FechaEdicion,
			1
		FROM dbo.MM_HistorialCambiosCotizacion AS HC
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = HC.IdEditadoPor
		WHERE HC.IdSolicitudPedido = @IdDocumento;

	END

	IF @IdProceso = 4 --PEDIDO
	BEGIN

		--INSERT INTO @HISTORIALSEC
		--(
		--	IdDocumento,
		--	Descripcion,
		--	Fecha,
		--	IdEstatus
		--)
		--SELECT 
		--	OP.IdOperacion,
		--	US.Nombre + ' registro el pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + ' para que sea evaluada.',
		--	OP.FechaRegistro,
		--	2
		--FROM dbo.MM_Pedido AS P
		--	LEFT JOIN dbo.TA_Operacion AS OP
		--		ON OP.IdDocumento = P.IdSolicitudPedido
		--		AND OP.IdTipoOperacion = 9
		--		AND OP.NoVersion = P.Version
		--	LEFT JOIN dbo.S_Usuario AS US
		--		ON US.IdUsuario = OP.IdAsignador
		--	LEFT JOIN dbo.MM_Pedidos AS PS
		--		ON PS.IdIdentificador = P.IdPedido
		--WHERE P.IdPedido = @IdDocumento
		--	AND P.IdEstatusEliminado IS NULL;
	    
		INSERT INTO @HISTORIALSEC
		(
			IdDocumento,
			Descripcion,
			Fecha,
			IdEstatus
		)
		SELECT
			T.IdTarea,
			CASE 
				WHEN T.IdEstatus = 2 THEN US.Nombre + ' aprobo el Pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 3 THEN US.Nombre + ' rechazo el pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 6 THEN US.Nombre + '(Asignador) cancelo el pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 7 THEN US.Nombre + ' reasigno el pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
			END,
			T.FechaCambioEstatus,
			CASE 
				WHEN T.IdEstatus = 2 THEN 2
				ELSE 3
			END
		FROM dbo.MM_Pedido AS P
			LEFT JOIN dbo.TA_Operacion AS OP
				ON OP.IdDocumento = P.IdSolicitudPedido
				AND OP.IdTipoOperacion = 9
				AND OP.NoVersion = P.Version
			LEFT JOIN dbo.TA_Tarea AS T
				ON T.IdOperacion = OP.IdOperacion
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = T.IdAprobador
			LEFT JOIN dbo.MM_Pedidos AS PS
				ON PS.IdIdentificador = P.IdPedido
		WHERE P.IdPedido = @IdDocumento
			AND T.IdEstatus <> 1
			AND P.IdEstatusEliminado IS NULL;

		INSERT INTO @HISTORIALSEC
		(
			IdDocumento,
			Descripcion,
			Fecha,
			IdEstatus
		)
		SELECT TOP 1
			HF.IdHistorial,
			'Finalizó la evaluación del pedido.<br>' + 'El pedido N.' + CAST(PS.IdPedido AS NVARCHAR(10)) + ' fue ' + REPLACE(TA.Nombre,'da','do') + '.',
			HF.Fecha,
			TA.IdEstatus
		FROM dbo.MM_Pedido AS P
			LEFT JOIN dbo.TA_Operacion AS OP
				ON OP.IdDocumento = P.IdSolicitudPedido
				AND OP.IdTipoOperacion = 9
				AND OP.NoVersion = P.Version
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = OP.IdAsignador
			LEFT JOIN dbo.MM_Pedidos AS PS
				ON PS.IdIdentificador = P.IdPedido
			LEFT JOIN dbo.TA_HistorialFlujoTarea AS HF
				ON HF.IdOperacion = OP.IdOperacion
			LEFT JOIN dbo.TA_Estatus AS TA
				ON TA.IdEstatus = OP.IdEstatusOperacion 
		WHERE P.IdPedido = @IdDocumento
			AND HF.IdEstadoFlujo = 7
		ORDER BY HF.Fecha DESC;

		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus
		)
		SELECT
			P.IdPedido,
			CASE
				WHEN P.RecepcionServicio = 1 THEN PR.RazonSocial + ' confirmo la recepción del servicio del Pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
				WHEN P.RecepcionServicio = 0 THEN PR.RazonSocial + ' rechazo la recepción del servicio del Pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
			END,
			P.FechaRecepcionServicio,
			CASE
				WHEN P.RecepcionServicio = 1 THEN 2
				WHEN P.RecepcionServicio = 0 THEN 3
			END
		FROM dbo.MM_Pedido AS P
			LEFT JOIN dbo.TA_Operacion AS OP
				ON OP.IdDocumento = P.IdSolicitudPedido
				AND OP.IdTipoOperacion = 9
				AND OP.NoVersion = P.Version
			LEFT JOIN dbo.MM_Pedidos AS PS
				ON PS.IdIdentificador = P.IdPedido
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PR.IdProveedor = P.IdSubcontratista
		WHERE P.IdPedido = @IdDocumento
			AND P.RecepcionServicio IS NOT NULL
			AND P.IdEstatusEliminado IS NULL;
	
		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus,
			tieneHistorial,
			IsRedireccion,
			Url
		)
		SELECT
			AP.IdAceptacionPedido,
			US.Nombre + ' registro la Aceptacion N.' + CAST(AP.IdAceptacionPedido AS NVARCHAR(10)) + ', del Pedido N.' + CAST(PS.IdPedido AS NVARCHAR(10)) + '.',
			AP.Creado,
			2,
			1,
			1,
			'/02Proveedores/AceptacionDetalle.aspx?aceptacion=' + CAST(AP.IdAceptacionPedido AS NVARCHAR(10))
		FROM dbo.MM_AceptacionPedido AS AP
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = AP.CreadorPor
			LEFT JOIN dbo.MM_Pedido AS P
				ON P.IdPedido = AP.IdPedido
			LEFT JOIN dbo.MM_Pedidos AS PS
				ON PS.IdIdentificador = P.IdPedido
					AND PS.IdProveedorCliente = P.IdProveedorCompras
		WHERE AP.IdPedido = @IdDocumento
			AND AP.IdEstatusEliminado IS NULL;

	END

	IF @IdProceso = 5 --ACEPTACION DE PEDIDO
	BEGIN
	    
		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus
		)
		SELECT
			SECN.IdAprobacionExclucionCN,
			US.Nombre + ' solicito excluir la Carta de Contenido Nacional para la Aceptacion N.' + CAST(SECN.IdAceptacionPedido AS NVARCHAR(10)) + '.',
			SECN.FechaSolicitud,
			1
		FROM dbo.MM_Solicitud_ExclucionCN AS SECN
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = SECN.IdUsuarioRequesitor
		WHERE SECN.IdAceptacionPedido = @IdDocumento;

		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus
		)
		SELECT
			SECN.IdAprobacionExclucionCN,
			CASE
				WHEN SECN.IdEstatus = 2 THEN US.Nombre + ' aprobo la solicitud para excluir la Carta de Contenido Nacional para la Aceptacion N.' + CAST(SECN.IdAceptacionPedido AS NVARCHAR(10)) + '.'
				WHEN SECN.IdEstatus = 3 THEN US.Nombre + ' rechazo la solicitud para excluir la Carta de Contenido Nacional para la Aceptacion N.' + CAST(SECN.IdAceptacionPedido AS NVARCHAR(10)) + '.'
			END,
			SECN.FechaSolicitud,
			SECN.IdEstatus
		FROM dbo.MM_Solicitud_ExclucionCN AS SECN
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = SECN.UsuarioAprobador
		WHERE SECN.IdAceptacionPedido = @IdDocumento
			AND SECN.IdEstatus <> 1;

		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus,
			IsRedireccion,
			Url
		)
		SELECT
			ACN.IdAceptacionCartaPCN,
			ISNULL(US.Nombre + ' de ','') + PR.RazonSocial + ' registro la Carta de Contenido Nacional de la Aceptación N.' + CAST(ACN.IdAceptacionPedido AS NVARCHAR(10)),
			ACN.CreadoEl,
			1,
			1,
			'/02Proveedores/AprobacionCNDetalle.aspx?aceptacion=' + CAST(ACN.IdAceptacionCartaPCN AS NVARCHAR(10))
		FROM dbo.MM_AceptacionCartaPCN AS ACN
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = ACN.CreadoPor
			LEFT JOIN dbo.MM_AceptacionPedido AS AP
				ON AP.IdAceptacionPedido = ACN.IdAceptacionPedido
			LEFT JOIN dbo.MM_Pedido AS P
				ON P.IdPedido = AP.IdPedido
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PR.IdProveedor = P.IdSubcontratista
		WHERE ACN.IdAceptacionPedido = @IdDocumento
			AND ACN.IdEstatusEliminado IS NULL;

		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus
		)
		SELECT
			ACN.IdAceptacionPedido,
			CASE
				WHEN ACN.IdEstatus = 2 THEN US.Nombre + ' aprobo la Carta de Contenido Nacional de la Aceptación N.' + CAST(ACN.IdAceptacionPedido AS NVARCHAR(10))
				WHEN ACN.IdEstatus = 3 THEN US.Nombre + ' rechazo la Carta de Contenido Nacional de la Aceptación N.' + CAST(ACN.IdAceptacionPedido AS NVARCHAR(10))
			END,
			ACN.FechaEvaluacion,
			ACN.IdEstatus
		FROM dbo.MM_AceptacionCartaPCN AS ACN
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = ACN.IdUsuarioEvaluador
			LEFT JOIN dbo.MM_AceptacionPedido AS AP
				ON AP.IdAceptacionPedido = ACN.IdAceptacionPedido
			LEFT JOIN dbo.MM_Pedido AS P
				ON P.IdPedido = AP.IdPedido
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PR.IdProveedor = P.IdSubcontratista
		WHERE ACN.IdAceptacionPedido = @IdDocumento
			AND ACN.IdEstatus <> 1
			AND ACN.IdEstatusEliminado IS NULL;
		
		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus,
			IsRedireccion,
			Url
		)
		SELECT
			AF.IdAceptacionFactura,
			ISNULL(US.Nombre + ' de ','') + ISNULL(PR.RazonSocial,'') + ' cargo y envio la factura para su aprobación de la Aceptación N.' + CAST(AF.IdAceptacionPedido AS NVARCHAR(10)),
			OP.FechaRegistro,
			1,
			1,
			'/02Proveedores/RecepcionVentanillaDetalle.aspx?aceptacion=' + CAST(AF.IdAceptacionPedido AS NVARCHAR(10))
		FROM dbo.MM_AceptacionFactura AS AF
			LEFT JOIN dbo.MM_AceptacionPedido AS AP
				ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
			LEFT JOIN dbo.MM_Pedido AS P
				ON P.IdPedido = AP.IdPedido
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PR.IdProveedor = P.IdSubcontratista
			LEFT JOIN dbo.TA_Operacion AS OP
				ON OP.IdDocumento = AF.IdAceptacionFactura
				AND OP.IdTipoOperacion = 10
			LEFT JOIN dbo.FI_Factura AS F
				ON F.IdFactura = AF.IdFactura
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = F.CreadoPor
		WHERE AF.IdAceptacionPedido = @IdDocumento
			AND AF.IdEstatusXML <> 1
			AND AF.IdEstatusEliminado IS NULL;

		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus
		)
		SELECT
			AF.IdAceptacionFactura,
			CASE 
				WHEN T.IdEstatus = 2 THEN US.Nombre + ' aprobo la factura N.' + CAST(AF.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 3 THEN US.Nombre + ' rechazo la factura N.' + CAST(AF.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 6 THEN US.Nombre + '(Asignador) cancelo la factura N.' + CAST(AF.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 7 THEN US.Nombre + ' reasigno la factura N.' + CAST(AF.IdAceptacionPedido AS NVARCHAR(100)) + '.'
			END,
			T.FechaCambioEstatus,
			CASE 
				WHEN T.IdEstatus = 2 THEN 2
				ELSE 3
			END
		FROM dbo.MM_AceptacionFactura AS AF
			LEFT JOIN dbo.MM_AceptacionPedido AS AP
				ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
			LEFT JOIN dbo.MM_Pedido AS P
				ON P.IdPedido = AP.IdPedido
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PR.IdProveedor = P.IdSubcontratista
			LEFT JOIN dbo.TA_Operacion AS OP
				ON OP.IdDocumento = AF.IdAceptacionFactura
				AND OP.IdTipoOperacion = 10
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = OP.IdAsignador
			LEFT JOIN dbo.TA_Tarea AS T
				ON T.IdOperacion = OP.IdOperacion
		WHERE AF.IdAceptacionPedido = @IdDocumento
			AND T.IdEstatus <> 1
			AND T.IdEstatus <> 12
			AND AF.IdEstatusEliminado IS NULL;
		
		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus
		)
		SELECT
			AF.IdAceptacionFactura,
			HF.Descripcion + ', fue ' + TE.Nombre,
			HF.Fecha,
			OP.IdEstatusOperacion
		FROM dbo.MM_AceptacionFactura AS AF
			LEFT JOIN dbo.MM_AceptacionPedido AS AP
				ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
			LEFT JOIN dbo.MM_Pedido AS P
				ON P.IdPedido = AP.IdPedido
			LEFT JOIN dbo.TA_Operacion AS OP
				ON OP.IdDocumento = AF.IdAceptacionFactura
				AND OP.IdTipoOperacion = 10
			LEFT JOIN dbo.TA_HistorialFlujoTarea AS HF
				ON HF.IdOperacion = OP.IdOperacion
			LEFT JOIN dbo.TA_Estatus AS TE
				ON TE.IdEstatus = OP.IdEstatusOperacion
		WHERE AF.IdAceptacionPedido = @IdDocumento
			AND HF.IdEstadoFlujo = 7
			AND AF.IdEstatusEliminado IS NULL;
		
		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus,
			IsRedireccion,
			Url,
			IsEncriptado
		)
		SELECT
			APPC.IdAceptacionPedido,
			US.Nombre + ' registro el Pedimento/Comprobante Extranjero de la Aceptación N.' + CAST(APPC.IdAceptacionPedido AS NVARCHAR(10)) + ' para su aprobación.',
			APPC.CreadoEl,
			1,
			1,
			'/02Proveedores/PC_PedimentoComprobanteDetalle.aspx?aceptacion=',
			1
		FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APPC
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = APPC.CreadoPor
		WHERE APPC.IdAceptacionPedido = @IdDocumento;
		

		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus
		)
		SELECT 
			APPC.IdAceptacionPedido,
			CASE 
				WHEN T.IdEstatus = 2 THEN US.Nombre + ' aprobo el Pedimento/Comprobante Extranjero de la aceptación N.' + CAST(APPC.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 3 THEN US.Nombre + ' rechazo el Pedimento/Comprobante Extranjero de la aceptación N.' + CAST(APPC.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 6 THEN US.Nombre + '(Asignador) cancelo del Pedimento/Comprobante Extranjero aceptación N.' + CAST(APPC.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 7 THEN US.Nombre + ' reasigno el Pedimento/Comprobante Extranjero N.' + CAST(APPC.IdAceptacionPedido AS NVARCHAR(100)) + '.'
			END,
			T.FechaCambioEstatus,
			CASE 
				WHEN T.IdEstatus = 2 THEN 2
				ELSE 3
			END
		FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APPC
			LEFT JOIN dbo.TA_Operacion AS OP
				ON OP.IdDocumento = APPC.IdPedimentoComprobante
				AND OP.IdTipoOperacion = 16
			LEFT JOIN dbo.TA_Tarea AS T
				ON T.IdOperacion = OP.IdOperacion
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = T.IdAprobador
		WHERE APPC.IdAceptacionPedido = @IdDocumento
			AND T.IdEstatus <> 1;

		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus
		)
		SELECT TOP 1
			APPC.IdAceptacionPedido,
			HF.Descripcion + ', fue ' + ES.Nombre,
			HF.Fecha,
			OP.IdEstatusOperacion
		FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APPC
			LEFT JOIN dbo.TA_Operacion AS OP
				ON OP.IdDocumento = APPC.IdPedimentoComprobante
				AND OP.IdTipoOperacion = 16
			LEFT JOIN dbo.TA_HistorialFlujoTarea AS HF
				ON HF.IdOperacion = OP.IdOperacion
			LEFT JOIN dbo.TA_Estatus AS ES
				ON ES.IdEstatus = OP.IdEstatusOperacion
		WHERE APPC.IdAceptacionPedido = @IdDocumento
			AND HF.IdEstadoFlujo = 7
		ORDER BY HF.Fecha DESC;

	END

	IF @IdProceso = 10
	BEGIN
	    
		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus
		)
		SELECT
			PRS.IdPRESES,
			CASE 
				WHEN PRS.IdEstatus = 2 THEN US.Nombre + ' approve the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
				WHEN PRS.IdEstatus = 3 THEN US.Nombre + ' reject the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
			END,
			PRS.ModificadoEl,
			PRS.IdEstatus
		FROM Adinco.dbo.CO_SAPPRESES AS PRS
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = PRS.ModificadoPor
		WHERE PRS.IdPRESES = @IdDocumento
		AND PRS.IdEstatus <> 1;

	END

	IF @IdProceso = 11
	BEGIN
	    
		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus
		)
		SELECT
			AC.IdAceptacionCartaPCN,
			CASE 
				WHEN AC.Editado = 1 THEN US.Nombre + ' reject the national content letter of the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10)) + ' to edit and reload (AUTOMATIC REJECTION FOR EDITING)'
				WHEN AC.IdEstatus = 2 THEN US.Nombre + ' approve the national content letter of the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
				WHEN AC.IdEstatus = 3 THEN US.Nombre + ' reject the national content letter of the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
			END,
			AC.FechaEvaluacion,
			AC.IdEstatus
		FROM Adinco.dbo.CO_SAPPRESES AS PRS
		LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PRS.SAPPONumber
			AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = PRS.SAPSESNumber
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES
			ON SES.PO_SAPNumer = PRS.SAPPONumber
			AND SES.SESReferenceNumber = PRS.SAPSESNumber
			AND SES.SESNumber = PRS.SESN
		LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC
			ON AC.IdAceptacionPedido = AP.IdAceptacionPedido
			AND ISNULL(AC.IdEstatusEliminado,0) <> 1
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS VE 
			ON VE.VendorIDSAP = PRS.SAPVendorNumber
		LEFT JOIN dbo.S_Usuario AS US
			ON US.IdUsuario = AC.IdUsuarioEvaluador
		WHERE AC.IdAceptacionCartaPCN = @IdDocumento
			AND AC.IdAceptacionCartaPCN IS NOT NULL
			AND AC.IdEstatus <> 1
			AND PRS.IdEstatus = 2
		GROUP BY AC.IdAceptacionCartaPCN,
				 PRS.SAPPONumber,
				 PRS.SAPSESNumber,
				 AP.IdAceptacionPedido,
				 PRS.IdPRESES,
				 AC.CreadoEl,
				 VE.VendorName,
				 US.Nombre,
				 SES.SESNumber,
				 AC.IdEstatus,
				 AC.FechaEvaluacion,
				 AC.Editado

	END

	IF @IdProceso = 12
	BEGIN
	    
		INSERT INTO @HISTORIALSEC
		(
		    IdDocumento,
		    Descripcion,
		    Fecha,
		    IdEstatus
		)
		SELECT
			AF.IdAceptacionFactura,
			CASE 
				WHEN AF.IdEstatus = 2 THEN US.Nombre + ' approve the invoice of the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
				WHEN AF.IdEstatus = 3 THEN US.Nombre + ' rejecte the invoice of the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
			END,
			AF.FechaAprobacion,
			AF.IdEstatus
		FROM Adinco.dbo.CO_SAPPRESES AS PRS
		LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PRS.SAPPONumber
			AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = PRS.SAPSESNumber
		LEFT JOIN dbo.MPY_MM_AceptacionFactura AS AF
			ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
			AND ISNULL(AF.IdEstatusEliminado,0) <> 1
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES
			ON SES.PO_SAPNumer = PRS.SAPPONumber
			AND SES.SESReferenceNumber = PRS.SAPSESNumber
			AND SES.SESNumber = PRS.SESN
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS VE 
			ON VE.VendorIDSAP = PRS.SAPVendorNumber
		LEFT JOIN dbo.FI_Factura AS F
			ON F.IdFactura = AF.IdFactura
		LEFT JOIN dbo.S_Usuario AS US
			ON US.IdUsuario = AF.IdAprobador
	WHERE AF.IdAceptacionFactura = @IdDocumento
		AND AF.IdAceptacionFactura IS NOT NULL
		AND PRS.IdEstatus = 2
		AND AF.IdEstatus <> 1
	GROUP BY AP.IdAceptacionPedido,
			 PRS.SAPPONumber,
			 PRS.SAPSESNumber,
			 AP.IdAceptacionPedido,
			 PRS.IdPRESES,
			 AF.CreadoEl,
			 VE.VendorName,
			 US.Nombre,
			 SES.SESNumber,
			 AF.IdAceptacionFactura,
			 AF.IdEstatus,
			 AF.FechaAprobacion

	END

	SELECT
		IdDocumento,
		Descripcion,
		Fecha,
		IdEstatus,
		ISNULL(tieneHistorial,0) AS tieneHistorial,
		ISNULL(IsRedireccion,0) AS IsRedireccion,
		Url,
		ISNULL(IsEncriptado,0) AS IsEncriptado
	FROM @HISTORIALSEC ORDER BY Fecha ASC;

END
