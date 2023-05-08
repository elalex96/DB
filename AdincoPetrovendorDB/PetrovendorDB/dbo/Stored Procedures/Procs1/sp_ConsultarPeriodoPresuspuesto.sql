CREATE PROCEDURE [dbo].[sp_ConsultarPeriodoPresuspuesto]
(
    @IdLineaPresupuesto INT,
    @idProveedorAdinco INT --CID
)
AS
BEGIN
    DECLARE @IdPeriodo INT,
            @IdPresupuesto INT,
            @Presupuesto NVARCHAR(MAX)

    SELECT @IdPeriodo = IdPeriodo
    FROM dbo.CO_PeriodoContrato
    WHERE IdProveedor = @idProveedorAdinco

    SELECT @IdPresupuesto = linea.IdPresupuesto,
           @Presupuesto = CONCAT(presupuesto.Nombre, '-', presupuesto.IdPresupuestoCNH)
    FROM CO_LineaPresupuestoMes linea
        INNER JOIN dbo.CO_Presupuesto presupuesto
            ON presupuesto.IdPresupuesto = linea.IdPresupuesto
    WHERE IdLineaPresupuestoMes = @IdLineaPresupuesto
    
	--Retorno
    SELECT @IdPeriodo AS IdPeriodo,
           @IdPresupuesto AS IdPresupuesto,
		   @Presupuesto AS Presupuesto
END