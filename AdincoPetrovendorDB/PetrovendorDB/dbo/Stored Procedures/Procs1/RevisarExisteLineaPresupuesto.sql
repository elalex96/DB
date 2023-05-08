-- =============================================
-- Author:		Pedro Acu�a
-- Create date: 21-01-2020
-- Description:	Revisar si existe la linea seleccionada en caso de que no exista no permitir el guardado
-- =============================================

CREATE PROCEDURE RevisarExisteLineaPresupuesto @IdContrato         INT, 
                                               @IdPeriodo          INT, 
                                               @IdPresupuesto      INT, 
                                               @IdLineaPresupuesto INT
AS
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM Adinco.dbo.CO_LineaPresupuestoMes linea
                 INNER JOIN Adinco.dbo.CO_Presupuesto pres ON pres.IdPresupuesto = linea.IdPresupuesto
                 INNER JOIN Adinco.dbo.CO_AnioContractual anio ON anio.IdAnioContractual = pres.IdAnioContractual
                                                                  AND anio.IdContrato = @IdContrato
                 INNER JOIN Adinco.dbo.CO_Contrato con ON con.IdContrato = anio.IdContrato
                 INNER JOIN Adinco.dbo.CO_PeriodoContrato c ON c.IdContrato = con.IdContrato
            WHERE anio.IdContrato = @IdContrato
                  AND c.IdPeriodo = @IdPeriodo
                  AND linea.IdPresupuesto = @IdPresupuesto
                  AND linea.IdLineaPresupuestoMes = @IdLineaPresupuesto
        )
            BEGIN
                SELECT 1;
        END;
            ELSE
            BEGIN
                SELECT 0; --no existe esa linea entonces no permitir el guardado
        END;
    END;