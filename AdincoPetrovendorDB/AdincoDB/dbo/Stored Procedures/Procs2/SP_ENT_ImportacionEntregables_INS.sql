USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_ENT_ImportacionEntregables_INS]    Script Date: 16/07/2021 11:42:08 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <06/12/2019>  
-- Description: <Actualizacion de los registros existentes>  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_ENT_ImportacionEntregables_INS] 
@Layout dbo.Entregables_Importacion READONLY,
@IdContrato INT,
@IdUsuario INT
AS
BEGIN

	SELECT
		ROW_NUMBER() OVER (ORDER BY IdEntregable DESC) AS R,
		*
	INTO #TB_EXCEL
	FROM @Layout;

    DECLARE @CONT INT = 1;
	DECLARE @CONTTOTAL INT = (SELECT COUNT(R) FROM #TB_EXCEL);
	DECLARE @IDAREA INT;
	DECLARE @AREA NVARCHAR(500);
	DECLARE @USUARIOELABORADOR NVARCHAR(500);
	DECLARE @IDUSUARIOELABORADOR INT;
	DECLARE @ACTIVO BIT;
	DECLARE @ERRORES NVARCHAR(MAX) = '';
	DECLARE @IDENTREGABLE INT;
	DECLARE @CONTADORAFECTADOS INT = 0;
	DECLARE @CONTADORERRORES INT = 0;
	DECLARE @DIASALERTAPREVIO INT;
	DECLARE @DIASELABORACION INT;
	DECLARE @DIASREVISION INT;
	DECLARE @DIASAPROBACION INT;


	WHILE @CONT <= @CONTTOTAL
	BEGIN
		
		SET @IDENTREGABLE = (SELECT TOP 1 IdEntregable FROM #TB_EXCEL WHERE R = @CONT);
		--BUSQUEDA DE AREA SELECCIONADA
		SET @AREA = (SELECT TOP 1 Area FROM #TB_EXCEL WHERE R = @CONT);
		SET @IDAREA = (SELECT TOP 1 idArea FROM dbo.EN_Area WHERE NombreArea = @AREA AND idContrato = @IdContrato AND Activo = 1);

		--BUSQUEDA DE USUARIO ELABORADOR SELECCIONADO
		SET @USUARIOELABORADOR = (SELECT TOP 1 Elaborador FROM #TB_EXCEL WHERE R = @CONT);
		SET @IDUSUARIOELABORADOR = (SELECT TOP 1 UsuarioID FROM AP_Usuario WHERE Nombre = @USUARIOELABORADOR);

		--ASIGNACION DE ACTIVO
		SELECT
			@ACTIVO = CASE
						WHEN Activo = 'SI' THEN 1
						WHEN Activo = 'NO' THEN 0
					END,
			@DIASALERTAPREVIO = DiasAlertaPrevia,
			@DIASELABORACION = DiasElaboracion,
			@DIASAPROBACION = DiasAprobacion,
			@DIASREVISION = DiasRevicion
		FROM #TB_EXCEL
		WHERE R = @CONT;

		--VALIDACION DE DATOS SELECCIONADOS
		IF ISNULL(@IDAREA,0) > 0 
			AND ISNULL(@IDUSUARIOELABORADOR,0) > 0 
			AND @ACTIVO IS NOT NULL 
			AND ISNULL(@IDENTREGABLE,0) > 0
			AND ISNULL(@DIASALERTAPREVIO,0) > 0
			AND ISNULL(@DIASAPROBACION,0) > 0
			AND ISNULL(@DIASELABORACION,0) > 0
			AND ISNULL(@DIASREVISION,0) > 0
		BEGIN 

			--GUARDADO DE LOS DATOS
			UPDATE CE
			SET CE.IdArea = @IDAREA,
				CE.DiasAlerta = TE.DiasAlertaPrevia,
				CE.DiasElaboracion = TE.DiasElaboracion,
				CE.DiasRevision = TE.DiasRevicion,
				CE.DiasAprobacion = TE.DiasAprobacion,
				CE.Activo = ISNULL(@ACTIVO,0),
				CE.ReceptorAlerta = TE.ReceptorAlerta,
				CE.AccountableCompliance = TE.LiderArea,
				CE.FocalPoint = TE.ElaboradorInterno,
				CE.ModificadoEl = GETDATE(),
				CE.ModificadoPor = @IdUsuario
			FROM dbo.EN_ContratoEntregable AS CE
			JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
			WHERE TE.R = @CONT AND CE.IdContrato = @IdContrato;

			UPDATE AC
			SET AC.idUsuario = @IDUSUARIOELABORADOR,
				AC.ModificadoEn = GETDATE(),
				AC.ModificadoPor = @IdUsuario
			FROM dbo.EN_ContratoEntregable AS CE
			JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
			LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = AC.IdContratoEntregable AND AC.EstadoID IN (10000, 10001, 10002, 10003)
			WHERE TE.R = @CONT AND CE.IdContrato = @IdContrato;

			--GUARDADO EXITOSO AGREGADO AL CONTADOR
			SET @CONTADORAFECTADOS = @CONTADORAFECTADOS + 1;

		END
		ELSE
		BEGIN
			--VALIDACION DE DATOS ERRONES Y AGREGADO DE TEXTO DESCRIPTIVO DEL ERROR
			IF ISNULL(@IDENTREGABLE,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + ' Se detecto que en la fila #' + CAST((@CONT + 1) AS NVARCHAR) + ' no se señalo el entregable a editar,'; 
			END

			IF ISNULL(@IDAREA,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + ' En el Entregable #'+ CAST(@IDENTREGABLE AS nvarchar) + ' el Area seleccionada no es aceptable,';
			END

			IF ISNULL(@IDUSUARIOELABORADOR,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + ' En el Entregable #'+ CAST(@IDENTREGABLE AS nvarchar) + ' el Elaborador seleccionado no es aceptable,';
			END

			IF @ACTIVO IS NULL
			BEGIN
				SET @ERRORES = @ERRORES + ', En el Entregable #'+ CAST(@IDENTREGABLE AS nvarchar) + ' el valor de Activo seleccionado no es aceptable, '
			END

			IF ISNULL(@DIASALERTAPREVIO,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + ' En el Entregable #'+ CAST(@IDENTREGABLE AS nvarchar) + ' los dias de alerta previa deben ser mayor a 0,';
			END

			IF ISNULL(@DIASAPROBACION,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + ' En el Entregable #'+ CAST(@IDENTREGABLE AS nvarchar) + ' los dias de aprobación deben ser mayor a 0,';
			END

			IF ISNULL(@DIASELABORACION,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + ' En el Entregable #'+ CAST(@IDENTREGABLE AS nvarchar) + ' los dias de elaboracion deben ser mayor a 0,';
			END

			IF ISNULL(@DIASREVISION,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + ' En el Entregable #'+ CAST(@IDENTREGABLE AS nvarchar) + ' los dias de revisión deben ser mayor a 0,';
			END

			--ERROR AGREGADO AL CONTADOR
			SET @CONTADORERRORES = @CONTADORERRORES + 1;
		END

		SET @CONT = @CONT + 1;

	END

	SELECT @CONTADORERRORES AS ERRORES,
			@CONTADORAFECTADOS AS AFECTADOS,
			@ERRORES AS TEXTOERRORES

END
