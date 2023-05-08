-- =============================================
-- Author:		Alexander Gomez
-- Create date: 08/01/2018
-- Description:	Reporte de pagos por operadora (RENAISSANCE)
-- =============================================
CREATE  PROCEDURE [dbo].[SP_RPT_ReportePagosProveedores]-- 420
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	CREATE TABLE #PedidoCondiciones(IdPedido INT, UnicaCondicionPago BIT,IdCondicionPago INT, CondicionPago NVARCHAR(MAX), DiasCredito INT)


	INSERT INTO #PedidoCondiciones
    SELECT P.IdPedido, P.UnicaCondicionPago,NULL, '', 0
	FROM  
	dbo.MM_Pedido P	
	WHERE IdProveedorCompras = @IdProveedor 
	
	UPDATE PDC
	SET PDC.CondicionPago=CP.CondicionPago,
	PDC.DiasCredito=PD.DiasCredito,
	PDC.IdCondicionPago=PD.IdCondicionPago
	FROM #PedidoCondiciones  PDc
	INNER JOIN dbo.MM_PedidoDetalle PD ON PD.IdPedido = PDc.IdPedido
	INNER JOIN dbo.MM_CondicionPago CP ON CP.IdCondicionPago=PD.IdCondicionPago
	WHERE UnicaCondicionPago=1 --> QUE ES DE UNICA CONDICION DE PAGO 
	
    -- Insert statements for procedure here
	SELECT DISTINCT
	ROW_NUMBER() OVER (ORDER BY PS.IdPedido) AS Nro,
	PR.RazonSocial AS NombreComercial,
	PR.RFC,
	PR.IdProveedor,
	SP.IdSolicitudPedido,
	P.IdPedido,
	STUFF((
			SELECT ' \ ' + CONCAT(DG.Calle,', ', DG.NoExterior,'-',DG.NoInterior,', ',DG.Colonia,', ',DG.CodigoPostal,', ',DG.Municipio,', ', DG.Estado)
			FROM dbo.DG_Domicilio AS DG
			LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPI ON SPI.IdDomicilioEntrega = DG.IdDomicilio
			WHERE (SPI.IdSolicitudPedido = SP.IdSolicitudPedido) 
			GROUP BY CONCAT(DG.Calle,', ', DG.NoExterior,'-',DG.NoInterior,', ',DG.Colonia,', ',DG.CodigoPostal,', ',DG.Municipio,', ', DG.Estado)
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		  ,1,2,'') AS Domicilio,
	(SELECT TOP 1 US.Correo
		FROM dbo.S_UsuarioProveedor AS USP
				LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = USP.IdUsuario AND US.Activo = 1
		WHERE USP.IdProveedor = PR.IdProveedor AND USP.IsAdmin = 1
		ORDER BY US.FechaRegistro ASC) AS Email,
	(SELECT TOP 1 US.Telefono
	FROM dbo.S_UsuarioProveedor AS USP
		LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = USP.IdUsuario AND US.Activo = 1
	WHERE USP.IdProveedor = PR.IdProveedor AND USP.IsAdmin = 1
	ORDER BY US.FechaRegistro ASC) AS Telefono,
	(SELECT TOP 1 TUS.NombreTipoUsuario
	FROM dbo.S_UsuarioProveedor AS USP
		LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = USP.IdUsuario AND US.Activo = 1 
		LEFT JOIN dbo.S_TipoUsuario AS TUS ON TUS.IdTipoUsuario = US.IdTipoUsuario
	WHERE USP.IdProveedor = PR.IdProveedor AND USP.IsAdmin = 1
	ORDER BY US.FechaRegistro ASC) AS Categoria,
	AC.NombreAreaContractual AS AreaPozo,
	ISNULL(CC.numero,'') AS CentroCosto,
	ISNULL(CC.CentroCosto,'N/A') AS NombreCentroCostos,
	M.DescripcionCorta AS Sevicio,
	AF.IdAceptacionFactura,
	F.FechaTimbrado AS FechaFactura,
	F.FechaRecepcion AS FechaRecepcionFactura,
	F.Folio AS NoFactura,
	F.IdFactura,
	PS.IdPedido AS NoOrdenCompra,
	F.SubTotal,
	(F.MontoConIva - F.SubTotal) AS IVA,
	F.MontoConIva AS Total,
	TM.TipoMonedaCorto AS Moneda,
	CASE
		WHEN TFA.MontoPagado >= F.MontoConIva THEN 'PAGADO'
		WHEN ISNULL(TFA.MontoPagado,0) <= F.MontoConIva THEN 'PENDIENTE'
	END AS EstatusPago,
	ISNULL(TFA.ModificadoEn,TFA.CreadoEn) AS FechaPago,
	USI.Nombre AS Autorizo,
	(SELECT TOP 1 B.Banco
		FROM dbo.PV_CuentaBancaria AS CB
			LEFT JOIN dbo.PV_CuentaBancariaSubContratista AS CBS ON CBS.IdCuentaBancaria = CB.DatoBancarioID AND CBS.IsActivo = 1
			LEFT JOIN dbo.PV_Banco AS B ON B.BancoID = CB.BancoID
		WHERE CB.IdProveedor = P.IdSubcontratista
				AND ISNULL(CB.IsEliminado,0) = 0
				AND CBS.IdSubcontratista = P.IdProveedorCompras) AS Banco,
	(SELECT TOP 1 CB.NumeroCuenta
		FROM dbo.PV_CuentaBancaria AS CB
			LEFT JOIN dbo.PV_CuentaBancariaSubContratista AS CBS ON CBS.IdCuentaBancaria = CB.DatoBancarioID AND CBS.IsActivo = 1
		WHERE CB.IdProveedor = P.IdSubcontratista
				AND ISNULL(CB.IsEliminado,0) = 0
				AND CBS.IdSubcontratista = P.IdProveedorCompras) AS NumeroCuneta,
	(SELECT TOP 1 CB.CuentaClabe
		FROM dbo.PV_CuentaBancaria AS CB
			LEFT JOIN dbo.PV_CuentaBancariaSubContratista AS CBS ON CBS.IdCuentaBancaria = CB.DatoBancarioID AND CBS.IsActivo = 1
		WHERE CB.IdProveedor = P.IdSubcontratista
				AND ISNULL(CB.IsEliminado,0) = 0
				AND CBS.IdSubcontratista = P.IdProveedorCompras) AS ClaveInterbancaria,
	CASE
		WHEN ISNULL(P.UnicaCondicionPago,0) = 1 THEN 
		  CASE WHEN PDC.IdCondicionPago=1 THEN --->CREDITO
		  CONCAT(PDC.DiasCredito,' días de ', PDC.CondicionPago )
		  ELSE 
		  PDC.CondicionPago
		  END 
		ELSE
		'Condiciones de pago, diferidas para las partidas de la orden de compra'
	END AS DiasCredito,
	CASE
		WHEN ISNULL(PDC.DiasCredito,0) = 0 THEN 'N/A'
		WHEN PDC.DiasCredito > 0 THEN CAST(DATEADD(DAY,PDC.DiasCredito,AP.Modificado) AS NVARCHAR(300))
	END AS FechaEstimadaPago,
	CASE
		WHEN ISNULL(PDC.DiasCredito,0) = 0 THEN 'N/A'
		WHEN DATEDIFF(DAY,AP.Modificado,DATEADD(DAY,PDC.DiasCredito,AP.Modificado)) > 0 THEN 'VENCIDA +' + CAST(DATEDIFF(DAY,AP.Modificado,DATEADD(DAY,PDC.DiasCredito,AP.Modificado)) AS NVARCHAR(300))
	END AS Estatus,
	(F.MontoConIva - ISNULL(TFA.MontoPagado,0)) AS Credito,
	CASE
		WHEN F.IdMoneda = 1 THEN dbo.FN_PesosDolaresTipoCambio(F.MontoConIva,F.FechaTimbrado)
		ELSE F.MontoConIva
	END TotalUSD
FROM dbo.MM_Pedido AS P
LEFT JOIN dbo.MM_Pedidos AS PS ON PS.IdIdentificador = P.IdPedido
LEFT JOIN dbo.MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = P.IdSubcontratista AND PR.Activo = 1
LEFT JOIN dbo.MM_PeticionOferta AS PO ON PO.IdSolicitudPedido = P.IdSolicitudPedido
LEFT JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = P.IdSolicitudPedido AND SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle 
LEFT JOIN Adinco.dbo.CO_Contrato AS CO ON CO.IdContrato = SP.IdContrato
LEFT JOIN dbo.MM_Material AS M ON M.IdMaterial = PD.IdMaterial
LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = CO.IdAreaContractual
LEFT JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdPedido = P.IdPedido
LEFT JOIN dbo.MM_AceptacionFactura AS AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido AND AF.IdEstatusXML = 2
LEFT JOIN dbo.FI_Factura AS F ON F.IdFactura = AF.IdFactura AND ISNULL(F.IsEliminado,0) = 0
LEFT JOIN Adinco.dbo.FI_Factura AS FA ON FA.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = F.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
LEFT JOIN Adinco.dbo.FI_TransferFactura AS TFA ON TFA.IdFactura = FA.IdFactura
LEFT JOIN dbo.S_Usuario AS USI ON USI.IdUsuario = AF.ModificadoPor
LEFT JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = F.IdMoneda
LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
LEFT JOIN dbo.CC_CentroCosto AS CC ON CC.IdCentroCosto = SPDLP.IdCentroCosto
LEFT JOIN #PedidoCondiciones PDC ON PDC.IdPedido=P.IdPedido
WHERE 
AF.IdEstatusXML = 2 AND
P.IdProveedorCompras = @IdProveedor
GROUP BY
         PR.RazonSocial,
         PR.RFC,
         SP.IdSolicitudPedido,
         AC.NombreAreaContractual,
         F.FechaTimbrado,
         F.FechaRecepcion,
         F.Folio,
         PS.IdPedido,
         F.SubTotal,
         F.MontoConIva,
         F.Moneda,
		 PR.IdProveedor,
		 P.IdPedido,
		 TFA.IdTransferFactura,
		 USI.Nombre,
		P.DiasCredito,
		AP.Modificado,
		TFA.MontoPagado,
		TFA.ModificadoEn,
		TFA.CreadoEn,
		F.IdFactura,
		P.IdProveedorCompras,
		P.IdSubcontratista,
		F.IdMoneda,
		TM.TipoMonedaCorto,
		CC.numero,
		CC.CentroCosto,
		M.DescripcionCorta,
		AF.IdAceptacionFactura,
		P.UnicaCondicionPago,
		PDC.DiasCredito,
		PDC.IdCondicionPago,
		PDC.CondicionPago
--ORDER BY FechaEstimadaPago DESC;

END

