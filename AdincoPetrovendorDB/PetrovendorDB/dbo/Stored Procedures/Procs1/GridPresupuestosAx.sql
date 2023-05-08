CREATE PROCEDURE GridPresupuestosAx @IdContrato INT
AS
BEGIN
    -- se pone un top 3 ya que solo los tres primeros presupuestos P001, P002, P003
-- son los que se tomaran en cuenta en esta consulta
SELECT TOP 3 p.IdPresupuesto, p.Nombre, ax.AnioReal AS Anio, ax.AnioLinea AS AxPresupuesto
FROM dbo.AX_AnioContractual ax 
            LEFT JOIN Adinco.dbo.CO_AnioContractual AC
                ON ax.AnioReal = AC.Anio
                   AND AC.IdContrato = @IdContrato
			LEFT JOIN Adinco.dbo.CO_Presupuesto p ON p.IdAnioContractual = AC.IdAnioContractual
WHERE ax.IdPresupuesto IS NULL AND ax.AnioReal <=2020 -- el año es 2020 ya que es apartir de aqui que se pueden cargar mas de un presupuesto para Carso
UNION	
	SELECT p.IdPresupuesto,
           p.Nombre,
           anio.Anio,
           ax.AnioLinea AS AxPresupuesto
    FROM Adinco.dbo.CO_Presupuesto p
        INNER JOIN Adinco.dbo.CO_AnioContractual anio
            ON anio.IdAnioContractual = p.IdAnioContractual
        LEFT JOIN Petrovendor.dbo.AX_AnioContractual ax
            ON ax.IdPresupuesto = p.IdPresupuesto
    WHERE anio.IdContrato = @IdContrato
          AND p.Activo = 1
          AND ax.IdPresupuesto IS NOT NULL	
END