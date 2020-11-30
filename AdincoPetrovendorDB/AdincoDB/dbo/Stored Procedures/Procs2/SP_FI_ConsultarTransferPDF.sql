-- =============================================
-- Author:		Josue  
-- Create date: 26-12-2016
-- Description:	Consulta las transferencias del contrato para anexar PDF Factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultarTransferPDF] 
-- Add the parameters for the stored procedure here
@IdContrato INT,
@FechaInicio datetime,
@FechaFin datetime
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

       SELECT A.[IdTransferencia]
      ,A.[IdContrato]
      ,A.[IdComprobantePago]
      ,A.NumeroPolizaContable  as [NombreExtencionArchivo]
      ,A.[ReferenciaBancaria]
      ,A.[FechaPago]
      ,O.NumeroCuenta as Cuenta_Origen
      ,D.NumeroCuenta as Cuenta_Destino
      ,A.[MontoPagado]
      ,B.[TipoMoneda]
      ,A.[Concepto]
      ,C.[MetodoPago] as MetodoPago
      ,A.[ProcesadoSIPAC]
      ,A.[NumeroPolizaContable]
      ,A.[Intereses]
  FROM [Adinco].[dbo].[FI_Transfer] A
		inner join [dbo].[PV_TipoMoneda] B on A.IdMoneda = B.IdMoneda
		inner join  PV_MetodoPago C on  A.[IdMetodoPago] = C.[IdMetodoPago] 
		inner join PV_CuentaBancaria O on A.[IdCuentaOrigen] = O.[DatoBancarioID]
		inner join PV_CuentaBancaria D on A.[IdCuentaDestino] = D.[DatoBancarioID]
  where 
		A.IdContrato = @IdContrato
		and A.FechaPago between @FechaInicio and @FechaFin
   END

