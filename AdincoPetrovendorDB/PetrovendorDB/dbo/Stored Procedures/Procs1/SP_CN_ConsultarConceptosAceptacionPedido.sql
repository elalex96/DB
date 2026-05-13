-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CN_ConsultarConceptosAceptacionPedido]
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @FALTANTES INT =  (SELECT COUNT(IdAceptacionPedido) FROM dbo.MM_AceptacionPedidoDetalle WHERE IdAceptacionPedido = @IdAceptacionPedido AND ClasificacionCN IS NULL)

	IF @FALTANTES = 0
	BEGIN
		SELECT 'TRUE'
	END
	ELSE
	BEGIN
		SELECT 'FALSE'
	END
END
