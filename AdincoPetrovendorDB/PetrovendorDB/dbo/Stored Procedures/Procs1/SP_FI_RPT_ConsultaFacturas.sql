-- =============================================
-- Author:		Alexander Gomez
-- Create date: 23/03/2018
-- Description:	Consulta de todas las facturas para el modulo de reporte de facturas
-- Author:		Daniel AC
-- Update date: 06/06/2018
-- Description:	Se agrego condicion donde se indica aceptaci�n de factura esta activa
-- =============================================
-- Author:		Pedro Acu�a
-- Update date: 27/08/2018
-- Description:	Se modifica la compra directa de donde se toma el numero consecutivo de la compra directa
-- =============================================

CREATE PROCEDURE [dbo].[SP_FI_RPT_ConsultaFacturas] @IdProveedor INT, @TipoCompra INT	--1=TODOS LOS TIPOS DE COMPRA EXCEPTO COMPRA DIRECTA
-- Add the parameters for the stored procedure here
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;

		-- Insert statements for procedure here
		CREATE TABLE #RPTFLUJOFACTURAS
			( NCompra INT ,
			  RazonSocial NVARCHAR(MAX) ,
			  NPedido INT ,
			  NAceptacionPedido INT ,
			  FechaCreacion DATETIME ,
			  CentroCosto NVARCHAR(MAX) ,
			  CuentaContable NVARCHAR(MAX) ,
			  CuentaSectorHid NVARCHAR(MAX) ,
			  MontoFactura FLOAT ,
			  MontoTotalPagar FLOAT ,
			  MontoEjercido FLOAT ,
			  InicioEjecucion NVARCHAR(MAX) ,
			  FinEjecucion NVARCHAR(MAX) ,
			  NombreInstalacion NVARCHAR(MAX) ,
			  Moneda NVARCHAR(MAX) ,
			  TipoOperacion NVARCHAR(MAX) ,
			  EstatusCompra NVARCHAR(MAX) ,
			  AreaContractual NVARCHAR(MAX) ,
			  Activo NVARCHAR(200) ,
			  RFC NVARCHAR(50))

		IF @TipoCompra = 1 --> FACTURAS POR MERCADEO O AD
			BEGIN
				INSERT INTO #RPTFLUJOFACTURAS
				SELECT		SOLPED.IdSolicitudPedido AS NCompra, PV.RazonSocial, POS.IdPedido AS NPedido ,
							AP.IdAceptacionPedido AS NAceptacionPedido, SOLPED.FechaAlta AS FechaCreacion ,
							dbo.Fn_ObtenerCentroCosto ( SOLPED.IdSolicitudPedido ) AS CentroCosto, NULL AS CuentaContable ,
							NULL AS CuentaSectorHid, FAC.SubTotal AS MontoFactura, FAC.MontoConIva AS MontoTotalPagar ,
							NULL AS MontoEjercido, NULL, NULL, NULL, TM.TipoMonedaCorto AS Moneda ,
							TPED.TipoPedido AS TipoOperacion, ES.Nombre AS EstatusCompra, AAC.NombreAreaContractual ,
							CASE WHEN ISNULL ( AF.IdEstatusEliminado, 0 ) = 0 THEN
									 'Activo'
							WHEN ISNULL ( AF.IdEstatusEliminado, 0 ) = 1 THEN
								'Eliminado'
							END AS Activo, PV.RFC
				FROM		dbo.FI_Factura AS FAC
				LEFT JOIN	dbo.MM_AceptacionFactura AS AF
					ON AF.IdFactura = FAC.IdFactura
				LEFT JOIN	dbo.TA_Operacion AS TAO
					ON TAO.IdDocumento = AF.IdAceptacionFactura ---OR TAO.IdDocumento = FAC.IdFactura
				LEFT JOIN	dbo.MM_AceptacionPedido AS AP
					ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				LEFT JOIN	MM_Pedido AS PO
					ON PO.IdPedido = AP.IdPedido
				LEFT JOIN	dbo.MM_Pedidos AS POS
					ON POS.IdIdentificador = PO.IdPedido
					   AND	POS.IdProveedorCliente = @IdProveedor
				LEFT JOIN	dbo.MM_SolicitudPedido AS SOLPED
					ON SOLPED.IdSolicitudPedido = PO.IdSolicitudPedido
				LEFT JOIN	dbo.S_Proveedor AS PC
					ON PC.IdProveedor = SOLPED.IdProveedor
				LEFT JOIN	dbo.S_Proveedor AS PV
					ON PV.IdProveedor = PO.IdSubcontratista
				LEFT JOIN	dbo.CC_CentroCosto AS CC
					ON CC.IdCentroCosto = SOLPED.IdCentroCosto
				LEFT JOIN	dbo.TA_TipoOperacion AS TAP
					ON TAP.IdTipoOperacion = TAO.IdTipoOperacion
				LEFT JOIN	dbo.TA_Estatus AS ES
					ON ES.IdEstatus = TAO.IdEstatusOperacion
				LEFT JOIN	dbo.PV_TipoMoneda AS TM
					ON TM.IdMoneda = FAC.IdMoneda
				LEFT JOIN	dbo.MM_TipoPedido AS TPED
					ON TPED.IdTipoPedido = POS.IdTipoPedido
				LEFT JOIN	Adinco.dbo.CO_Contrato AS ACC
					ON ACC.IdContrato = FAC.IdContrato
				LEFT JOIN	Adinco.dbo.CO_AreaContractual AS AAC
					ON AAC.IdAreaContractual = ACC.IdAreaContractual
				WHERE
							TAO.IdTipoOperacion = 10 --> APROBACI�N DE FACTURA
							AND SOLPED.IdProveedor = @IdProveedor
			END
		ELSE
			BEGIN
				INSERT INTO #RPTFLUJOFACTURAS
				SELECT		SOLPED.IdSolicitudPedido AS NCompra, PV.RazonSocial, POS.IdPedido AS NPedido ,
							0 AS NAceptacionPedido, FAC.FechaTimbrado AS FechaCreacion, CC.CentroCosto ,
							CCG.Descripcion AS CuentaContable, CSH.Descripcion AS CuentaSectorHid ,
							FAC.SubTotal AS MontoFactura, FAC.MontoConIva AS MontoTotalPagar ,
							CR.MontoRegistro AS MontoEjercido, CR.InicioEjecucion, CR.FinEjecucion, INC.NombreInstalacion ,
							TM.TipoMonedaCorto AS Moneda, TAP.NombreOperacion AS TipoOperacion, ES.Nombre AS EstatusCompra ,
							AAC.NombreAreaContractual, 'Activo' AS Activo, PV.RFC
				FROM		dbo.FI_Factura AS FAC
				LEFT JOIN	dbo.MM_AceptacionFactura AS AF
					ON AF.IdFactura = FAC.IdFactura
				LEFT JOIN	dbo.TA_Operacion AS TAO
					ON TAO.IdDocumento = FAC.IdFactura
				LEFT JOIN	dbo.MM_Pedidos AS POS
					ON POS.IdIdentificador = FAC.IdFactura
				LEFT JOIN	MM_Pedido AS PO
					ON PO.IdPedido = POS.IdPedido
				LEFT JOIN	dbo.MM_SolicitudPedido AS SOLPED
					ON SOLPED.IdSolicitudPedido = PO.IdSolicitudPedido
				LEFT JOIN	dbo.CO_Registro AS CR
					ON CR.IdFactura = FAC.IdFactura
				LEFT JOIN	dbo.S_Proveedor AS PV
					ON PV.IdProveedor = FAC.IdSubcontratista
				LEFT JOIN	dbo.CO_Instalacion AS INC
					ON INC.IdInstalacion = CR.IdInstalacion
				LEFT JOIN	dbo.CC_CentroCosto AS CC
					ON CC.IdCentroCosto = CR.CentroCostos
				LEFT JOIN	dbo.DG_CuentaContable AS CCG
					ON CCG.Id = CR.CuentaContable
				LEFT JOIN	dbo.CO_CatalogoCuentaSH AS CSH
					ON CSH.IdCatalogoCuentasSH = CR.IdCatalogoCuentasSH
				LEFT JOIN	dbo.TA_TipoOperacion AS TAP
					ON TAP.IdTipoOperacion = TAO.IdTipoOperacion
				LEFT JOIN	dbo.TA_Estatus AS ES
					ON ES.IdEstatus = TAO.IdEstatusOperacion
				LEFT JOIN	dbo.PV_TipoMoneda AS TM
					ON TM.IdMoneda = FAC.IdMoneda
				LEFT JOIN	Adinco.dbo.CO_Contrato AS ACC
					ON ACC.IdContrato = FAC.IdContrato
				LEFT JOIN	Adinco.dbo.CO_AreaContractual AS AAC
					ON AAC.IdAreaContractual = ACC.IdAreaContractual
				WHERE
							TAO.IdTipoOperacion = 14 --> TIPO DE ACEPACI�N DE FACTURA 
							AND POS.IdProveedorCliente = @IdProveedor
			END

		SELECT	( CASE WHEN NCompra IS NULL THEN 0 ELSE NCompra END ) AS NCompra ,
				( CASE WHEN RazonSocial IS NULL THEN 'N/A' ELSE RazonSocial END ) AS RazonSocial, NPedido ,
				NAceptacionPedido , FechaCreacion ,
				( CASE WHEN CentroCosto IS NULL THEN 'N/A' ELSE CentroCosto END ) AS CentroCosto ,
				( CASE WHEN CuentaContable IS NULL THEN 'N/A' ELSE CuentaContable END ) AS CuentaContable ,
				( CASE WHEN CuentaSectorHid IS NULL THEN 'N/A' ELSE CuentaSectorHid END ) AS CuentaSectorHid ,
				( CASE WHEN MontoFactura IS NULL THEN 0.0 ELSE MontoFactura END ) AS MontoFactura ,
				( CASE WHEN MontoTotalPagar IS NULL THEN 0.0 ELSE MontoTotalPagar END ) AS MontoTotalPagar ,
				( CASE WHEN MontoEjercido IS NULL THEN 0.0 ELSE MontoEjercido END ) AS MontoEjercido ,
				( CASE WHEN InicioEjecucion IS NULL THEN 'N/A' ELSE InicioEjecucion END ) AS InicioEjecucion ,
				( CASE WHEN FinEjecucion IS NULL THEN 'N/A' ELSE FinEjecucion END ) AS FinEjecucion ,
				( CASE WHEN NombreInstalacion IS NULL THEN 'N/A' ELSE NombreInstalacion END ) NombreInstalacion ,
				( CASE Moneda WHEN 'Peso Mexicano' THEN 'MXN' ELSE Moneda END ) AS Moneda ,
				( CASE TipoOperacion
				  WHEN 'Aprobaci�n Factura ' THEN
					  'Mercadeo'
				  ELSE
					  TipoOperacion
				  END ) AS TipoOperacion, EstatusCompra ,
				( CASE WHEN AreaContractual IS NULL THEN 'N/A' ELSE AreaContractual END ) AS AreaContractual, Activo ,
				RFC
		FROM	#RPTFLUJOFACTURAS
	END
