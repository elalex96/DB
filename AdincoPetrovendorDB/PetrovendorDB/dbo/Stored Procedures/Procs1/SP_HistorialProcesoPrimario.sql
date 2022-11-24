-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <03/02/2020>
-- Description:	<Consuta principal del historial de una solped>
-- =============================================
CREATE PROCEDURE [dbo].[SP_HistorialProcesoPrimario] --9
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @HISTORIAL TABLE (
		IdDocumento INT,
		Proceso NVARCHAR(100),
		Descripcion NVARCHAR(1000),
		Fecha DATETIME,
		IdProceso INT,
		Url NVARCHAR(1000),
		IsEncriptado BIT,
		tieneHistorial BIT	
	);
	
	INSERT INTO @HISTORIAL
	(
		IdDocumento,
		Proceso,
		Descripcion,
		Fecha,
		IdProceso,
		Url,
		tieneHistorial
	)
	SELECT
		R.IdSolPedAnterior,
		'Reciclaje de Solicitud de Pedido',
		ISNULL(US.Nombre,'') + ' registro la solicitud de pedido N.' + CAST(R.IdSolPedNueva AS NVARCHAR(10)) + ', reciclada de los datos de la solicitud de pedido N.' + CAST(R.IdSolPedAnterior AS NVARCHAR(10)),
		DATEADD(SECOND,-1,SP.FechaAlta),
		0,
		'/01Proveedores/SP_DetalleSolicitudPedido.aspx?solped=' + CAST(R.IdSolPedAnterior AS NVARCHAR(10)) + '&origin=s&tp_user=2',
		0
	FROM dbo.TA_RecicajeSolPed AS R
		LEFT JOIN dbo.MM_SolicitudPedido AS SP
			ON R.IdSolPedNueva = SP.IdSolicitudPedido
		LEFT JOIN dbo.S_Usuario AS US
			ON  SP.IdUsuarioSolicitante = US.IdUsuario
	WHERE R.IdSolPedNueva = @IdSolicitudPedido;

	INSERT INTO @HISTORIAL
	(
		IdDocumento,
		Proceso,
		Descripcion,
		Fecha,
		IdProceso,
		Url
	)
	SELECT
		SP.IdSolicitudPedido,
		'Solicitud de Pedido No. ' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)),
		ISNULL(US.Nombre,'') + ' registro de la Solicitud de Pedido No.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)) + ' para su aprobación.',
		SP.FechaAlta,
		1, --SOLICITUD DE PEDIDO
		'/01Proveedores/SP_DetalleSolicitudPedido.aspx?solped=' + CAST(SP.IdSolicitudPedido AS nvarchar(10)) +'&origin=s&tp_user=2'
	FROM dbo.MM_SolicitudPedido AS SP
		LEFT JOIN dbo.S_Usuario AS US
			ON SP.IdUsuarioSolicitante = US.IdUsuario 
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido;

	INSERT INTO @HISTORIAL
	(
		IdDocumento,
		Proceso,
		Descripcion,
		Fecha,
		IdProceso,
		Url,
		IsEncriptado
	)
	SELECT
		SP.IdSolicitudPedido,
		'Solicitud de Cotización No. ' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)),
		'Fecha limite de cotización: ' + CONVERT(VARCHAR,TOA.FechaFinalizacion,22) + '.',
		TOA.FechaRegistro,
		2, --PETICION OFERTA
		'/01Proveedores/DetallePeticionOfertav2.aspx?solped=',
		1
	FROM dbo.MM_SolicitudPedido AS SP
	LEFT JOIN dbo.TA_Operacion AS TOA
	 ON SP.IdSolicitudPedido = TOA.IdDocumento 
		AND TOA.IdTipoOperacion = 6
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
		AND TOA.IdOperacion IS NOT NULL;

	DECLARE @ISHISTCOTI INT = 0;
	DECLARE @HISTCO TABLE (
		HISTORICO INT
	);

	INSERT INTO @HISTCO
	SELECT
		PO.IdPeticionOferta
	FROM dbo.MM_SolicitudPedido AS SP
			LEFT JOIN dbo.MM_PeticionOferta AS PO
				ON SP.IdSolicitudPedido = PO.IdSolicitudPedido 
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PO.IdSubcontratista = PR.IdProveedor 
			LEFT JOIN dbo.S_Usuario AS US
				ON PO.ModificadoPor = US.IdUsuario 
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
			AND PO.FechaFinalizado IS NOT NULL
			AND SP.IdEstatusEliminado IS NULL;

	INSERT INTO @HISTCO
	SELECT
		HC.Id_Historial
	FROM dbo.MM_HistorialCambiosCotizacion AS HC
			LEFT JOIN dbo.S_Usuario AS US
				ON HC.IdEditadoPor = US.IdUsuario
	WHERE HC.IdSolicitudPedido = @IdSolicitudPedido;

	IF (SELECT COUNT(HISTORICO) FROM @HISTCO) > 0
	BEGIN
	    SET @ISHISTCOTI = 1;
	END

	INSERT INTO @HISTORIAL
	(
		IdDocumento,
		Proceso,
		Descripcion,
		Fecha,
		IdProceso,
		Url,
		IsEncriptado,
		tieneHistorial
	)
	SELECT
		SP.IdSolicitudPedido,
		'Fecha Límite de la Cotización para la Solicitud de Pedido No. ' + CAST(SP.IdSolicitudPedido AS NVARCHAR(100)),
		'Finalizó la cotización.',
		TOA.FechaFinalizacion,
		3, --COTIZACION
		CASE
			WHEN SP.IdTipoProceso = 2 THEN '/02Proveedores/DetalleOferta.aspx?solped=' + CAST(SP.IdSolicitudPedido AS NVARCHAR(10))
			WHEN SP.IdTipoProceso = 4 THEN '/01Proveedores/DetalleADOferta.aspx?solped='
			WHEN SP.IdTipoProceso = 6 THEN '/02Proveedores/DetalleOferta.aspx?solped=' + CAST(SP.IdSolicitudPedido AS NVARCHAR(10))
		END,
		CASE
			WHEN SP.IdTipoProceso = 2 THEN 0
			WHEN SP.IdTipoProceso = 4 THEN 1
			WHEN SP.IdTipoProceso = 6 THEN 0
		END,
		@ISHISTCOTI
	FROM dbo.MM_SolicitudPedido AS SP
	LEFT JOIN dbo.TA_Operacion AS TOA
	 ON  SP.IdSolicitudPedido = TOA.IdDocumento
		AND TOA.IdTipoOperacion = 6
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
		AND TOA.IdOperacion IS NOT NULL;

	INSERT INTO @HISTORIAL
	(
		IdDocumento,
		Proceso,
		Descripcion,
		Fecha,
		IdProceso,
		Url
	)
	SELECT
		P.IdPedido,
		'Pedido No. ' + CAST(PS.IdPedido AS NVARCHAR(100)),
		ISNULL(US.Nombre,'') + ' registro el Pedido No.' + CAST(PS.IdPedido AS NVARCHAR(100)) + ', para su aprobación.',
		P.CreadoEl,
		4, --PEDIDO
		'/02Proveedores/PedidoDetalle.aspx?ped=' + CAST(P.IdPedido AS NVARCHAR(10)) + '&type=2'
	FROM dbo.MM_SolicitudPedido AS SP
	LEFT JOIN dbo.TA_Operacion AS TOA
	 ON  SP.IdSolicitudPedido = TOA.IdDocumento 
		AND TOA.IdTipoOperacion = 9
	LEFT JOIN dbo.MM_Pedido AS P
		ON SP.IdSolicitudPedido = P.IdSolicitudPedido  
		 AND P.Version = TOA.NoVersion
	LEFT JOIN dbo.MM_Pedidos AS PS
		ON  P.IdPedido = PS.IdIdentificador 
		 AND  P.IdProveedorCompras = PS.IdProveedorCliente
		 AND PS.IdTipoPedido IN (2,4,6)
	LEFT JOIN dbo.S_Proveedor AS PR
		ON  P.IdSubcontratista = PR.IdProveedor
	LEFT JOIN dbo.S_Usuario AS US
		ON  P.CreadoPor =US.IdUsuario 
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
		AND TOA.IdOperacion IS NOT NULL
	ORDER BY P.CreadoEl DESC;

	INSERT INTO @HISTORIAL
	(
		IdDocumento,
		Proceso,
		Descripcion,
		Fecha,
		IdProceso,
		Url,
		IsEncriptado,
		tieneHistorial
	)
	SELECT
		PRS.IdPRESES,
		'Proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10)) + ' - PO No.' + ISNULL(PRS.SAPPONumber,''),
		CONCAT(ISNULL(US.Nombre,'') , ' from ' , ISNULL(VE.VendorName,'') , ' register the proforma N.' , CAST(PRS.IdPRESES AS NVARCHAR(10)) , ', PO N.' , ISNULL(PRS.SAPPONumber,'') ,', Reference No.',ISNULL(PRS.SAPSESNumber,''), ', for you approval.') COLLATE SQL_Latin1_General_CP1_CI_AS,
		PRS.CreadoEl,
		10,--proforma
		'/Murphy/MPY_RecepcionPreFacturaDetalle.aspx?PRESES=' + CAST(PRS.IdPRESES AS NVARCHAR(10)),
		0,
		1
	FROM Adinco.dbo.CO_SAPPRESES AS PRS
		JOIN Adinco.dbo.CO_SAPPO AS PO 
			ON PO.SAPPONumber = PRS.SAPPONumber 
			AND PO.SAPVendorNumber = PRS.SAPVendorNumber
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS VE 
			ON VE.VendorIDSAP = PRS.SAPVendorNumber
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES 
			ON SES.PO_SAPNumer = PRS.SAPPONumber 
			AND SES.SESReferenceNumber = PRS.SAPSESNumber 
			AND SES.SESNumber = PRS.SESN 
		LEFT JOIN Adinco.dbo.CO_SAPGR AS GR 
			ON GR.PO_SAPNumber = PRS.SAPPONumber
		LEFT JOIN dbo.S_Usuario AS US
			ON US.IdUsuario = PRS.CreadoPor 
	WHERE PRS.IdPRESES = @IdSolicitudPedido
	GROUP BY PRS.IdPRESES,
			 PRS.CreadoEl,
			 VE.VendorName,
			 US.Nombre,
			 PRS.SAPPONumber,
			 PRS.SAPPONumber,
			 PRS.SAPSESNumber;

	INSERT INTO @HISTORIAL
	(
		IdDocumento,
		Proceso,
		Descripcion,
		Fecha,
		IdProceso,
		Url,
		IsEncriptado,
		tieneHistorial
	)
	SELECT 
		AC.IdAceptacionCartaPCN,
		'National content letter of the Proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10)) + ', PO No.' + ISNULL(PRS.SAPPONumber,'') + ISNULL(',SES No.' + ISNULL(SES.SESNumber,''),'') COLLATE SQL_Latin1_General_CP1_CI_AS,
		ISNULL(US.Nombre,'') + ' of ' + ISNULL(VE.VendorName,'') + ' register the National content letter of the proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10)) + ', PO No.' + ISNULL(PRS.SAPPONumber,'') + ISNULL(',SES No.' + SES.SESNumber,'') + ', Reference No.' + ISNULL(PRS.SAPSESNumber,'') COLLATE SQL_Latin1_General_CP1_CI_AS,
		AC.CreadoEl,
		11,--contenido nacional para murphy
		'/MurphyExcel/MPY_AprobacionCNDetalle.aspx?aceptacion=' + CAST(AC.IdAceptacionCartaPCN AS NVARCHAR(10)),
		0,
		1
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
			ON US.IdUsuario = AC.CreadoPor
	WHERE PRS.IdPRESES = @IdSolicitudPedido
		AND AC.IdAceptacionCartaPCN IS NOT NULL
		AND PRS.IdEstatus = 2
	GROUP BY AC.IdAceptacionCartaPCN,
			 PRS.SAPPONumber,
			 PRS.SAPSESNumber,
			 AP.IdAceptacionPedido,
			 PRS.IdPRESES,
			 AC.CreadoEl,
			 VE.VendorName,
			 US.Nombre,
			 SES.SESNumber

	INSERT INTO @HISTORIAL
	(
		IdDocumento,
		Proceso,
		Descripcion,
		Fecha,
		IdProceso,
		Url,
		IsEncriptado,
		tieneHistorial
	)
	SELECT 
		AF.IdAceptacionFactura,
		'Invoice Approval of the Proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10)) + ', PO No.' + ISNULL(PRS.SAPPONumber,'') + ISNULL(',SES No.' + SES.SESNumber,'') COLLATE SQL_Latin1_General_CP1_CI_AS,
		'Supplier (' + VE.VendorName + ') upload & send an invoice for approval. (proforma No.' + CAST(PRS.IdPRESES AS NVARCHAR(10))  + ', PO No.' + ISNULL(PRS.SAPPONumber,'') + ISNULL(',SES No.' + SES.SESNumber,'') + ', Reference No.' + ISNULL(PRS.SAPSESNumber,'') + ').' COLLATE SQL_Latin1_General_CP1_CI_AS,
		AF.CreadoEl,
		12,---aprobacion de factura murphy
		'/MurphyExcel/MPY_RecepcionVentanillaDetalle.aspx?aceptacion=' + CAST(AP.IdAceptacionPedido AS NVARCHAR(10)),
		0,
		1
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
			ON US.IdUsuario = F.CreadoPor
	WHERE PRS.IdPRESES = @IdSolicitudPedido
		AND AF.IdAceptacionFactura IS NOT NULL
		AND PRS.IdEstatus = 2
	GROUP BY AP.IdAceptacionPedido,
			 PRS.SAPPONumber,
			 PRS.SAPSESNumber,
			 AP.IdAceptacionPedido,
			 PRS.IdPRESES,
			 AF.CreadoEl,
			 VE.VendorName,
			 US.Nombre,
			 SES.SESNumber,
			 AF.IdAceptacionFactura

	SELECT 
		IdDocumento,
		Proceso,
		Descripcion,
		Fecha,
		IdProceso,
		Url,
		ISNULL(IsEncriptado,0) AS IsEncriptado,
		ISNULL(tieneHistorial,1) AS tieneHistorial
	FROM @HISTORIAL;

END