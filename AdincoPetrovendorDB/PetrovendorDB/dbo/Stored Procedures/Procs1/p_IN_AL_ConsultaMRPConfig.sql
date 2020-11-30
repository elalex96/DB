-- p_IN_AL_ConsultaMRPConfig 1,14818
CREATE PROC [dbo].[p_IN_AL_ConsultaMRPConfig]
@pIdAlmacen INT,
@pIdLineaPresupuestoMes INT
AS

	SELECT 
		ROW_NUMBER() OVER(ORDER BY IdMaterial ASC) AS ID,
			MRP.IdAlmacen,
			MRP.IdMaterial,
			MRP.IdLineaPresupuesto,
			MRP.CantidadMinima,
			MRP.CantidadMaxima,
			MRP.CantidadSobreMinimo,
			MRP.CreadoPor,
			MRP.CreadoEl,
			MRP.ModificadoPor,
			MRP.ModificadoEl 
	FROM dbo.IN_AL_MRP MRP
	WHERE MRP.IdAlmacen = @pIdAlmacen AND
    @pIdLineaPresupuestoMes IN (0,mrp.IdLineaPresupuesto)
