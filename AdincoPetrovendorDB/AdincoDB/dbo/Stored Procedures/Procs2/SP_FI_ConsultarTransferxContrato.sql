-- =============================================
-- Author:		Josue  
-- Create date: 26-12-2016
-- Description:	Consulta las transferencias del contrato para relacionarlas a facturas
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultarTransferxContrato]-- 10005
-- Add the parameters for the stored procedure here
@IdContrato INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

         DECLARE @contratista INT;
         
	    SELECT @contratista = idcontratista
         FROM co_contrato
         WHERE idcontrato = @idcontrato;
         
	    SELECT A.[IdTransferencia],
                A.[IdComprobantePago],
                A.[ReferenciaBancaria],
                A.[FechaPago],
               O.NumeroCuenta AS Cuenta_Origen,
                D.NumeroCuenta AS Cuenta_Destino,
                A.[MontoPagado],
                B.[TipoMoneda],
                A.[Concepto],
                C.[MetodoPago],
                A.[NumeroPolizaContable],
                A.[Intereses],
			 A.idContrato
         FROM [Adinco].[dbo].[FI_Transfer] A
              INNER JOIN [dbo].[PV_TipoMoneda] B ON A.IdMoneda = B.IdMoneda
              INNER JOIN PV_MetodoPago C ON A.[IdMetodoPago] = C.[IdMetodoPago]
              INNER JOIN PV_CuentaBancaria O ON A.[IdCuentaOrigen] = O.[DatoBancarioID]
              INNER JOIN PV_CuentaBancaria D ON A.[IdCuentaDestino] = D.[DatoBancarioID]
		left join fi_transferFactura		TF on TF.idtransfer  = A.idtransferencia
              JOIN pv_cuentabancaria CO ON CO.[DatoBancarioID] = A.IdCuentaOrigen
         WHERE 
	    A.IdContrato = @IdContrato
	    -- CO.idcontratista = @contratista
         ORDER BY NumeroPolizaContable;
     END;