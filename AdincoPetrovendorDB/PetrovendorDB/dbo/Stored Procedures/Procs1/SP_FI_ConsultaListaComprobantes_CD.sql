-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/09/2020>
-- Description:	<consultar los comprobantes extranjeros de compra directa>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaListaComprobantes_CD] --420,0,1,''
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
	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 10;

	SET @AllRecords = (SELECT 
							COUNT(1)
						 FROM dbo.FI_PedimentoComprobante AS PC
							LEFT JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
							LEFT JOIN Adinco.dbo.PV_Subcontratista SI ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
							LEFT JOIN Adinco.dbo.PV_Subcontratista SE ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
							LEFT JOIN Adinco.dbo.PV_TipoMoneda TM ON PC.IdMoneda = TM.IdMoneda
							LEFT JOIN Adinco.dbo.AP_Lista L ON PC.IdFormaPago = L.IdClave
									 AND L.IdGrupo = 10001
							JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
									ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
							JOIN dbo.TA_Operacion AS OP
								ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
								AND OP.IdTipoOperacion = 19
								AND OP.IdProveedor = APC.IdProveedor
							JOIN dbo.TA_Estatus AS TE
									ON TE.IdEstatus = OP.IdEstatusOperacion
						 WHERE PC.CvTipoDocFacturacion = 3
							   AND APC.IdProveedor = @IdProveedor
							   AND ISNULL(PC.IdEstatusEliminado,0) = 0
							   AND (CAST(PC.IdPedimentoComprobante AS NVARCHAR) LIKE '%' + @Buscar + '%'
								OR PC.FolioComprobante LIKE '%' + @Buscar + '%'
								OR PC.NumFacturaC LIKE '%' + @Buscar + '%'
								OR PCD.DescripcionMercancia LIKE '%' + @Buscar + '%')
							   );

    SELECT *,
			  @AllRecords AS Records,
			  @RecordsByPage AS RecordsByPage
		FROM
		(
	SELECT 
		ROW_NUMBER() OVER(PARTITION BY APC.IdPedimentoComprobante ORDER BY APC.IdPedimentoComprobante DESC) AS R,
		PC.IdPedimentoComprobante AS IdComprobante,
        PC.FolioComprobante,
        PC.FechaPago,
        SUBSTRING(SE.RazonSocial, 0, 30) AS Exportador,
        CASE
			WHEN LEN(ISNULL(PCD.ClaseBienServicio,'')) > 50 THEN SUBSTRING(ISNULL(PCD.ClaseBienServicio,''),1,48) + '..'
			ELSE ISNULL(PCD.ClaseBienServicio,'') 
		END AS ClaseBienServicio,
        SUBSTRING(MU.Unidad, 0, 30) AS UnidadMedida,
        TM.TipoMonedaCorto,
        PCD.PrecioUnitario,
        PCD.Cantidad,
        PCD.ImporteTotal,
        L.Nombre AS FormaDePago,
        UC.Nombre AS CreadoPor,
        PC.CreadoEn,
        UM.Nombre AS ModificadoPor,
        PC.ModificadoEn,
        PC.NumFacturaC,
		CASE 
			WHEN ISNULL(PC.EsnotaCredito,0) = 0 THEN  'No'
			ELSE 'Si'
		END AS EsnotaCredito,
		TE.Nombre AS Estatus,
		CC.CentroCosto,
		CO.Numero + ' - ' + CO.Descripcion AS CuentaContable,
		(ROW_NUMBER() OVER(ORDER BY PC.CreadoEn DESC) - 1) / @RecordsByPage AS _Page
     FROM dbo.FI_PedimentoComprobante AS PC
        LEFT JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
        LEFT JOIN Adinco.dbo.PV_Subcontratista SI ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
        LEFT JOIN Adinco.dbo.PV_Subcontratista SE ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
        LEFT JOIN Adinco.dbo.PV_TipoMoneda TM ON PC.IdMoneda = TM.IdMoneda
        LEFT JOIN dbo.S_Usuario UC ON PC.CreadoPor = UC.IdUsuario
        LEFT JOIN dbo.S_Usuario UM ON PC.ModificadoPor = UM.IdUsuario
        LEFT JOIN Adinco.dbo.AP_Lista L ON PC.IdFormaPago = L.IdClave
                 AND L.IdGrupo = 10001
        LEFT JOIN Adinco.dbo.PV_MM_MaterialUnidad MU ON PCD.IdUnidadMedida = MU.IdUnidad
        LEFT JOIN dbo.FI_Documento D ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante
		JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
				ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		JOIN dbo.TA_Operacion AS OP
			ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
			AND OP.IdTipoOperacion = 19
			AND OP.IdProveedor = APC.IdProveedor
		LEFT JOIN dbo.FI_RelacionAdincoPedimentoComprobante AS RAPC
				ON RAPC.IdPedimentoComprobantePetrovendor = PC.IdPedimentoComprobante
		JOIN dbo.TA_Estatus AS TE
				ON TE.IdEstatus = OP.IdEstatusOperacion
		LEFT JOIN dbo.CC_CentroCosto AS CC
				ON CC.IdCentroCosto = PC.IdCentroCosto
		LEFT JOIN dbo.DG_CuentaContable AS CO
				ON CO.Id = PC.IdCuentaContable
     WHERE PC.CvTipoDocFacturacion = 3
           AND APC.IdProveedor = @IdProveedor
		   AND ISNULL(PC.IdEstatusEliminado,0) = 0
		   AND (CAST(PC.IdPedimentoComprobante AS NVARCHAR) LIKE '%' + @Buscar + '%'
								OR PC.FolioComprobante LIKE '%' + @Buscar + '%'
								OR PC.NumFacturaC LIKE '%' + @Buscar + '%'
								OR PCD.DescripcionMercancia LIKE '%' + @Buscar + '%')
	 ) AS R
		WHERE R.R = 1 AND
			R._Page = (@Page - 1)
		ORDER BY R.CreadoEn DESC;

END
