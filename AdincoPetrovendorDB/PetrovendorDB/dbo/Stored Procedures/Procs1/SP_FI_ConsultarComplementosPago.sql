-- =============================================
-- Author:		<Alexander GOmez>
-- Create date: <07/01/2020>
-- Description:	<Consulta de los complementos de pago>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultarComplementosPago] --420,3,1
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdContrato INT,
	@Estatus INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		AF.IdAceptacionFactura,
		AF.IdAceptacionPedido,
		F.IdFactura,
		F.UUID AS FacturaUUID,
		FCDP.UUID AS ComplementoUUID,
		DR.ImpPagado AS ImportePagadoComplemento,
		TM.TipoMonedaCorto AS TipoMonedaFactura,
		F.SubTotal AS SubTotalFactura,
		F.MontoConIva AS TotalFactura,
		CASE
			WHEN CP.IdComplementoDePago IS NOT NULL THEN 'COMPLEMENTO(S) CARGADO(S)'
			WHEN CP.IdComplementoDePago IS NULL THEN 'COMPLEMENTO(S) NO CARGADO(S)'
			ELSE 'COMPLEMENTO(S) NO CARGADO(S)'
		END AS ESTATUSCOMPLEMENTOS,
		PR.RazonSocial AS NombreSubContratista,
		TA.IdOperacion,
		CAST(F.Fecha AS DATE) AS Fecha,
		CASE  
			WHEN CP.IdComplementoDePago IS NOT NULL THEN 'label label-primary'  
			WHEN CP.IdComplementoDePago IS NULL THEN 'label label-secondary'
		END AS SPAN,
		Contrato = c.NumeroContrato
	INTO #COMPLEMENTOSPAGO
	FROM dbo.TA_Operacion AS TA
		LEFT JOIN dbo.MM_AceptacionFactura AS AF ON AF.IdAceptacionFactura = TA.IdDocumento
		LEFT JOIN dbo.FI_Factura AS F ON F.IdFactura = AF.IdFactura
		LEFT JOIN Adinco.dbo.FI_CPDocRelacionado AS DR ON DR.IdDocumento COLLATE SQL_Latin1_General_CP1_CI_AS = F.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN Adinco.dbo.FI_ComplementoDePago AS CP ON CP.IdComplementoDePago = DR.IdComplementoDePago
		LEFT JOIN Adinco.dbo.FI_Factura AS FCDP ON FCDP.IdFactura = CP.IdFactura
		LEFT JOIN dbo.S_Proveedor AS PO ON PO.RFC = F.Receptor
		LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC = F.Emisor
		LEFT JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = F.IdMoneda 
		inner JOIN	Adinco.dbo.CO_Contrato	AS	C 	ON	FCDP.IdContrato	=	C.IdContrato 
	WHERE TA.IdTipoOperacion = 10
		AND TA.IdEstatusOperacion = 2
		AND F.IdContrato = @IdContrato
		AND PO.IdProveedor = @IdProveedor
	GROUP BY CP.IdComplementoDePago,
             AF.IdAceptacionFactura,
             AF.IdAceptacionPedido,
             F.IdFactura,
             F.UUID,
             TM.TipoMonedaCorto,
             F.SubTotal,
             F.MontoConIva,
             PR.RazonSocial,
             TA.IdOperacion,
			 FCDP.UUID,
			 DR.ImpPagado,
             F.Fecha,
			 c.IdContrato,
			 c.NumeroContrato


		SELECT
			IdAceptacionPedido,
			IdFactura,
			FacturaUUID,
			TipoMonedaFactura,
			SubTotalFactura,
			TotalFactura,
			ESTATUSCOMPLEMENTOS,
			NombreSubContratista,
			Fecha,
			SPAN,
			SUM(ISNULL(ImportePagadoComplemento,0)) AS MontoAcumulado,
			(TotalFactura - (SUM(ISNULL(ImportePagadoComplemento,0)))) AS MontoInsoluto,
			Contrato
		FROM #COMPLEMENTOSPAGO
		GROUP BY IdAceptacionPedido,
                 IdFactura,
                 FacturaUUID,
                 TipoMonedaFactura,
                 SubTotalFactura,
                 TotalFactura,
                 ESTATUSCOMPLEMENTOS,
                 NombreSubContratista,
                 Fecha,
                 SPAN,
				 Contrato
		ORDER BY MontoInsoluto ASC

END