IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_CO_ConsultaMesesAltaProduccionPorContrato'
)
    DROP PROCEDURE sp_CO_ConsultaMesesAltaProduccionPorContrato
GO
CREATE PROCEDURE [dbo].[sp_CO_ConsultaMesesAltaProduccionPorContrato]     
--[sp_CO_ConsultaMesesAltaProduccionPorContrato] 10007,1    
-- Add the parameters for the stored procedure here    
@IdContrato INT = 0,     
@IdUsuario  INT = 0    
AS    
BEGIN    
  
    SET NOCOUNT ON    
    DECLARE @FechaEfectiva AS DATE    
    SET LANGUAGE spanish    
    --    
    SELECT @FechaEfectiva = InicioVigencia    
    FROM dbo.CO_Contrato    
    WHERE IdContrato = @IdContrato    

            SELECT PM.IdContrato,     
                CAST(C.IdFecha AS DATE) AS IdFecha,     
                CONCAT(RIGHT('00'+CAST(MONTH(IdFecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, IdFecha), ' ', YEAR(IdFecha)) AS Fecha    
            FROM dbo.AP_Calendario C    
                LEFT JOIN dbo.CO_ProduccionCrudoMensualCIEP PM ON C.IdFecha = PM.Mes    
                                                                AND PM.IdContrato = @IdContrato    
            WHERE C.Dia = 1    
                AND C.IdFecha BETWEEN @FechaEfectiva AND CURRENT_TIMESTAMP --AND PM.Mes  IS NULL --and PM.IdContrato = @IdContrato    
                AND PM.Mes IS NULL-- Insert statements for procedure here    
            ORDER BY IdFecha DESC    
END 
