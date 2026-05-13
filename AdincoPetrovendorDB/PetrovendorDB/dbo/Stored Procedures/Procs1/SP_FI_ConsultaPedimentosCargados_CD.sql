-- =============================================
-- Author:		<Alexnader Gomez>
-- Create date: <08/09/2020>
-- Description:	<Consulta de los pedimentos/comprobantes en adinco>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaPedimentosCargados_CD]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT
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
    PCD.DescripcionMercancia,
    TM.TipoMonedaCorto,
    PCD.PrecioUnitario,
    PCD.Cantidad,
	CASE
        WHEN D.DocumentoByte IS NULL OR D.DocumentoByte LIKE 0x
        THEN 'NO CARGADO'
        ELSE 'Cargado'
    END AS 'Archivo',
	US.Nombre AS CreadoPor,
	PC.CreadoEn,
	PC.ModificadoEn,
	USM.Nombre AS ModificadoPor,
	ISNULL(PC.CuentaBancaria,'') CuentaBancaria,
	CASE
		WHEN RAPC.IdRelacionPedimentoComprobante IS NOT NULL THEN 1
		ELSE 0
	END AS EnviadoAdinco,
	TE.Nombre AS Estatus
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
WHERE APC.IdProveedor = @IdProveedor
AND PC.CvTipoDocFacturacion = 2
ORDER BY PC.CreadoEn DESC

END
