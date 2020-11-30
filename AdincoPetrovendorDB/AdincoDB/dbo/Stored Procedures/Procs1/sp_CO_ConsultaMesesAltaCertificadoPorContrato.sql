-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	Consulta lista de meses alta produccion por contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaMesesAltaCertificadoPorContrato] 
--[sp_CO_ConsultaMesesAltaCertificadoPorContrato] 10007
-- Add the parameters for the stored procedure here
@IdContrato INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @FechaEfectiva AS DATE;
         SET LANGUAGE spanish;
         --
         SELECT @FechaEfectiva = InicioVigencia
         FROM CO_Contrato
         WHERE IdContrato = @IdContrato;
         --
         IF(@IdContrato = 10007)
             BEGIN
                 SELECT CAST(C.IdFecha AS DATE) AS IdFecha, 
                        CONCAT(RIGHT('00'+CAST(MONTH(IdFecha) AS VARCHAR(2)), 2), ' ', datename(month, IdFecha), ' ', YEAR(IdFecha)) AS Fecha
                 FROM AP_Calendario C
                      LEFT JOIN CO_GEAceptadosMes GEA ON C.IdFecha = GEA.Mes
                                                         AND GEA.IdContrato = @IdContrato
                 WHERE C.Dia = 1
                       AND C.IdFecha BETWEEN @FechaEfectiva AND '2019-12-01'
                       AND GEA.Mes IS NULL
                 ORDER BY IdFecha DESC;
             END;
             ELSE
             BEGIN
                 SELECT CAST(C.IdFecha AS DATE) AS IdFecha, 
                        CONCAT(RIGHT('00'+CAST(MONTH(IdFecha) AS VARCHAR(2)), 2), ' ', datename(month, IdFecha), ' ', YEAR(IdFecha)) AS Fecha
                 FROM AP_Calendario C
                      LEFT JOIN CO_GEAceptadosMes GEA ON C.IdFecha = GEA.Mes
                                                         AND GEA.IdContrato = @IdContrato
                 WHERE C.Dia = 1
                       AND C.IdFecha BETWEEN @FechaEfectiva AND CURRENT_TIMESTAMP
                       AND GEA.Mes IS NULL
                 ORDER BY IdFecha DESC
             END;
                 -- Insert statements for procedure here

     END;