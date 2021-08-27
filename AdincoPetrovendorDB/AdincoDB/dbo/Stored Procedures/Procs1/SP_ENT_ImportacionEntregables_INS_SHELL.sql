DROP PROCEDURE IF EXISTS SP_ENT_ImportacionEntregables_INS_SHELL
GO
-- =============================================  
-- Author:  <Luis David De La Cruz>  
-- Create date: <26/08/2021>  
-- Description: <Actualizacion de los registros existentes>  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_ENT_ImportacionEntregables_INS_SHELL] 
@Layout dbo.Entregables_Importacion_SHELL READONLY,
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
	DECLARE @FUNCION NVARCHAR(500);
	DECLARE @AREA INT; -- IdArea de EN_ContratoEntregable
	DECLARE @SUBFUNCION NVARCHAR(500); --Subfuncion from EN_ContratoEntregable
	DECLARE @DIASALERTAPREVIO INT;
	DECLARE @DIASELABORACION INT;
	DECLARE @DIASREVISION INT = 1;
	DECLARE @DIASAPROBACION INT = 1;
	DECLARE @ACTIVO BIT;


	DECLARE @USUARIOELABORADOR NVARCHAR(500); -- Guardar en idUsuario de EN_Actividad para el estado (EstadoID) 10000
	DECLARE @IDUSUARIOELABORADOR INT;

	DECLARE @IDUSUARIOREVISOR INT;--Guardar en idUsuario de EN_Actividad para el estado (EstadoID) 10001, el mismo usuario que se eligio en Elaborador

	DECLARE @IDUSUARIOAPROBADOR INT; --Guardar en idUsuario de EN_Actividad para los estados (EstadoID) 10002 y 10003, el mismo usuario que se eligio en Elaborador

	DECLARE @FOCALPOINT NVARCHAR(500); --	FocalPoint de EN_ContratoEntregable
	DECLARE @ACCOUNTABLE NVARCHAR(500); --	Accountable de EN_ContratoEntregable 
	DECLARE @ACCOUNTABLECOMPLIANCE NVARCHAR(500); -- AccountableCompliance de EN_ContratoEntregable
	-------------------------------
	DECLARE @IDACTIVIDADACTUAL INT;
	DECLARE @ERRORES NVARCHAR(MAX) = '';
	DECLARE @IDENTREGABLE INT;
	DECLARE @CONTADORAFECTADOS INT = 0;
	DECLARE @CONTADORERRORES INT = 0;


	WHILE @CONT <= @CONTTOTAL
	BEGIN
		SET @IDENTREGABLE = (SELECT TOP 1 IdEntregable FROM #TB_EXCEL WHERE R = @CONT);
		SET @FUNCION = (SELECT TOP 1 Funcion FROM #TB_EXCEL WHERE R = @CONT);
		SET @AREA = (SELECT TOP 1 idArea FROM dbo.EN_Area WHERE NombreArea = @FUNCION AND idContrato = @IdContrato AND Activo = 1);
		SET @SUBFUNCION = (SELECT TOP 1 Subfuncion FROM #TB_EXCEL WHERE R = @CONT);
		SET @DIASALERTAPREVIO = (SELECT TOP 1 DiasAlertaPrevia FROM #TB_EXCEL WHERE R = @CONT);
		SET @DIASELABORACION = (SELECT TOP 1 DiasElaboracion FROM #TB_EXCEL WHERE R = @CONT);
		SET @ACTIVO = (SELECT  CASE
						WHEN Activo = 'SI' THEN 1
						WHEN Activo = 'NO' THEN 0
					END AS ACTIVO FROM #TB_EXCEL WHERE R = @CONT);

		SET @USUARIOELABORADOR = (SELECT TOP 1 Elaborador FROM #TB_EXCEL WHERE R = @CONT);
		SET @IDUSUARIOELABORADOR = (SELECT TOP 1 UsuarioID FROM AP_Usuario WHERE Nombre = @USUARIOELABORADOR);
		SET @IDUSUARIOREVISOR = @IDUSUARIOELABORADOR
		SET @IDUSUARIOAPROBADOR = @IDUSUARIOELABORADOR

		SET @FOCALPOINT = (SELECT TOP 1 FocalPoint FROM #TB_EXCEL WHERE R = @CONT);
		SET @ACCOUNTABLE = (SELECT TOP 1 Accountable FROM #TB_EXCEL WHERE R = @CONT);
		SET @ACCOUNTABLECOMPLIANCE = (SELECT TOP 1 AccountableCompliance FROM #TB_EXCEL WHERE R = @CONT);

		IF ISNULL(@AREA,0) > 0 
			AND ISNULL(@SUBFUNCION,'') != ''
			AND ISNULL(@DIASALERTAPREVIO,0) > 0
			AND ISNULL(@DIASELABORACION,0) > 0
			AND @ACTIVO IS NOT NULL 
			AND ISNULL(@IDUSUARIOELABORADOR,0) > 0 
			AND ISNULL(@IDENTREGABLE,0) > 0
		BEGIN 
		--GUARDADO DE LOS DATOS
			UPDATE CE
			SET CE.IdArea = @AREA,
				CE.DiasAlerta = TE.DiasAlertaPrevia,
				CE.DiasElaboracion = TE.DiasElaboracion,
				CE.DiasRevision = @DIASREVISION,
				CE.DiasAprobacion = @DIASAPROBACION,
				CE.Activo = ISNULL(@ACTIVO,0),
				CE.FocalPoint = TE.FocalPoint,
				CE.Accountable = TE.Accountable,
				CE.AccountableCompliance = TE.AccountableCompliance,
				CE.ModificadoEl = GETDATE(),
				CE.ModificadoPor = @IdUsuario,
				Ce.Subfuncion = @SUBFUNCION
			FROM dbo.EN_ContratoEntregable AS CE
			JOIN #TB_EXCEL AS TE 
			ON CE.IdContratoEntregable = TE.IdEntregable
			WHERE 
			TE.R = @CONT AND 
			CE.IdContrato = @IdContrato;

			--select * FROM dbo.EN_ContratoEntregable AS CE
			--JOIN #TB_EXCEL AS TE 
			--ON CE.IdContratoEntregable = TE.IdEntregable
			--WHERE 
			--TE.R = @CONT 
			--AND 
			--CE.IdContrato = @IdContrato;

			UPDATE AC
			SET AC.idUsuario = @IDUSUARIOELABORADOR,
				AC.ModificadoEn = GETDATE(),
				AC.ModificadoPor = @IdUsuario
			FROM dbo.EN_ContratoEntregable AS CE
			JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
			LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = 
			AC.IdContratoEntregable AND AC.EstadoID IN (10000, 10001, 10002, 10003)
			WHERE 
			TE.R = @CONT AND 
			CE.IdContrato = @IdContrato;

			--VALIDA SI EXISTEN USUARIO DE APROBACIÓN
			IF EXISTS (SELECT 1 FROM 
						dbo.EN_ContratoEntregable AS CE
						JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
						LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = 
						AC.IdContratoEntregable AND AC.EstadoID = 10000
						WHERE 
						TE.R = @CONT AND 
						CE.IdContrato = @IdContrato)
			BEGIN
				UPDATE AC
				SET AC.idUsuario = @IDUSUARIOELABORADOR,
					AC.ModificadoEn = GETDATE(),
					AC.ModificadoPor = @IdUsuario
				FROM dbo.EN_ContratoEntregable AS CE
				JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
				LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = 
				AC.IdContratoEntregable AND AC.EstadoID IN (10000)
				WHERE 
				TE.R = @CONT AND 
				CE.IdContrato = @IdContrato;
			END
			ELSE
			begin
				INSERT INTO en_actividad (ActividadID,EstadoID,idUsuario,IdContratoEntregable,CreadoPor,CreadoEn,Activo)
				SELECT TOP 1
				AC.ActividadID,
				10000,
				@USUARIOELABORADOR,
				CE.IdContratoEntregable,
				@IdUsuario,
				GETDATE(),
				1
				FROM dbo.EN_ContratoEntregable AS CE
				JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
				LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = 
				AC.IdContratoEntregable
				WHERE 
				TE.R = @CONT AND 
				CE.IdContrato = @IdContrato;
			end

			--VALIDA SI EXISTEN USUARIO DE REVISOR
			IF EXISTS (SELECT 1 FROM 
						dbo.EN_ContratoEntregable AS CE
						JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
						LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = 
						AC.IdContratoEntregable AND AC.EstadoID = 10001
						WHERE 
						TE.R = @CONT AND 
						CE.IdContrato = @IdContrato)
			BEGIN
				UPDATE AC
				SET AC.idUsuario = @IDUSUARIOELABORADOR,
					AC.ModificadoEn = GETDATE(),
					AC.ModificadoPor = @IdUsuario
				FROM dbo.EN_ContratoEntregable AS CE
				JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
				LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = 
				AC.IdContratoEntregable AND AC.EstadoID IN (10001)
				WHERE 
				TE.R = @CONT AND 
				CE.IdContrato = @IdContrato;
			END
			ELSE
			begin
				INSERT INTO en_actividad (ActividadID,EstadoID,idUsuario,IdContratoEntregable,CreadoPor,CreadoEn,Activo)
				SELECT TOP 1
				AC.ActividadID,
				10001,
				@USUARIOELABORADOR,
				CE.IdContratoEntregable,
				@IdUsuario,
				GETDATE(),
				1
				FROM dbo.EN_ContratoEntregable AS CE
				JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
				LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = 
				AC.IdContratoEntregable
				WHERE 
				TE.R = @CONT AND 
				CE.IdContrato = @IdContrato;
			end

			--VALIDA SI EXISTEN USUARIO DE APROBADOR
			IF EXISTS (SELECT 1 FROM 
						dbo.EN_ContratoEntregable AS CE
						JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
						LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = 
						AC.IdContratoEntregable AND AC.EstadoID IN (10002,10003)
						WHERE 
						TE.R = @CONT AND 
						CE.IdContrato = @IdContrato)
			BEGIN
				UPDATE AC
				SET AC.idUsuario = @IDUSUARIOELABORADOR,
					AC.ModificadoEn = GETDATE(),
					AC.ModificadoPor = @IdUsuario
				FROM dbo.EN_ContratoEntregable AS CE
				JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
				LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = 
				AC.IdContratoEntregable AND AC.EstadoID IN (10002,10003)
				WHERE 
				TE.R = @CONT AND 
				CE.IdContrato = @IdContrato;
			END
			ELSE
			begin
				INSERT INTO en_actividad (ActividadID,EstadoID,idUsuario,IdContratoEntregable,CreadoPor,CreadoEn,Activo)
				SELECT TOP 1
				AC.ActividadID,
				10002,
				@USUARIOELABORADOR,
				CE.IdContratoEntregable,
				@IdUsuario,
				GETDATE(),
				1
				FROM dbo.EN_ContratoEntregable AS CE
				JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
				LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = 
				AC.IdContratoEntregable
				WHERE 
				TE.R = @CONT AND 
				CE.IdContrato = @IdContrato;

				INSERT INTO en_actividad (ActividadID,EstadoID,idUsuario,IdContratoEntregable,CreadoPor,CreadoEn,Activo)
				SELECT TOP 1
				AC.ActividadID,
				10003,
				@USUARIOELABORADOR,
				CE.IdContratoEntregable,
				@IdUsuario,
				GETDATE(),
				1
				FROM dbo.EN_ContratoEntregable AS CE
				JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
				LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = 
				AC.IdContratoEntregable
				WHERE 
				TE.R = @CONT AND 
				CE.IdContrato = @IdContrato;
			end
			SET @CONTADORAFECTADOS = @CONTADORAFECTADOS + 1;
		END
		ELSE
		BEGIN
			IF ISNULL(@IDENTREGABLE,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + '<li>Se detecto que en la fila <strong>#' + CAST((@CONT + 1) AS NVARCHAR) + '</strong> no se señalo el entregable a editar. </li>'; 
			END
			IF ISNULL(@AREA,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + '<li>En el Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> La Función seleccionada no es aceptable.</li>';
			END
			IF ISNULL(@SUBFUNCION,'') = ''
			BEGIN
				SET @ERRORES = @ERRORES + '<li>En el Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> La Subfunción ingresada no es aceptable.</li>';
			END
			IF ISNULL(@DIASALERTAPREVIO,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + '<li>En el Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> los dias de alerta previa deben ser mayor a 0.</li>';
			END
			IF ISNULL(@DIASELABORACION,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + '<li>En el Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> los dias de elaboracion deben ser mayor a 0.</li>';
			END
			IF @ACTIVO IS NULL
			BEGIN
				SET @ERRORES = @ERRORES + '<li>En el Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> el valor de Activo seleccionado no es aceptable.</li>'
			END
			IF ISNULL(@IDUSUARIOELABORADOR,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + '<li>En el Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> el Aprobador seleccionado no es aceptable.</li>';
			END
			SET @CONTADORERRORES = @CONTADORERRORES + 1;
		END
		SET @CONT = @CONT + 1;
	END
	SELECT @CONTADORERRORES AS ERRORES,
			@CONTADORAFECTADOS AS AFECTADOS,
			@ERRORES AS TEXTOERRORES
END