-- =============================================
-- Author:		Manuel CD
-- Create date: 2018-08-28
-- Description:	Consulta lista de meses alta marcador menusal por contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaMesesAltaPrecioMarcadorPorContrato] 
--[sp_CO_ConsultaMesesAltaPrecioMarcadorPorContrato] 10007,1
-- Add the parameters for the stored procedure here
@IdContrato INT = 0, 
@IdUsuario  INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @FechaEfectiva AS DATE;
         SET LANGUAGE spanish;
         --
         SELECT @FechaEfectiva = InicioVigencia
         FROM dbo.CO_Contrato
         WHERE IdContrato = @IdContrato;
         --
         IF(@IdContrato = 10007)
             BEGIN
                 SELECT DISTINCT 
                        PM.IdContrato, 
                        CAST(C.IdFecha AS DATE) AS IdFecha, 
                        CONCAT(RIGHT('00'+CAST(MONTH(IdFecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, IdFecha), ' ', YEAR(IdFecha)) AS Fecha
                 FROM dbo.AP_Calendario C
                      LEFT JOIN dbo.CO_PrecioMarcadorMensual PM ON C.IdFecha = PM.Mes
                                                                   AND PM.IdContrato = @IdContrato
                 WHERE C.Dia = 1
                       AND C.IdFecha BETWEEN @FechaEfectiva AND '2019-12-01' --AND PM.Mes  IS NULL --and PM.IdContrato = @IdContrato
                 ORDER BY IdFecha DESC;
             END;
             ELSE
             BEGIN
                 SELECT DISTINCT 
                        PM.IdContrato, 
                        CAST(C.IdFecha AS DATE) AS IdFecha, 
                        CONCAT(RIGHT('00'+CAST(MONTH(IdFecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, IdFecha), ' ', YEAR(IdFecha)) AS Fecha
                 FROM dbo.AP_Calendario C
                      LEFT JOIN dbo.CO_PrecioMarcadorMensual PM ON C.IdFecha = PM.Mes
                                                                   AND PM.IdContrato = @IdContrato
                 WHERE C.Dia = 1
                       AND C.IdFecha BETWEEN @FechaEfectiva AND CURRENT_TIMESTAMP --AND PM.Mes  IS NULL --and PM.IdContrato = @IdContrato
                 ORDER BY IdFecha DESC;
             END;
     END;