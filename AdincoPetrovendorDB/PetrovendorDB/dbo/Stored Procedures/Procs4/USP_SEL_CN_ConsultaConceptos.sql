Use Petrovendor
GO
DROP PROC IF EXISTS USP_SEL_CN_ConsultaConceptos
GO
CREATE PROC USP_SEL_CN_ConsultaConceptos
@IdUsuario INT = NULL,
@IdContrato INT = NULL,
@IdPedimentoComprobante INT
AS
BEGIN
	SELECT IdCDCN,
			IdContrato,
			IdProveedor,
			IdFactura,
			IdPedido,
			DescripcionBienesServicios,
			ValorFactura,
			PCN,
			IdActividadBS,
			ClasificacionSH,
			Activo,
			ModificadoPor,
			ModificadoEl,
			ElimiadoPor,
			EliminadoEl,
			CreadoPor,
			CreadoEl,
			IdPedimentoComprobante
	FROM CN_CompraDirecta 
	WHERE IdPedimentoComprobante = @IdPedimentoComprobante
END