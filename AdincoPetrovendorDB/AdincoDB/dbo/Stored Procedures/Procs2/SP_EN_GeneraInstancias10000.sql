USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_EN_GeneraInstancias10000'
)
    DROP PROCEDURE SP_EN_GeneraInstancias10000;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_EN_GeneraInstancias10000] --'20200718',3,'20200720',1,2,1,18777,3,10061,13047
    @FechaLimiteint DATE,
    @DiasElaboracion INT,
    @FechaLimiteEntregaRegulador DATE,
    @DiasRevision INT,
    @DiasAprobacion INT,
    @DiasAlerta INT,
    @IdContratoEntregable INT,
    @idContrato INT,
    @idUsuario INT,
    @idEntregable INT,
    @BitProgramaImplementa INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/04/2019
-- Description:	
-- =============================================
-- 20200716	BAAC Se modifica para considerar mas de una fecha de entregable por evento en el mismo mes
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/08/2023
-- Description:	correccion para contemplar los entregables que tienen cargados urls
-- =============================================
    SET NOCOUNT ON;
    -----------------------------------------------
    CREATE TABLE #DiasCE
    (
        id INT IDENTITY(1, 1),
        dias INT,
        tipo NVARCHAR(15)
    );

    CREATE TABLE #DiasHabiles
    (
        Id INT IDENTITY(1, 1),
        IdFecha DATE
    );

    CREATE TABLE #InstanciasEntregable
    (
        IdInstanciaEntregable INT,
        FechasLimiteAprobacion DATE,
        Estatus INT,
        TieneArchivo INT
    );

    CREATE TABLE #TEMP_InstanciasEntregable
    (
        Id INT,
        FechasLimiteElaboracion DATETIME,
        FechasLimiteRevision DATETIME,
        FechasLimiteAprobacion DATETIME,
        FechaEnvioMensajeAtrasoRevision DATETIME,
        FechasLimiteEntregaReg DATETIME,
        FechaInicioElaboracion DATETIME
    );

    CREATE TABLE #DiasHabilesFrecuencia
    (
        Id INT IDENTITY(1, 1),
        IdFecha DATE
    );

    CREATE TABLE #FechasCalcEntregaRegulador
    (
        Id INT IDENTITY(1, 1),
        IdFecha DATE
    );

    DECLARE @CountFF INT,
            @C INT = 1,
            @CantidadDias INT,
            @FechaInicialSig DATE,
            @Frecuencia INT,
            @CountDias INT,
            @idActividadElab INT,
            @idActividadRevi INT,
            @idActividadAprob INT,
            @FechaFinFlujo DATE;

    -----------------------------------------------
	IF(@idEntregable=0)
	BEGIN
	 SELECT @idEntregable = 
	 IdEntregable
    FROM dbo.EN_ContratoEntregable
    WHERE IdContratoEntregable =@IdContratoEntregable;

    END

    SELECT @Frecuencia =  IdFrecuenciaEntregable
    FROM dbo.EN_Entregable
    WHERE IdEntregable = @idEntregable;


    IF (@BitProgramaImplementa = 0)
    BEGIN
        SELECT @FechaFinFlujo = FinVigencia
								FROM dbo.CO_Contrato (NOLOCK)
								WHERE IdContrato = @idContrato;
    END;
    ELSE
    BEGIN
        SELECT  @FechaFinFlujo = PI.FechaFin
        FROM dbo.EN_ContratoEntregableProgramaImplementaAcciones CEPI (NOLOCK)
            JOIN dbo.CO_ProgramaImplementaAcciones PIA (NOLOCK)
                ON CEPI.IdContratoEntregable = @IdContratoEntregable
                   AND CEPI.IdProgramaImplementaAccion = PIA.IdProgramaImplementaAccion
            JOIN dbo.CO_ProgramaImplementaElemento PIE (NOLOCK)
                ON PIA.IdProgramaImplementaElemento = PIE.IdProgramaImplementaElemento
            JOIN dbo.CO_ProgramaImplementaPoliticas PIP (NOLOCK)
                ON PIE.IdProgramaImplementaPolitica = PIP.IdProgramaImplementaPolitica
            JOIN dbo.CO_ProgramaImplementa PI (NOLOCK)
                ON PIP.IdProgramaImplementa = PI.IdProgramaImplementa;
    END;


    IF ( @FechaFinFlujo >= @FechaLimiteint AND @FechaFinFlujo >= @FechaLimiteEntregaRegulador )
    BEGIN
        IF (@Frecuencia NOT IN ( 10005 ))--Diaria
        BEGIN
            SELECT @idActividadElab = ActividadID
            FROM dbo.EN_Actividad (NOLOCK)
            WHERE IdContratoEntregable = @IdContratoEntregable --16622
                  AND EstadoID = 10000; --Para elaboración o corrección

            SELECT TOP 1 @idActividadRevi = ActividadID
            FROM dbo.EN_Actividad (NOLOCK)
            WHERE IdContratoEntregable = @IdContratoEntregable --16622
                  AND EstadoID = 10001; --Para Revisión

            SELECT @idActividadAprob = ActividadID
            FROM dbo.EN_Actividad (NOLOCK)
            WHERE IdContratoEntregable = @IdContratoEntregable --16622
                  AND EstadoID = 10002; --Para Aprobación

            IF (       @idActividadElab IS NOT NULL
                   AND @idActividadRevi IS NOT NULL
                   AND @idActividadAprob IS NOT NULL
                   AND @DiasAlerta IS NOT NULL
                   AND @DiasAlerta > 0
                   AND @DiasAprobacion IS NOT NULL
                   AND @DiasAprobacion > 0
                   AND @DiasRevision IS NOT NULL
                   AND @DiasRevision > 0
                   AND @DiasElaboracion IS NOT NULL
                   AND @DiasElaboracion > 0
               )
            BEGIN
			IF(@Frecuencia <>  10019)-- SOLO PARA FRECUENCIAS DIFERENTES A SEMANALES, YA QUE SE IGUALA CON MES Y AÑO
				BEGIN
					INSERT INTO #DiasHabilesFrecuencia
					(
						IdFecha
					)
					EXEC [SP_EN_GeneraInstanciasFechasLimite] --'20191001',3, 10019,17464,0,0
						@FechaLimiteint,
						@idContrato,
						@Frecuencia,
						@IdContratoEntregable,
						@BitProgramaImplementa,0

					INSERT INTO #FechasCalcEntregaRegulador
					(
						IdFecha
					)
					EXEC [SP_EN_GeneraInstanciasFechasLimite] --'20190319',3, 10008
						@FechaLimiteEntregaRegulador,
						@idContrato,
						@Frecuencia,
						@IdContratoEntregable,
						@BitProgramaImplementa,1;

					INSERT INTO #DiasCE
                (
                    dias,
                    tipo
                )
                VALUES
                (@DiasAprobacion, 'Aprobacion'),
                (@DiasRevision, 'revision'),
                (@DiasAlerta, 'Alerta');
				
					SELECT @CountFF = COUNT(*)
					FROM #DiasHabilesFrecuencia;

					WHILE (@C <= @CountFF) 
					BEGIN
						SET @CantidadDias = 1;
						INSERT INTO #TEMP_InstanciasEntregable
						(
							Id,
							FechasLimiteElaboracion,
							FechasLimiteRevision,
							FechasLimiteAprobacion,
							FechaEnvioMensajeAtrasoRevision,
							FechasLimiteEntregaReg,
							FechaInicioElaboracion
						)
						SELECT F.Id,
							   NULL,
							   NULL,
							   F.IdFecha,
							   NULL,
							   R.IdFecha,
							   NULL
						FROM #DiasHabilesFrecuencia F
							JOIN #FechasCalcEntregaRegulador R
								ON R.Id = F.Id
						WHERE F.Id = @C;

						SELECT @FechaInicialSig = FechasLimiteAprobacion
						FROM #TEMP_InstanciasEntregable
						WHERE Id = @C;

						SELECT @CountDias = COUNT(*)
								FROM #DiasCE;
				WHILE (@CantidadDias <= @CountDias) 
						BEGIN
							------------------------------------------------
							TRUNCATE TABLE #DiasHabiles;
							INSERT INTO #DiasHabiles
						  (
								IdFecha
							)
							SELECT IdFecha
							FROM dbo.AP_Calendario (NOLOCK)
							WHERE IdFecha < @FechaInicialSig
								  AND DATEADD(YEAR, -3, @FechaInicialSig) <= IdFecha
								  AND FinDeSemana = 0
								  AND DiaLaborable = 1
							ORDER BY IdFecha DESC;
							----------------------------------------------------
							UPDATE TIE
							SET FechasLimiteRevision = CASE CE.tipo
														   WHEN 'Aprobacion' THEN
															   DH.IdFecha
														   ELSE
															   TIE.FechasLimiteRevision
													   END,
								FechasLimiteElaboracion = CASE CE.tipo
															  WHEN 'revision' THEN
																  DH.IdFecha
															  ELSE
																  TIE.FechasLimiteElaboracion
														  END,
								FechaEnvioMensajeAtrasoRevision = CASE CE.tipo
																	  WHEN 'Alerta' THEN
																		  DH.IdFecha
																	  ELSE
																		  TIE.FechaEnvioMensajeAtrasoRevision
																  END
							--Select *
							FROM #TEMP_InstanciasEntregable TIE
								LEFT JOIN #DiasCE CE
									ON CE.id = @CantidadDias
								LEFT JOIN #DiasHabiles DH
									ON @FechaInicialSig >= DH.IdFecha
									   AND CE.dias = DH.Id
								LEFT JOIN dbo.AP_Calendario C2 (NOLOCK)
									ON @FechaInicialSig >= C2.IdFecha
									   AND C2.IdFecha > DATEADD(YEAR, -1, @FechaInicialSig)
									   AND C2.FinDeSemana = 0
									   AND C2.DiaLaborable = 1
							WHERE TIE.Id = @C;

							IF ((SELECT tipo FROM #DiasCE WHERE id = @CantidadDias) = 'Alerta')
							BEGIN
								UPDATE TIE
								SET FechaInicioElaboracion = DH.IdFecha
								FROM #TEMP_InstanciasEntregable TIE
									LEFT JOIN #DiasHabiles DH
										ON @FechaInicialSig >= DH.IdFecha
										   AND @DiasElaboracion = DH.Id
									LEFT JOIN dbo.AP_Calendario C2 (NOLOCK)
										ON @FechaInicialSig >= C2.IdFecha
										   AND C2.IdFecha > DATEADD(YEAR, -3, @FechaInicialSig)
										   AND C2.FinDeSemana = 0
										   AND C2.DiaLaborable = 1
								WHERE TIE.Id = @C;
							END;


							SELECT @FechaInicialSig = DH.IdFecha
							FROM #TEMP_InstanciasEntregable TIE
								LEFT JOIN #DiasCE CE
									ON CE.id = @CantidadDias
								LEFT JOIN #DiasHabiles DH
									ON @FechaInicialSig >= DH.IdFecha
									AND CE.dias = DH.Id
								LEFT JOIN dbo.AP_Calendario C2 (NOLOCK)
									ON @FechaInicialSig >= C2.IdFecha
									   AND C2.IdFecha > DATEADD(YEAR, -1, @FechaInicialSig)
									   AND C2.FinDeSemana = 0
									   AND C2.DiaLaborable = 1
							WHERE TIE.Id = @C;


							SET @CantidadDias = @CantidadDias + 1;
						END;
						SET @C = @C + 1;
					END;

					INSERT INTO #InstanciasEntregable
					(
						IdInstanciaEntregable,
						FechasLimiteAprobacion,
						Estatus,
						TieneArchivo
					)
					SELECT IE.idInstanciaEntregable,
						   IE.FechasLimiteAprobacion,
						   ISNULL(A.EstadoID, 10000),
						   ISNULL(COUNT(ED.DocumentoEntregableId), 0)
					FROM dbo.EN_InstanciasEntregable IE (NOLOCK)
						LEFT JOIN dbo.EN_Actividad A (NOLOCK)
							ON IE.ActividadID = A.ActividadID
							   AND IE.IdContratoEntregable = A.IdContratoEntregable
						LEFT JOIN EN_EntregableDocumento ED (NOLOCK)
							ON IE.idInstanciaEntregable = ED.idInstanciaEntregable
						LEFT JOIN EN_HistorialAprobacionesLineaTiempo HALT (NOLOCK)
							ON IE.idInstanciaEntregable = HALT.idInstanciaEntregable
					WHERE IE.IdContratoEntregable = @IdContratoEntregable
						AND IE.Activo = 1
						AND HALT.IdHistorialAprobacionesVersion IS NULL
					GROUP BY IE.idInstanciaEntregable,
							 IE.FechasLimiteAprobacion,
							 ISNULL(A.EstadoID, 10000);
            
					DELETE FROM #TEMP_InstanciasEntregable
					WHERE Id IN
						  (
							  SELECT Id
							  FROM #TEMP_InstanciasEntregable TIE
								  JOIN #InstanciasEntregable IE
									  ON MONTH(TIE.FechasLimiteAprobacion) = MONTH(IE.FechasLimiteAprobacion)
										 AND YEAR(TIE.FechasLimiteAprobacion) = YEAR(IE.FechasLimiteAprobacion)
										 AND DAY(TIE.FechasLimiteAprobacion) = DAY(IE.FechasLimiteAprobacion)
							  WHERE Estatus <> 10000
									OR IE.TieneArchivo <> 0
						  );

					-- SI ES UN ENTREGABLE POR EVENTO, NO SE ELIMINAN LOS ENTREGABLES QUE YA ESTEN PROGRAMADOS
					IF @Frecuencia <> 10011
					BEGIN

						DELETE dbo.EN_InstanciasEntregable
						WHERE idInstanciaEntregable IN
						  (
							  SELECT IdInstanciaEntregable
							  FROM #InstanciasEntregable
							  WHERE Estatus = 10000
									AND TieneArchivo = 0
						  )
						  AND IdContratoEntregable = @IdContratoEntregable;

					END

				INSERT INTO dbo.EN_InstanciasEntregable
                (
                    FechasLimiteElaboracion,
                    FechasLimiteRevision,
                    FechasLimiteAprobacion,
                    FechaEnvioMensajeAtrasoRevision,
                    idFrecuencua,
                    IdContratoEntregable,
                    CorreoEnviado,
                    ActividadID,
                    CreadoPor,
                    CreadoEn,
                    ModificadoPor,
                    ModificadoEn,
                    Activo,
                    FechaCalculadaEntregaReg,
                    FechaInicioElaboracion
                )
                SELECT FechasLimiteElaboracion,
                       FechasLimiteRevision,
                       FechasLimiteAprobacion,
                       FechaEnvioMensajeAtrasoRevision,
                       @Frecuencia,
                       @IdContratoEntregable,
                       0,
                       @idActividadElab,
						@idUsuario,
                     GETDATE(),
                       @idUsuario,
                       GETDATE(),
                       1,
					   FechasLimiteEntregaReg,
                       FechaInicioElaboracion
                FROM #TEMP_InstanciasEntregable;
				END
				ELSE
				BEGIN --FRECUENCIA SEMANAL
					IF((DATEDIFF( DAY , @FechaLimiteint,@FechaLimiteEntregaRegulador))<=7)
					BEGIN
						INSERT INTO #DiasHabilesFrecuencia
						(
							IdFecha
						)
						EXEC [SP_EN_GeneraInstanciasFechasLimite] --'20191001',3, 10019,17464,0,0
							@FechaLimiteint,
							@idContrato,
							@Frecuencia,
							@IdContratoEntregable,
							@BitProgramaImplementa,0

						INSERT INTO #FechasCalcEntregaRegulador
					(
						IdFecha
					)
					EXEC [SP_EN_GeneraInstanciasFechasLimite] --'20190319',3, 10008
						@FechaLimiteEntregaRegulador,
						@idContrato,
						@Frecuencia,
						@IdContratoEntregable,
						@BitProgramaImplementa,1;

						INSERT INTO #TEMP_InstanciasEntregable
						(
							Id,
							FechasLimiteElaboracion,
							FechasLimiteRevision,
							FechasLimiteAprobacion,
							FechaEnvioMensajeAtrasoRevision,
							FechasLimiteEntregaReg,
							FechaInicioElaboracion
						)
						SELECT F.Id,
							   NULL,
							   NULL,
							   F.IdFecha,
							   NULL,
							   R.IdFecha,
							   NULL
						FROM #DiasHabilesFrecuencia F
							JOIN #FechasCalcEntregaRegulador R
								ON R.Id = F.Id

						UPDATE #TEMP_InstanciasEntregable
						SET FechasLimiteRevision=DATEADD(DAY, -@DiasAprobacion, FechasLimiteAprobacion)

						UPDATE #TEMP_InstanciasEntregable
						SET FechasLimiteElaboracion=DATEADD(DAY, -@DiasElaboracion, FechasLimiteRevision)

						UPDATE #TEMP_InstanciasEntregable
						SET FechaInicioElaboracion=DATEADD(DAY, -@DiasElaboracion, FechasLimiteElaboracion)

						UPDATE #TEMP_InstanciasEntregable
						SET FechaEnvioMensajeAtrasoRevision=DATEADD(DAY, -@DiasAlerta, FechaInicioElaboracion)

						INSERT INTO #InstanciasEntregable
						(
							IdInstanciaEntregable,
							FechasLimiteAprobacion,
							Estatus,
							TieneArchivo
						)
						SELECT IE.idInstanciaEntregable,
							   IE.FechasLimiteAprobacion,
							   ISNULL(A.EstadoID, 10000),
							   ISNULL(COUNT(ED.DocumentoEntregableId), 0)
						FROM dbo.EN_InstanciasEntregable IE (NOLOCK)
							LEFT JOIN dbo.EN_Actividad A
								ON IE.ActividadID = A.ActividadID
								   AND IE.IdContratoEntregable = A.IdContratoEntregable
							LEFT JOIN EN_EntregableDocumento ED (NOLOCK)
								ON IE.idInstanciaEntregable = ED.idInstanciaEntregable
							LEFT JOIN EN_HistorialAprobacionesLineaTiempo HALT (NOLOCK)
								ON IE.idInstanciaEntregable = HALT.idInstanciaEntregable
						WHERE IE.IdContratoEntregable = @IdContratoEntregable
							AND IE.Activo = 1
							AND HALT.IdHistorialAprobacionesVersion IS NULL
						GROUP BY IE.idInstanciaEntregable,
								 IE.FechasLimiteAprobacion,
								 ISNULL(A.EstadoID, 10000);

						DELETE dbo.EN_InstanciasEntregable
						WHERE idInstanciaEntregable IN
								(
									SELECT IdInstanciaEntregable
									FROM #InstanciasEntregable
									WHERE Estatus = 10000
										AND TieneArchivo = 0
								)
								AND IdContratoEntregable = @IdContratoEntregable;

						INSERT INTO dbo.EN_InstanciasEntregable
						(
							FechasLimiteElaboracion,
							FechasLimiteRevision,
							FechasLimiteAprobacion,
							FechaEnvioMensajeAtrasoRevision,
							idFrecuencua,
							IdContratoEntregable,
							CorreoEnviado,
							ActividadID,
							CreadoPor,
							CreadoEn,
							ModificadoPor,
							ModificadoEn,
							Activo,
							FechaCalculadaEntregaReg,
							FechaInicioElaboracion
						)
						SELECT FechasLimiteElaboracion,
							   FechasLimiteRevision,
							   FechasLimiteAprobacion,
							   FechaEnvioMensajeAtrasoRevision,
							   @Frecuencia,
							   @IdContratoEntregable,
							   0,
							   @idActividadElab,
							   @idUsuario,
							   GETDATE(),
							   @idUsuario,
							   GETDATE(),
							   1,
							   FechasLimiteEntregaReg,
							   FechaInicioElaboracion
						FROM #TEMP_InstanciasEntregable
						ORDER BY ID;

					END
					ELSE
					 BEGIN
						SELECT 'El entregable es de frecuencia semanal, la fecha de entrega a regulador debe ser menor o igual a ' + Ltrim(Dateadd(day, 7, @FechaLimiteint)) +' y mayor a ' + ltrim(@FechaLimiteint) AS error;
					END;
				END

            END;
            ELSE
            BEGIN
                SELECT 'Guarde usuarios responsables del entregable, los días de elaboración, revisión, aprobación y alerta deben ser mayor a 0' AS error;
            END;

        END;
        ELSE
        BEGIN
            SELECT 'Es Entregable con Frecuencia Diaria' AS error;
        END;
    END;
    ELSE
    BEGIN
        SELECT CASE @BitProgramaImplementa
                   WHEN 1 THEN
                       'No se pueden generar entregables con fecha mayor a la fecha del programa de implementación SASISOPA'
                   ELSE
                       'No se pueden generar entregables con fecha mayor a la fecha fin del contrato'
               END AS error;
    END;

END;
