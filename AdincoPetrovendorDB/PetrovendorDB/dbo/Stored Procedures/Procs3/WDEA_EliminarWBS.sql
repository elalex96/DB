CREATE PROC WDEA_EliminarWBS
@Id Int,
@IdUsuario int,
@IdContrato int,
@Desactivar varchar(300)
AS
BEGIN
IF @Desactivar = 'WBS'
BEGIN
	Update WDEA_WBS
	set Activo = 0,
	ModificadoPor = @IdUsuario,
	ModificadoEl = GETDATE()
	where Id = @Id

	UPDATE WDEA_WBSLineaPresupuesto
	SET Activo = 0,
	ModificadoPor = @IdUsuario,
	ModificadoEl = GETDATE()
	WHERE IdWBS = @Id
END
IF @Desactivar = 'WBSLINEAPRESUPUESTO'
BEGIN
	UPDATE WDEA_WBSLineaPresupuesto
	SET Activo = 0,
	ModificadoPor = @IdUsuario,
	ModificadoEl = GETDATE()
	WHERE Id = @Id
END
END