-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-11-20
-- Description:	
-- =============================================
CREATE PROCEDURE SP_CP_GuardarDiferenciaEconomica
-- Add the parameters for the stored procedure here
@IdContrato  INT, 
@IdUsuario   INT, 
@Mes         DATE, 
@Base        FLOAT, 
@Adicional   FLOAT, 
@Contractual FLOAT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

         IF EXISTS
         (
             SELECT *
             FROM dbo.CP_DiferenciaEconomica
             WHERE IdContrato = @IdContrato
                   AND Mes = @Mes
         )
             BEGIN
                 UPDATE dbo.CP_DiferenciaEconomica
                   SET 
                       RegaliaBase = @Base, 
                       RegaliaAdicional = @Adicional, 
                       CuotaContractual = @Contractual,
					   ModificadoPor = @IdUsuario,
					   ModificadoEn = GETDATE()
                 WHERE IdContrato = @IdContrato
                       AND Mes = @Mes;
             END;
             ELSE
             BEGIN
                 INSERT INTO dbo.CP_DiferenciaEconomica
                 (IdContrato, 
                  Mes, 
                  RegaliaBase, 
                  RegaliaAdicional, 
                  CuotaContractual, 
                  CreadoPor, 
                  CreaadoEn
                 )
                 VALUES
                 (@IdContrato, 
                  @Mes, 
                  @Base, 
                  @Adicional, 
                  @Contractual, 
                  @IdUsuario, 
                  GETDATE()
                 );
             END;
     END;
