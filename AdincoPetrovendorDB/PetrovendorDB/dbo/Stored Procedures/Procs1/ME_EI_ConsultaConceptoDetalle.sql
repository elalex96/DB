-- =============================================
-- Author:		<Jose Roman>
-- Create date: <30-07-2018>
-- Description:	<Se crea consulta para ver los conceptos detalle ya acompletados>
-- =============================================

CREATE PROCEDURE ME_EI_ConsultaConceptoDetalle	
	@IdProveedor INT,
	@IdConcepto INT,
	@TipoRegimen INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	DECLARE @SoloMoral BIT
    
	IF(@TipoRegimen = 2)
	BEGIN
		SET @SoloMoral = 0
	END
    ELSE
    BEGIN
		SET @SoloMoral = 1
	END

	SELECT cc.IdConceptoCompletado, 
		cd.Detalle,  
		CASE WHEN cc.Completado > 0 THEN 1 ELSE 0 END AS Completado 
	FROM dbo.EI_ConceptosDetalle cd
	INNER JOIN dbo.EI_ConceptosCompletados cc ON cc.IdConceptoDetalle = cd.IdConceptoDetalle 
	WHERE cd.IdConcepto = @IdConcepto
		AND cc.IdProveedor = @IdProveedor
		AND (cd.SoloMoral = @SoloMoral OR @SoloMoral = 1)
		
END