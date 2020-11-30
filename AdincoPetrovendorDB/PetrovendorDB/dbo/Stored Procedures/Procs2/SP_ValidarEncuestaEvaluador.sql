-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarEncuestaEvaluador]
@IdPedido INT,
@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IS_EVALUADOR INT = ( SELECT COUNT (U.IdUsuario)
								  FROM dbo.S_Usuario U
								  INNER JOIN dbo.MM_Pedido P 
								  ON P.CreadoPor = U.IdUsuario
								  WHERE  P.IdPedido = @IdPedido AND P.CreadoPor = @IdUsuario)
	IF(@IS_EVALUADOR > 0)
	BEGIN
	SELECT 'ES_EVALUADOR'
	END
	ELSE
	BEGIN
	SELECT 'NO_ES_EVALUADOR'
	END

END

