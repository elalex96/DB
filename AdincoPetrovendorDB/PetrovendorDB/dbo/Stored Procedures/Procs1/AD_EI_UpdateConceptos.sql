
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <31-07-2018>
-- Description:	<Se actualizan los conceptos>
-- =============================================

CREATE PROCEDURE AD_EI_UpdateConceptos	
	@IdConcepto INT,
	@Concepto NVARCHAR(100),
	@IdConceptoURL INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	UPDATE dbo.EI_Conceptos
		SET Concepto = @Concepto,
			IdConceptoURL = @IdConceptoURL
		WHERE IdConcepto = @IdConcepto
END