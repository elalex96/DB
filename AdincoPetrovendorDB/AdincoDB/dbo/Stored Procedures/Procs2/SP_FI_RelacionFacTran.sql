-- =============================================
-- Author:		Manuel Cruz
-- Create date: 02-08-17
-- Description:	
-- =============================================
CREATE PROCEDURE SP_FI_RelacionFacTran 
	-- Add the parameters for the stored procedure here
	
	@IdContrato INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT F.IdFactura,
                F.Serie + F.Folio AS Factura,
                F.Fecha,
                F.SubTotal,
                F.Moneda,
                F.MontoConIva,
                F.UUID,
                F.FechaTimbrado,
                T.IdTransferencia,
			 CBO.NumeroCuenta AS CuentaOrigen,
			 CBO.Titular,
			 CBD.NumeroCuenta AS CuentaDestino,
			 CBD.Titular,
                T.ReferenciaBancaria,
                T.FechaPago,
			 TM.TipoMonedaCorto,
                T.MontoPagado,
			 MP.MetodoPago,
                T.Concepto,
                T.NumeroPolizaContable
         FROM FI_Factura AS F
              JOIN FI_TransferFactura AS TF ON F.IdFactura = TF.IdFactura
              JOIN FI_Transfer AS T ON TF.IdTransfer = T.IdTransferencia
		    LEFT JOIN PV_CuentaBancaria AS CBO ON T.IdCuentaOrigen = CBO.DatoBancarioID
		    LEFT JOIN PV_CuentaBancaria AS CBD ON T.IdCuentaDestino = CBD.DatoBancarioID
		    JOIN PV_TipoMoneda AS TM ON T.IdMoneda = TM.IdMoneda
		    JOIN PV_MetodoPago AS MP ON T.IdMetodoPago = MP.idMetodoPago
		    WHERE F.IdContrato = @IdContrato
     END;
	--EXEC SP_FI_RelacionFacTran 10003
