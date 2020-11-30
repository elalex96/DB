-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19/04/2020>
-- Description:	<guardado de un nuevo concepto de contenido nacional de compra directa>
-- =============================================
CREATE PROCEDURE SP_OCD_EliminadoConceptoCN
	-- Add the parameters for the stored procedure here
	@IdCDCN INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.CN_CompraDirecta
		SET Activo = 0,
			ElimiadoPor = @IdUsuario,
			EliminadoEl = GETDATE()
		WHERE IdCDCN = @IdCDCN;

END
