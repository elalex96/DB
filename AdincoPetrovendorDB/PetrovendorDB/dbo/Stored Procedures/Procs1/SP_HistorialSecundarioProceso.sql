USE [Petrovendor]

GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_HistorialSecundarioProceso'
)
    DROP PROCEDURE SP_HistorialSecundarioProceso;
GO 

/****** Object:  StoredProcedure [dbo].[SP_HistorialSecundarioProceso]    Script Date: 11/05/2021 11:21:56 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <03/03/2020>
-- Description:	<Consulta del detalle del historial>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <11/05/2020>
-- Description:	Se agrega isnull a textos
-- =============================================
CREATE PROCEDURE [dbo].[SP_HistorialSecundarioProceso] --3,12
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
				WHEN T.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' aprobo la solicitud de pedido N.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 3 THEN ISNULL(US.Nombre,'') + ' rechazo la solicitud de pedido N.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 6 THEN ISNULL(US.Nombre,'') + '(Asignador) cancelo la solicitud de pedido N.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 7 THEN ISNULL(US.Nombre,'') + ' reasigno la solicitud de pedido N.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)) + '.'
			END,
			T.FechaCambioEstatus,
			CASE 
				WHEN T.IdEstatus = 2 THEN 2
				ELSE 3
			END
		FROM dbo.MM_SolicitudPedido AS SP
			LEFT JOIN dbo.TA_Operacion AS OP
				ON SP.IdSolicitudPedido =OP.IdDocumento 
				AND OP.IdTipoOperacion = 2
			LEFT JOIN dbo.TA_Tarea AS T
				ON OP.IdOperacion =T.IdOperacion 
			LEFT JOIN dbo.S_Usuario AS US
				ON T.IdAprobador = US.IdUsuario 
		WHERE SP.IdSolicitudPedido = @IdDocumento
			AND T.IdEstatus <> 1
			AND T.Activo = 1
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
			'Finalizó la evaluación de la requisición.<br>' + 'La solicitud de pedido N.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(10)) + ' fue ' + ISNULL(TA.Nombre,'') + '.',
			HF.Fecha,
			TA.IdEstatus
		FROM dbo.MM_SolicitudPedido AS SP
			LEFT JOIN dbo.TA_Operacion AS OP
				ON SP.IdSolicitudPedido = OP.IdDocumento  
				AND OP.IdTipoOperacion = 2--> APROBACIÓN DE SOLPED
			LEFT JOIN dbo.TA_HistorialFlujoTarea AS HF
				ON OP.IdOperacion = HF.IdOperacion 
			LEFT JOIN dbo.TA_Estatus AS TA
				ON OP.IdEstatusOperacion  = TA.IdEstatus 
		WHERE SP.IdSolicitudPedido = @IdDocumento
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
				WHEN SP.IdTipoProceso = 2 THEN REPLACE(CONCAT(US.Nombre , ' envio una solicitud de cotización bajo el metodo de mercadeo, a los Proveedores : ' , (SELECT '| -' + ISNULL(PR.RazonSocial,'')
																																							FROM dbo.MM_PeticionOferta AS PO
																																							INNER JOIN dbo.S_Proveedor AS PR
																																								ON PO.IdSubcontratista = PR.IdProveedor 
																																							WHERE PO.IdSolicitudPedido = TOPA.IdDocumento
																																							FOR XML PATH (''))),'|','<br>')
				WHEN SP.IdTipoProceso = 4 THEN REPLACE(CONCAT(US.Nombre , ' envio una solicitud de cotización bajo el metodo de adjudciación directa, al Proveedor : ' , (SELECT '| -' + ISNULL(PR.RazonSocial,'')
																																							FROM dbo.MM_PeticionOferta AS PO
																																							INNER JOIN dbo.S_Proveedor AS PR
																																								ON PR.IdProveedor = PO.IdSubcontratista
																																							WHERE PO.IdSolicitudPedido = TOPA.IdDocumento
																																							FOR XML PATH (''))),'|','<br>')

				WHEN SP.IdTipoProceso = 6 THEN REPLACE(CONCAT(US.Nombre , ' envio una solicitud de cotización bajo el metodo de adjudciación directa, al Proveedor : ' , (SELECT '| -' + ISNULL(PR.RazonSocial,'')
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
				ON SP.IdSolicitudPedido = TOPA.IdDocumento 
				AND TOPA.IdTipoOperacion = 6
			LEFT JOIN dbo.S_Usuario AS US
				ON TOPA.IdAsignador = US.IdUsuario  
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
			ISNULL(US.Nombre + ' de ','')  + ISNULL(PR.RazonSocial,'') + ' envió su cotización.',
			PO.FechaFinalizado,
			2
		FROM dbo.MM_SolicitudPedido AS SP
			LEFT JOIN dbo.MM_PeticionOferta AS PO
				ON SP.IdSolicitudPedido = PO.IdSolicitudPedido 
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PO.IdSubcontratista = PR.IdProveedor
			LEFT JOIN dbo.S_Usuario AS US
				ON PO.ModificadoPor = US.IdUsuario
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
			ISNULL(US.Nombre,'Se') + ' cambio la fecha límite de cotización a ' + CONVERT(VARCHAR,HC.FechaNueva,22)  + '.',
			HC.FechaEdicion,
			1
		FROM dbo.MM_HistorialCambiosCotizacion AS HC
			LEFT JOIN dbo.S_Usuario AS US
				ON HC.IdEditadoPor = US.IdUsuario
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
				WHEN T.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' aprobó el Pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 3 THEN ISNULL(US.Nombre,'') + ' rechazó el pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 6 THEN ISNULL(US.Nombre,'') + '(Asignador) cancelo el pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 7 THEN ISNULL(US.Nombre,'') + ' reasignó el pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
			END,
			T.FechaCambioEstatus,
			CASE 
				WHEN T.IdEstatus = 2 THEN 
				2
				ELSE 
				3
			END
		FROM dbo.MM_Pedido AS P
			LEFT JOIN dbo.TA_Operacion AS OP
				ON P.IdSolicitudPedido= OP.IdDocumento 
				AND OP.IdTipoOperacion = 9
				AND P.Version =OP.NoVersion  
			LEFT JOIN dbo.TA_Tarea AS T
				ON OP.IdOperacion=T.IdOperacion 
			LEFT JOIN dbo.S_Usuario AS US
				ON T.IdAprobador = US.IdUsuario 
			LEFT JOIN dbo.MM_Pedidos AS PS
				ON P.IdPedido = PS.IdIdentificador 
				AND P.IdProveedorCompras = PS.IdProveedorCliente
				AND PS.IdTipoPedido IN (2,4,6) ---(Mer, AD, OT)
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
				ON P.IdSolicitudPedido = OP.IdDocumento 
				AND OP.IdTipoOperacion = 9
				AND P.Version = OP.NoVersion 
			LEFT JOIN dbo.S_Usuario AS US
				ON OP.IdAsignador = US.IdUsuario
			LEFT JOIN dbo.MM_Pedidos AS PS
				ON P.IdPedido = PS.IdIdentificador  
				AND P.IdProveedorCompras= PS.IdProveedorCliente
				AND PS.IdTipoPedido IN (2,4,6) ---(Mer, AD, OT)
			LEFT JOIN dbo.TA_HistorialFlujoTarea AS HF
				ON OP.IdOperacion = HF.IdOperacion 
			LEFT JOIN dbo.TA_Estatus AS TA
				ON OP.IdEstatusOperacion = TA.IdEstatus 
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
				WHEN P.RecepcionServicio = 1 THEN ISNULL(PR.RazonSocial,'') + ' confirmó la recepción del servicio del Pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
				WHEN P.RecepcionServicio = 0 THEN ISNULL(PR.RazonSocial,'') + ' rechazo la recepción del servicio del Pedido N.' + CAST(PS.IdPedido AS NVARCHAR(100)) + '.'
			END,
			ISNULL(P.FechaRecepcionServicio,P.CreadoEl) AS FechaRecepcionServicio,
			CASE
				WHEN P.RecepcionServicio = 1 THEN 2
				WHEN P.RecepcionServicio = 0 THEN 3
			END
		FROM dbo.MM_Pedido AS P
			LEFT JOIN dbo.TA_Operacion AS OP
				ON P.IdSolicitudPedido = OP.IdDocumento 
				AND OP.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
				AND P.Version = OP.NoVersion 
			LEFT JOIN dbo.MM_Pedidos AS PS
				ON  P.IdPedido = PS.IdIdentificador 
				AND P.IdProveedorCompras = PS.IdProveedorCliente
				AND PS.IdTipoPedido IN (2,4,6) ---(Mer, AD, OT)
			LEFT JOIN dbo.S_Proveedor AS PR
				ON  P.IdSubcontratista = PR.IdProveedor
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
			ISNULL(US.Nombre,'') + ' registro la Aceptacion N.' + CAST(AP.IdAceptacionPedido AS NVARCHAR(10)) + ', del Pedido N.' + CAST(PS.IdPedido AS NVARCHAR(10)) + '.',
			AP.Creado,
			2,
			1,
			1,
			'/02Proveedores/AceptacionDetalle.aspx?aceptacion=' + CAST(AP.IdAceptacionPedido AS NVARCHAR(10))
		FROM dbo.MM_AceptacionPedido AS AP
			LEFT JOIN dbo.S_Usuario AS US
				ON AP.CreadorPor = US.IdUsuario
			LEFT JOIN dbo.MM_Pedido AS P
				ON AP.IdPedido = P.IdPedido 
			LEFT JOIN dbo.MM_Pedidos AS PS
				ON P.IdPedido = PS.IdIdentificador 
				AND PS.IdProveedorCliente = P.IdProveedorCompras
				AND PS.IdTipoPedido IN (2,4,6) ---(Mer, AD, OT)
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
			ISNULL(US.Nombre,'Se') + ' solicito excluir la Carta de Contenido Nacional para la Aceptacion N.' + CAST(SECN.IdAceptacionPedido AS NVARCHAR(10)) + '.',
			SECN.FechaSolicitud,
			1
		FROM dbo.MM_Solicitud_ExclucionCN AS SECN
			LEFT JOIN dbo.S_Usuario AS US
				ON SECN.IdUsuarioRequesitor = US.IdUsuario 
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
				WHEN SECN.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' aprobó la solicitud para excluir la Carta de Contenido Nacional para la Aceptacion N.' + CAST(SECN.IdAceptacionPedido AS NVARCHAR(10)) + '.'
				WHEN SECN.IdEstatus = 3 THEN ISNULL(US.Nombre,'') + ' rechazó la solicitud para excluir la Carta de Contenido Nacional para la Aceptacion N.' + CAST(SECN.IdAceptacionPedido AS NVARCHAR(10)) + '.'
			END,
			SECN.FechaSolicitud,
			SECN.IdEstatus
		FROM dbo.MM_Solicitud_ExclucionCN AS SECN
			LEFT JOIN dbo.S_Usuario AS US
				ON SECN.UsuarioAprobador = US.IdUsuario 
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
			ISNULL(US.Nombre + ' de ','') + ISNULL(PR.RazonSocial,'') + ' registro la Carta de Contenido Nacional de la Aceptación N.' + CAST(ACN.IdAceptacionPedido AS NVARCHAR(10)),
			ACN.CreadoEl,
			1,
			1,
			'/02Proveedores/AprobacionCNDetalle.aspx?aceptacion=' + CAST(ACN.IdAceptacionCartaPCN AS NVARCHAR(10))
		FROM dbo.MM_AceptacionCartaPCN AS ACN
			LEFT JOIN dbo.S_Usuario AS US
				ON ACN.CreadoPor = US.IdUsuario  
			LEFT JOIN dbo.MM_AceptacionPedido AS AP
				ON ACN.IdAceptacionPedido = AP.IdAceptacionPedido 
			LEFT JOIN dbo.MM_Pedido AS P
				ON AP.IdPedido = P.IdPedido 
			LEFT JOIN dbo.S_Proveedor AS PR
				ON P.IdSubcontratista = PR.IdProveedor 
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
				WHEN ACN.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' aprobó la Carta de Contenido Nacional de la Aceptación N.' + CAST(ACN.IdAceptacionPedido AS NVARCHAR(10))
				WHEN ACN.IdEstatus = 3 THEN ISNULL(US.Nombre,'') + ' rechazó la Carta de Contenido Nacional de la Aceptación N.' + CAST(ACN.IdAceptacionPedido AS NVARCHAR(10))
			END,
			ACN.FechaEvaluacion,
			ACN.IdEstatus
		FROM dbo.MM_AceptacionCartaPCN AS ACN
			LEFT JOIN dbo.S_Usuario AS US
				ON  ACN.IdUsuarioEvaluador = US.IdUsuario 
			LEFT JOIN dbo.MM_AceptacionPedido AS AP
				ON ACN.IdAceptacionPedido = AP.IdAceptacionPedido  
			LEFT JOIN dbo.MM_Pedido AS P
				ON AP.IdPedido = P.IdPedido 
			LEFT JOIN dbo.S_Proveedor AS PR
				ON P.IdSubcontratista = PR.IdProveedor 
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
			ISNULL(US.Nombre + ' de ','') + ISNULL(PR.RazonSocial,'') + ' cargo y envió la factura para su aprobación de la Aceptación N.' + CAST(AF.IdAceptacionPedido AS NVARCHAR(10)),
			OP.FechaRegistro,
			1,
			1,
			'/02Proveedores/RecepcionVentanillaDetalle.aspx?aceptacion=' + CAST(AF.IdAceptacionPedido AS NVARCHAR(10))
		FROM dbo.MM_AceptacionFactura AS AF
			LEFT JOIN dbo.MM_AceptacionPedido AS AP
				ON AF.IdAceptacionPedido = AP.IdAceptacionPedido 
			LEFT JOIN dbo.MM_Pedido AS P
				ON AP.IdPedido = P.IdPedido 
			LEFT JOIN dbo.S_Proveedor AS PR
				ON  P.IdSubcontratista = PR.IdProveedor
			LEFT JOIN dbo.TA_Operacion AS OP
				ON AF.IdAceptacionFactura =  OP.IdDocumento 
				AND OP.IdTipoOperacion = 10
			LEFT JOIN dbo.FI_Factura AS F
				ON  AF.IdFactura = F.IdFactura
			LEFT JOIN dbo.S_Usuario AS US
				ON F.CreadoPor = US.IdUsuario 
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
				WHEN T.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' aprobó la factura N.' + CAST(AF.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 3 THEN ISNULL(US.Nombre,'')  + ' rechazó la factura N.' + CAST(AF.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 6 THEN ISNULL(US.Nombre,'')  + '(Asignador) cancelo la factura N.' + CAST(AF.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 7 THEN ISNULL(US.Nombre,'')  + ' reasigno la factura N.' + CAST(AF.IdAceptacionPedido AS NVARCHAR(100)) + '.'
			END,
			T.FechaCambioEstatus,
			CASE 
				WHEN T.IdEstatus = 2 THEN 2
				ELSE 3
			END
		FROM dbo.MM_AceptacionFactura AS AF
			LEFT JOIN dbo.MM_AceptacionPedido AS AP
				ON AF.IdAceptacionPedido= AP.IdAceptacionPedido 
			LEFT JOIN dbo.MM_Pedido AS P
				ON AP.IdPedido= P.IdPedido 
			LEFT JOIN dbo.S_Proveedor AS PR
				ON P.IdSubcontratista= PR.IdProveedor 
			LEFT JOIN dbo.TA_Operacion AS OP
				ON AF.IdAceptacionFactura= OP.IdDocumento 
				AND OP.IdTipoOperacion = 10
			LEFT JOIN dbo.S_Usuario AS US
				ON OP.IdAsignador =US.IdUsuario 
			LEFT JOIN dbo.TA_Tarea AS T
				ON OP.IdOperacion =T.IdOperacion 
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
			ISNULL(HF.Descripcion,'') + ', fue ' + ISNULL(TE.Nombre,''),
			HF.Fecha,
			OP.IdEstatusOperacion
		FROM dbo.MM_AceptacionFactura AS AF
			LEFT JOIN dbo.MM_AceptacionPedido AS AP
				ON AF.IdAceptacionPedido= AP.IdAceptacionPedido
			LEFT JOIN dbo.MM_Pedido AS P
				ON AP.IdPedido= P.IdPedido 
			LEFT JOIN dbo.TA_Operacion AS OP
				ON  AF.IdAceptacionFactura = OP.IdDocumento 
				AND OP.IdTipoOperacion = 10
			LEFT JOIN dbo.TA_HistorialFlujoTarea AS HF
				ON OP.IdOperacion= HF.IdOperacion
			LEFT JOIN dbo.TA_Estatus AS TE
				ON OP.IdEstatusOperacion= TE.IdEstatus 
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
			ISNULL(US.Nombre,'') + ' registro el Pedimento/Comprobante Extranjero de la Aceptación N.' + CAST(APPC.IdAceptacionPedido AS NVARCHAR(10)) + ' para su aprobación.',
			APPC.CreadoEl,
			1,
			1,
			'/02Proveedores/PC_PedimentoComprobanteDetalle.aspx?aceptacion=',
			1
		FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APPC
			LEFT JOIN dbo.S_Usuario AS US
				ON  APPC.CreadoPor = US.IdUsuario 
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
				WHEN T.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' aprobo el Pedimento/Comprobante Extranjero de la aceptación N.' + CAST(APPC.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 3 THEN ISNULL(US.Nombre,'') + ' rechazo el Pedimento/Comprobante Extranjero de la aceptación N.' + CAST(APPC.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 6 THEN ISNULL(US.Nombre,'') + '(Asignador) cancelo del Pedimento/Comprobante Extranjero aceptación N.' + CAST(APPC.IdAceptacionPedido AS NVARCHAR(100)) + '.'
				WHEN T.IdEstatus = 7 THEN ISNULL(US.Nombre,'') + ' reasigno el Pedimento/Comprobante Extranjero N.' + CAST(APPC.IdAceptacionPedido AS NVARCHAR(100)) + '.'
			END,
			T.FechaCambioEstatus,
			CASE 
				WHEN T.IdEstatus = 2 THEN 2
				ELSE 3
			END
		FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APPC
			LEFT JOIN dbo.TA_Operacion AS OP
				ON APPC.IdPedimentoComprobante = OP.IdDocumento 
				AND OP.IdTipoOperacion = 16
			LEFT JOIN dbo.TA_Tarea AS T
				ON  OP.IdOperacion = T.IdOperacion
			LEFT JOIN dbo.S_Usuario AS US
				ON T.IdAprobador = US.IdUsuario 
		WHERE APPC.IdAceptacionPedido = @IdDocumento
			AND T.Activo = 1 
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
			ISNULL(HF.Descripcion,'') + ', fue ' + ISNULL(ES.Nombre,''),
			HF.Fecha,
			OP.IdEstatusOperacion
		FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APPC
			LEFT JOIN dbo.TA_Operacion AS OP
				ON  APPC.IdPedimentoComprobante = OP.IdDocumento
				AND OP.IdTipoOperacion = 16
			LEFT JOIN dbo.TA_HistorialFlujoTarea AS HF
				ON OP.IdOperacion =  HF.IdOperacion
			LEFT JOIN dbo.TA_Estatus AS ES
				ON OP.IdEstatusOperacion = ES.IdEstatus 
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
				WHEN PRS.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' approve the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
				WHEN PRS.IdEstatus = 3 THEN ISNULL(US.Nombre,'') + ' reject the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
			END,
			PRS.ModificadoEl,
			PRS.IdEstatus
		FROM Adinco.dbo.CO_SAPPRESES AS PRS
			LEFT JOIN dbo.S_Usuario AS US
				ON PRS.ModificadoPor= US.IdUsuario 
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
				WHEN AC.Editado = 1 THEN ISNULL(US.Nombre,'') + ' reject the national content letter of the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10)) + ' to edit and reload (AUTOMATIC REJECTION FOR EDITING)'
				WHEN AC.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' approve the national content letter of the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
				WHEN AC.IdEstatus = 3 THEN ISNULL(US.Nombre,'') + ' reject the national content letter of the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
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
				WHEN AF.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' approve the invoice of the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
				WHEN AF.IdEstatus = 3 THEN ISNULL(US.Nombre,'') + ' rejecte the invoice of the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))
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
