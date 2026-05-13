-- =============================================
-- Modificacion:Daniel Ac
-- Update date: 01-06-18
-- Description:	Se agrega filtro para no mostrar aprobaciones con aceptacion factura con estatus eliminado = 1 y eliminación de sumatoria con excedente 
-- =============================================
	CREATE   PROCEDURE [dbo].[SP_PR_MM_ListaFacturasAprobacion] --364,0
	-- Add the parameters for the stored procedure here
	 @IdProveedor int,
	 @Estatus int ,	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null

AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PROVEDORRFC NVARCHAR(20) = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor)

	CREATE TABLE #AceptacionesPedido(
	IdAceptacionPedido INT null,
	Pedido NVARCHAR(50) null,
	IdPedido INT null,
	FechaRegistro DATETIME null,
	Proveedor NVARCHAR(100) null,
	Nombre NVARCHAR(100) null,
	IdPedidoGeneral INT null,
	TipoPedido NVARCHAR(MAX) null,
	TotalPedido MONEY NULL,
	Moneda NVARCHAR(100) null,
	RFC NVARCHAR(100) null,
	IdSolicitudPedido NVARCHAR(100) NULL,
	span NVARCHAR(100) NULL
	);
	
	IF @Estatus IN (1,2,3)
		BEGIN
				INSERT INTO #AceptacionesPedido
				SELECT 
					AF.IdAceptacionPedido,
					Pe.IdPedido, 
					Pe.IdPedido, 
					O.FechaRegistro, 
					PR.RazonSocial+' '+ISNULL(Pr.RegimenCapital,'') As Proveedor, 
					E.Nombre,
					PG.IdPedido AS IdPedidoGeneral, 
					TP.TipoPedido,  
					SUM(APD.Cantidad * PED.PrecioUnitario) AS TotalPedido,
					TM.TipoMonedaCorto AS Moneda, 
					PR.RFC, 
					PE.IdSolicitudPedido,
					CASE
						WHEN E.IdEstatus = 2 THEN 'label label-success'
						WHEN E.IdEstatus = 1 THEN 'label label-primary'
						WHEN E.IdEstatus = 3 THEN 'label label-danger'
						WHEN E.IdEstatus IS NULL THEN 'label label-default'
					END
				FROM MM_AceptacionFactura AS AF
				INNER JOIN  TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura 
				 INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion 
				 INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				 INNER JOIN MM_Pedido AS PE ON PE.IdPedido = AP.IdPedido 
				 INNER JOIN MM_PedidoDetalle AS PED ON PED.IdPedido = PE.IdPedido
				 INNER JOIN dbo.MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido=AP.IdAceptacionPedido AND APD.IdPedidoDetalle=PED.IdPedidoDetalle
				 INNER JOIN MM_Pedidos AS PG ON PE.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
				 INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = PE.IdSubcontratista
				 INNER JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda=PE.IdMoneda
				 LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido		
				WHERE O.IdTipoOperacion = 10 
				AND PE.IdProveedorCompras= @IdProveedor  
				AND O.IdEstatusOperacion = @Estatus
				AND ISNULL(AF.IdEstatusEliminado,0)<>1  --> QUE NO ESTE CON ESTATUS ELIMINADO
				GROUP BY AF.IdAceptacionPedido,
					Pe.IdPedido, 
					O.FechaRegistro, 
					PR.RazonSocial,
					Pr.RegimenCapital, 
					E.Nombre,
					PG.IdPedido, 
					TP.TipoPedido,
					TM.TipoMonedaCorto, 
					PR.RFC, PE.IdSolicitudPedido,--,APD.Cantidad,APD.Excedente,PED.PrecioUnitario
					E.IdEstatus
			 ORDER BY AF.IdAceptacionPedido DESC

			 INSERT INTO #AceptacionesPedido
			 SELECT 
					AF.IdAceptacionPedido,
					AP.IdPedido, 
					00,
					AF.CreadoEl, 
					ISNULL(SV.VendorName,AP.IdSubContratista) As Proveedor,
					E.Nombre,  
					00,
					00,
					SUM(ISNULL(APD.Cantidad,0) * APD.PrecioUnitario) AS TotalPedido,
					APD.IdMoneda,
					SV.TaxID AS RFC,
					'N/A',
					CASE
						WHEN E.IdEstatus = 2 THEN 'label label-success'
						WHEN E.IdEstatus = 1 THEN 'label label-primary'
						WHEN E.IdEstatus = 3 THEN 'label label-danger'
						WHEN E.IdEstatus IS NULL THEN 'label label-default'
					END
				FROM MPY_MM_AceptacionFactura AS AF
				LEFT JOIN TA_Estatus AS E ON E.IdEstatus = AF.IdEstatus 
				LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
				LEFT JOIN S_Proveedor AS PR ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1	
				WHERE AP.IdContrato = 10039
					AND AF.IdEstatus = @Estatus
					AND ISNULL(AF.IdEstatusEliminado,0)<>1 
				GROUP BY AF.IdAceptacionPedido,
					AP.IdPedido, 
					AF.CreadoEl, 
					PR.RazonSocial,
					Pr.RegimenCapital, 
					E.Nombre,
					AP.IdSubContratista, 
					PR.RFC,
					APD.IdMoneda,
					SV.TaxID,
					SV.VendorName,
					E.IdEstatus
				ORDER BY AF.IdAceptacionPedido DESC
			
		 END 

	 IF @Estatus=0  --TODAS
	 BEGIN
		INSERT INTO #AceptacionesPedido
		SELECT 
			AF.IdAceptacionPedido,
			Pe.IdPedido,
			Pe.IdPedido,
			O.FechaRegistro, 
			PR.RazonSocial+' '+ISNULL(Pr.RegimenCapital,'') As Proveedor, 		
			E.Nombre,
			PG.IdPedido AS IdPedidoGeneral, 
			TP.TipoPedido, 
			SUM(APD.Cantidad * PED.PrecioUnitario) AS TotalPedido,
			TM.TipoMonedaCorto AS Moneda, 
			PR.RFC,
			PE.IdSolicitudPedido,
			CASE
				WHEN E.IdEstatus = 2 THEN 'label label-success'
				WHEN E.IdEstatus = 1 THEN 'label label-primary'
				WHEN E.IdEstatus = 3 THEN 'label label-danger'
				WHEN E.IdEstatus IS NULL THEN 'label label-default'
			END
		FROM MM_AceptacionFactura AS AF
		INNER JOIN  TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura 	
		INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion 
		INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
		INNER JOIN dbo.MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido=AP.IdAceptacionPedido
		INNER JOIN MM_Pedido AS PE ON PE.IdPedido = AP.IdPedido
		INNER JOIN MM_PedidoDetalle AS PED ON PED.IdPedido = PE.IdPedido AND APD.IdPedidoDetalle=PED.IdPedidoDetalle 		 
		INNER JOIN MM_Pedidos AS PG ON PE.IdPedido = PG.IdIdentificador  AND PG.IdProveedorCliente = @IdProveedor
		INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = PE.IdSubcontratista
		INNER JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda=PE.IdMoneda
		LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
		WHERE 
		O.IdTipoOperacion = 10 
		AND PE.IdProveedorCompras= @IdProveedor 
		AND ISNULL(AF.IdEstatusEliminado,0)<>1 --> QUE NO ESTE CON ESTATUS ELIMINADO
	    GROUP BY AF.IdAceptacionPedido,
			Pe.IdPedido, 
			O.FechaRegistro, 
			PR.RazonSocial,
			Pr.RegimenCapital, 
			E.Nombre,
			PG.IdPedido, 
			TP.TipoPedido,
			TM.TipoMonedaCorto, 
			PR.RFC,
			AF.IdEstatusEliminado,
			PE.IdSolicitudPedido,
			E.IdEstatus
		ORDER BY AF.IdAceptacionPedido DESC

		INSERT INTO #AceptacionesPedido
		SELECT 
		AF.IdAceptacionPedido,
		AP.IdPedido,
		00,
		AF.CreadoEl, 
		ISNULL(SV.VendorName,PR.RazonSocial) As Proveedor, 		
		E.Nombre,
		00,
		00,
		SUM(APD.Cantidad * APD.PrecioUnitario) AS TotalPedido,
		APD.IdMoneda,
		SV.TaxID AS RFC,
		'N/A',
		CASE
			WHEN E.IdEstatus = 2 THEN 'label label-success'
			WHEN E.IdEstatus = 1 THEN 'label label-primary'
			WHEN E.IdEstatus = 3 THEN 'label label-danger'
			WHEN E.IdEstatus IS NULL THEN 'label label-default'
		END
		FROM MPY_MM_AceptacionFactura AS AF
				LEFT JOIN TA_Estatus AS E ON E.IdEstatus = AF.IdEstatus
				LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN S_Proveedor AS PR ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1
				LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE AP.IdContrato = 10039
		AND AF.IdAceptacionFactura IS NOT NULL 
		AND ISNULL(AF.IdEstatusEliminado,0)<>1 
	    GROUP BY AF.IdAceptacionPedido,
			AP.IdPedido,
			PR.RazonSocial,
			Pr.RegimenCapital, 
			E.Nombre,
			PR.RFC,
			AP.IdSubContratista,
			AF.IdEstatusEliminado,
			AF.CreadoEl,
			SV.VendorName,
			APD.IdMoneda,
			SV.TaxID,
			E.IdEstatus
		ORDER BY AF.IdAceptacionPedido DESC
     END 

	 SELECT
		ROW_NUMBER() OVER(ORDER BY FechaRegistro DESC) AS IdRow,
		IdAceptacionPedido,
		Pedido,
		IdPedido,
		FechaRegistro,
		Proveedor,
		Nombre,
		IdPedidoGeneral,
		TipoPedido,
		TotalPedido,
		Moneda,
		RFC,
		IdSolicitudPedido,
		span
	 FROM #AceptacionesPedido ORDER BY FechaRegistro DESC;
END