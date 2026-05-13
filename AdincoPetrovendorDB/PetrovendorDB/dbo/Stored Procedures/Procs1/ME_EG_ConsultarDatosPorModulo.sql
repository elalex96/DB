-- =============================================
-- Author:		<Jose Roman>
-- Create date: <19/01/2018>
-- Description:	<Consultar datos por modulo>
-- =============================================

CREATE procedure ME_EG_ConsultarDatosPorModulo
	@IdModulo INT,
	@IdProveedor INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	DECLARE @NombreModulo VARCHAR(200), 
			@CantidadConceptos INT,
			@CantidadConceptosCompletados INT,
			@PuntosObtenidos FLOAT,
			@PuntosTotales FLOAT
            
	SET @NombreModulo = (SELECT Modulo FROM dbo.ME_EG_Modulos WHERE IdModulo = @IdModulo)
	SET @CantidadConceptos = (SELECT COUNT(IdConcepto) FROM dbo.ME_EG_Conceptos WHERE IdModulo = @IdModulo)
	SET @CantidadConceptosCompletados = (SELECT COUNT(c.IdConcepto) 
											FROM dbo.ME_EG_Conceptos c
											INNER JOIN dbo.ME_EG_ConceptosCompletados cc ON cc.IdConcepto = c.IdConcepto
											WHERE c.IdModulo = @IdModulo
												AND cc.Completado > 0 
												AND cc.IdProveedor = @IdProveedor)
	SET @PuntosObtenidos = (SELECT SUM(cc.Completado) 
											FROM dbo.ME_EG_Conceptos c
											INNER JOIN dbo.ME_EG_ConceptosCompletados cc ON cc.IdConcepto = c.IdConcepto
											WHERE c.IdModulo = @IdModulo
												AND cc.Completado > 0 
												AND cc.IdProveedor = @IdProveedor)
	SET @PuntosTotales = (SELECT SUM(IdConcepto) 
											FROM dbo.ME_EG_Conceptos 
											WHERE IdModulo = @IdModulo)

	SELECT @NombreModulo, 
			@CantidadConceptos,
			@CantidadConceptosCompletados,
			@PuntosObtenidos,
			@PuntosTotales
			
END