CREATE PROCEDURE CmbPresupuestoAx @IdContrato INT
AS
BEGIN
    SELECT p.IdPresupuesto,
           p.Nombre AS Presupuesto
    FROM Adinco.dbo.CO_Presupuesto p
        INNER JOIN Adinco.dbo.CO_AnioContractual anio
            ON anio.IdAnioContractual = p.IdAnioContractual
    WHERE anio.IdContrato = @IdContrato
          AND p.Activo = 1
END








