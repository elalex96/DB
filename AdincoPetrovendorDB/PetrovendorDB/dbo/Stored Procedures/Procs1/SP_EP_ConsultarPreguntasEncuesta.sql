-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EP_ConsultarPreguntasEncuesta]
@IdTipoEvaluacion INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT IdConceptoEvaluar,
           CAST(ROW_NUMBER() OVER(ORDER BY IdConceptoEvaluar  ASC) AS NVARCHAR(10)) + ') ' + ConceptoEvaluarNombre AS ConceptoEvaluarNombre,
           valor 
	       FROM EP_PregConceptoEvaluar 
		   WHERE IdTipoDeEvaluacion = @IdTipoEvaluacion

END
