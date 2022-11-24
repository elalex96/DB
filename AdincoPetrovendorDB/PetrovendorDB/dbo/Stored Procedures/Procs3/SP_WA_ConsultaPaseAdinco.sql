-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/10/2019>
-- Description:	<Consulta del pase adinco>
-- =============================================
CREATE PROCEDURE [dbo].[SP_WA_ConsultaPaseAdinco]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		BEA.IdRegistroEnvioAdinco,
		BEA.FechaEnvio,
		CONCAT(ISNULL(US.Nombre,''),' - ' , ISNULL(US.Correo,'')) AS Usuario,
		CONCAT(ISNULL(PR.RazonSocial,''), ' - RFC:' , ISNULL(PR.RFC,'')) AS Proveedor,
		CONCAT(ISNULL(C.NumeroContrato,''),' - ',ISNULL(AC.NombreAreaContractual,'')) AS Contrato,
		CASE
			WHEN BEA.IdTipoEnvio = 1 THEN 'FACTURA'
			WHEN BEA.IdTipoEnvio = 2 THEN 'GASTO'
			WHEN BEA.IdTipoEnvio = 3 THEN 'COMPROBANTE EXTRANJERO'
			WHEN BEA.IdTipoEnvio = 4 THEN 'PEDIMENTO DE IMPORTACION'
		END AS TipoEnvio,
		CASE
			WHEN BEA.IdTipoEnvio = 1 THEN CONCAT(
													'IdFacturaPetrovendor: ' , BEA.IdDocumento,
													' - IdFacturaAdinco: ', BEA.IdDocumentoAdinco,
													' - UUID: ', FB.UUID
													)
			WHEN BEA.IdTipoEnvio = 2 THEN CONCAT(
													'IdRegistroPetrovendor: ' , BEA.IdDocumento,
													' - IdRegistroAdinco: ', BEA.IdDocumentoAdinco,
													' - IdAceptacionPedidoDetalle: ', RB.IdAceptacionPedidoDetalle
													)
			WHEN BEA.IdTipoEnvio = 3 THEN CONCAT(
													'IdComprobantePetrovendor: ' , BEA.IdDocumento,
													' - IdComprobanteAdinco: ', BEA.IdDocumentoAdinco
													)
			WHEN BEA.IdTipoEnvio = 4 THEN CONCAT(
													'IdPedimentoPetrovendor: ' , BEA.IdDocumento,
													' - IdPedimentoAdinco: ', BEA.IdDocumentoAdinco
													)
		END AS DatosEnviados,
		BEA.IsError AS ErrorEnvio,
		BEA.WSMensaje
	FROM dbo.WA_BitacoraEnvioAdinco AS BEA
		LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = BEA.IdUsuario
		LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = BEA.IdProveedor
		LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = BEA.IdContrato
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
		LEFT JOIN dbo.WA_Factura_Bitacora AS FB ON FB.IdFactura = BEA.IdDocumento
		LEFT JOIN dbo.WA_Registro_Bitacora AS RB ON RB.IdRegistro = BEA.IdDocumento
	GROUP BY CONCAT(ISNULL(US.Nombre, ''), ' - ', ISNULL(US.Correo, '')),
             CONCAT(ISNULL(PR.RazonSocial, ''), ' - RFC:', ISNULL(PR.RFC, '')),
             CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')),
             CASE
             WHEN BEA.IdTipoEnvio = 1 THEN
             'FACTURA'
             WHEN BEA.IdTipoEnvio = 2 THEN
             'GASTO'
             WHEN BEA.IdTipoEnvio = 3 THEN
             'COMPROBANTE EXTRANJERO'
             WHEN BEA.IdTipoEnvio = 4 THEN
             'PEDIMENTO DE IMPORTACION'
             END,
             CASE
             WHEN BEA.IdTipoEnvio = 1 THEN
             CONCAT(
             'IdFacturaPetrovendor: ',
             BEA.IdDocumento,
             ' - IdFacturaAdinco: ',
             BEA.IdDocumentoAdinco,
             ' - UUID: ',
             FB.UUID
             )
             WHEN BEA.IdTipoEnvio = 2 THEN
             CONCAT(
             'IdRegistroPetrovendor: ',
             BEA.IdDocumento,
             ' - IdRegistroAdinco: ',
             BEA.IdDocumentoAdinco,
             ' - IdAceptacionPedidoDetalle: ',
             RB.IdAceptacionPedidoDetalle
             )
             WHEN BEA.IdTipoEnvio = 3 THEN
             CONCAT('IdComprobantePetrovendor: ', BEA.IdDocumento, ' - IdComprobanteAdinco: ', BEA.IdDocumentoAdinco)
             WHEN BEA.IdTipoEnvio = 4 THEN
             CONCAT('IdPedimentoPetrovendor: ', BEA.IdDocumento, ' - IdPedimentoAdinco: ', BEA.IdDocumentoAdinco)
             END,
             BEA.IdRegistroEnvioAdinco,
             BEA.FechaEnvio,
             BEA.IsError,
             BEA.WSMensaje
		ORDER BY BEA.FechaEnvio DESC

END
