
CREATE PROC [dbo].[p_IN_AL_ActualizarMRPConfig]
@pIdAlmacen	int,
@pIdMaterial	int,
@pIdLineaPresupuesto	int,
@pCantidadMinima	decimal(14,2),
@pCantidadMaxima	decimal(14,2),
@pCantidadSobreMinimo	decimal(14,2),
@pCreadoPor	int
AS

	UPDATE IN_AL_MRP
	SET CantidadMinima = @pCantidadMinima,
	CantidadMaxima = @pCantidadMaxima,
	CantidadSobreMinimo = @pCantidadSobreMinimo,
	ModificadoPor = @pCreadoPor,
	ModificadoEl = GETDATE()
	WHERE IdAlmacen = @pIdAlmacen AND
    IdMaterial = @pIdMaterial
		


	
