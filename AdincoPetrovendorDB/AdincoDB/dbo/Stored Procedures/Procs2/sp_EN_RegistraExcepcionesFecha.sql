USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[sp_EN_RegistraExcepcionesFecha]    Script Date: 23/11/2021 05:24:31 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019
-- Description:Crea excepciones para los responsables de una instancia
-- =============================================
-- 24/11/2021 MC quitar prints ISSUE 383 adincopetrodb
-- =============================================
ALTER PROCEDURE [dbo].[sp_EN_RegistraExcepcionesFecha] --3,10061,249263,'20190910','20190913'
    @idContrato INT,
    @idUsuario INT,
    @idInstanciaentregable INT,
    @FechaLimiteint DATE,
    @FechaLimiteEntregaRegulador DATE,
    @Activo BIT,
    @MotivoDesactivar VARCHAR(500)
AS
BEGIN
	set nocount on

    IF OBJECT_ID('tempdb..#DiasCE', 'U') IS NOT NULL
        DROP TABLE #DiasCE;
    CREATE TABLE #DiasCE
    (
        id INT IDENTITY(1, 1),
        dias INT,
        tipo NVARCHAR(15)
    );

    IF OBJECT_ID('tempdb..#DiasHabiles', 'U') IS NOT NULL
        DROP TABLE #DiasHabiles;
    CREATE TABLE #DiasHabiles
    (
        Id INT IDENTITY(1, 1),
        IdFecha DATE
    );

    IF OBJECT_ID('tempdb..#TEMP_InstanciasEntregable', 'U') IS NOT NULL
        DROP TABLE #TEMP_InstanciasEntregable;
    CREATE TABLE #TEMP_InstanciasEntregable
    (
        Id INT,
        idInstanciaEntregable INT,
        FechasLimiteElaboracion DATETIME,
        FechasLimiteRevision DATETIME,
        FechasLimiteAprobacion DATETIME,
        FechaEnvioMensajeAtrasoRevision DATETIME,
        FechasLimiteEntregaReg DATETIME,
        FechaInicioElaboracion DATETIME
    );

    IF OBJECT_ID('tempdb..#DiasHabilesFrecuencia', 'U') IS NOT NULL
        DROP TABLE #DiasHabilesFrecuencia;
    CREATE TABLE #DiasHabilesFrecuencia
    (
        Id INT IDENTITY(1, 1),
        IdFecha DATE
    );

    IF OBJECT_ID('tempdb..#FechasCalcEntregaRegulador', 'U') IS NOT NULL
        DROP TABLE #FechasCalcEntregaRegulador;
    CREATE TABLE #FechasCalcEntregaRegulador
    (
        Id INT IDENTITY(1, 1),
        IdFecha DATE
    );


    DECLARE @IdContratoEntregable INT,
            @Frecuencia INT,
            @idEntregable INT,
            @DiasAprobacion INT,
            @DiasRevision INT,
            @DiasAlerta INT,
            @DiasElaboracion INT,
            @CountFF INT,
            @C INT = 1,
            @CantidadDias INT,
            @FechaInicialSig DATE,
            @CountDias INT,
            @EstadoId INT,
			@ExisteCountFechaLimiteAprob INT = 0,
			@ExisteCountFechaLimiteReg	INT = 0;
    ----------------------------------------------------------------------

    SELECT @EstadoId = A.EstadoID
    FROM dbo.EN_InstanciasEntregable IE --10003       Aprobado Internamente  
    JOIN dbo.EN_Actividad A ON IE.ActividadID = A.ActividadID
    WHERE IE.idInstanciaEntregable = @idInstanciaentregable;

    IF (@Activo = 1)
    BEGIN
        SELECT @Frecuencia = IdFrecuenciaEntregable
        FROM dbo.EN_Entregable
        WHERE IdEntregable = @idEntregable;

        SELECT @IdContratoEntregable = IE.IdContratoEntregable,
               @Frecuencia = E.IdFrecuenciaEntregable,
               @idEntregable = CE.IdEntregable,
               @DiasAprobacion = CE.DiasAprobacion,
               @DiasRevision = CE.DiasRevision,
               @DiasAlerta = CE.DiasAlerta,
               @DiasElaboracion = CE.DiasElaboracion
        FROM dbo.EN_InstanciasEntregable IE (NOLOCK)
        JOIN dbo.EN_ContratoEntregable CE (NOLOCK) ON IE.IdContratoEntregable = CE.IdContratoEntregable
        JOIN dbo.EN_Entregable E (NOLOCK) ON CE.IdEntregable = E.IdEntregable
        WHERE idInstanciaEntregable = @idInstanciaentregable;

        INSERT INTO #DiasHabilesFrecuencia (IdFecha)
        EXEC [SP_EN_GeneraInstanciasFechasLimite] @FechaLimiteint,
                                                  @idContrato,
                                                  10008, --Evento Único por que es una sola instancia
												  @IdContratoEntregable,
												  0,0;

		

        INSERT INTO #FechasCalcEntregaRegulador (IdFecha)
        EXEC [SP_EN_GeneraInstanciasFechasLimite] @FechaLimiteEntregaRegulador,
                                    @idContrato,
												  10008, --Evento Único por que es una sola instancia
												   @IdContratoEntregable,
												  0,1;

		declare @IdProceso int
		/*Identificar cual es el proceso*/
		select		@IdProceso									=			IPF.IdProceso 
		from 		EN_InstanciasEntregable						IE (NOLOCK)  
		inner JOIN	EN_InstanciasEntregables_InstanciaActividad IEIA (NOLOCK)		ON						IE.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
		inner JOIN	EN_InstanciasActividades					IA (NOLOCK)			ON						IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
		inner JOIN	EN_InstanciasProcesosFecha					IPF (NOLOCK)		ON						IA.IdInstanciasProcesos		=	IPF.IdInstanciasProcesos
		where		IE.IdInstanciaEntregable					=			@idInstanciaentregable
		and			IE.IdContratoEntregable						=			@IdContratoEntregable
		and			IPF.IdProceso								is not null
		
		--select @IdProceso
		--select * from #DiasHabilesFrecuencia
		--SELECT		IPF.IdProceso
		--		FROM		EN_InstanciasEntregable						IE
		--		JOIN		#DiasHabilesFrecuencia						FLA		ON			IE.IdContratoEntregable						=		@IdContratoEntregable
		--																		AND			IE.FechasLimiteAprobacion					=		FLA.IdFecha
		--																		AND			IE.idInstanciaEntregable					<>		@idInstanciaentregable
		--		inner join	EN_InstanciasEntregables_InstanciaActividad IEIA	ON			IE.idInstanciaEntregable					=		IEIA.idInstanciaEntregable
		--		inner JOIN	EN_InstanciasActividades					IA		ON			IEIA.idInstanciaActividad					=		IA.idInstanciaActividad
		--		inner JOIN	EN_InstanciasProcesosFecha					IPF		ON			IA.IdInstanciasProcesos						=		IPF.IdInstanciasProcesos
		--		where		IPF.IdProceso								=		@IdProceso

		if (/*Verificamos que el registro tenga un proceso ligado*/
					@IdProceso is not null		)
		begin	/*Si es asi, verificamos si existe otro proceso, que este sea uno distinto al que ya existe*/
			if not exists(
				SELECT		IPF.IdProceso
				FROM		EN_InstanciasEntregable						IE (NOLOCK)
				JOIN		#DiasHabilesFrecuencia						FLA		ON			IE.IdContratoEntregable						=		@IdContratoEntregable
																				AND			IE.FechasLimiteAprobacion					=		FLA.IdFecha
																				AND			IE.idInstanciaEntregable					<>		@idInstanciaentregable
				inner join	EN_InstanciasEntregables_InstanciaActividad IEIA (NOLOCK)	ON			IE.idInstanciaEntregable					=		IEIA.idInstanciaEntregable
				inner JOIN	EN_InstanciasActividades					IA (NOLOCK)		ON			IEIA.idInstanciaActividad					=		IA.idInstanciaActividad
				inner JOIN	EN_InstanciasProcesosFecha					IPF	(NOLOCK)	ON			IA.IdInstanciasProcesos						=		IPF.IdInstanciasProcesos
				where		IPF.IdProceso								=		@IdProceso
			)
			begin	/*De ser asi, le asignamos un 0 a las variales para permitirle guardar*/
					select	@ExisteCountFechaLimiteAprob	=	0,
							@ExisteCountFechaLimiteReg		=	0
			end
			--else
			--begin	/*De lo contrario indicamos que almenos existe un registro para posteriormente no dejarlo guardar*/
					
			--		select @ExisteCountFechaLimiteAprob		=	1,
			--				@ExisteCountFechaLimiteReg		=	1
			--end
		end
		else
		begin
			/*Si no, hacemos la validación actual*/
			--select [@IdProceso] = @IdProceso

			SELECT	@ExisteCountFechaLimiteAprob	=	COUNT(1)	
			FROM	EN_InstanciasEntregable	IE
		
			JOIN	
				#DiasHabilesFrecuencia	FLA
				ON	IE.IdContratoEntregable		=	@IdContratoEntregable
				AND IE.FechasLimiteAprobacion	=	FLA.IdFecha
				AND	IE.idInstanciaEntregable	<>	@idInstanciaentregable
		

			SELECT	@ExisteCountFechaLimiteReg	=	COUNT(1)	
			FROM	EN_InstanciasEntregable	IE
		
			JOIN	
				#FechasCalcEntregaRegulador	FLR
				ON	IE.IdContratoEntregable		=	@IdContratoEntregable
				AND	IE.FechaCalculadaEntregaReg	=	FLR.IdFecha
				AND	IE.idInstanciaEntregable	<>	@idInstanciaentregable
		end
	
	IF(@ExisteCountFechaLimiteAprob	=	0	AND	@ExisteCountFechaLimiteReg	=	0)
	BEGIN
		
        INSERT INTO #DiasCE (dias, tipo)
        VALUES (@DiasAprobacion, 'Aprobacion'),
               (@DiasRevision, 'revision'),
               --(@DiasElaboracion, 'Elaboracion'),
               (@DiasAlerta, 'Alerta');

        SELECT @CountFF = COUNT(*)
        FROM #DiasHabilesFrecuencia;

        WHILE (@C <= @CountFF) --1<=80
        BEGIN
            SET @CantidadDias = 1;
            INSERT INTO #TEMP_InstanciasEntregable (Id,
                                                    idInstanciaEntregable,
                                                    FechasLimiteElaboracion,
                                                    FechasLimiteRevision,
                                                    FechasLimiteAprobacion,
                                                    FechaEnvioMensajeAtrasoRevision,
                                                    FechasLimiteEntregaReg,
                             FechaInicioElaboracion)
            SELECT F.Id,
                   @idInstanciaentregable,
                   NULL,
                   NULL,
                   F.IdFecha,
                   NULL,
                   R.IdFecha,
                   NULL
            FROM #DiasHabilesFrecuencia F
            JOIN #FechasCalcEntregaRegulador R ON R.Id = F.Id
            WHERE F.Id = @C;

            SELECT @FechaInicialSig = FechasLimiteAprobacion
            FROM #TEMP_InstanciasEntregable
            WHERE Id = @C;

            SELECT @CountDias = --4
                COUNT(*)
            FROM #DiasCE;

            WHILE (@CantidadDias <= @CountDias) --1<=3
            BEGIN
                ------------------------------------------------
                TRUNCATE TABLE #DiasHabiles;
                INSERT INTO #DiasHabiles (IdFecha)
                SELECT IdFecha
                FROM dbo.AP_Calendario
                WHERE IdFecha < @FechaInicialSig
                      AND DATEADD(YEAR, -1, @FechaInicialSig) <= IdFecha
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
                LEFT JOIN #DiasCE CE ON CE.id = @CantidadDias
                LEFT JOIN #DiasHabiles DH ON @FechaInicialSig >= DH.IdFecha
                                             AND CE.dias = DH.Id
                LEFT JOIN dbo.AP_Calendario C2 ON @FechaInicialSig >= C2.IdFecha
                 AND C2.IdFecha > DATEADD(YEAR, -1, @FechaInicialSig)
        AND C2.FinDeSemana = 0
                                                  AND C2.DiaLaborable = 1
                WHERE TIE.Id = @C;

                IF ((SELECT tipo FROM #DiasCE WHERE id = @CantidadDias) = 'Alerta')
                BEGIN
                    UPDATE TIE
                    SET FechaInicioElaboracion = DH.IdFecha
                    FROM #TEMP_InstanciasEntregable TIE
                    LEFT JOIN #DiasHabiles DH ON @FechaInicialSig >= DH.IdFecha
                                                 AND @DiasElaboracion = DH.Id
                    LEFT JOIN dbo.AP_Calendario C2 ON @FechaInicialSig >= C2.IdFecha
                                                      AND C2.IdFecha > DATEADD(YEAR, -1, @FechaInicialSig)
                                                      AND C2.FinDeSemana = 0
                                                      AND C2.DiaLaborable = 1
                    WHERE TIE.Id = @C;
                END;


                SELECT @FechaInicialSig = DH.IdFecha
                FROM #TEMP_InstanciasEntregable TIE
               LEFT JOIN #DiasCE CE ON CE.id = @CantidadDias
                LEFT JOIN #DiasHabiles DH ON @FechaInicialSig >= DH.IdFecha
                                             AND CE.dias = DH.Id
                LEFT JOIN dbo.AP_Calendario C2 ON @FechaInicialSig >= C2.IdFecha
                                                  AND C2.IdFecha > DATEADD(YEAR, -1, @FechaInicialSig)
                                                  AND C2.FinDeSemana = 0
                                                  AND C2.DiaLaborable = 1
                WHERE TIE.Id = @C;


                SET @CantidadDias = @CantidadDias + 1;
            END;
            SET @C = @C + 1;
        END;

        UPDATE ie
        SET FechasLimiteElaboracion = te.FechasLimiteElaboracion,
            FechasLimiteRevision = te.FechasLimiteRevision,
            FechasLimiteAprobacion = te.FechasLimiteAprobacion,
            FechaEnvioMensajeAtrasoRevision = te.FechaEnvioMensajeAtrasoRevision,
            ContieneAjusteFechas = 1,
            ModificadoEn = GETDATE(),
            ModificadoPor = @idUsuario,
            FechaCalculadaEntregaReg = te.FechasLimiteEntregaReg,
            FechaInicioElaboracion = te.FechaInicioElaboracion,
            ie.Activo = @Activo
        FROM #TEMP_InstanciasEntregable te
        JOIN dbo.EN_InstanciasEntregable ie ON te.idInstanciaEntregable = ie.idInstanciaEntregable
        WHERE ie.idInstanciaEntregable = @idInstanciaentregable;


        IF @@ERROR <> 0
        BEGIN
            SELECT CAST(@@ERROR AS NVARCHAR(8)) AS error;
        END;
        ELSE
        BEGIN
            SELECT '' AS error;
        END;
	END
	ELSE
	BEGIN
		SELECT	
		CASE 
		WHEN @ExisteCountFechaLimiteAprob	>	0	AND	@ExisteCountFechaLimiteReg	>	0
		THEN	'Esta obligación ya contiene una programación con la misma fecha de entrega interna y fecha de entrega regulador'	
		WHEN @ExisteCountFechaLimiteAprob	>	0	AND	@ExisteCountFechaLimiteReg	=	0
		THEN	'Esta obligación ya contiene una programación con la misma fecha de entrega interna'	
		WHEN @ExisteCountFechaLimiteAprob	=	0	AND	@ExisteCountFechaLimiteReg	>	0
		THEN	'Esta obligación ya contiene una programación con la misma fecha de entrega regulador'	
		END AS error;


	END
    END;
    ELSE IF (@Activo = 0)
    BEGIN
        IF (@EstadoId <> 10003)
        BEGIN
            IF (@MotivoDesactivar <> '')
            BEGIN
                UPDATE EN_InstanciasEntregable
                SET Activo = 0
                WHERE idInstanciaEntregable = @idInstanciaentregable;
                DECLARE @idVersion INT = 0;

               
                SELECT @idVersion = (ISNULL(MAX(IdLineaTiempo), 0) + 1)
                FROM dbo.EN_HistorialAprobacionesLineaTiempo;

                INSERT INTO dbo.EN_HistorialAprobacionesLineaTiempo (IdLineaTiempo,
                                                                     idInstanciaEntregable,
                                                                     idContrato,
																	Comentario,
																	Rechazado,
																	idTipoOperacion,
                                                                     CreadoPor,
                                                                     CreadoEn,
                                                                     ModificadoPor,
                                                                     ModificadoEn,
                                                                     Activo,
                                                                     ActualizadoByApp,
                                                                     URLRepositorio,
                                                                     ContieneURLRepositorio)
                VALUES (@idVersion,             -- IdLineaTiempo - int
                        @idInstanciaentregable, -- idInstanciaEntregable - int
       @idContrato,            -- idContrato - int
                        @MotivoDesactivar,      -- Comentario - nvarchar(250)
                        0,                      -- Rechazado - bit
                        6,                      -- idTipoOperacion - int
                        @idUsuario,             -- CreadoPor - int
                        GETDATE(),              -- CreadoEn - datetime
                        @idUsuario,             -- ModificadoPor - int
                        GETDATE(),              -- ModificadoEn - datetime
                        1,                      -- Activo - bit
                        0,                      -- ActualizadoByApp - bit
                        '-',                    -- URLRepositorio - varchar(1500)
                        0                       -- ContieneURLRepositorio - bit
                    );

                IF @@ERROR <> 0
                BEGIN
                    SELECT CAST(@@ERROR AS NVARCHAR(8)) AS error;
                END;
                ELSE
                BEGIN
                    SELECT '' AS error;
                END;
            END;
            ELSE
            BEGIN
                SELECT 'Para desactivar una fecha, ingres un motivo.' AS error;
            END;
        END;
        ELSE
        BEGIN
            SELECT 'No puede desactivar un entregable que ya esta aprobado internamente.' AS error;
        END;
    END;



END;