-- =============================================
-- Author:		DANIEL AC
-- Update date: 07/02/2018
-- Description:	agregue filtro para todos los estatus de carta de contenido nacional y cambio tipo pedido
-- Author:		DANIEL AC
-- Update date: 01/06/2018
-- Description:	Se agrego condicion solo mostrar aquellas aprobaciones con aceptacion de carta de contenido nacional diferente a estatus eliminado =!
-- Author:		Alexander Gomez
-- Update date: 04/12/2018
-- Description:	se agregaron las adecuaciones para murphy
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_ListaAprobacionCN_S3] --364,0
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@Estado INT,
@IdContrato NVARCHAR(MAX)
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

	CREATE TABLE #AceptacionesPedido(
	IdAceptacionCartaPCN INT NULL,
	IdAceptacionPedido INT null,
	Pedido NVARCHAR(max) null,
	IdDocumento INT NULL,
	IdPedido INT null,
	CreadoEl DATETIME null,
	TipoValidacion NVARCHAR(100) null,
	Proveedor NVARCHAR(100) null,
	IdPedidoGeneral INT null,
	TipoPedido NVARCHAR(100) null,
	IdSolicitudPedido NVARCHAR(100) NULL,
	span NVARCHAR(100) NULL
	);

	 IF @Estado IN (1,2,3) 
	 BEGIN
		INSERT INTO #AceptacionesPedido
        SELECT 
			AC.IdAceptacionCartaPCN, 
			Ac.IdAceptacionPedido,
			PG.IdPedido, 
			AC.IdDocumento, 
			AP.IdPedido,
			Ac.CreadoEl,
			TD.TipoValidacion,
			CONCAT(PR.RazonSocial ,' ', ISNULL(PR.RegimenCapital,'')) AS Proveedor,
			PG.IdPedido AS IdPedidoGeneral,
			TP.TipoPedido,
			P.IdSolicitudPedido,
			CASE
				WHEN TD.IdTipoValidacionDoc = 2 THEN 'label label-success'
				WHEN TD.IdTipoValidacionDoc = 1 THEN 'label label-primary'
				WHEN TD.IdTipoValidacionDoc = 3 THEN 'label label-danger'
				WHEN TD.IdTipoValidacionDoc IS NULL THEN 'label label-default'
			END
		FROM [dbo].[MM_AceptacionCartaPCN] AS AC
		INNER JOIN [dbo].[S_Documento_S3] AS D ON D.IdDocumento = AC.IdDocumento
		INNER JOIN [dbo].[MM_AceptacionPedido] AS AP ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		INNER JOIN [dbo].[MM_Pedido] AS P ON P.IdPedido = AP.IdPedido
		INNER JOIN [dbo].[S_Proveedor] AS PR ON PR.IdProveedor = P.IdSubcontratista
		INNER JOIN [dbo].[S_TipoValidacionDoc] AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
		INNER JOIN [dbo].[MM_Pedidos] AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
	    LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
		WHERE 
		P.IdProveedorCompras = @IdProveedor 
		AND AC.IdEstatus = @Estado
		AND ISNULL(AC.IdEstatusEliminado,0) <>1   --> QUE NO ESTEN ELIMINADOS
		ORDER BY  Ac.IdAceptacionPedido DESC;

		INSERT INTO #AceptacionesPedido
		SELECT 
			AC.IdAceptacionCartaPCN, 
			AC.IdAceptacionPedido, 
			CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS,' ','- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS ,' - Proforma Number:', CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS), 
			AC.IdDocumento,
			00, 
			AC.CreadoEl,
			TD.TipoValidacion,
			ISNULL(SPV.VendorName,PR.RazonSocial) AS Proveedor,			 
			00,
			'N/A',
			CONCAT('Reference Number: ',AP.ReferenceNumber),
			CASE
				WHEN TD.IdTipoValidacionDoc = 2 THEN 'label label-success'
				WHEN TD.IdTipoValidacionDoc = 1 THEN 'label label-primary'
				WHEN TD.IdTipoValidacionDoc = 3 THEN 'label label-danger'
				WHEN TD.IdTipoValidacionDoc IS NULL THEN 'label label-default'
			END
		FROM dbo.MPY_MM_AceptacionPedido AS AP 
		LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		LEFT JOIN [dbo].[S_Documento_S3] AS D ON D.IdDocumento = AC.IdDocumento
		LEFT JOIN [dbo].[S_Proveedor] AS PR ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1
		LEFT JOIN [dbo].[S_TipoValidacionDoc] AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS SPV ON  SPV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN
		WHERE 
		AP.IdContrato = @IdContrato
		AND AC.IdAceptacionCartaPCN IS NOT NULL
		AND AC.IdEstatus = @Estado
		AND ISNULL(AC.IdEstatusEliminado,0) <> 1  --> QUE NO ESTEN ELIMINADOS
		GROUP BY CONCAT(
                 'PO Number:',
                 AP.IdPedido COLLATE Modern_Spanish_CI_AS,
                 ' ',
                 '- SES Number: ',
                 SES.SESNumber COLLATE Modern_Spanish_CI_AS,
                 ' - Proforma Number:',
                 CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS
                 ),
                 ISNULL(SPV.VendorName, PR.RazonSocial),
                 CASE
                 WHEN TD.IdTipoValidacionDoc = 2 THEN
                 'label label-success'
                 WHEN TD.IdTipoValidacionDoc = 1 THEN
                 'label label-primary'
                 WHEN TD.IdTipoValidacionDoc = 3 THEN
                 'label label-danger'
                 WHEN TD.IdTipoValidacionDoc IS NULL THEN
                 'label label-default'
                 END,
                 AC.IdAceptacionCartaPCN,
                 AC.IdAceptacionPedido,
                 AC.IdDocumento,
                 AC.CreadoEl,
                 TD.TipoValidacion,
				 ap.ReferenceNumber
		ORDER BY  Ac.IdAceptacionPedido DESC;

     END;

	 IF @Estado = 0  ---TODOS
	 BEGIN	     
		INSERT INTO #AceptacionesPedido
        SELECT 
			AC.IdAceptacionCartaPCN, 
			Ac.IdAceptacionPedido, 
			PG.IdPedido, 
			AC.IdDocumento, 
			AP.IdPedido, 
			Ac.CreadoEl,
			TD.TipoValidacion,
			CONCAT(PR.RazonSocial ,' ', ISNULL(PR.RegimenCapital,'')) AS Proveedor,	
			PG.IdPedido AS IdPedidoGeneral,
			TP.TipoPedido,
			P.IdSolicitudPedido,
			CASE
				WHEN TD.IdTipoValidacionDoc = 2 THEN 'label label-success'
				WHEN TD.IdTipoValidacionDoc = 1 THEN 'label label-primary'
				WHEN TD.IdTipoValidacionDoc = 3 THEN 'label label-danger'
				WHEN TD.IdTipoValidacionDoc IS NULL THEN 'label label-default'
			END
		FROM [dbo].[MM_AceptacionCartaPCN] AS AC
		INNER JOIN [dbo].[S_Documento_S3] AS D ON D.IdDocumento = AC.IdDocumento
		INNER JOIN [dbo].[MM_AceptacionPedido] AS AP ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		INNER JOIN [dbo].[MM_Pedido] AS P ON P.IdPedido = AP.IdPedido
		INNER JOIN [dbo].[S_Proveedor] AS PR ON PR.IdProveedor = P.IdSubcontratista
		INNER JOIN [dbo].[S_TipoValidacionDoc] AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
		INNER JOIN [dbo].[MM_Pedidos] AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
	    LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
		WHERE  P.IdProveedorCompras = @IdProveedor
		AND ISNULL(AC.IdEstatusEliminado,0) <> 1  --> QUE NO ESTEN ELIMINADOS
		ORDER BY  Ac.IdAceptacionPedido DESC;

		INSERT INTO #AceptacionesPedido
		SELECT 
			AC.IdAceptacionCartaPCN, 
			AC.IdAceptacionPedido, 
			CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS,' ','- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS ,' - Proforma Number:', CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS), 
			AC.IdDocumento,
			00, 
			AP.Creado AS CreadoEl,
			ISNULL(TD.TipoValidacion, 'Sin Iniciar AprobaciÛn') AS TipoValidacion,
			ISNULL(SPV.VendorName,PR.RazonSocial) AS Proveedor,
			00,
			'N/A',
			CONCAT('Reference Number: ',AP.ReferenceNumber),
			CASE
				WHEN TD.IdTipoValidacionDoc = 2 THEN 'label label-success'
				WHEN TD.IdTipoValidacionDoc = 1 THEN 'label label-primary'
				WHEN TD.IdTipoValidacionDoc = 3 THEN 'label label-danger'
				WHEN TD.IdTipoValidacionDoc IS NULL THEN 'label label-default'
			END
		FROM dbo.MPY_MM_AceptacionPedido AS AP 
		JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		LEFT JOIN [dbo].[S_Documento_S3] AS D ON D.IdDocumento = AC.IdDocumento
		LEFT JOIN [dbo].[S_Proveedor] AS PR ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1
		LEFT JOIN [dbo].[S_TipoValidacionDoc] AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS SPV ON  SPV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN
		WHERE 
		AP.IdContrato = @IdContrato
		AND AC.IdAceptacionCartaPCN IS NOT NULL
		AND ISNULL(AC.IdEstatusEliminado,0) <> 1  --> QUE NO ESTEN ELIMINADOS
		GROUP BY CONCAT(
                 'PO Number:',
                 AP.IdPedido COLLATE Modern_Spanish_CI_AS,
                 ' ',
                 '- SES Number: ',
                 SES.SESNumber COLLATE Modern_Spanish_CI_AS,
                 ' - Proforma Number:',
                 CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS
                 ),
                 ISNULL(TD.TipoValidacion, 'Sin Iniciar AprobaciÛn'),
                 ISNULL(SPV.VendorName, PR.RazonSocial),
                 CASE
                 WHEN TD.IdTipoValidacionDoc = 2 THEN
                 'label label-success'
                 WHEN TD.IdTipoValidacionDoc = 1 THEN
                 'label label-primary'
                 WHEN TD.IdTipoValidacionDoc = 3 THEN
                 'label label-danger'
                 WHEN TD.IdTipoValidacionDoc IS NULL THEN
                 'label label-default'
                 END,
                 AC.IdAceptacionCartaPCN,
                 AC.IdAceptacionPedido,
                 AC.IdDocumento,
                 AP.Creado,
				 AP.ReferenceNumber
		ORDER BY  AP.Creado DESC;

     END

	 SELECT DISTINCT
		ROW_NUMBER() OVER(ORDER BY CreadoEl DESC) AS IdRow,
		IdAceptacionCartaPCN,
		IdAceptacionPedido,
		Pedido,
		IdDocumento,
		IdPedido,
		CreadoEl,
		TipoValidacion,
		Proveedor,
		IdPedidoGeneral,
		TipoPedido,
		IdSolicitudPedido,
		span
	 FROM #AceptacionesPedido ORDER BY CreadoEl DESC;
END