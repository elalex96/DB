-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/03/2020>
-- Description:	<Consultar solicitudes de pedido par visualizar el historial>
-- =============================================
create PROCEDURE [dbo].[SP_ConsultaSolicitudesHistorial_V2] --364,3,2205,1,'4500097817'
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
	@Page INT,
	@Buscar NVARCHAR(100)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @PLANT NVARCHAR(10) = (SELECT TOP 1 CP.Planta
									FROM Adinco.dbo.CO_SAPContratista_Planta AS CP
									JOIN Adinco.dbo.CO_Contratista AS C ON C.IdContratista = CP.IdContratista
									JOIN Petrovendor.dbo.S_Proveedor AS PR ON PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = C.RFC
									WHERE PR.IdProveedor = @IdProveedor)

	DECLARE @SAPVENDOR NVARCHAR(50) = (SELECT TOP 1 VendorIDSAP 
										FROM Adinco.dbo.CO_SAPVendor AS SV
										LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = SV.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS
										WHERE PR.IdProveedor = @IdProveedor AND
											SV.Activo = 1);

	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 10;
	DECLARE @DATOSALL TABLE(
		IdSolicitudPedido INT
	);

	INSERT INTO @DATOSALL
	SELECT 
		COUNT(P.IdSolicitudPedido)
	FROM dbo.MM_SolicitudPedido AS SP
		LEFT JOIN dbo.MM_Pedido AS P
			ON P.IdSolicitudPedido = SP.IdSolicitudPedido
		LEFT JOIN dbo.MM_Pedidos AS PS
			ON PS.IdIdentificador = P.IdPedido
				AND PS.IdProveedorCliente = P.IdProveedorCompras
		LEFT JOIN dbo.S_Proveedor AS PR
			ON PR.IdProveedor = P.IdSubcontratista
	WHERE SP.IdProveedor = @IdProveedor
		AND SP.IdContrato = @IdContrato
		AND ISNULL(SP.IdEstatusEliminado,0) <> 1
		AND ISNULL(P.IdEstatusEliminado,0) <> 1
		AND (
				CAST(SP.IdSolicitudPedido AS NVARCHAR(10)) LIKE '%' + @Buscar + '%' OR 
				SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
                CAST(PS.IdPedido AS NVARCHAR(10)) LIKE '%' + @Buscar + '%'
			)
	GROUP BY P.IdPedido,
		SP.IdSolicitudPedido,
		P.CreadoEl, 
		SP.FechaAlta,
		SP.MotivoUrgencia;

	INSERT INTO @DATOSALL
	SELECT
		COUNT(PRS.IdPRESES)
	FROM Adinco.dbo.CO_SAPPRESES AS PRS
		JOIN Adinco.dbo.CO_SAPPO AS PO
			ON PO.SAPPONumber = PRS.SAPPONumber 
			AND PO.SAPVendorNumber = PRS.SAPVendorNumber
	WHERE PO.Plant = @PLANT
	AND (
						CAST(PRS.IdPRESES AS NVARCHAR(10)) LIKE '%' + @Buscar + '%' OR 
						PRS.SAPPONumber LIKE '%' + @Buscar + '%' OR
						PRS.SAPSESNumber LIKE '%' + @Buscar + '%' 
					)
	GROUP BY PRS.IdPRESES;
	--ORDER BY SP.FechaAlta DESC;

	SET @AllRecords = (SELECT COUNT(1) FROM @DATOSALL);

	IF @PLANT IS NOT NULL
	BEGIN
		SELECT
			*,
			@AllRecords AS Records,
			@RecordsByPage AS RecordByPage
		FROM 
		(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY PRS.CreadoEl ORDER BY PRS.CreadoEl  DESC) AS R,
			PRS.IdPRESES AS IdSolicitudPedido,
			PRS.IdPRESES AS IdDocumento,
			CONVERT(VARCHAR,PRS.CreadoEl,22) AS FechaAlta,
			'Proforma' AS Proceso,
			'PO No.' + PRS.SAPPONumber + ' - Reference N.' + PRS.SAPSESNumber + ISNULL(' - SES N.' + SES.SESNumber,'')  AS Descripcion,
			'/02Proveedores/HistorialSolped.aspx?' AS URL,
			'solped=|' + CAST(PRS.IdPRESES AS NVARCHAR(10)) + ',&MPY=1' AS PARAMETROS,
			(ROW_NUMBER() OVER(ORDER BY PRS.CreadoEl DESC) - 1)/ @RecordsByPage AS _Page
		FROM Adinco.dbo.CO_SAPPRESES AS PRS
			JOIN Adinco.dbo.CO_SAPPO AS PO
				ON PO.SAPPONumber = PRS.SAPPONumber 
				AND PO.SAPVendorNumber = PRS.SAPVendorNumber
			LEFT JOIN Adinco.dbo.CO_SAPSES AS SES 
				ON SES.PO_SAPNumer = PRS.SAPPONumber AND 
					SES.SESReferenceNumber = PRS.SAPSESNumber AND 
					SES.SESNumber = PRS.SESN  
		WHERE PO.Plant = @PLANT
			AND (
						CAST(PRS.IdPRESES AS NVARCHAR(10)) LIKE '%' + @Buscar + '%' OR 
						PRS.SAPPONumber LIKE '%' + @Buscar + '%' OR
						PRS.SAPSESNumber LIKE '%' + @Buscar + '%' OR
						SES.SESNumber LIKE '%' + @Buscar + '%'
					)
		GROUP BY PRS.IdPRESES,
		PRS.CreadoEl,
		PRS.SAPPONumber,
		SES.SESNumber,
		PRS.SAPSESNumber
		) AS R
		WHERE
			--R.R = 1 AND 
			R._Page = (@Page - 1)
		ORDER BY R.FechaAlta DESC
	END
	ELSE
	BEGIN
		SELECT
			*,
			@AllRecords AS Records,
			@RecordsByPage AS RecordByPage
		FROM 
		(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY SP.FechaAlta ORDER BY SP.FechaAlta DESC) AS R,
			SP.IdSolicitudPedido,
			ISNULL(PS.IdPedido,SP.IdSolicitudPedido) AS IdDocumento,
			CONVERT(VARCHAR,ISNULL(P.CreadoEl,SP.FechaAlta),22) AS FechaAlta,
			CASE
				WHEN P.IdPedido IS NOT NULL THEN 'Pedido'
				ELSE 'Requisición'
			END AS Proceso,
			CASE
				WHEN P.IdPedido IS NOT NULL THEN 'N. Solicitud Pedido.' + CAST(SP.IdSolicitudPedido AS NVARCHAR(10)) + ' - ' + SP.MotivoUrgencia + ' - Proveedor: ' + ISNULL(PR.RazonSocial,'')
				ELSE SP.MotivoUrgencia
			END AS Descripcion,
			'/02Proveedores/HistorialSolped.aspx?' AS URL,
			'solped=|' + CAST(SP.IdSolicitudPedido AS NVARCHAR(10)) AS PARAMETROS,
			(ROW_NUMBER() OVER(ORDER BY SP.FechaAlta DESC) - 1)/ @RecordsByPage AS _Page
		FROM dbo.MM_SolicitudPedido AS SP
			LEFT JOIN dbo.MM_Pedido AS P
				ON P.IdSolicitudPedido = SP.IdSolicitudPedido
			LEFT JOIN dbo.MM_Pedidos AS PS
				ON PS.IdIdentificador = P.IdPedido
					AND PS.IdProveedorCliente = P.IdProveedorCompras
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PR.IdProveedor = P.IdSubcontratista
		WHERE SP.IdProveedor = @IdProveedor
			AND SP.IdContrato = @IdContrato
			AND ISNULL(SP.IdEstatusEliminado,0) <> 1
			AND ISNULL(P.IdEstatusEliminado,0) <> 1
			AND (
					CAST(SP.IdSolicitudPedido AS NVARCHAR(10)) LIKE '%' + @Buscar + '%' OR 
					SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
					CAST(PS.IdPedido AS NVARCHAR(10)) LIKE '%' + @Buscar + '%'
				)
		GROUP BY P.IdPedido,
				SP.IdSolicitudPedido,
				P.CreadoEl, 
				SP.FechaAlta,
				SP.MotivoUrgencia,
				PR.RazonSocial,
				PS.IdPedido
		) AS R
		WHERE
			--R.R = 1 AND 
			R._Page = (@Page - 1)
		ORDER BY R.FechaAlta DESC
	END
	--SELECT
	--	IdSolicitudPedido,
	--	IdDocumento,
	--	Fecha,
	--	Proceso,
	--	Descripcion,
	--	URL,
	--	PARAMETROS
	--FROM @DATOS;

END
