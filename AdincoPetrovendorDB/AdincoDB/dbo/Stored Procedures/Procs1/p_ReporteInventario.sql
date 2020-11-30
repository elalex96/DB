
-- p_ReporteInventario 3,3
CREATE Proc [dbo].[p_ReporteInventario]
@pIdContrato int,
@pIdPresupuesto int
as

CREATE TABLE #Facturas
(
	IdFacturaAdinco INT,
	IdFacturaPetro	INT,
	IdContrato		INT,
	FechaTimbrado	DATETIME
)

INSERT INTO #facturas
(
	IdFacturaAdinco,
	IdFacturaPetro,
	IdContrato,
	FechaTimbrado
)
SELECT Cpago.IdFactura,
	FAP.IdFacturaPetrovendor,
	ff.IdContrato,
	FF.FechaTimbrado
FROM
	Adinco.dbo.FI_Factura ff (NOLOCK) 
JOIN  
	Adinco.dbo.FI_CPDocRelacionado DR   (NOLOCK)
	ON ff.UUID =  DR.IdDocumento COLLATE Modern_Spanish_CI_AS
	AND	ff.IdContrato =	@pIdContrato
JOIN
	Adinco.dbo.FI_ComplementoDePago CPago (NOLOCK)
	ON Cpago.IdComplementoDePago = DR.IdComplementoDePago  
JOIN  
	Adinco.dbo.FI_TransferFactura TRFAC (NOLOCK)
	ON Cpago.IdFactura =  TRFAC.IdFactura  
JOIN  
	Adinco.dbo.FI_FacturaAdincoPetrovendor FAP  (NOLOCK)
	ON Cpago.IdFactura = FAP.IdFacturaAdinco
	AND FAP.Activo	=	1
WHERE
	ff.IdContrato =	 @pIdContrato

UNION

SELECT
	FF.IdFactura,
	FAP.IdFacturaPetrovendor,
	ff.IdContrato,
	FF.FechaTimbrado
FROM 
	Adinco.dbo.FI_Factura ff (NOLOCK)
JOIN  
	Adinco.dbo.FI_TransferFactura TRFAC (NOLOCK)
	ON FF.IdFactura =  TRFAC.IdFactura
	AND ff.IdContrato =	@pIdContrato
JOIN  
	Adinco.dbo.FI_FacturaAdincoPetrovendor FAP  (NOLOCK)
	ON FF.IdFactura = FAP.IdFacturaAdinco
	AND FAP.Activo	=	1
WHERE
	ff.IdContrato =	 @pIdContrato

-- SELECT PARA CARSO
SELECT
	ROW_NUMBER() OVER (ORDER BY c.NumeroContrato) AS Consecutivo,
	c.NumeroContrato AS Contrato,
	ac.NombreAreaContractual AS AreaContratual,
	CASE 
		WHEN rc.IdRegimenCapital IS NOT NULL 
		THEN pr.RazonSocial + ', ' + rc.Regimen
		ELSE pr.RazonSocial + ISNULL(pr.RegimenCapital, '')
	END AS Contratista,
	pod.MaterialCotizadoTextoC AS NombreDelMaterial,
	CASE WHEN c.IdContrato = 10036--CNH-A3.CÁRDENAS-MORA/2018
		THEN 'PCM' + RIGHT('00000' + CAST(ap.IdAceptacionPedido AS NVARCHAR(5)), 5)
		ELSE RIGHT('00000' + CAST(ap.IdAceptacionPedido AS NVARCHAR(5)), 5) 
	END	AS CodigoDeInventario,
	apd.Cantidad,
	pod.MaterialCotizadoTextoL AS DescripcionTecnica,
	'Otro' AS Sistema,
	CASE
		WHEN r.IdRegistro IS NULL
		THEN Petrovendor.dbo.FN_ObtenerInstalacionGasto(f.IdFacturaAdinco)
		ELSE ISNULL(i.NombreInstalacion, 'Sin Instalación') 
	END AS Localizacion,
	'Operando' AS CondicionDeOperacion,
	CONVERT(NVARCHAR(100), ap.Creado, 103) AS FechaDeInicioDeOperacion,
	CASE 
		WHEN p.IdMoneda = 1
		THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio((apd.Cantidad * pod.PrecioUnitario), F.FechaTimbrado)
		ELSE apd.Cantidad * pod.PrecioUnitario
	END AS MontoCargadoCuentaDLLS,
	Petrovendor.dbo.FN_ValorTipoCambio(F.FechaTimbrado) AS TipoCambioMontoCargadoCuenta,
	CONVERT(NVARCHAR(100), F.FechaTimbrado, 103) AS FechaTipoCambio,
	CASE 
		WHEN r.IdRegistro IS NULL
		THEN DATENAME(MONTH, Petrovendor.dbo.FN_ObtenerMesGasto(F.IdFacturaAdinco))
		ELSE DATENAME(MONTH, RA.MesPresentacion)
	END AS MesCargoCuenta,
	LPM.IdLineaPresupuestoMes
FROM #facturas	F
JOIN Adinco.dbo.CO_Contrato c 
	ON c.IdContrato = F.IdContrato
JOIN Adinco.dbo.CO_AreaContractual ac (NOLOCK) ON ac.IdAreaContractual = c.IdAreaContractual
JOIN Adinco.dbo.CO_Contratista	CC (NOLOCK) ON C.IdContratista	=	CC.IdContratista
	AND C.IdContrato IN (10048,10047)--CARSO
JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF (NOLOCK) ON F.IdFacturaPetro =	AF.IdFactura
JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP (NOLOCK) ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
JOIN Petrovendor.dbo.MM_Pedido AS P (NOLOCK) ON AP.IdPedido =  P.IdPedido
JOIN Petrovendor.dbo.S_Proveedor pr (NOLOCK) ON p.IdSubcontratista = pr.IdProveedor
JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle apd (NOLOCK) ON  ap.IdAceptacionPedido = apd.IdAceptacionPedido
JOIN Petrovendor.dbo.MM_PedidoDetalle pd (NOLOCK) ON apd.IdPedidoDetalle = pd.IdPedidoDetalle
JOIN Petrovendor.dbo.AX_UnidadClasificacion auc (NOLOCK) ON  pd.IdUnidadProveedor = auc.IdUnidad AND auc.IdClasificacion = 1
JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle (NOLOCK) pod ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
LEFT JOIN Petrovendor.dbo.RegimenCapital rc (NOLOCK) ON pr.IdRegimenCapital = rc.IdRegimenCapital
LEFT JOIN Adinco.dbo.CO_Registro AS RA (NOLOCK) ON F.IdFacturaAdinco = RA.IdFactura
LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes lpm (NOLOCK) ON RA.IdPrograma = lpm.IdLineaPresupuestoMes
LEFT JOIN Adinco.dbo.CO_Instalacion i (NOLOCK) ON lpm.IdInstalacion = i.IdInstalacion 
LEFT JOIN Petrovendor.dbo.CO_Registro r (NOLOCK) ON apd.IdAceptacionPedidoDetalle = r.IdAceptacionPedidoDetalle 
WHERE
	lpm.IdPresupuesto = @pIdPresupuesto
GROUP BY
	c.NumeroContrato,
	ac.NombreAreaContractual,
	CASE 
		WHEN rc.IdRegimenCapital IS NOT NULL 
		THEN pr.RazonSocial + ', ' + rc.Regimen
		ELSE pr.RazonSocial + ISNULL(pr.RegimenCapital, '')
	END,
	pod.MaterialCotizadoTextoC,
	CASE WHEN  c.IdContrato = 10036
		THEN 'PCM' + RIGHT('00000' + CAST(ap.IdAceptacionPedido AS NVARCHAR(5)), 5)
		ELSE RIGHT('00000' + CAST(ap.IdAceptacionPedido AS NVARCHAR(5)), 5) 
	END,
	apd.Cantidad,
	pod.MaterialCotizadoTextoL,
	CASE
		WHEN r.IdRegistro IS NULL
		THEN Petrovendor.dbo.FN_ObtenerInstalacionGasto(f.IdFacturaAdinco)
		ELSE ISNULL(i.NombreInstalacion, 'Sin Instalación') 
	END,
	CONVERT(NVARCHAR(100), ap.Creado, 103),
	CASE 
		WHEN p.IdMoneda = 1
		THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio((apd.Cantidad * pod.PrecioUnitario), F.FechaTimbrado)
		ELSE apd.Cantidad * pod.PrecioUnitario
	END,
	Petrovendor.dbo.FN_ValorTipoCambio(F.FechaTimbrado),
	CONVERT(NVARCHAR(100), F.FechaTimbrado, 103),
	CASE 
		WHEN r.IdRegistro IS NULL
		THEN DATENAME(MONTH, Petrovendor.dbo.FN_ObtenerMesGasto(F.IdFacturaAdinco))
		ELSE DATENAME(MONTH, RA.MesPresentacion)
	END,
	LPM.IdLineaPresupuestoMes,
	c.IdContrato,
	ap.IdAceptacionPedido 
UNION

-- SELECT  PARA  TODOS LOS DEMAS
SELECT
	ROW_NUMBER() OVER (ORDER BY c.NumeroContrato) AS Consecutivo,
	c.NumeroContrato AS Contrato,
	ac.NombreAreaContractual AS AreaContratual,
	CASE 
		WHEN rc.IdRegimenCapital IS NOT NULL 
		THEN pr.RazonSocial + ', ' + rc.Regimen
		ELSE pr.RazonSocial + ISNULL(pr.RegimenCapital, '')
	END AS Contratista,
	pod.MaterialCotizadoTextoC AS NombreDelMaterial,
	CASE WHEN c.IdContrato = 10036--CNH-A3.CÁRDENAS-MORA/2018
		THEN 'PCM' + RIGHT('00000' + CAST(ap.IdAceptacionPedido AS NVARCHAR(5)), 5)
		ELSE RIGHT('00000' + CAST(ap.IdAceptacionPedido AS NVARCHAR(5)), 5) 
	END	AS CodigoDeInventario,
	apd.Cantidad,
	pod.MaterialCotizadoTextoL AS DescripcionTecnica,
	'Otro' AS Sistema,
	CASE
		WHEN r.IdRegistro IS NULL
		THEN Petrovendor.dbo.FN_ObtenerInstalacionGasto(f.IdFacturaAdinco)
		ELSE ISNULL(i.NombreInstalacion, 'Sin Instalación') 
	END AS Localizacion,
	'Operando' AS CondicionDeOperacion,
	CONVERT(NVARCHAR(100), ap.Creado, 103) AS FechaDeInicioDeOperacion,
	CASE 
		WHEN p.IdMoneda = 1
		THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio((apd.Cantidad * pod.PrecioUnitario), F.FechaTimbrado)
		ELSE apd.Cantidad * pod.PrecioUnitario
	END AS MontoCargadoCuentaDLLS,
	Petrovendor.dbo.FN_ValorTipoCambio(F.FechaTimbrado) AS TipoCambioMontoCargadoCuenta,
	CONVERT(NVARCHAR(100), F.FechaTimbrado, 103) AS FechaTipoCambio,
	CASE 
		WHEN r.IdRegistro IS NULL
		THEN DATENAME(MONTH, Petrovendor.dbo.FN_ObtenerMesGasto(F.IdFacturaAdinco))
		ELSE DATENAME(MONTH, RA.MesPresentacion)
	END AS MesCargoCuenta,
	LPM.IdLineaPresupuestoMes
FROM #facturas	F
JOIN Adinco.dbo.CO_Contrato c (NOLOCK)
	ON c.IdContrato = F.IdContrato
JOIN Adinco.dbo.CO_AreaContractual ac (NOLOCK) ON ac.IdAreaContractual = c.IdAreaContractual
JOIN Adinco.dbo.CO_Contratista	CC (NOLOCK) ON C.IdContratista	=	CC.IdContratista
JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF (NOLOCK) ON F.IdFacturaPetro =	AF.IdFactura
JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP (NOLOCK) ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
JOIN Petrovendor.dbo.MM_Pedido AS P (NOLOCK) ON AP.IdPedido =  P.IdPedido
JOIN Petrovendor.dbo.S_Proveedor pr (NOLOCK) ON p.IdSubcontratista = pr.IdProveedor 
JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle apd (NOLOCK) ON  ap.IdAceptacionPedido = apd.IdAceptacionPedido
JOIN Petrovendor.dbo.MM_PedidoDetalle pd (NOLOCK) ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle pod (NOLOCK) ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
LEFT JOIN Petrovendor.dbo.RegimenCapital rc (NOLOCK) ON pr.IdRegimenCapital = rc.IdRegimenCapital
LEFT JOIN Adinco.dbo.CO_Registro AS RA (NOLOCK) ON F.IdFacturaAdinco = RA.IdFactura
LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes lpm (NOLOCK) ON RA.IdPrograma = lpm.IdLineaPresupuestoMes
LEFT JOIN Adinco.dbo.CO_Instalacion i (NOLOCK) ON lpm.IdInstalacion = i.IdInstalacion
LEFT JOIN Petrovendor.dbo.CO_Registro r (NOLOCK) ON apd.IdAceptacionPedidoDetalle = r.IdAceptacionPedidoDetalle
WHERE
	lpm.IdPresupuesto = @pIdPresupuesto
GROUP BY
	c.NumeroContrato,
	ac.NombreAreaContractual,
	CASE 
		WHEN rc.IdRegimenCapital IS NOT NULL 
		THEN pr.RazonSocial + ', ' + rc.Regimen
		ELSE pr.RazonSocial + ISNULL(pr.RegimenCapital, '')
	END,
	pod.MaterialCotizadoTextoC,
	CASE WHEN c.IdContrato = 10036--CNH-A3.CÁRDENAS-MORA/2018
		THEN 'PCM' + RIGHT('00000' + CAST(ap.IdAceptacionPedido AS NVARCHAR(5)), 5)
		ELSE RIGHT('00000' + CAST(ap.IdAceptacionPedido AS NVARCHAR(5)), 5) 
	END,
	apd.Cantidad,
	pod.MaterialCotizadoTextoL,
	CASE
		WHEN r.IdRegistro IS NULL
		THEN Petrovendor.dbo.FN_ObtenerInstalacionGasto(f.IdFacturaAdinco)
		ELSE ISNULL(i.NombreInstalacion, 'Sin Instalación') 
	END,
	CONVERT(NVARCHAR(100), ap.Creado, 103),
	CASE 
		WHEN p.IdMoneda = 1
		THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio((apd.Cantidad * pod.PrecioUnitario), F.FechaTimbrado)
		ELSE apd.Cantidad * pod.PrecioUnitario
	END,
	Petrovendor.dbo.FN_ValorTipoCambio(F.FechaTimbrado),
	CONVERT(NVARCHAR(100), F.FechaTimbrado, 103),
	CASE 
		WHEN r.IdRegistro IS NULL
		THEN DATENAME(MONTH, Petrovendor.dbo.FN_ObtenerMesGasto(F.IdFacturaAdinco))
		ELSE DATENAME(MONTH, RA.MesPresentacion)
	END,
	LPM.IdLineaPresupuestoMes,
	c.IdContrato,
	ap.IdAceptacionPedido 