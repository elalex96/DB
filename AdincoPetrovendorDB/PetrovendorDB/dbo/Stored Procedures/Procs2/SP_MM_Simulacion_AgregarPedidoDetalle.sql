-- =============================================
-- Author:Daniel AC
-- Create date: 25/10/2019
-- Description:	Simula el pedido detalle 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Simulacion_AgregarPedidoDetalle]
    -- Add the parameters for the stored procedure here
    @IdSolicitudPedido INT,
    @IdUsuarioCompras INT,
    @IdProveedorCompras INT,
    @IdContrato INT, 
	@IdPeticionOferta INT,
	@IdMoneda INT,
	@IdProveedorVenta INT 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	

    SELECT         
           ISNULL(prov.RazonSocial, '') + ' ' + ISNULL(prov.RegimenCapital, '') AS Proveedor,           
           tm.TipoMonedaCorto AS TipoMoneda,           
           PO.IdSubcontratista AS IdProveedorVenta,
           POD.IdMoneda, 
           POD.IdPeticionOferta,
           POD.IdPeticionOfertaDetalle,
           POD.AddCantidadTemp AS Cantidad,
           POD.MaterialCotizadoTextoC,
           CASE
               WHEN ISNULL(POD.IdCondicionPagoTemp,0)=0 THEN
                   2 --> SI LA CONDICION DE PAGO ES 0 ENTONCES  POR DEFAULT ASIGNAR COMO DE CONTADO
               ELSE
                   POD.IdCondicionPagoTemp
           END AS IdCondicionPago,
           CASE
               WHEN ISNULL(POD.IdCondicionPagoTemp,0)=0 THEN
                   0
               ELSE
                   POD.DiasCreditoTemp
           END AS DiasCredito,
           (POD.PrecioUnitario*POD.AddCantidadTemp) AS Subtotal,
		   POD.PrecioUnitario,
		    CASE
               WHEN ISNULL(CP.IdCondicionPago, 0) = 0 THEN
                  'No definido'
               WHEN  ISNULL(CP.IdCondicionPago, 0) = 1 THEN 
			     CONCAT(cp.CondicionPago,' ', POD.DiasCredito, ' día(s)')
			   WHEN ISNULL(CP.IdCondicionPago, 0) = 2 THEN 
                  CP.CondicionPago
           END AS CondicionPagoCotizacion,
		   0 AS IdPedidoSimul,
		   PO.IdSolicitudPedido
    FROM dbo.MM_PeticionOfertaDetalle POD 
		INNER JOIN dbo.MM_PeticionOferta PO ON PO.IdPeticionOferta=POD.IdPeticionOferta
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = PO.IdSubcontratista
        INNER JOIN dbo.PV_TipoMoneda tm
            ON tm.IdMoneda = POD.IdMoneda
        LEFT JOIN dbo.PV_ContratistaSubContratista contratista
            ON contratista.IdContratista = prov.IdProveedor
               AND contratista.IsActivo = 1
               AND contratista.IdSubContratista = @IdProveedorCompras
        LEFT JOIN PV_CondicionesPago condici
            ON condici.IdContratistaSubContratista = contratista.IdRelacion        
        LEFT JOIN dbo.MM_CondicionPago CP
            ON CP.IdCondicionPago = POD.IdCondicionPago
	WHERE PO.IdPeticionOferta=@IdPeticionOferta
	AND POD.IdMoneda=@IdMoneda
	AND PO.IdSubcontratista=@IdProveedorVenta
	AND PO.IdSolicitudPedido=@IdSolicitudPedido
	AND POD.AddPedidoTemp=1 ---> QUE ESTE EN EL CARRITO
    GROUP BY prov.RazonSocial,
             prov.RegimenCapital,       
             tm.TipoMonedaCorto,
             condici.DiasCredito,            
             POD.MaterialCotizadoTextoC,
             CP.CondicionPago,
             POD.DiasCredito,
             CP.IdCondicionPago,          
			 POD.PrecioUnitario,
			 POD.AddCantidadTemp,
			 PO.IdSubcontratista,
			 POD.IdMoneda, 
			 POD.IdPeticionOferta,
			 POD.IdPeticionOfertaDetalle,
			 POD.AddCantidadTemp,
			 POD.MaterialCotizadoTextoC,
			 PO.IdSolicitudPedido,
			 POD.IdCondicionPagoTemp,
			 POD.IdCondicionPago,
			 POD.DiasCreditoTemp
END;

