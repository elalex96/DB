USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ENT_ImportacionEntregables_INS_SHELL'
)

    DROP PROCEDURE SP_ENT_ImportacionEntregables_INS_SHELL;
/****** Object:  StoredProcedure [dbo].[SP_ENT_ImportacionEntregables_INS_SHELL]    Script Date: 01/02/2024 02:01:22 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  <Luis David De La Cruz>  
-- Create date: <26/08/2021>  
-- Description: <Actualizacion de los registros existentes>  
-- =============================================  
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <12/05/2022>  
-- Description: <descarte de elementos vacios, incertado en en_Actividad en caso de que el entregable no tenga registros en esta tabla>  
-- =============================================  
-- =============================================
-- Author:	Daniel Ac 
-- Create date: <01/02/2024>
-- Description:	<Se CONSIDERA los usuarios de grupos a la lista de elaboradores>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENT_ImportacionEntregables_INS_SHELL] 
@Layout dbo.Entregables_Importacion_SHELL READONLY,
@IdContrato INT,
@IdUsuario INT
AS
BEGIN

	CREATE TABLE #TB_EXCEL(
	[R] INT,
	[IdEntregable] [nvarchar](500) NULL,
	[Funcion] [nvarchar](500) NULL,
	[Subfuncion] [nvarchar](500) NULL,
	[DiasAlertaPrevia] [nvarchar](500) NULL,
	[DiasElaboracion] [nvarchar](500) NULL,
	[Activo] [nvarchar](500) NULL,
	[Elaborador] [nvarchar](500) NULL,
	[FocalPoint] [nvarchar](500) NULL,
	[Accountable] [nvarchar](500) NULL,
	[AccountableCompliance] [nvarchar](500) NULL,
	[Column16] [nvarchar](500) NULL
	)

	INSERT INTO #TB_EXCEL(
	R,
	IdEntregable,
	Funcion,
	Subfuncion,
	DiasAlertaPrevia,
	DiasElaboracion,
	Activo,
	Elaborador,
	FocalPoint,
	Accountable,
	AccountableCompliance,
	Column16)
	SELECT
		ROW_NUMBER() OVER (ORDER BY IdEntregable DESC) AS R,
		IdEntregable,
		Funcion,
		Subfuncion,
		DiasAlertaPrevia,
		DiasElaboracion,
		Activo,
		Elaborador,
		FocalPoint,
		Accountable,
		AccountableCompliance,
		Column16
	FROM @Layout
	WHERE IdEntregable <> '';

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
	DECLARE @ID_ACTIVIDAD INT;


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

	CREATE TABLE #UsuariosContrato(UsuarioId INT,Usuario NVARCHAR(MAX),Nombre NVARCHAR(MAX))

	-- OBTENER LOS USUARIOS DEL CONTRATO
	INSERT INTO #UsuariosContrato(UsuarioId,Usuario,Nombre)
	EXEC sp_Ap_Usuario_Cmb @IdContrato,'CON_GRUPOS'


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
		SET @IDUSUARIOELABORADOR = (SELECT TOP 1 UsuarioID FROM #UsuariosContrato WHERE Nombre = @USUARIOELABORADOR);
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

			SELECT TOP 1
				@ID_ACTIVIDAD = AC.ActividadID
			FROM dbo.EN_ContratoEntregable AS CE
			JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
			LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = AC.IdContratoEntregable AND AC.EstadoID IN (10000, 10001, 10002, 10003)
			WHERE TE.R = @CONT AND CE.IdContrato = @IdContrato
			ORDER BY CreadoEn DESC;

			IF ISNULL(@ID_ACTIVIDAD,0) > 0
			BEGIN
				
				UPDATE AC
				SET AC.idUsuario = @IDUSUARIOELABORADOR,
					AC.ModificadoEn = GETDATE(),
					AC.ModificadoPor = @IdUsuario
				FROM dbo.EN_ContratoEntregable AS CE
				JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
				LEFT JOIN EN_Actividad AS AC ON CE.IdContratoEntregable = AC.IdContratoEntregable AND AC.EstadoID IN (10000, 10001, 10002, 10003)
				WHERE TE.R = @CONT AND CE.IdContrato = @IdContrato;

			END
			ELSE
			BEGIN

				INSERT INTO EN_Actividad (EstadoID,idUsuario,CreadoPor,CreadoEn,Activo,IdContratoEntregable) VALUES (10000,@IDUSUARIOELABORADOR,@IdUsuario,GETDATE(),1,@IDENTREGABLE);
				INSERT INTO EN_Actividad (EstadoID,idUsuario,CreadoPor,CreadoEn,Activo,IdContratoEntregable) VALUES (10001,@IDUSUARIOELABORADOR,@IdUsuario,GETDATE(),1,@IDENTREGABLE);
				INSERT INTO EN_Actividad (EstadoID,idUsuario,CreadoPor,CreadoEn,Activo,IdContratoEntregable) VALUES (10002,@IDUSUARIOELABORADOR,@IdUsuario,GETDATE(),1,@IDENTREGABLE);
				INSERT INTO EN_Actividad (EstadoID,idUsuario,CreadoPor,CreadoEn,Activo,IdContratoEntregable) VALUES (10003,@IDUSUARIOELABORADOR,@IdUsuario,GETDATE(),1,@IDENTREGABLE);

			END

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
				SET @ERRORES = @ERRORES + '<li>En el Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> los días de alerta previa deben ser mayor a 0.</li>';
			END
			IF ISNULL(@DIASELABORACION,0) = 0
			BEGIN
				SET @ERRORES = @ERRORES + '<li>En el Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> los días de elaboración deben ser mayor a 0.</li>';
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