-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <08/09/2020>
-- Description:	<Consultar Datos Pedimento/Comprobante>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaPedimentoComprobanteProcura_CD] 
	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT, 
	@Accion                 INT, 
	@IdContrato             INT, 
	@IdUsuario              INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(@Accion = 1)
             BEGIN
                 SELECT PC.IdSubcontratistaExportador AS IdSubcontratista, 
                        PC.FolioComprobante, 
                        PC.NumFacturaC, 
                        PC.FechaPago, 
                        PCD.ClaseBienServicio, 
                        PC.IdMoneda, 
                        PCD.PrecioUnitario, 
                        PCD.IdUnidadMedida,
						ISNULL(PC.EsnotaCredito,0) AS EsnotaCredito,
						OP.IdEstatusOperacion
                 FROM dbo.FI_PedimentoComprobante PC WITH(NOLOCK)
                      LEFT JOIN dbo.FI_PedimentoComprobanteDetalle PCD WITH(NOLOCK) ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
					  LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
						ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
					  LEFT JOIN dbo.TA_Operacion AS OP
							ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
							AND OP.IdTipoOperacion = 19
							AND OP.IdProveedor = APC.IdProveedor
                 WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante;
             END;
         IF(@Accion = 0)
             BEGIN
                 SELECT PC.IdSubcontratistaExportador, 
                        PC.IdFiscalP, 
                        PC.RazonSocialP, 
                        PC.NumeroPedimento, 
                        PC.ClavePedimento, 
                        PC.FechaPago, 
                        PC.Regimen, 
                        PC.AduanaES, 
                        PCD.DescripcionMercancia, 
                        PC.IdMoneda, 
                        PCD.PrecioUnitario, 
                        PCD.ImporteTotal, 
                        PC.AcuseElectronico,                        
                        PC.FolioComprobante,
						ISNULL(PC.CuentaBancaria,'') CuentaBancaria,
						OP.IdEstatusOperacion
                 FROM dbo.FI_PedimentoComprobante PC
                      INNER JOIN dbo.FI_PedimentoComprobanteDetalle PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
					  LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
						ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
					  LEFT JOIN dbo.TA_Operacion AS OP
							ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
							AND OP.IdTipoOperacion = 19
							AND OP.IdProveedor = APC.IdProveedor
                 WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante;
             END;
END
