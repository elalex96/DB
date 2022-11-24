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
-- Author:		LUIS DAVID
-- Create date: 02/03/2022
-- Description:	SE AGREGA EL PO PARA DEA ISSUE#1651
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 07/04/2022
-- Description:	Se agrega la relación a la aceptación del pedido para correcta agrupación #1720
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 03-05-2022
-- Description:	se corrige la consulta de murphy para consultar por contrato 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_ListaAprobacionCN_S3] 
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
	Proveedor NVARCHAR(MAX) null,
	IdPedidoGeneral INT null,
	TipoPedido NVARCHAR(100) null,
	IdSolicitudPedido NVARCHAR(100) NULL,
	span NVARCHAR(MAX) NULL,
	Contrato varchar(50),
	PO varchar(300)
	);

	DECLARE @PLANT NVARCHAR(10) = (SELECT TOP 1
										P.Planta
										FROM Adinco.dbo.CO_Contrato AS C (NOLOCK)
										LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS P (NOLOCK)
											ON C.IdContratista = P.IdContratista
										WHERE C.IdContrato = @IdContrato);



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
			END,
			Contrato = c.NumeroContrato,
			ISNULL(RPO.PO,'Sin PO relacionada') AS PO
		FROM [dbo].[MM_AceptacionCartaPCN] AS AC  (NOLOCK)
		JOIN [dbo].[S_Documento_S3] AS D  (NOLOCK)
			ON AC.IdDocumento = D.IdDocumento
			AND AC.IdEstatus = @Estado
		JOIN [dbo].[MM_AceptacionPedido] AS AP  (NOLOCK)
			ON AC.IdAceptacionPedido = AP.IdAceptacionPedido
		JOIN [dbo].[MM_Pedido] AS P  (NOLOCK)
			ON AP.IdPedido = P.IdPedido
			AND P.IdProveedorCompras = @IdProveedor 		
		JOIN [dbo].[S_Proveedor] AS PR  (NOLOCK)
			ON P.IdSubcontratista = PR.IdProveedor
		JOIN [dbo].[S_TipoValidacionDoc] AS TD   (NOLOCK)
			ON AC.IdEstatus = TD.IdTipoValidacionDoc
		JOIN [dbo].[MM_Pedidos] AS PG  (NOLOCK)
			ON P.IdPedido = PG.IdIdentificador 
			AND PG.IdProveedorCliente = @IdProveedor 
			AND PG.IdTipoPedido IN (2, 4, 6)
		JOIN Adinco.dbo.CO_Contrato	AS	C 	 (NOLOCK)
			ON	P.IdContrato = C.IdContrato
	    LEFT  JOIN dbo.MM_TipoPedido AS TP  (NOLOCK)
			ON PG.IdTipoPedido = TP.IdTipoPedido		
		LEFT JOIN DEA_Relacion_PR_PO AS RPO	 (NOLOCK)
			ON P.IdPedido = RPO.IdPedido
		WHERE ISNULL(AC.IdEstatusEliminado,0) <>1   --> QUE NO ESTEN ELIMINADOS
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
			END,
			Contrato = c.NumeroContrato,
			PO.SAPPONumber AS PO
		FROM dbo.MPY_MM_AceptacionPedido AS AP  (NOLOCK)
		LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC  (NOLOCK)
			ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		LEFT JOIN [dbo].[S_Documento_S3] AS D  (NOLOCK)
			ON AC.IdDocumento = D.IdDocumento
		LEFT JOIN [dbo].[S_Proveedor] AS PR  (NOLOCK)
			ON AP.IdSubContratista = PR.RFC 
			AND PR.Activo = 1
		LEFT JOIN [dbo].[S_TipoValidacionDoc] AS TD  (NOLOCK)
			ON AC.IdEstatus = TD.IdTipoValidacionDoc
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS SPV  (NOLOCK)
			ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SPV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES  (NOLOCK)
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS 
			AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES  (NOLOCK)
			ON PSES.SAPPONumber = SES.PO_SAPNumer 
			AND PSES.SAPSESNumber = SES.SESReferenceNumber 
			AND PSES.SESN = SES.SESNumber
		LEFT JOIN Adinco.dbo.CO_SAPPO AS PO  (NOLOCK)
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
		JOIN	Adinco.dbo.CO_Contrato	AS	C (NOLOCK)
			ON	AP.IdContrato = C.IdContrato
		WHERE 
		PO.Plant = @PLANT
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
				 ap.ReferenceNumber,
				 c.NumeroContrato,
				 c.IdContrato,
				 PO.SAPPONumber
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
			END,
			Contrato = c.NumeroContrato,
			ISNULL(RPO.PO,'Sin PO relacionada') AS PO
		FROM [dbo].[MM_AceptacionCartaPCN] AS AC  (NOLOCK)
		 JOIN [dbo].[S_Documento_S3] AS D  (NOLOCK)
			ON AC.IdDocumento = D.IdDocumento
		 JOIN [dbo].[MM_AceptacionPedido] AS AP  (NOLOCK)
			ON AC.IdAceptacionPedido = AP.IdAceptacionPedido
		 JOIN [dbo].[MM_Pedido] AS P  (NOLOCK)
			ON AP.IdPedido =  P.IdPedido
		 JOIN [dbo].[S_Proveedor] AS PR  (NOLOCK)
			ON P.IdSubcontratista = PR.IdProveedor
		 JOIN [dbo].[S_TipoValidacionDoc] AS TD  (NOLOCK)
			ON AC.IdEstatus = TD.IdTipoValidacionDoc
		 JOIN [dbo].[MM_Pedidos] AS PG  (NOLOCK)
			ON P.IdPedido = PG.IdIdentificador
			AND PG.IdProveedorCliente = @IdProveedor 
			AND PG.IdTipoPedido IN (2,4, 6)
	    LEFT  JOIN dbo.MM_TipoPedido AS TP  (NOLOCK)
			ON PG.IdTipoPedido = TP.IdTipoPedido
		INNER JOIN	Adinco.dbo.CO_Contrato	AS	C 	 (NOLOCK)
			ON	P.IdContrato = C.IdContrato
		LEFT JOIN DEA_Relacion_PR_PO AS RPO	 (NOLOCK)
			ON P.IdPedido = RPO.IdPedido
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
			ISNULL(TD.TipoValidacion, 'Sin Iniciar Aprobaci�n') AS TipoValidacion,
			ISNULL(SPV.VendorName,PR.RazonSocial) AS Proveedor,
			00,
			'N/A',
			CONCAT('Reference Number: ',AP.ReferenceNumber),
			CASE
				WHEN TD.IdTipoValidacionDoc = 2 THEN 'label label-success'
				WHEN TD.IdTipoValidacionDoc = 1 THEN 'label label-primary'
				WHEN TD.IdTipoValidacionDoc = 3 THEN 'label label-danger'
				WHEN TD.IdTipoValidacionDoc IS NULL THEN 'label label-default'
			END,
			Contrato = c.NumeroContrato,
			PO.SAPPONumber AS PO
		FROM dbo.MPY_MM_AceptacionPedido AS AP  (NOLOCK)
		LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC  (NOLOCK)
			ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		LEFT JOIN [dbo].[S_Documento_S3] AS D  (NOLOCK)
			ON AC.IdDocumento = D.IdDocumento
		LEFT JOIN [dbo].[S_Proveedor] AS PR  (NOLOCK)
			ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1
		LEFT JOIN [dbo].[S_TipoValidacionDoc] AS TD  (NOLOCK)
			ON AC.IdEstatus = TD.IdTipoValidacionDoc
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS SPV  (NOLOCK)
			ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SPV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES  (NOLOCK)
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES  (NOLOCK)
			ON PSES.SAPPONumber = SES.PO_SAPNumer
			AND PSES.SAPSESNumber = SES.SESReferenceNumber
			AND PSES.SESN = SES.SESNumber
		LEFT JOIN Adinco.dbo.CO_SAPPO AS PO  (NOLOCK)
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
		JOIN	Adinco.dbo.CO_Contrato AS C  (NOLOCK)	
			ON AP.IdContrato = C.IdContrato
		WHERE 
		PO.Plant = @PLANT
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
                 ISNULL(TD.TipoValidacion, 'Sin Iniciar Aprobaci�n'),
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
				 AP.ReferenceNumber,
				 c.NumeroContrato,
				 c.IdContrato,
				 PO.SAPPONumber
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
		span,
		Contrato,
		PO
	 FROM #AceptacionesPedido ORDER BY CreadoEl DESC;
END