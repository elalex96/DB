---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:    Reyna Olvera
-- Create date: 20181023
-- Description:  Guarda Procesos EntregablesIntancias
-- =============================================
-- Author:    LUIS DAVID
-- Create date: 20/10/2022
-- Description:  Se recibe como parámetro la etapa para crear el proceso
-- =============================================
CREATE PROCEDURE [dbo].[sp_GeneraFechasProcesosGuarda] --3,10061,1,'2020-03-27',12778,'CALCULO PROCESO PRUEBA',0,0
@idContrato int,
@idUsuario int,
@FechaSeleccionada bit, -- 1=Inicial 0=final
@Fecha date,
@idProceso int,
@DescripcionProcesoCalculo nvarchar(150),
@idInstanciaProcesoExistente int,
@IdInstalacion int,
@IdEtapa int
AS  
BEGIN
  SET NOCOUNT ON;

  CREATE TABLE #ActividadesGuarda (
    IdProceso int,
    DescripcionProceso varchar(500),
    IdContrato int,
    Orden int,
    IdActividad int,
    NombreActividad varchar(500),
    Dias int,
    DiasNaturales bit,
    FechaInicial date,
    FechaLimite date,
    IdActividadPredecesora int,
    IdActividadSucesora int
  );

  CREATE TABLE #ActividadesGuardaSinEntregable (
    IdProceso int,
    DescripcionProceso varchar(500),
    IdContrato int,
    Orden int,
    IdActividad int,
    NombreActividad varchar(500),
    Dias int,
    DiasNaturales bit,
    FechaInicial date,
    FechaLimite date,
    IdActividadPredecesora int,
    IdActividadSucesora int
  );

  CREATE TABLE #EN_InstanciasActividadesT (
    IdInstanciaActividad int,
    IdInstanciasProcesos int,
    IdActividad int,
    FechaActividad date
  );

  CREATE TABLE #EN_InstanciasEntregables_InstanciaActividad (
    idInstanciaEntregable int,
    idInstanciaActividad int
  );

  CREATE TABLE #FechasInicialFinalProceso (
    IdInstanciasProcesos int,
    FechaInicioProceso date,
    FechaFinProceso date
  );

  DECLARE @IsProcesoEvento int,
          @idProcesoInstancia int,
          @IdInstanciasProcesosCount int,
          @CountSinEntregables int,
          @CountActividadesT int,
          @countAC int = 0,
          @TieneInstalacion int,
          @NombreProceso varchar(5000),
          @Descripcion varchar(5000),
          @IdProcesoTemp int,
          @NombreInstalacion varchar(500),
          @count1 int,
          @count2 int,
          @IsSerie int;

  SELECT @IsProcesoEvento = IsProcesoEvento
  FROM dbo.EN_Procesos
  WHERE IdProceso = @idProceso;

  IF (@DescripcionProcesoCalculo <> '' OR @IsProcesoEvento = 0)
  BEGIN
    SELECT @IsSerie = ISNULL(IsSerie, 1)
    FROM dbo.EN_Procesos
    WHERE IdProceso = @idProceso; -- SI ESTA NULL SE TOMA COMO PROCESO LINEAL

    IF (@IsProcesoEvento = 0 AND @IdInstalacion = 0)
    BEGIN
      SELECT @IdInstalacion	=	I.IdInstalacion
      FROM 
		dbo.CO_Instalacion	I
      JOIN 
		dbo.CO_Contrato	C
        ON	I.IdAreaContractual	=	C.IdAreaContractual
        AND	I.EsBolsa	=	1
        AND	C.IdContrato	=	@idContrato;
    END;

    --CHECA LA INSTALACIÓN
    SELECT	@TieneInstalacion	=	COUNT(1)-- 1 ES PROCESO PARA COPIAR 
    FROM	
		dbo.EN_Procesos
    WHERE	IdProceso	=	@idProceso
		AND	IdInstalacion	IS	NULL;


    SELECT	@NombreProceso	=	NombreProceso,
			@Descripcion	=	Descripcion
    FROM	
		dbo.EN_Procesos
    WHERE	IdProceso	=	@idProceso
    AND	IdInstalacion	IS	NULL;


    SELECT	@count2	=	COUNT(1) --SI HAY PROCESOS CON ESTA INSTALACIÓN
    FROM	
		dbo.EN_Procesos	P
    WHERE	IdInstalacion	IS	NOT	NULL
    AND	NombreProceso	Like	@NombreProceso	+	'%' 
    AND	IdInstalacion	=	@IdInstalacion
	AND	P.Activo	=	1
	AND P.idTipoProceso	=	10000
	AND P.IsProcesoEvento	=	@IsProcesoEvento
	AND P.IsSerie	=	@IsSerie


    IF (@TieneInstalacion	=	1 -- ES PARA COPIAR
		AND	@IdInstalacion	<>	0
		AND	@count2	=	0) -- NO HAY PROCESO CON ESA INSTALACION
    BEGIN

      SELECT	@NombreInstalacion	=	' '	+	ISNULL(NombreInstalacion, '')
      FROM	
		dbo.CO_Instalacion
      WHERE	IdInstalacion	=	@IdInstalacion;

      SET	@NombreProceso	=	@NombreProceso	+	'-'	+	@NombreInstalacion;

      --SE GUARDA EL PROCESO
      EXEC	[sp_EN_GuardaProcesos]	@idContrato = @idContrato,
									@idUsuario = @idUsuario,
									@NombreProceso = @NombreProceso,
									@Descripcion = @Descripcion,
									@idTipoProceso = 10000,
									@IdInstalacion = @IdInstalacion,
									@IsProcesoEvento = @IsProcesoEvento,
									@isSerie = @IsSerie,
									@EtapaPozoId = @IdEtapa;


      SELECT	@IdProcesoTemp	=	ISNULL(P.IdProceso, 0)
      FROM	
		dbo.EN_Procesos	P
      JOIN 
		dbo.EN_ProcesosContrato	PC
        ON	P.IdProceso	=	PC.idProceso
        AND	pc.idContrato	=	@idContrato
      WHERE	NombreProceso	=	@NombreProceso
      AND	p.IdInstalacion	=	@IdInstalacion
	  AND P.idTipoProceso	=	10000
	  AND P.IsProcesoEvento	=	@IsProcesoEvento
	  AND P.IsSerie	=	@IsSerie;


      IF (@IdProcesoTemp	<>	0)
      BEGIN

        INSERT	INTO EN_Actividades	(NombreActividad, Dias, DiasNaturales, CreadoPor, CreadoEl, Activo, IdRegulador, IdActividadOriginal)
          SELECT	NombreActividad,
					@IdProcesoTemp,--Dias,
					DiasNaturales,
					@idUsuario,
					GETDATE(),
					1,
					IdRegulador,
					a.idActividad
          FROM	
			dbo.EN_ProcesosActividades PA
          JOIN	
			EN_Actividades	A
            ON	pa.idActividad	=	A.IdActividad
          WHERE	IdProceso	=	@idProceso
          AND	pa.Activo	=	1
          AND	a.Activo	=	1;


        INSERT	INTO	dbo.EN_ProcesosActividades	(IdProceso,idActividad,IdContrato,Orden,CreadoPor,CreadoEl,ModificadoPor, ModificadoEl,Activo,BitIniciaSigProceso)
          SELECT	@IdProcesoTemp,
					ao.idActividad,
					@idContrato,
					Orden,
					@idUsuario,
					GETDATE(),
					@idUsuario,
					GETDATE(),
					1,
					pa.BitIniciaSigProceso
          FROM	
		  dbo.EN_ProcesosActividades	PA
          JOIN 
			EN_Actividades	AO
			ON	PA.IdActividad	=	AO.IdActividadOriginal 
          WHERE	PA.IdProceso	=	@idProceso 
		  AND	AO.DIAS	=	@IdProcesoTemp
          AND	PA.Activo	=	1
          AND	AO.Activo	=	1
		  

        INSERT	INTO	EN_ActividadesEntregables	(IdActividad,IdEntregable,CreadoPor,CreadoEl,Activo)
          SELECT	AO.IdActividad,
					IdEntregable,
					@idUsuario,
					GETDATE(),
					1
          FROM 
			dbo.EN_ActividadesEntregables	AE
          JOIN 
			dbo.EN_ProcesosActividades	PA
            ON	AE.IdActividad	=	PA.IdActividad
          JOIN 
			EN_Actividades	AO
            ON	PA.IdActividad	=	AO.IdActividadOriginal
          WHERE	
			  PA.IdProceso	=	@idProceso
			  AND	AO.DIAS	=	@IdProcesoTemp
			  AND	PA.Activo	=	1
			  AND	AO.Activo	=	1;

		  
		  UPDATE	AO
		  SET	AO.DIAS	=	A.Dias
		  FROM	
			dbo.EN_ProcesosActividades	PA
          JOIN 
			EN_Actividades	AO
			ON	pa.IdActividad	=	AO.IdActividadOriginal
		  JOIN	
			EN_Actividades	A
			ON	AO.IdActividadOriginal	=	A.IdActividad
          WHERE	
			  PA.IdProceso	=	@idProceso
			  AND	AO.DIAS	=	@IdProcesoTemp
			  AND	PA.Activo	=	1
			  AND	AO.Activo	=	1;

        SET @idProceso = @IdProcesoTemp;

      END;
    END;

    IF	(@TieneInstalacion	=	1 --ES PARA COPIAR
		AND	@IdInstalacion	<>	0
		AND	@count2	>=	1   )   --HAY CON ESA INSTALACIÓN
    BEGIN

      SELECT	@NombreInstalacion	=	' '	+	ISNULL(NombreInstalacion, '')
      FROM 
		dbo.CO_Instalacion
      WHERE	IdInstalacion	=	@IdInstalacion;


      SET	@NombreProceso	=	@NombreProceso	+	'-'	+	@NombreInstalacion;


      SELECT	@IdProcesoTemp	=	ISNULL(p.IdProceso, 0)
      FROM
		dbo.EN_Procesos	P
      JOIN 
		dbo.EN_ProcesosContrato PC
        ON	P.IdProceso	=	PC.idProceso
        AND	PC.idContrato	=	@idContrato
      WHERE NombreProceso	=	@NombreProceso
      AND	P.IdInstalacion	=	@IdInstalacion
	  AND P.IsProcesoEvento	=	@IsProcesoEvento
	  AND P.IsSerie	=	@IsSerie;

      SET	@idProceso	=	@IdProcesoTemp;

    END;
    ----------------------------------------CALCULO---------------------------------------------------
    IF (@IsProcesoEvento	=	0)
    BEGIN
		EXEC	[sp_EN_CalculoProcesosFrecuencia]	@idContrato,@idUsuario,@idProceso,0;
    END;
    ELSE
    BEGIN
      --=========================================FECHAS==========================================================
      IF (@FechaSeleccionada = 1) --PARA CALCULO CON FECHA INICIAL
      BEGIN

        INSERT INTO #ActividadesGuarda	(IdProceso,DescripcionProceso,IdContrato,Orden,IdActividad,NombreActividad,Dias,DiasNaturales,FechaInicial,FechaLimite,IdActividadPredecesora,IdActividadSucesora)
        EXEC	sp_GeneraFechasProcesos	@idContrato,
										@idUsuario,
										@Fecha,
										@idProceso;

      END;
      ELSE
      IF (@FechaSeleccionada = 0) --PARA CALCULO CON FECHA FINAL
      BEGIN

        INSERT	INTO	#ActividadesGuarda	(IdProceso,DescripcionProceso,IdContrato,Orden,IdActividad,NombreActividad,Dias,DiasNaturales,FechaInicial,FechaLimite,IdActividadPredecesora,IdActividadSucesora)
        EXEC	sp_GeneraFechasProcesosConFechaFinal	@idContrato,
														@idUsuario,
														@Fecha,
														@idProceso;

      END;
      --=========================================================================================================


      SELECT	@IdInstanciasProcesosCount	=	COUNT(1)
      FROM	
		dbo.EN_InstanciasProcesosFecha
      WHERE	IdProceso	=	@idProceso
      AND	Fecha	=	@Fecha
      AND	FechaInicial	=	@FechaSeleccionada;


      IF (@IdInstanciasProcesosCount	=	0	AND	@idInstanciaProcesoExistente	=	0) --IF DE SI NO TIENE NINGUNA INATANCIA CON EL MISMO PROCESO, FECHA Y FECHA INICIAL
      BEGIN

        INSERT INTO #ActividadesGuardaSinEntregable (IdProceso,DescripcionProceso,IdContrato,Orden,IdActividad,NombreActividad,Dias,DiasNaturales,FechaInicial,FechaLimite,IdActividadPredecesora,IdActividadSucesora)
          SELECT	AE.IdProceso,
					AE.DescripcionProceso,
					AE.IdContrato,
					AE.Orden,
					AE.IdActividad,
					AE.NombreActividad,
					AE.Dias,
					AE.DiasNaturales,
					AE.FechaInicial,
					AE.FechaLimite,
					AE.IdActividadPredecesora,
					AE.IdActividadSucesora
          FROM	
			#ActividadesGuarda	AE
          LEFT	JOIN 
			dbo.EN_ActividadesEntregables	A
            ON	AE.IdActividad	=	A.IdActividad
          WHERE	A.IdActividad	IS	NULL;


        DELETE	
		FROM	
			#ActividadesGuarda
        WHERE	IdActividad	IN (SELECT	IdActividad	FROM	#ActividadesGuardaSinEntregable);


        SELECT	@countAC	=	COUNT(*)
        FROM
			#ActividadesGuarda A
        LEFT JOIN
			EN_ActividadesEntregables	AE
			ON	A.idActividad = AE.IdActividad

        LEFT JOIN
			EN_Entregable E
			ON	AE.IdEntregable = E.IdEntregable

        LEFT JOIN
			EN_ContratoEntregable CE
			ON	AE.IdEntregable	=	CE.IdEntregable
			AND	CE.IdContrato	=	@idContrato

        LEFT JOIN
			dbo.EN_Actividad AEl
			ON	AEl.IdContratoEntregable	=	CE.IdContratoEntregable
			AND	AEl.EstadoID	=	10000

        LEFT JOIN 
			dbo.EN_Actividad	AR
			ON	AR.IdContratoEntregable	=	CE.IdContratoEntregable
			AND	AR.EstadoID	=	10001

        LEFT JOIN 
			dbo.EN_Actividad	AA
			ON	AA.IdContratoEntregable	=	CE.IdContratoEntregable
			AND	AA.EstadoID	=	10002

        WHERE
			AE.IdEntregable IS NOT NULL
			AND (
				AA.ActividadID IS NULL
				OR AEl.ActividadID IS NULL
				OR AR.ActividadID IS NULL
				OR CE.DiasElaboracion IS NULL
				OR CE.DiasElaboracion = 0
				OR CE.DiasRevision IS NULL
				OR CE.DiasRevision = 0
				OR CE.DiasAprobacion IS NULL
				);--Verifica los responsables

        IF (@countAC	=	0)--Cantidad de entregables sin usuarios responsables o días asignados
        BEGIN

          INSERT	INTO EN_InstanciasProcesosFecha	(IdProceso,Descripcion,Fecha,FechaInicial,idContrato,CreadoPor,CreadoEl,Activo)
            SELECT	@idProceso,
					@DescripcionProcesoCalculo,
					@Fecha,
					@FechaSeleccionada,
					@idContrato,
					@idUsuario,
					GETDATE(),
					1;


          SET	@idProcesoInstancia	=	@@IDENTITY;

		  
          INSERT	INTO EN_InstanciasActividades	(IdInstanciasProcesos, IdActividad,FechaActividad,FechaInicioActividad,CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,Activo)--Actividades sin entregables
            (
			SELECT
				@idProcesoInstancia,
				IdActividad,
				FechaLimite,
				FechaInicial,
				@idUsuario,
				GETDATE(),
				@idUsuario,
				GETDATE(),
				1
            FROM	
				#ActividadesGuardaSinEntregable
			);


          IF ((SELECT	COUNT(1)	FROM #ActividadesGuarda)	>=	1) --Si tiene entregables, creara las instancias de los entregables
          BEGIN

            INSERT INTO EN_InstanciasActividades (IdInstanciasProcesos,IdActividad,FechaActividad,FechaInicioActividad,CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,Activo)
              (SELECT
					@idProcesoInstancia,
					IdActividad,
					FechaLimite,
					FechaInicial,
					@idUsuario,
					GETDATE(),
					@idUsuario,
					GETDATE(),
					1
              FROM 
				#ActividadesGuarda
			  );


            INSERT INTO EN_InstanciasEntregable (FechasLimiteElaboracion,FechasLimiteRevision,FechasLimiteAprobacion,FechaEnvioMensajeAtrasoRevision,idFrecuencua,IdContratoEntregable,ActividadID,CorreoEnviado,CreadoPor,CreadoEn,ModificadoPor,ModificadoEn,


Activo,FechaCalculadaEntregaReg,ContieneAjusteFechas,BitContieneAcuse)
              SELECT	NULL,
						NULL,
						FechaLimite,
						NULL,
						E.IdFrecuenciaEntregable,
						CE.IdContratoEntregable,
						ActividadID,
						0,
						@idUsuario,
						GETDATE(),
						@idUsuario,
						GETDATE(),
						1,
						FechaLimite,
						@idProcesoInstancia,
						0
              FROM 
				#ActividadesGuarda	A

              LEFT	JOIN 
					EN_ActividadesEntregables	AE
					ON	AE.IdActividad	=	A.IdActividad

              LEFT	JOIN 
					EN_ContratoEntregable	CE
					ON	AE.IdEntregable	=	CE.IdEntregable
					AND	CE.IdContrato	=	@idContrato

              LEFT	JOIN 
					EN_Entregable	E
					ON	CE.IdEntregable	=	E.IdEntregable

              LEFT	JOIN 
					EN_FrecuenciaEntregable	FE
					ON	E.IdFrecuenciaEntregable	=	FE.IdFrecuenciaEntregable

              LEFT	JOIN 
					EN_Actividad
					ON	EN_Actividad.IdContratoEntregable	=	CE.IdContratoEntregable
					AND	EstadoID	=	10000

              WHERE	
					CE.IdContratoEntregable	IS	NOT	NULL
					AND	CE.DiasRevision	IS	NOT	NULL
					AND	CE.DiasElaboracion	IS	NOT	NULL;



            UPDATE IE
				SET	FechasLimiteRevision	=	Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteAprobacion,CE.DiasAprobacion)
            FROM 
				dbo.EN_InstanciasEntregable	IE
            JOIN	
				EN_ContratoEntregable	CE
				ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
				AND	IdContrato	=	@idContrato

            JOIN	
				dbo.EN_Actividad	A
				ON	IE.ActividadID	=	A.ActividadID
            WHERE
				A.EstadoID = 10000
				AND FechasLimiteRevision IS NULL
				AND IE.ContieneAjusteFechas = @idProcesoInstancia


            UPDATE IE
				SET	FechasLimiteElaboracion	=	Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteRevision,CE.DiasRevision)
            FROM	
				dbo.EN_InstanciasEntregable	IE
            JOIN	
				EN_ContratoEntregable	CE
				ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
				AND	IdContrato	=	@idContrato

            JOIN 
				dbo.EN_Actividad	A
				ON	IE.ActividadID	=	A.ActividadID

            WHERE 
				A.EstadoID	=	10000
				AND	FechasLimiteElaboracion	IS	NULL
				AND	IE.ContieneAjusteFechas	=	@idProcesoInstancia


            UPDATE IE
            SET	IE.FechaInicioElaboracion	=	Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteElaboracion,CE.DiasElaboracion),
                IE.FechaEnvioMensajeAtrasoRevision	=	Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteElaboracion,CE.DiasAlerta)
            FROM	
				dbo.EN_InstanciasEntregable	IE
            JOIN	
				EN_ContratoEntregable	CE
				ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
				AND IdContrato	=	@idContrato

            JOIN 
				dbo.EN_Actividad	A
				ON	IE.ActividadID	=	A.ActividadID

            WHERE 
				A.EstadoID	=	10000
				AND	FechaInicioElaboracion	IS	NULL
				OR	FechaEnvioMensajeAtrasoRevision	IS	NULL
				AND	IE.ContieneAjusteFechas	=	@idProcesoInstancia


            INSERT INTO EN_InstanciasEntregables_InstanciaActividad (idInstanciaEntregable,idInstanciaActividad,CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,Activo)
              (
			  SELECT
					idInstanciaEntregable,
					idInstanciaActividad,
					@idUsuario,
					GETDATE(),
					@idUsuario,
					GETDATE(),
					1
              FROM 
				#ActividadesGuarda	A
              JOIN 
				EN_ActividadesEntregables	AE
                ON	A.IdActividad	=	AE.IdActividad

              JOIN 
				EN_ContratoEntregable	CE
                ON	AE.IdEntregable	=	CE.IdEntregable
                AND	CE.IdContrato	=	@idContrato

              JOIN 
				EN_Entregable	E
                ON	CE.IdEntregable	=	E.IdEntregable

              JOIN 
				EN_FrecuenciaEntregable	FE
                ON	E.IdFrecuenciaEntregable	=	FE.IdFrecuenciaEntregable

              JOIN 
				EN_InstanciasEntregable	IE
				ON	IE.FechasLimiteAprobacion	=	A.FechaLimite
                AND	CE.IdContratoEntregable	=	IE.IdContratoEntregable
                AND	IE.ContieneAjusteFechas	=	@idProcesoInstancia

              JOIN 
				dbo.EN_Actividad	EA
                ON	EA.ActividadID	=	IE.ActividadID

              JOIN 
				EN_InstanciasActividades	IA
                ON	IA.IdActividad	=	A.IdActividad
                AND	IdInstanciasProcesos	=	@idProcesoInstancia
                AND	EA.EstadoID	=	10000);


            UPDATE EN_InstanciasEntregable
				SET ContieneAjusteFechas = 0
            WHERE 
				ContieneAjusteFechas = @idProcesoInstancia

          END

          INSERT	INTO	#FechasInicialFinalProceso	(IdInstanciasProcesos, FechaInicioProceso, FechaFinProceso)
            SELECT	@idProcesoInstancia,
					MIN(IA.FechaInicioActividad),
					MAX(IA.FechaActividad)
            FROM	
				dbo.EN_InstanciasActividades	IA
            JOIN	
				dbo.EN_InstanciasProcesosFecha	IPF
				ON IA.IdInstanciasProcesos	=	@idProcesoInstancia
				AND IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos; --Para modificar la fecha inicio y fin calculados de la isntancia proceso


          UPDATE IPF
          SET FechaInicioProceso	=	FIP.FechaInicioProceso,
              FechaFinProceso	=	FIP.FechaFinProceso
          FROM 
			dbo.EN_InstanciasProcesosFecha	IPF
          JOIN 
			#FechasInicialFinalProceso	FIP
            ON IPF.IdInstanciasProcesos	=	FIP.IdInstanciasProcesos;


        END;
        ELSE
        BEGIN

          SELECT 'No puede guardar el proceso, ya que contiene entregables sin usuarios responsables o sin días asignados, verifique el recuadro con titulo:"Entregables sin responsables asignados".' AS Error;

        END;
      END; --CUANDO NO MANDA UN IDPROCESO EXISTENTE
      ELSE
      BEGIN
        IF (@IdInstanciasProcesosCount > 0	AND @idInstanciaProcesoExistente = 0) ---Si existe uno, debe de buscar el idProcesoExistente en el grid que les mostrara en la pantalla
        BEGIN

          SELECT 'Ya existe un proceso con la misma fecha seleccionada, favor de seleccionar el correspondiente en el recuedro de la parte superior' AS Error;

        END;

        IF (@idInstanciaProcesoExistente > 0) --Si manda un procesoExistente
        BEGIN

          SELECT	@IdInstanciasProcesosCount	=	COUNT(1) ---confirma la existencia en el contrato, el proceso conrrecto y el idproceso Existente coincidan
          FROM 
			dbo.EN_InstanciasProcesosFecha
          WHERE 
			IdProceso	=	@idProceso
			AND IdInstanciasProcesos	=	@idInstanciaProcesoExistente
			AND idContrato	=	@idContrato;

          IF (@IdInstanciasProcesosCount > 0) ---Si coincide
          BEGIN

            INSERT INTO #EN_InstanciasActividadesT (IdInstanciaActividad,IdInstanciasProcesos,IdActividad,FechaActividad)--Busca actividades
              (SELECT
				idInstanciaActividad,
                IdInstanciasProcesos,
                IdActividad,
                FechaActividad
              FROM 
				dbo.EN_InstanciasActividades
              WHERE
				IdInstanciasProcesos	=	@idInstanciaProcesoExistente);

            INSERT INTO #EN_InstanciasEntregables_InstanciaActividad (idInstanciaEntregable,idInstanciaActividad)
              (SELECT
                idInstanciaEntregable,
                idInstanciaActividad
              FROM 
				dbo.EN_InstanciasEntregables_InstanciaActividad
              WHERE
				idInstanciaActividad IN (SELECT	IdInstanciaActividad	FROM	#EN_InstanciasActividadesT)); --Busca las instancias

            UPDATE	IE
            SET	IE.FechasLimiteAprobacion	=	AGT.FechaLimite,
                IE.FechaCalculadaEntregaReg	=	AGT.FechaLimite
            FROM 
				dbo.EN_InstanciasEntregable	IE
				 
            JOIN 
				#EN_InstanciasEntregables_InstanciaActividad	IET
				ON	IET.idInstanciaEntregable	=	IE.idInstanciaEntregable

            JOIN 
				dbo.EN_InstanciasActividades	IA
				ON IA.idInstanciaActividad	=	IET.idInstanciaActividad

            JOIN 
				dbo.EN_Actividades	ACT
				ON	ACT.IdActividad	=	IA.IdActividad

            JOIN 
				dbo.EN_ActividadesEntregables	AE
				ON	AE.IdActividad	=	ACT.IdActividad

            JOIN 
				EN_ContratoEntregable	CE
				ON IE.IdContratoEntregable	=	CE.IdContratoEntregable
				AND IdContrato	=	@idContrato
				AND AE.IdEntregable	=	CE.IdEntregable

            JOIN
				dbo.EN_Actividad	A
				ON	A.ActividadID	=	IE.ActividadID

            JOIN 
				AP_Calendario	C
              ON C.IdFecha	=	IE.FechasLimiteAprobacion

            LEFT	JOIN 
				#ActividadesGuarda	AGT
				ON	AGT.IdActividad	=	IA.IdActividad

            WHERE	
				A.EstadoID	=	10000;


            UPDATE IE
            SET FechasLimiteRevision = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteAprobacion,CE.DiasAprobacion)
            --SELECT *
            FROM 
				dbo.EN_InstanciasEntregable IE ---Busca las 

            JOIN 
				#EN_InstanciasEntregables_InstanciaActividad	IET
				 ON	IE.idInstanciaEntregable	=	IET.idInstanciaEntregable

            JOIN 
				dbo.EN_InstanciasActividades	IA
				ON	IET.idInstanciaActividad	=	IA.idInstanciaActividad

            JOIN 
				dbo.EN_Actividades	ACT
				ON	IA.IdActividad	=	ACT.IdActividad

            JOIN 
				dbo.EN_ActividadesEntregables	AE
				ON	ACT.IdActividad	=	AE.IdActividad

            JOIN 
				EN_ContratoEntregable	CE
				ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
				AND	IdContrato	=	@idContrato
				AND	AE.IdEntregable	=	CE.IdEntregable

            JOIN 
				dbo.EN_Actividad	A
				ON	IE.ActividadID	=	A.ActividadID

            JOIN 
				AP_Calendario	C
				ON	IE.FechasLimiteAprobacion	=	C.IdFecha

            LEFT JOIN 
				#ActividadesGuarda	AGT
				ON IA.IdActividad	=	AGT.IdActividad

            WHERE	
				A.EstadoID	=	10000;



            UPDATE IE
				SET FechasLimiteElaboracion = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteRevision,CE.DiasRevision)
            FROM 
			dbo.EN_InstanciasEntregable	IE 
            JOIN 
				#EN_InstanciasEntregables_InstanciaActividad	IET
				ON	IE.idInstanciaEntregable	=	IET.idInstanciaEntregable

            JOIN 
				dbo.EN_InstanciasActividades	IA
				ON IET.idInstanciaActividad	=	IA.idInstanciaActividad

            JOIN 
				dbo.EN_Actividades	ACT
				ON	IA.IdActividad	=	ACT.IdActividad

            JOIN 
				dbo.EN_ActividadesEntregables	AE
				ON	ACT.IdActividad	=	AE.IdActividad

            JOIN 
				EN_ContratoEntregable	CE
				ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
				AND	IdContrato	=	@idContrato
				AND	AE.IdEntregable	=	CE.IdEntregable

            JOIN 
				dbo.EN_Actividad	A
				ON	IE.ActividadID	=	A.ActividadID

            JOIN 
				AP_Calendario	C
				ON	IE.FechasLimiteAprobacion	=	C.IdFecha

            LEFT JOIN 
				#ActividadesGuarda	AGT
				ON	IA.IdActividad	=	AGT.IdActividad

            WHERE 
				A.EstadoID = 10000;


            UPDATE IE
				SET FechaInicioElaboracion = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteElaboracion,CE.DiasElaboracion),
                FechaEnvioMensajeAtrasoRevision = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteElaboracion,CE.DiasAlerta)
            FROM 
				dbo.EN_InstanciasEntregable	IE 

            JOIN 
				#EN_InstanciasEntregables_InstanciaActividad	IET
				ON IE.idInstanciaEntregable	=	IET.idInstanciaEntregable

            JOIN 
				dbo.EN_InstanciasActividades	IA
				ON	IET.idInstanciaActividad	=	IA.idInstanciaActividad

            JOIN 
				dbo.EN_Actividades	ACT
				ON	IA.IdActividad = ACT.IdActividad

            JOIN 
				dbo.EN_ActividadesEntregables	AE
				ON	ACT.IdActividad	=	AE.IdActividad

            JOIN 
				EN_ContratoEntregable	CE
				ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
				AND	IdContrato	=	@idContrato
				AND	AE.IdEntregable	=	CE.IdEntregable

            JOIN 
				dbo.EN_Actividad	A
				ON IE.ActividadID = A.ActividadID

            LEFT JOIN 
				#ActividadesGuarda	AGT
				ON	IA.IdActividad	=	AGT.IdActividad

            WHERE	
				A.EstadoID	=	10000;


            UPDATE IA
				SET IA.FechaActividad = AGT.FechaLimite,
					IA.FechaInicioActividad = FechaInicial
            FROM
			dbo.EN_InstanciasActividades	IA
            JOIN
				#EN_InstanciasActividadesT	IAT
				ON	IAT.IdInstanciaActividad	=	IA.idInstanciaActividad
            JOIN 
				#ActividadesGuarda	AGT
				ON	AGT.IdActividad	=	IAT.IdActividad
				AND	IAT.IdInstanciasProcesos	=	IA.IdInstanciasProcesos;


            INSERT INTO #FechasInicialFinalProceso (IdInstanciasProcesos, FechaInicioProceso, FechaFinProceso)
              SELECT	@idInstanciaProcesoExistente,
						MIN(IA.FechaInicioActividad),
						MAX(IA.FechaActividad)
              FROM	
				dbo.EN_InstanciasActividades	IA
              JOIN	
				dbo.EN_InstanciasProcesosFecha	IPF
				ON	IA.IdInstanciasProcesos	=	@idInstanciaProcesoExistente
				AND IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos; --Para modificar la fecha inicio y fin calculados de la isntancia proceso


            UPDATE IPF
				SET Descripcion = @DescripcionProcesoCalculo,
					Fecha = @Fecha,
					idContrato = @idContrato,
					ModificadoPor = @idUsuario,
					ModificadoEl = GETDATE(),
					FechaInicial = @FechaSeleccionada,
					Activo = 1,
					FechaInicioProceso = FIP.FechaInicioProceso,
					FechaFinProceso = FIP.FechaFinProceso
            FROM
				dbo.EN_InstanciasProcesosFecha	IPF
            JOIN 
				#FechasInicialFinalProceso	FIP
				ON	IPF.IdInstanciasProcesos	=	FIP.IdInstanciasProcesos;

          END;
          ELSE
          BEGIN
            SELECT 'Problemas con el proceso, favor de enviar correo a soporte@adinco.mx' AS Error;
          END;
        END;
      END;
    END;
  END
  ELSE
  BEGIN
    SELECT 'Debe ingresar un nombre para la programación de fechas' AS Error;
  END

END;