-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EP_ValoracionEstrellas]
@IdProveedorEvaluado INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Estrellas INT = 5
	DECLARE @PuntajeXEstrella INT
	DECLARE @PuntajeMaximo INT
	DECLARE @EstrellasRecibidas INT = 0
	DECLARE @PuntajeTotalEnvaluacion INT

	DECLARE @IsEvaluado INT
	SET @IsEvaluado = (SELECT COUNT (IdEvaluacionProveedor) FROM EP_EvaluacionProveedor WHERE IsContestada = 1 AND IdProveedorEvaluado = @IdProveedorEvaluado)

	IF (@IsEvaluado != 0)
	BEGIN
		SET @PuntajeTotalEnvaluacion = (SELECT TotalDePuntos FROM EP_EvaluacionProveedor						        								
									WHERE IdProveedorEvaluado = @IdProveedorEvaluado)
									 

	SET @PuntajeMaximo = (SELECT SUM(valor * 3) FROM EP_PregConceptoEvaluar)

	SET @PuntajeXEstrella = (SELECT @PuntajeMaximo/@Estrellas)
	


	SET @EstrellasRecibidas = (@PuntajeTotalEnvaluacion/@PuntajeXEstrella)

	SELECT @EstrellasRecibidas AS NumeroDeEstrellas
	END

	ELSE
	BEGIN
	SELECT @EstrellasRecibidas AS NumeroDeEstrellas
	END





END

