-- =============================================
-- Author:		Manuel Cruz
-- Create date: 08-05-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_ConsultaTransferencias]
-- 10003,  '2016-01-01', '2016-12-12'
-- Add the parameters for the stored procedure here
@IdContrato INT,
@PInicial   NVARCHAR(50),
@PFinal     NVARCHAR(50)
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @CONTRATISTA INT;
         SELECT @CONTRATISTA = Ca.IdContratista
         FROM CO_Contrato Co
              JOIN CO_Contratista Ca ON Co.IdContratista = Ca.IdContratista
         WHERE Co.IdContrato = @IdContrato;
         -- Insert statements for procedure here

         IF @CONTRATISTA = 10000
             SELECT CAST(F.IdTransferencia AS NVARCHAR(50)) AS IdTransferencia,
                    IDComprobantePago,
                    ReferenciaBancaria,
                    FechaPago,
                    MontoPagado,
                    Concepto,
                    ProcesadoSIPAC
             FROM FI_transfer F
                  JOIN CO_Contrato C ON C.IdContrato = F.IdContrato
                  JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
             WHERE C.IdContratista = @CONTRATISTA
                   AND F.FechaPago BETWEEN @PInicial AND @PFinal
                   AND isnull(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0;
             ELSE
         SELECT CAST(F.IdTransferencia AS NVARCHAR(50)) AS IdTransferencia,
                IDComprobantePago,
                ReferenciaBancaria,
                FechaPago,
                MontoPagado,
                Concepto,
                ProcesadoSIPAC
         FROM FI_transfer F
         WHERE F.IdContrato = @IdContrato
               AND F.FechaPago BETWEEN @PInicial AND @PFinal
               AND isnull(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0;

         --EXEC sp_FI_ConsultaTransferencias 10003,'20170101','20170531'
     END;