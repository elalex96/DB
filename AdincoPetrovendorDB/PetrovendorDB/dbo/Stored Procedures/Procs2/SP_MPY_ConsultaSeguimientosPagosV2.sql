-- =============================================
-- Author:		<Jose Roman>
-- Create date: <07-06-2018>
-- Description:	<Modificacion de sp para consultar >
-- =============================================

CREATE procedure [dbo].[SP_MPY_ConsultaSeguimientosPagosV2] --420, 0
	@IdProveedor INT,
	@Pagado BIT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN

DECLARE @RFCProveedor NVARCHAR(300) = (SELECT TOP 1 RFC FROM S_Proveedor where idProveedor = @IdProveedor)

SELECT aFact.IdFactura,
           pFact.IdFactura IdFacturaPet,
		   --p.IdSolicitudPedido, 
           prov.RazonSocial AS Receptor,
           aFact.Fecha,
           aFact.Serie,
           aFact.Folio,
           aFact.MontoConIva AS Total,
           aFact.UUID,
           M.TipoMonedaCorto AS Moneda,
           Proceso = CASE
                         WHEN transf.PDF IS NULL THEN
                             'No pagado'
                         WHEN transf.PDF IS NOT NULL THEN
                             'Pagado'
                         WHEN aFact.IdFactura IS NULL THEN
                             'En proceso'
                     END,
           TieneArchivo = CAST(CASE
                                   WHEN transf.PDF IS NULL THEN
                                       0
                                   ELSE
                                       1
                               END AS BIT),
           acepFact.IdAceptacionPedido,
		   aFact.Receptor,
		  TieneComprobante = CAST(CASE		
				WHEN fcpr.IdFacturaCompPagoRelacion IS NOT NULL THEN 1
				ELSE 0
			END AS BIT)
    FROM Adinco.dbo.FI_Factura aFact
        LEFT JOIN Petrovendor.dbo.FI_Factura pFact	ON pFact.UUID = aFact.UUID COLLATE Modern_Spanish_CI_AS
        LEFT JOIN dbo.MPY_MM_AceptacionFactura acepFact ON acepFact.IdFactura = pFact.IdFactura
		INNER JOIN dbo.MPY_MM_AceptacionPedido acepPed ON acepPed.IdAceptacionPedido = acepFact.IdAceptacionPedido
	
        INNER JOIN Petrovendor.dbo.S_Proveedor prov ON prov.RFC = aFact.Receptor COLLATE Modern_Spanish_CI_AS
        LEFT JOIN Adinco.dbo.PV_TipoMoneda M ON M.IdMoneda = aFact.IdMoneda
        LEFT JOIN Adinco.dbo.FI_TransferFactura transFac ON transFac.IdFactura = aFact.IdFactura
        LEFT JOIN Adinco.dbo.FI_Transfer transf ON transf.IdTransferencia = transFac.IdTransfer
		LEFT JOIN Petrovendor.dbo.FI_FacturaCompPagoRelacion fcpr ON fcpr.IdFactura = pFact.IdFactura 
    WHERE acepFact.IdEstatus = 2 --aprobadas
          AND aFact.Activa = 1
          AND pFact.Activa = 1
			AND acepPed.IdSubcontratista = @RFCProveedor
		  AND (transf.PDF IS NOT NULL or @Pagado = 0)
		 AND (fcpr.IdFacturaCompPagoRelacion IS NULL OR @Pagado = 0)
END
