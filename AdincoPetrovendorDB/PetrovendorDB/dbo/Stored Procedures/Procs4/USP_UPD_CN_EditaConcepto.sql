Use Petrovendor
GO
DROP PROC IF EXISTS USP_UPD_CN_EditaConcepto
GO
CREATE PROC USP_UPD_CN_EditaConcepto
@IdCDCN INT,
@IdActividadBS INT,
@DescripcionBienesServicios VARCHAR(1000),
@ValorFactura FLOAT,
@PCN FLOAT,
@ClasificacionSH INT,
@IdUsuario INT = NULL,
@IdContrato INT = NULL
AS
BEGIN
	UPDATE CN_CompraDirecta
	SET IdActividadBS = @IdActividadBS,
	DescripcionBienesServicios = @DescripcionBienesServicios,
	ValorFactura = @ValorFactura,
	PCN = @PCN,
	ClasificacionSH = @ClasificacionSH,
	ModificadoPor = @IdUsuario,
	ModificadoEl = GETDATE()
	WHERE IdCDCN = @IdCDCN
END
