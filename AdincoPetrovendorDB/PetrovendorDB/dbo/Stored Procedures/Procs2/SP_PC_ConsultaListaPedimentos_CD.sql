-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/09/20202>
-- Description:	<Consulta de los pedimentos de compra directa>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultaListaPedimentos_CD] --420,2199,1,''
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
	@Page INT,
	@Buscar NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 10;

	SET @AllRecords = (SELECT
							COUNT(1)
						FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
							JOIN dbo.TA_Operacion AS OP
								ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
								AND OP.IdTipoOperacion = 19
								AND OP.IdProveedor = APC.IdProveedor
							JOIN dbo.FI_PedimentoComprobante AS PC
								ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante
							JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD
								ON PCD.IdPedimentoComprobante = PC.IdPedimentoComprobante
							LEFT JOIN Adinco.dbo.FI_ClavesPedimento AS CP 
								ON PC.ClavePedimento = CP.IdPedimento
							LEFT JOIN Adinco.dbo.PV_Subcontratista AS SE 
								ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
						WHERE APC.IdProveedor = @IdProveedor
							AND PC.CvTipoDocFacturacion = 2
							AND ISNULL(PC.IdEstatusEliminado,0) = 0
							AND (PC.NumeroPedimento LIKE '%' + @Buscar + '%'
								OR CP.Clave LIKE '%' + @Buscar + '%'
								OR PC.FolioComprobante LIKE '%' + @Buscar + '%'
								OR SE.RazonSocial LIKE '%' + @Buscar + '%'
								OR CAST(PC.IdPedimentoComprobante AS NVARCHAR) LIKE '%' + @Buscar + '%')
							AND ISNULL(PC.IdEstatusEliminado,0) = 0
							AND ISNULL(OP.IdEstatusEliminado,0) = 0
							AND PC.TipoOrigen = 'PC_CD');

		SELECT *,
			  @AllRecords AS Records,
			  @RecordsByPage AS RecordsByPage
		FROM
		(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY APC.IdAceptacionPedidoPedimentoComprobante ORDER BY APC.IdAceptacionPedidoPedimentoComprobante DESC) AS R,
			PC.IdPedimentoComprobante AS IdPedimento,
			PC.NumeroPedimento,
			CP.Clave AS ClavePedimento,
			PC.FolioComprobante,
			PC.FechaPago,
			PC.Regimen,
			SI.RazonSocial AS Importador,
			PC.AduanaES,
			SUBSTRING(SE.RazonSocial, 0, 30) AS Exportador,
			PC.AcuseElectronico,
			CASE
				WHEN LEN(ISNULL(PCD.DescripcionMercancia,'')) > 50 THEN SUBSTRING(ISNULL(PCD.DescripcionMercancia,''),1,48) + '..'
				ELSE ISNULL(PCD.DescripcionMercancia,'') 
			END AS DescripcionMercancia,
			TM.TipoMonedaCorto,
			PCD.PrecioUnitario,
			PCD.Cantidad,
			US.Nombre AS CreadoPor,
			PC.CreadoEn,
			PC.ModificadoEn,
			USM.Nombre AS ModificadoPor,
			CASE
				WHEN LEN(ISNULL(PC.CuentaBancaria,'')) > 20 THEN SUBSTRING(ISNULL(PC.CuentaBancaria,''),1,18) + '..'
				ELSE ISNULL(PC.CuentaBancaria,'') 
			END AS CuentaBancaria,
			CASE
				WHEN RAPC.IdRelacionPedimentoComprobante IS NOT NULL THEN 1
				ELSE 0
			END AS EnviadoAdinco,
			TE.Nombre AS Estatus,
			CC.CentroCosto,
			CO.Numero + ' - ' + CO.Descripcion AS CuentaContable,
			(ROW_NUMBER() OVER(ORDER BY PC.CreadoEn DESC) - 1) / @RecordsByPage AS _Page
		FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
			JOIN dbo.TA_Operacion AS OP
				ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
				AND OP.IdTipoOperacion = 19
				AND OP.IdProveedor = APC.IdProveedor
			JOIN dbo.FI_PedimentoComprobante AS PC
				ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante
			JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD
				ON PCD.IdPedimentoComprobante = PC.IdPedimentoComprobante
			LEFT JOIN Adinco.dbo.FI_ClavesPedimento AS CP 
				ON PC.ClavePedimento = CP.IdPedimento
			LEFT JOIN Adinco.dbo.PV_Subcontratista AS SI 
				ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
			LEFT JOIN Adinco.dbo.PV_Subcontratista AS SE 
				ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
			INNER JOIN Adinco.dbo.PV_TipoMoneda AS TM 
				ON PC.IdMoneda = TM.IdMoneda
			JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = APC.CreadoPor
			LEFT JOIN dbo.S_Usuario AS USM
				ON USM.IdUsuario = PC.ModificadoPor
			LEFT JOIN dbo.FI_Documento AS D
				ON D.IdPedimentoComprobante = PC.IdPedimentoComprobante
			LEFT JOIN dbo.FI_RelacionAdincoPedimentoComprobante AS RAPC
				ON RAPC.IdPedimentoComprobantePetrovendor = PC.IdPedimentoComprobante
			JOIN dbo.TA_Estatus AS TE
				ON TE.IdEstatus = OP.IdEstatusOperacion
			LEFT JOIN dbo.CC_CentroCosto AS CC
				ON CC.IdCentroCosto = PC.IdCentroCosto
			LEFT JOIN dbo.DG_CuentaContable AS CO
				ON CO.Id = PC.IdCuentaContable
		WHERE APC.IdProveedor = @IdProveedor
			AND ISNULL(PC.IdEstatusEliminado,0) = 0
			AND (PC.NumeroPedimento LIKE '%' + @Buscar + '%'
								OR CP.Clave LIKE '%' + @Buscar + '%'
								OR PC.FolioComprobante LIKE '%' + @Buscar + '%'
								OR SE.RazonSocial LIKE '%' + @Buscar + '%'
								OR CAST(PC.IdPedimentoComprobante AS NVARCHAR) LIKE '%' + @Buscar + '%')
			AND ISNULL(PC.IdEstatusEliminado,0) = 0
			AND ISNULL(OP.IdEstatusEliminado,0) = 0
			AND PC.TipoOrigen = 'PC_CD'
		) AS R
		WHERE R.R = 1 AND
			R._Page = (@Page - 1)
		ORDER BY R.CreadoEn DESC;
END
