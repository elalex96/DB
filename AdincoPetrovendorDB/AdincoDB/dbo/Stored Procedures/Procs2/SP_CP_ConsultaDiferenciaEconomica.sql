-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-11-20
-- Description:	
-- =============================================
CREATE PROCEDURE SP_CP_ConsultaDiferenciaEconomica
--SP_CP_ConsultaDiferenciaEconomica 3,1,'2018-09-01'
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT, 
@Mes        DATE = NULL
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         --IF @Mes IS NULL
         --    BEGIN
         --        SELECT IdDiferenciaEconomica, 
         --               Mes, 
         --               ISNULL(RegaliaBase, 0) AS RegaliaBase, 
         --               ISNULL(RegaliaAdicional, 0) AS RegaliaAdicional, 
         --               ISNULL(CuotaContractual, 0) AS CuotaContractual, 
         --               UC.Nombre AS CreadoPor, 
         --               CreaadoEn, 
         --               UM.Nombre AS ModificadoPor, 
         --               ModificadoEn
         --        FROM dbo.CP_DiferenciaEconomica DE
         --             JOIN dbo.AP_Usuario UC ON UC.UsuarioID = DE.CreadoPor
         --             LEFT JOIN dbo.AP_Usuario UM ON UM.UsuarioID = DE.ModificadoPor
         --        WHERE IdContrato = @IdContrato;
         --    END;
         --    ELSE
             BEGIN
                 SELECT IdDiferenciaEconomica, 
                        Mes, 
                        ISNULL(RegaliaBase, 0) AS RegaliaBase, 
                        ISNULL(RegaliaAdicional, 0) AS RegaliaAdicional, 
                        ISNULL(CuotaContractual, 0) AS CuotaContractual, 
                        UC.Nombre AS CreadoPor, 
                        CreaadoEn, 
                        UM.Nombre AS ModificadoPor, 
                        ModificadoEn
                 FROM dbo.CP_DiferenciaEconomica DE
                      JOIN dbo.AP_Usuario UC ON UC.UsuarioID = DE.CreadoPor
                      LEFT JOIN dbo.AP_Usuario UM ON UM.UsuarioID = DE.ModificadoPor
                 WHERE IdContrato = @IdContrato
                       AND DE.Mes = @Mes
             END;
     END;
