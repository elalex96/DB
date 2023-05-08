-- =============================================
-- Author:		<Abel Rivera>
-- Mod date: <09/01/2018>
-- Description:	<Inserta el detalle de la encuesta de evaluacion del proveedor y parte de la cabecera>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EP_AgregarEvaluacionProveedorDetalle]
@table dbo.Evaluacion READONLY,
@IdEvaluacionCabecera INT,

@IdPedido INT,
@IdUsuarioEvaluador INT, -- Usuario de la sesion
@IdProveedorEvaluado INT, -- proveedor evaluado
@IdProveedorEvaluador INT, --proveedor evaluador

--Parametros del contrato
@IdContrato INT,
@IdUsuario  INT,
@FechaRegistro DATETIME

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @TotalDePuntos INT 
	DECLARE @IsContestada INT = (SELECT EstatusEvaluacion FROM dbo.EP_EvaluacionProveedor WHERE IdEvaluacionProveedor = @IdEvaluacionCabecera)

	IF (@IsContestada = 2) -- valida si ya fue contestada esta la evaluación
	BEGIN
		--Inserta las respuestas contestadas
		INSERT INTO Ep_EvaluacionProveedorDetalle(IdConceptoEvaluar,Ponderacion,IdEvaluacionCabecera) 
		SELECT t.IdConceptoEvaluar,t.Ponderacion,t.IdEvaluacionCabecera FROM @table AS t

		
		SET @TotalDePuntos = (
								SELECT SUM(PCE.valor * EPD.Ponderacion) AS TotalPuntos 
								FROM EP_EvaluacionProveedorDetalle EPD
								INNER JOIN EP_PregConceptoEvaluar PCE
								ON EPD.IdConceptoEvaluar = PCE.IdConceptoEvaluar
								WHERE IdEvaluacionCabecera = @IdEvaluacionCabecera
							 )

		--Actualiza la cabecera de la encuesta
		UPDATE dbo.EP_EvaluacionProveedor 
		SET
		TotalDePuntos = @TotalDePuntos,
		EstatusEvaluacion = 1, --contestada 
		FechaContestada = GETDATE()
		WHERE IdEvaluacionProveedor = @IdEvaluacionCabecera

		SELECT 'success'
	END
	ELSE
	BEGIN
		DECLARE @IdEvaluacion INT
		DECLARE @IdNuevaEvaluacion INT
		EXEC SP_InsertarEvaluacionCabecera @IdPedido,@IdUsuarioEvaluador,@IdProveedorEvaluador,@IdProveedorEvaluado,@IdContrato,@FechaRegistro,@IdNuevaEvaluacion OUTPUT

	    CREATE TABLE #tempPreguntas
		(
			IdConceptoEvaluar INT,
			Ponderacion INT,
			IdEvaluacionCabecera INT 
		)


	    --Inserta las respuestas contestadas temporalmente
		INSERT INTO #tempPreguntas(IdConceptoEvaluar,Ponderacion,IdEvaluacionCabecera) 
		SELECT t.IdConceptoEvaluar,t.Ponderacion,t.IdEvaluacionCabecera FROM @table AS t

		UPDATE #tempPreguntas SET IdEvaluacionCabecera = @IdNuevaEvaluacion --Actualizar a la nueva evaluacion del pedido

		--Inserta las respuestas contestadas a la tabla
	    INSERT INTO Ep_EvaluacionProveedorDetalle(IdConceptoEvaluar,Ponderacion,IdEvaluacionCabecera) 
		SELECT t.IdConceptoEvaluar,t.Ponderacion,t.IdEvaluacionCabecera FROM #tempPreguntas AS t

		SET @TotalDePuntos = (
								SELECT SUM(PCE.valor * EPD.Ponderacion) AS TotalPuntos 
								FROM EP_EvaluacionProveedorDetalle EPD
								INNER JOIN EP_PregConceptoEvaluar PCE
								ON EPD.IdConceptoEvaluar = PCE.IdConceptoEvaluar
								WHERE IdEvaluacionCabecera = @IdNuevaEvaluacion
							 )

		--Actualiza la cabecera de la encuesta
		UPDATE dbo.EP_EvaluacionProveedor 
		SET
		TotalDePuntos = @TotalDePuntos,
		EstatusEvaluacion = 1, --contestada 
		FechaContestada = GETDATE()
		WHERE IdEvaluacionProveedor = @IdNuevaEvaluacion

		SELECT @IdNuevaEvaluacion

    END 
    




END
