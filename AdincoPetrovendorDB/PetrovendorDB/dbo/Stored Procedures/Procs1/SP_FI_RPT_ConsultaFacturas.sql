USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_RPT_ConsultaFacturas'
)
    DROP PROCEDURE SP_FI_RPT_ConsultaFacturas;   
	
GO
/****** Object:  StoredProcedure [dbo].[SP_FI_RPT_ConsultaFacturas]    Script Date: 26/06/2023 03:36:00 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 23/03/2018
-- Description:	Consulta de todas las facturas para el modulo de reporte de facturas
-- Author:		Daniel AC
-- Update date: 06/06/2018
-- Description:	Se agrego condicion donde se indica aceptación de factura esta activa
-- =============================================
-- Author:		Pedro Acuña
-- Update date: 27/08/2018
-- Description:	Se modifica la compra directa de donde se toma el numero consecutivo de la compra directa
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 26-06-2023
-- Description:	Se agrega columnas uuid, folio factura y fecha de timbrado
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 30-03-2026
-- Description:	Se agregan columnas Requisitor y SoporteProveedor al reporte de facturas
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
			  RFC NVARCHAR(50),
			  FolioFactura		nvarchar(200)	NULL,
			  UUID				nvarchar(100)	NULL,
			  FechaTimbrado		datetime		NULL,
			  Requisitor		NVARCHAR(MAX)	NULL,
			  SoporteProveedor	NVARCHAR(10)	NULL)

		IF @TipoCompra = 1 --> FACTURAS POR MERCADEO O AD
			BEGIN
				INSERT INTO #RPTFLUJOFACTURAS(
				NCompra,
				  RazonSocial,
				  NPedido,
				  NAceptacionPedido,
				  FechaCreacion,
				  CentroCosto,
				  CuentaContable,
				  CuentaSectorHid,
				  MontoFactura ,
				  MontoTotalPagar,
				  MontoEjercido,
				  InicioEjecucion,
				  FinEjecucion,
				  NombreInstalacion,
				  Moneda,
				  TipoOperacion,
				  EstatusCompra,
				  AreaContractual,
				  Activo,
				  RFC,
				  FolioFactura,
				  UUID,
				  FechaTimbrado,
				  Requisitor,
				  SoporteProveedor)
				SELECT		SOLPED.IdSolicitudPedido AS NCompra, 
							PV.RazonSocial, 
							POS.IdPedido AS NPedido ,
							AP.IdAceptacionPedido AS NAceptacionPedido, 
							SOLPED.FechaAlta AS FechaCreacion ,
							dbo.Fn_ObtenerCentroCosto ( SOLPED.IdSolicitudPedido ) AS CentroCosto, 
							NULL AS CuentaContable ,
							NULL AS CuentaSectorHid, 
							FAC.SubTotal AS MontoFactura, 
							FAC.MontoConIva AS MontoTotalPagar ,
							NULL AS MontoEjercido, 
							NULL, 
							NULL, 
							NULL, 
							TM.TipoMonedaCorto AS Moneda ,
							TPED.TipoPedido AS TipoOperacion, 
							ES.Nombre AS EstatusCompra, 
							AAC.NombreAreaContractual ,
							CASE WHEN ISNULL ( AF.IdEstatusEliminado, 0 ) = 0 THEN
									 'Activo'
							WHEN ISNULL ( AF.IdEstatusEliminado, 0 ) = 1 THEN
								'Eliminado'
							END AS Activo, PV.RFC,
							CONCAT(ISNULL(FAC.Serie,''),(CASE WHEN LEN(RTRIM(LTRIM(ISNULL(FAC.Serie,''))))>0 AND LEN(RTRIM(LTRIM(ISNULL(FAC.Folio,'')))) >0 THEN '-' END), ISNULL(FAC.Folio,'')) AS FolioFactura,
							ISNULL(FAC.UUID,'') AS UUID,
							FAC.FechaTimbrado AS FechaTimbrado,
							ISNULL(USR.Nombre, 'N/A') AS Requisitor,
							CASE WHEN EXISTS (
								SELECT 1 FROM dbo.MM_DocSoporteRecepcionFactura DS (NOLOCK)
								WHERE DS.IdAceptacionPedido = AP.IdAceptacionPedido
								  AND ISNULL(DS.Eliminado, 0) = 0
							) THEN 'Sí' ELSE 'No' END AS SoporteProveedor
				FROM		dbo.FI_Factura AS FAC
				JOIN	dbo.MM_AceptacionFactura AS AF (NOLOCK)
					ON FAC.IdFactura = AF.IdFactura  
				JOIN	dbo.TA_Operacion AS TAO (NOLOCK)
					ON AF.IdAceptacionFactura = TAO.IdDocumento 
					 AND ISNULL(TAO.IdEstatusEliminado, 0) <> 1 -->CTE QUE NO ESTE ELIMINADO
				JOIN	dbo.MM_AceptacionPedido AS AP (NOLOCK)
					ON AF.IdAceptacionPedido =  AP.IdAceptacionPedido
					AND  ISNULL(AP.IdEliminado, 0) <> 1 -->CTE QUE NO ESTE ELIMINADO
				JOIN	MM_Pedido AS PO (NOLOCK)
					ON AP.IdPedido = PO.IdPedido  
				JOIN	dbo.MM_Pedidos AS POS (NOLOCK)
					ON PO.IdPedido = POS.IdIdentificador 
					   AND	POS.IdProveedorCliente = @IdProveedor
					   AND POS.IdTipoPedido IN (2, 4, 6)-->CTES	MERCADEO, ADJUDICACIÓN DIRECTA, CONTROL DE OBRA	
				JOIN	dbo.S_Proveedor AS PV (NOLOCK)
					ON PO.IdSubcontratista = PV.IdProveedor 
				JOIN	dbo.MM_SolicitudPedido AS SOLPED
					ON  PO.IdSolicitudPedido = SOLPED.IdSolicitudPedido 
				JOIN	dbo.TA_Estatus AS ES (NOLOCK)
					ON TAO.IdEstatusOperacion = ES.IdEstatus 
				LEFT JOIN	dbo.S_Usuario AS USR (NOLOCK)
					ON SOLPED.IdUsuarioSolicitante = USR.IdUsuario
				LEFT JOIN	dbo.CC_CentroCosto AS CC (NOLOCK)
					ON  SOLPED.IdCentroCosto = CC.IdCentroCosto 				 
				LEFT JOIN	dbo.PV_TipoMoneda AS TM (NOLOCK)
					ON FAC.IdMoneda = TM.IdMoneda 
				LEFT JOIN	dbo.MM_TipoPedido AS TPED (NOLOCK)
					ON  POS.IdTipoPedido = TPED.IdTipoPedido 
				LEFT JOIN	Adinco.dbo.CO_Contrato AS ACC (NOLOCK)
					ON FAC.IdContrato = ACC.IdContrato  
				LEFT JOIN	Adinco.dbo.CO_AreaContractual AS AAC (NOLOCK)
					ON ACC.IdAreaContractual = AAC.IdAreaContractual 
				WHERE
				TAO.IdTipoOperacion = 10 -->CTE APROBACIÓN DE FACTURA
				AND SOLPED.IdProveedor = @IdProveedor
				AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 -->CTE NO ESTE ELIMINADO
				AND ISNULL(TAO.IdFlujoTarea, 0) <> 0
			END
		ELSE
			BEGIN
				INSERT INTO #RPTFLUJOFACTURAS(
				NCompra,
				  RazonSocial,
				  NPedido,
				  NAceptacionPedido,
				  FechaCreacion,
				  CentroCosto,
				  CuentaContable,
				  CuentaSectorHid,
				  MontoFactura ,
				  MontoTotalPagar,
				  MontoEjercido,
				  InicioEjecucion,
				  FinEjecucion,
				  NombreInstalacion,
				  Moneda,
				  TipoOperacion,
				  EstatusCompra,
				  AreaContractual,
				  Activo,
				  RFC,
				  FolioFactura,
				  UUID,
				  FechaTimbrado,
				  Requisitor,
				  SoporteProveedor)
				SELECT		0 AS NCompra, 
							PV.RazonSocial, 
							POS.IdPedido AS NPedido ,
							0 AS NAceptacionPedido, 
							FAC.FechaTimbrado AS FechaCreacion, 
							CC.CentroCosto ,
							CCG.Descripcion AS CuentaContable, 
							CSH.Descripcion AS CuentaSectorHid ,
							FAC.SubTotal AS MontoFactura, 
							FAC.MontoConIva AS MontoTotalPagar ,
							CR.MontoRegistro AS MontoEjercido, 
							CR.InicioEjecucion, 
							CR.FinEjecucion, 
							INC.NombreInstalacion ,
							TM.TipoMonedaCorto AS Moneda, 
							TAP.NombreOperacion AS TipoOperacion, 
							ES.Nombre AS EstatusCompra ,
							AAC.NombreAreaContractual,
							'Activo' AS Activo,
							PV.RFC,
							CONCAT(ISNULL(FAC.Serie,''),(CASE WHEN LEN(RTRIM(LTRIM(ISNULL(FAC.Serie,''))))>0 AND LEN(RTRIM(LTRIM(ISNULL(FAC.Folio,'')))) >0 THEN '-' END), ISNULL(FAC.Folio,'')) AS FolioFactura,
							ISNULL(FAC.UUID,'') AS UUID,
							FAC.FechaTimbrado AS FechaTimbrado,
							'N/A' AS Requisitor,
							CASE WHEN EXISTS (
								SELECT 1 FROM dbo.Pv_DocSoporte_CompraDirecta DS (NOLOCK)
								WHERE DS.idFactura = FAC.IdFactura
								  AND ISNULL(DS.isEliminado, 0) = 0
							) THEN 'Sí' ELSE 'No' END AS SoporteProveedor
				FROM		dbo.CO_Registro AS CR (NOLOCK)
				JOIN FI_Factura AS FAC (NOLOCK)
						ON CR.IdFactura = FAC.IdFactura  
				JOIN	dbo.TA_Operacion AS TAO (NOLOCK)
					ON FAC.IdFactura = TAO.IdDocumento 
				JOIN	dbo.MM_Pedidos AS POS (NOLOCK)
					ON FAC.IdFactura = POS.IdIdentificador 
					 AND POS.IdTipoPedido= 1 --> CTE COMPRA DIRECTA
					 AND TAO.IdProveedor=POS.IdProveedorCliente	
				LEFT JOIN	dbo.S_Proveedor AS PV (NOLOCK)
					ON FAC.IdSubcontratista = PV.IdProveedor
				LEFT JOIN	dbo.CO_Instalacion AS INC (NOLOCK)
					ON CR.IdInstalacion = INC.IdInstalacion
				LEFT JOIN	dbo.CC_CentroCosto AS CC (NOLOCK)
					ON CR.CentroCostos = CC.IdCentroCosto
				LEFT JOIN	dbo.DG_CuentaContable AS CCG (NOLOCK)
					ON CR.CuentaContable = CCG.Id
				LEFT JOIN	dbo.CO_CatalogoCuentaSH AS CSH (NOLOCK)
					ON CR.IdCatalogoCuentasSH = CSH.IdCatalogoCuentasSH
				LEFT JOIN	dbo.TA_TipoOperacion AS TAP (NOLOCK)
					ON TAO.IdTipoOperacion = TAP.IdTipoOperacion
				LEFT JOIN	dbo.TA_Estatus AS ES (NOLOCK)
					ON TAO.IdEstatusOperacion = ES.IdEstatus
				LEFT JOIN	dbo.PV_TipoMoneda AS TM (NOLOCK)
					ON FAC.IdMoneda = TM.IdMoneda
				LEFT JOIN	Adinco.dbo.CO_Contrato AS ACC (NOLOCK)
					ON FAC.IdContrato = ACC.IdContrato
				LEFT JOIN	Adinco.dbo.CO_AreaContractual AS AAC (NOLOCK)
					ON ACC.IdAreaContractual = AAC.IdAreaContractual 
				WHERE
				TAO.IdTipoOperacion = 14 -->CTE TIPO DE ACEPTACIÓN DE FACTURA 
				AND TAO.IdProveedor = @IdProveedor
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
				  WHEN 'Aprobación Factura ' THEN
					  'Mercadeo'
				  ELSE
					  TipoOperacion
				  END ) AS TipoOperacion, EstatusCompra ,
				( CASE WHEN AreaContractual IS NULL THEN 'N/A' ELSE AreaContractual END ) AS AreaContractual, Activo ,
				RFC,
				FolioFactura,
				UUID,
				FechaTimbrado,
				( CASE WHEN Requisitor IS NULL THEN 'N/A' ELSE Requisitor END ) AS Requisitor,
				( CASE WHEN SoporteProveedor IS NULL THEN 'No' ELSE SoporteProveedor END ) AS SoporteProveedor
		FROM	#RPTFLUJOFACTURAS
	END
