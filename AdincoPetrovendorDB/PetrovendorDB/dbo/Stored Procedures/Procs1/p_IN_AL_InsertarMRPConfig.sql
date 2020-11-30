
CREATE PROC [dbo].[p_IN_AL_InsertarMRPConfig]
@pIdAlmacen	int,
@pIdMaterial	int,
@pIdLineaPresupuesto	int,
@pCantidadMinima	decimal(14,2),
@pCantidadMaxima	decimal(14,2),
@pCantidadSobreMinimo	decimal(14,2),
@pCreadoPor	int
AS


	INSERT INTO IN_AL_MRP(
		IdAlmacen,		IdMaterial,			IdLineaPresupuesto,		CantidadMinima,
		CantidadMaxima,	CantidadSobreMinimo,CreadoPor,				CreadoEl,
		ModificadoPor,	ModificadoEl)
	VALUES(
		@pIdAlmacen,		@pIdMaterial,			@pIdLineaPresupuesto,		@pCantidadMinima,
		@pCantidadMaxima,	@pCantidadSobreMinimo,	@pCreadoPor,				GETDATE(),
		null,				null
	)
