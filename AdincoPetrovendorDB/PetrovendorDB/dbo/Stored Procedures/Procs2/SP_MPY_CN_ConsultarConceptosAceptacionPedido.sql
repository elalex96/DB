-- =============================================
-- Author:		AlexandeR Gomez
-- Create date: 28/01/2019
-- Description:	Validacion de todos los materiales tengan clasificacion CNH
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_CN_ConsultarConceptosAceptacionPedido]
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @FALTANTES INT =  (SELECT COUNT(IdAceptacionPedido) FROM dbo.MPY_MM_AceptacionPedidoDetalle WHERE IdAceptacionPedido = @IdAceptacionPedido AND ClasificacionCN IS NULL)

	IF ISNULL(@FALTANTES,0) = 0
	BEGIN
		SELECT 'TRUE'
	END
	ELSE
	BEGIN
		SELECT 'FALSE'
	END
END
