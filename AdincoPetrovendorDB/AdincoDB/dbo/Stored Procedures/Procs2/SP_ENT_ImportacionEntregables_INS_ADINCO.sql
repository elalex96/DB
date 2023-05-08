
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <06/12/2019>  
-- Description: <Actualizacion de los registros existentes>  
-- =============================================  
-- =============================================  
-- Author:  Daniel AC
-- Create date: <04/05/2022>  
-- Description: Se actualiza modificación de revisores usando sps existentes en la pantalla EditaContratoEntreagble.aspx
-- =============================================  
CREATE PROCEDURE [dbo].[SP_ENT_ImportacionEntregables_INS_ADINCO] 
@Layout dbo.Entregables_Importacion_01 READONLY,
@IdContrato INT,
@IdUsuario INT
AS
BEGIN
	set nocount on
	create table #tmp
	(
		Activo int
	)

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
	DECLARE @IDACTIVIDADACTUAL INT;
	DECLARE @USUARIOREVISOR NVARCHAR(500);
	DECLARE @IDUSUARIOREVISOR INT;
	DECLARE @USUARIOAPROBADOR NVARCHAR(500);
	DECLARE @IDUSUARIOAPROBADOR INT;
	DECLARE @ACTIVO BIT;
	DECLARE @ERRORES NVARCHAR(MAX) = '';
	DECLARE @IDENTREGABLE INT;
	DECLARE @CONTADORAFECTADOS INT = 0;
	DECLARE @CONTADORERRORES INT = 0;
	DECLARE @DIASALERTAPREVIO INT;
	DECLARE @DIASELABORACION INT;
	DECLARE @DIASREVISION INT;
	DECLARE @DIASAPROBACION INT;
	declare @masDeUnRevisor bit
	select @masDeUnRevisor = 0;

	create table #responseAccionesResponsable(response nvarchar(max))	
	create table #Revisores(IdRow int identity(1,1), IdRevisor int, activo bit)	
	DECLARE @CantidadRevisores INT, @UsuarioActualEsRevisor INT,@RevisorIsActivo BIT, @IndRevidores int , @IdRevisorRow INT

	WHILE @CONT <= @CONTTOTAL
	BEGIN
		
		SET @IDENTREGABLE = (SELECT TOP 1 IdEntregable FROM #TB_EXCEL WHERE R = @CONT);
		--BUSQUEDA DE AREA SELECCIONADA
		SET @AREA = (SELECT TOP 1 Area FROM #TB_EXCEL WHERE R = @CONT);
		SET @IDAREA = (SELECT TOP 1 idArea FROM dbo.EN_Area WHERE NombreArea = @AREA AND idContrato = @IdContrato AND Activo = 1);

		--BUSQUEDA DE USUARIO ELABORADOR SELECCIONADO
		SET @USUARIOELABORADOR = (SELECT TOP 1 Elaborador FROM #TB_EXCEL WHERE R = @CONT);
		SET @IDUSUARIOELABORADOR = (SELECT TOP 1 UsuarioID FROM AP_Usuario WHERE Nombre = @USUARIOELABORADOR);

		--BUSQUEDA DE USUARIO REVISOR SELECCIONADO
		SET @USUARIOREVISOR = (SELECT TOP 1 Revisor FROM #TB_EXCEL WHERE R = @CONT);
		SET @IDUSUARIOREVISOR = (SELECT TOP 1 UsuarioID FROM AP_Usuario WHERE Nombre = @USUARIOREVISOR);

		--select @USUARIOREVISOR, @IDUSUARIOREVISOR
		
		if((SELECT CHARINDEX(',', @USUARIOREVISOR) position)>0)
		begin
			select @masDeUnRevisor = 1
		end


		--BUSQUEDA DE USUARIO APROBADOR SELECCIONADO
		SET @USUARIOAPROBADOR = (SELECT TOP 1 Aprobador FROM #TB_EXCEL WHERE R = @CONT);
		SET @IDUSUARIOAPROBADOR = (SELECT TOP 1 UsuarioID FROM AP_Usuario WHERE Nombre = @USUARIOAPROBADOR);

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
			AND ISNULL(@IDUSUARIOREVISOR,0) > 0 
			AND ISNULL(@IDUSUARIOAPROBADOR,0) > 0 
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
				CE.ModificadoEl = GETDATE(),
				CE.ModificadoPor = @IdUsuario
			FROM dbo.EN_ContratoEntregable AS CE
			JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
			WHERE TE.R = @CONT AND CE.IdContrato = @IdContrato;

			--BUSQUEDA EL APROBADOR
			SET @IDACTIVIDADACTUAL = (SELECT TOP 1 ActividadID FROM dbo.EN_Actividad WHERE IdContratoEntregable = @IDENTREGABLE AND Activo = 1 AND EstadoID = 10002 ORDER BY CreadoEn ASC);
			--ACTUALIZACION DEL APROBADOR
			IF @IDACTIVIDADACTUAL IS NOT NULL
			BEGIN
			
				UPDATE		ACAPROB
				SET			ACAPROB.idUsuario			=		@IDUSUARIOAPROBADOR,
							ACAPROB.ModificadoEn		=		GETDATE(),
							ACAPROB.ModificadoPor		=		@IdUsuario
				FROM		dbo.EN_ContratoEntregable	CE
				JOIN		#TB_EXCEL					TE	
				ON			CE.IdContratoEntregable		=		TE.IdEntregable
				LEFT JOIN	EN_Actividad				ACAPROB 
				ON			CE.IdContratoEntregable		=		ACAPROB.IdContratoEntregable 
				AND			ACAPROB.EstadoID			=		10002 --> CTE Aprobación
				WHERE		TE.R						=		@CONT 
				AND			CE.IdContrato				=		@IdContrato;
			END
			ELSE
			BEGIN
				if not exists(select * from EN_Actividad where EstadoID=10002 and idUsuario=@IDUSUARIOAPROBADOR and IdContratoEntregable = @IDENTREGABLE and  Activo = 1)
				begin
						INSERT INTO EN_Actividad (EstadoID,idUsuario,IdContratoEntregable,CreadoPor,CreadoEn,Activo)
						VALUES
						(10002,@IDUSUARIOAPROBADOR,@IDENTREGABLE,@IdUsuario,GETDATE(),1);
				end
			END;

			--BUSQUEDA DEL REVISORES Y ACTUALIZACIÓN
			truncate table #Revisores
			truncate table #responseAccionesResponsable
			
			set @CantidadRevisores=0
			set @UsuarioActualEsRevisor=0
			set @RevisorIsActivo = 1

			INSERT INTO #Revisores(IdRevisor,activo)
			SELECT  idUsuario, Activo
			FROM dbo.EN_Actividad 
			WHERE IdContratoEntregable = @IDENTREGABLE  
			AND EstadoID = 10001 --> CTE Revisión					

			SELECT @CantidadRevisores= COUNT(1) 
			FROM #Revisores						

			SELECT @UsuarioActualEsRevisor = COUNT(1) 
			FROM #Revisores 
			WHERE IdRevisor=@IDUSUARIOREVISOR			

			--> SI CANTIDAD DE REVISORES ES 1 Y SOLO SI EL REVISOR DEL EXCEL ES EL MISMO QUIERE DECIR QUE NO HUBO CAMBIO SOLO VALIDAR SI ESTA ACTIVO
			IF @CantidadRevisores = 1 AND @UsuarioActualEsRevisoR = 1
			BEGIN

				SELECT @RevisorIsActivo = activo 
				FROM #Revisores 
				WHERE IdRevisor=@IDUSUARIOREVISOR

				IF ISNULL(@RevisorIsActivo,0) = 0
					BEGIN 
						--> SI EXISTE RESPONSABLE PERO ESTA INACTIVO ENTONCES SE VUELVE A INSERTAR PARA QUE SE ACTIVE
						INSERT INTO #responseAccionesResponsable(response)
						EXEC EN_SqlResponsablesContratoEntregable
							@IdContratoEntregable =@IDENTREGABLE,
							@idUsuarioSession =@IdUsuario,
							@idContrato =@IdContrato,
							@idUsuario =@IDUSUARIOREVISOR, --Responsable
							@idEstatus = 10001 --> CTE Revisión
					END 
			END 
			ELSE
			BEGIN 
				--> SE ELIMINAN TODOS LOS REVISORES ACTUALES Y AL FINAL SE INSERTA EL NUEVO REVISOR 
				SET @IndRevidores = 1 -->CTE REINICIO DE CONTADOR

				WHILE @CantidadRevisores>=@IndRevidores
				BEGIN 
					SET @IdRevisorRow=0
					SELECT @IdRevisorRow=IdRevisor 
					FROM #Revisores 
					WHERE IdRow=@IndRevidores

					INSERT INTO #responseAccionesResponsable(response)
					 exec [dbo].[sp_EN_DeleteRevisorcontratoEntregable] 
						@IdContratoEntregable =@IDENTREGABLE,
						@idUsuarioSession =@IdUsuario,
						@idUsuario =@IdRevisorRow,
						@idContrato =@IdContrato
						SET @IndRevidores =@IndRevidores+ 1						
				END 

				--> SE INSERTA EL NUEVO REVISOR CARGADO EN EL EXCEL
				INSERT INTO #responseAccionesResponsable(response)
				EXEC EN_SqlResponsablesContratoEntregable
					@IdContratoEntregable =@IDENTREGABLE,
					@idUsuarioSession =@IdUsuario,
					@idContrato =@IdContrato,
					@idUsuario =@IDUSUARIOREVISOR, --Responsable
					@idEstatus = 10001 --> CTE Revisión

			END 

			--BUSQUEDA DEL ELABORADOR
			SET @IDACTIVIDADACTUAL = (SELECT TOP 1 ActividadID FROM dbo.EN_Actividad WHERE IdContratoEntregable = @IDENTREGABLE AND Activo = 1 AND EstadoID = 10000 ORDER BY CreadoEn ASC);
			--ACTUALIZACION DEL ELABORADOR
			IF @IDACTIVIDADACTUAL IS NOT NULL
			BEGIN
				UPDATE ACAPROB
				SET ACAPROB.idUsuario = @IDUSUARIOELABORADOR,
					ACAPROB.ModificadoEn = GETDATE(),
					ACAPROB.ModificadoPor = @IdUsuario
				FROM dbo.EN_ContratoEntregable AS CE
				JOIN #TB_EXCEL AS TE ON CE.IdContratoEntregable = TE.IdEntregable
				LEFT JOIN EN_Actividad AS ACAPROB 
				ON CE.IdContratoEntregable = ACAPROB.IdContratoEntregable AND ACAPROB.EstadoID = 10000 --> CTE Elaboración ó Correción
				WHERE TE.R = @CONT AND CE.IdContrato = @IdContrato;
			END
			ELSE
			BEGIN
				if not exists(select * from EN_Actividad where EstadoID=10000 and idUsuario=@IDUSUARIOAPROBADOR and IdContratoEntregable = @IDENTREGABLE and  Activo = 1)
				begin
					INSERT INTO EN_Actividad (EstadoID,idUsuario,IdContratoEntregable,CreadoPor,CreadoEn,Activo)
					VALUES
					(10000,@IDUSUARIOAPROBADOR,@IDENTREGABLE,@IdUsuario,GETDATE(),1);
				end
			END;

			--GUARDADO EXITOSO AGREGADO AL CONTADOR
			SET @CONTADORAFECTADOS = @CONTADORAFECTADOS + 1;

		END
		ELSE
		BEGIN
			if not (ISNULL(@IDENTREGABLE,0) = 0 and ISNULL(@IDAREA,0) = 0 and ISNULL(@IDUSUARIOREVISOR,0) = 0 and ISNULL(@IDUSUARIOAPROBADOR,0) = 0 and ISNULL(@IDUSUARIOELABORADOR,0) = 0 and
				@ACTIVO IS NULL and ISNULL(@DIASALERTAPREVIO,0) = 0 and ISNULL(@DIASAPROBACION,0) = 0 and ISNULL(@DIASELABORACION,0) = 0 and ISNULL(@DIASREVISION,0) = 0 )
			begin
				--VALIDACION DE DATOS ERRONES Y AGREGADO DE TEXTO DESCRIPTIVO DEL ERROR
				IF ISNULL(@IDENTREGABLE,0) = 0
				BEGIN
					SET @ERRORES = @ERRORES + '<li>Se detecto que en la fila <strong>#' + CAST((@CONT + 1) AS NVARCHAR) + '</strong> no se señalo el entregable a editar. </li>'; 
				END

				IF ISNULL(@IDAREA,0) = 0
				BEGIN
					SET @ERRORES = @ERRORES + '<li>Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> el Área seleccionada no es aceptable.</li>';
				END

				IF ISNULL(@IDUSUARIOREVISOR,0) = 0
				BEGIN
					if(@masDeUnRevisor=1)
					begin
						SET @ERRORES = @ERRORES + '<li>Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> Solo es posible agregar un Revisor mediante importación</li>';
					end
					else
					begin
						SET @ERRORES = @ERRORES + '<li>Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> el Revisor seleccionado no es aceptable.</li>';
					end
				END

				IF ISNULL(@IDUSUARIOAPROBADOR,0) = 0
				BEGIN
					SET @ERRORES = @ERRORES + '<li>Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> el Aprobador seleccionado no es aceptable.</li>';
				END

				IF ISNULL(@IDUSUARIOELABORADOR,0) = 0
				BEGIN
					SET @ERRORES = @ERRORES + '<li>Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> el Elaborador seleccionado no es aceptable.</li>';
				END

				IF @ACTIVO IS NULL
				BEGIN
					SET @ERRORES = @ERRORES + '<li>Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> el valor de Activo seleccionado no es aceptable.</li>'
				END

				IF ISNULL(@DIASALERTAPREVIO,0) = 0
				BEGIN
					SET @ERRORES = @ERRORES + '<li>Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> los días de alerta previa deben ser mayor a 0.</li>';
				END

				IF ISNULL(@DIASAPROBACION,0) = 0
				BEGIN
					SET @ERRORES = @ERRORES + '<li>Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> los días de aprobación deben ser mayor a 0.</li>';
				END

				IF ISNULL(@DIASELABORACION,0) = 0
				BEGIN
					SET @ERRORES = @ERRORES + '<li>Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> los días de elaboracion deben ser mayor a 0.</li>';
				END

				IF ISNULL(@DIASREVISION,0) = 0
				BEGIN
					SET @ERRORES = @ERRORES + '<li>Entregable <strong>#'+ CAST(@IDENTREGABLE AS nvarchar) + '</strong> los días de revisión deben ser mayor a 0.</li>';
				END

				--ERROR AGREGADO AL CONTADOR
				SET @CONTADORERRORES = @CONTADORERRORES + 1;
			end
		END

		SET @CONT = @CONT + 1;

	END

	SELECT @CONTADORERRORES AS ERRORES,
			@CONTADORAFECTADOS AS AFECTADOS,
			@ERRORES AS TEXTOERRORES


END

