-- =============================================
-- Author:		Daniel Cruz
-- Create date: 08-05-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_EST_ConsultaDashTesoreria2]
-- Add the parameters for the stored procedure here
@IdContrato INT,
@PInicial   NVARCHAR(50),
@PFinal     NVARCHAR(50)
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
		 DECLARE @Facturas int 
		 DECLARE @Trasferencias int 
		 DECLARE @MontoFacturas_Sub float
		 DECLARE @MontoTranferencias float
		 DECLARE @MontoFacturasIVA float
		 DECLARE @MontoFacturas_Total float
		 DECLARE @MontoIntereses float
         -- Insert statements for procedure here
        set @Facturas =( SELECT COUNT(IdFactura)
               
         FROM FI_Factura F
              JOIN PV_Subcontratista SE ON F.IdSubcontratista = SE.IdSubcontratista
              JOIN CO_Contrato C ON C.IdContrato = @IdContrato
              JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
         WHERE F.IdContrato = @IdContrato
               AND F.Fecha BETWEEN @PInicial AND @PFinal
			   and isnull(F.ProcesadoSIPAC, 'false') = 'false'
			   and rtrim(ArchivoXML ) <>''

		)
 
		SET @MontoFacturas_Total = (SELECT  ROUND(SUM(MontoConIva),2)
               
				 FROM FI_Factura F
					  JOIN PV_Subcontratista SE ON F.IdSubcontratista = SE.IdSubcontratista
					  JOIN CO_Contrato C ON C.IdContrato = @IdContrato
					  JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
				 WHERE F.IdContrato = @IdContrato
					   AND F.Fecha BETWEEN @PInicial AND @PFinal
					   and isnull(F.ProcesadoSIPAC, 'false') = 'false'
					   and rtrim(ArchivoXML ) <>''
		)

		

		SET @MontoFacturas_Sub = (SELECT  ROUND(SUM(SubTotal),2)
               
				 FROM FI_Factura F
					  JOIN PV_Subcontratista SE ON F.IdSubcontratista = SE.IdSubcontratista
					  JOIN CO_Contrato C ON C.IdContrato = @IdContrato
					  JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
				 WHERE F.IdContrato = @IdContrato
					   AND F.Fecha BETWEEN @PInicial AND @PFinal
					   and isnull(F.ProcesadoSIPAC, 'false') = 'false'
					   and rtrim(ArchivoXML ) <>''
		)

		SET @MontoFacturasIVA = @MontoFacturas_Total- @MontoFacturas_Sub

		SET @Trasferencias = (

		  SELECT COUNT(F.IdTransferencia)
          FROM FI_transfer F
          WHERE F.IdContrato = @IdContrato
          AND F.FechaPago BETWEEN @PInicial AND @PFinal
		  and isnull    (  convert(int,   F.ProcesadoSIPAC), 0) = 0
		
		)

		SET @MontoTranferencias = (
		  SELECT SUM(F.MontoPagado)
          FROM FI_transfer F
          WHERE F.IdContrato = @IdContrato
          AND F.FechaPago BETWEEN @PInicial AND @PFinal
		  and isnull    (  convert(int,   F.ProcesadoSIPAC), 0) = 0
		)



		SET  @MontoIntereses = (
		  SELECT SUM(F.Intereses)
          FROM FI_transfer F
          WHERE F.IdContrato = @IdContrato
          AND F.FechaPago BETWEEN @PInicial AND @PFinal
		  and isnull    (  convert(int,   F.ProcesadoSIPAC), 0) = 0
		)
		SELECT ISNULL(@Trasferencias,0),ISNULL( @Facturas,0), ISNULL(@MontoTranferencias,0),ISNULL(@MontoFacturas_Total,0), ISNULL(@MontoFacturas_Sub,0), ISNULL(@MontoFacturasIVA,0), ISNULL(@MontoIntereses,0)






         --EXEC sp_FI_ConsultaFacturas 3,'2016-01-01','2016-10-01'
     END;