
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <31-07-2018>
-- Description:	<Se actualizan el detalle de los conceptos>
-- =============================================

CREATE PROCEDURE AD_EI_UpdateConceptosDetalle	
	@IdConceptoDetalle INT,
	@Detalle NVARCHAR(1500),
	@SoloMoral BIT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	UPDATE dbo.EI_ConceptosDetalle
		SET Detalle = @Detalle,
			SoloMoral = @SoloMoral
		WHERE IdConceptoDetalle = @IdConceptoDetalle
END