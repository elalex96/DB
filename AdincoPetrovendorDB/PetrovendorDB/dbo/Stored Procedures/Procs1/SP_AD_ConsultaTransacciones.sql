-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ConsultaTransacciones] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PEDS.IdIdentificador, 
			PEDS.IdPedido, 
			SOLPED.IdSolicitudPedido, 
			PROV.RazonSocial AS Proveedor, 
			MMA.DescripcionCorta AS ServicioMaterial,
			SUM(PEDD.Subtotal) AS Monto,
			TMP.TipoMonedaCorto AS Moneda, 
			OPE.RazonSocial AS Operadora, 
			AAC.NombreAreaContractual, 
			SOLPED.FechaAlta AS FechaAltaSolicitud, 
			PED.CreadoEl AS FechaAltaPedido,
			TP.TipoPedido  
	FROM dbo.MM_SolicitudPedido AS SOLPED
	LEFT JOIN dbo.MM_Pedido AS PED ON PED.IdSolicitudPedido = SOLPED.IdSolicitudPedido
	LEFT JOIN dbo.MM_PedidoDetalle AS PEDD ON PEDD.IdPedido = PED.IdPedido
	LEFT JOIN dbo.MM_Pedidos AS PEDS ON PEDS.IdIdentificador = PED.IdPedido
	LEFT JOIN dbo.S_Proveedor AS PROV ON PROV.IdProveedor = PED.IdSubcontratista
	LEFT JOIN dbo.S_Proveedor AS OPE ON OPE.IdProveedor = SOLPED.IdProveedor
	LEFT JOIN Adinco.dbo.CO_Contrato AS ACC ON ACC.IdContrato = SOLPED.IdContrato
	LEFT JOIN Adinco.dbo.CO_AreaContractual AS AAC ON AAC.IdAreaContractual = ACC.IdAreaContractual
	LEFT JOIN dbo.MM_Material AS MMA ON MMA.IdMaterial = PEDD.IdMaterialVendedor
	LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PEDS.IdTipoPedido
	LEFT JOIN dbo.PV_TipoMoneda AS TMP ON TMP.IdMoneda = PEDD.IdMoneda
	GROUP BY PEDS.IdIdentificador, 
			PED.IdPedido, 
			SOLPED.IdSolicitudPedido, 
			PROV.RazonSocial, 
			PEDD.Subtotal, 
			OPE.RazonSocial, 
			AAC.NombreAreaContractual, 
			SOLPED.FechaAlta, 
			PED.CreadoEl,
			MMA.DescripcionCorta,
			TP.TipoPedido,
			PEDS.IdPedido,
			TMP.TipoMonedaCorto  
	ORDER BY FechaAltaPedido DESC

END
