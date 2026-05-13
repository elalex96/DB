
-- =============================================
-- Author:		Jose Roman
-- Create date: 04-01-2019
-- Description: Se consulta la linea de presupuesto del gasto
-- =============================================
CREATE FUNCTION FN_ObtenerInstalacionGasto
(
	@IdFactura INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Instalacion NVARCHAR(50),
			@IdLineaPresupuesto INT


	SET @IdLineaPresupuesto = (SELECT TOP 1 IdPrograma FROM Adinco.dbo.CO_Registro WHERE IdFactura = @IdFactura)
	
	SET @Instalacion = (SELECT ISNULL(i.NombreInstalacion, 'Sin instalación')
						FROM Adinco.dbo.CO_LineaPresupuestoMes lpm
						LEFT JOIN Adinco.dbo.CO_Instalacion i ON i.IdInstalacion = lpm.IdInstalacion
						WHERE lpm.IdLineaPresupuestoMes = @IdLineaPresupuesto)

	-- Return the result of the function
	RETURN @Instalacion;

END

