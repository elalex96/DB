-- =============================================
-- Author:		Alexander Gomez
-- Create date: 18-12-2018
-- Description:	Consultar Pedidos de proveedores extranjeros por filtro
-- =============================================

-- =============================================
-- Author:		LUIS DAVID
-- Create date: 15-07-2019
-- Description:	Se agrega la validación para mostrar unicamente las PO activas (no canceladas)
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidosExtranjerosCliente] 
	@IdProveedor int,
	@Filtro nvarchar(max),
	@IdContrato INT = NULL,
	@IdEstatus int = 0
	
AS
BEGIN

	SET NOCOUNT ON;

		IF  @Filtro ='TODOS'
		BEGIN 
			SELECT DISTINCT
				PO.SAPPONumber,
				CAST(PO.CreadoEl AS DATE) AS CreadoEl, 
				V.VendorName AS Proveedor,
				V.TaxID AS RFC,
				PO.Currency AS TipoMoneda,
				PO.SAPVendorNumber
			FROM Adinco.dbo.CO_SAPPO AS PO
			LEFT JOIN Adinco.dbo.CO_SAPVendor AS V ON V.VendorIDSAP = PO.SAPVendorNumber
		WHERE PO.IdContrato = @IdContrato
		AND V.Country <> 'MX'
		and (
			@IdEstatus = 0 OR
			(@IdEstatus = 1 and isnull(PO.POActivo,0) = 1) OR
			(@IdEstatus = 2 and isnull(PO.POActivo,0) = 0)

		)
		
		GROUP BY PO.SAPPONumber,
                 CAST(PO.CreadoEl AS DATE),
                 V.VendorName,
                 PO.Currency,
				 V.TaxID,
				 PO.SAPVendorNumber
	END 
END



