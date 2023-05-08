CREATE PROCEDURE sp_GuardaSimulaCalculoFinalMacro --12147,3,10061,'2019-09-25','prueba',11795,0
    @IdMacroproceso int,
	@idContrato int,
	@idUsuario int,
	@FechaSeleccionada date,
	@DescripcionCalculo varchar(max),
	@idinstalacion int  ,
	@guardar int,
	@idActividadComienza INT
	AS
BEGIN

IF OBJECT_ID('tempdb..#ProcesosActividadesMacro') IS NOT NULL 
BEGIN 
    DROP TABLE #ProcesosActividadesMacro 
END
IF OBJECT_ID('tempdb..##OrdenProcesos') IS NOT NULL 
BEGIN 
    DROP TABLE ##OrdenProcesos 
END
IF OBJECT_ID('tempdb..##FechasGenerados') IS NOT NULL 
BEGIN 
    DROP TABLE ##FechasGenerados 
END

CREATE TABLE #ProcesosActividadesMacro (
  idproceso int,
  idactividad int,
  nombreproceso varchar(max),
  nombreactividad varchar(max),
  dias int,
  diasnaturales varchar(max),
  bitiniciaproceso int,
  orden int,
  ordenprocesos int,
  idinstalacion int,
  idInstanciaProceso int
);

CREATE TABLE ##OrdenProcesos (
  id int IDENTITY (1, 1),
  idMacroproceso int,
  ordenprocesos int,
  idproceso int,
  nombreproceso varchar(max),
  idinstalacion int,
  BitGenerado bit,
  idInstanciaProceso int
);

CREATE TABLE ##FechasGenerados (
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
  IdActividadSucesora int,
  idInstanciaProceso int
);

DECLARE @IdProceso int,
        @FechaCalculo date,
        @OrdenMax int,
        @OrdenProceso int,
        @id int,
        @DesencadenaProceso int,
        @DescripcionProcesoCalculo varchar(max),
        @TieneProcesosGenerados int,
        @idInstanciaProceso int,
        @IdActividad int,
        @OrdenActividad int,
        @FechaCalculoAdelante date,@IdActividadSucesora INT;

SELECT @TieneProcesosGenerados =
  COUNT(1)
FROM EN_MacroProcesosRelacion MPR
JOIN EN_Procesos P
  ON MPR.idProcesoHijo = P.IdProceso
  AND P.IdInstalacion = @idinstalacion
JOIN EN_ProcesosActividades PA
  ON P.IdProceso = PA.IdProceso
JOIN EN_Actividades A
  ON PA.idActividad = A.IdActividad
WHERE idMacroProceso = @IdMacroproceso
	   AND PA.Activo = 1
	   AND PA.Orden	>= 0

IF (@TieneProcesosGenerados = 0)
BEGIN
  INSERT INTO #ProcesosActividadesMacro (idproceso,
  idactividad,
  nombreproceso,
  nombreactividad,
  dias,
  diasnaturales,
  bitiniciaproceso,
  orden,
  ordenprocesos)

  EXEC [Sp_EN_ExtraeActividadesMacroproceso] @idContrato,
                                             @idUsuario,
                                             @IdMacroproceso;--modificar para extraer el nombre del proceso sin orden
  UPDATE #ProcesosActividadesMacro
  SET idInstanciaProceso = 0;

  UPDATE #ProcesosActividadesMacro
  SET idinstalacion = @idinstalacion
END
ELSE
BEGIN
  INSERT INTO #ProcesosActividadesMacro (idproceso,
  idactividad,
  nombreproceso,
  nombreactividad,
  dias,
  diasnaturales,
  bitiniciaproceso,
  orden,
  ordenprocesos,
  idinstalacion,
  idInstanciaProceso)
    SELECT P.idproceso,
           PA.idactividad,
           nombreproceso,
           nombreactividad,
           dias,
           diasnaturales,
           PA.BitIniciaSigProceso,
           pa.orden,
           mpr.Orden,
           idinstalacion,
           ISNULL(IPF.IdInstanciasProcesos, 0)
    FROM EN_MacroProcesosRelacion MPR
    JOIN EN_Procesos P
      ON MPR.idProcesoHijo = P.IdProceso
      AND P.IdInstalacion = @idinstalacion
    JOIN EN_InstanciasProcesosFecha IPF
      ON P.IdProceso = IPF.IdProceso
    JOIN EN_ProcesosActividades PA
      ON P.IdProceso = PA.IdProceso
    JOIN EN_Actividades A
      ON PA.idActividad = A.IdActividad
    WHERE idMacroProceso = @IdMacroproceso
		  AND PA.Activo = 1
		  AND PA.Orden	>= 0
END

INSERT INTO ##OrdenProcesos (ordenprocesos, idMacroproceso, idproceso, nombreproceso, idinstalacion, idInstanciaProceso)
  SELECT ordenprocesos,
         @IdMacroproceso,
         idproceso,
         nombreproceso,
         idinstalacion,
         idInstanciaProceso
  FROM #ProcesosActividadesMacro -- obtengo el orden Asc si es fecha inicial y desc si es 
  GROUP BY ordenprocesos,
           idproceso,
           nombreproceso,
           idinstalacion,
           idInstanciaProceso				--Se obntienen los datos para ejecutar la info
  ORDER BY ordenprocesos DESC

SELECT @OrdenMax =
  MAX(ordenprocesos)
FROM ##OrdenProcesos

WHILE (SELECT COUNT(1)FROM ##OrdenProcesos WHERE BitGenerado IS NULL)> 0
BEGIN
SET @DesencadenaProceso=0;

  SELECT TOP 1 @idProceso =
               idProceso,
               @OrdenProceso =
               ordenprocesos,
               @id =
               id,
               @DescripcionProcesoCalculo =
               nombreproceso,
               @IdInstalacion =
               idinstalacion,
               @idInstanciaProceso =
               ISNULL(idInstanciaProceso, 0)
  FROM ##OrdenProcesos
  WHERE BitGenerado IS NULL
  ORDER BY ordenprocesos DESC;

  SELECT @OrdenActividad = MAX(orden)
  FROM #ProcesosActividadesMacro
  WHERE ordenprocesos = @OrdenProceso

  SELECT @IdActividad = idactividad
  FROM #ProcesosActividadesMacro
  WHERE ordenprocesos = @OrdenProceso
  AND orden = @OrdenActividad;


  IF (@OrdenMax = @OrdenProceso)
  BEGIN
    --Select 'entro al if'
    SET @FechaCalculo = @FechaSeleccionada;--FechaIngresada por el usuario

    INSERT INTO ##FechasGenerados (idproceso, DescripcionProceso, idContrato, orden, idactividad, nombreactividad, dias, diasnaturales, FechaInicial, FechaLimite, idActividadPredecesora, idActividadSucesora)
    EXEC [sp_CalculoFechasProcesosPorActividadFechaFinal]--3,	10061,	'2019-09-07',	12488,	11169
    @idContrato,
    @idUsuario,
    @FechaCalculo,
    @idProceso,
    @IdActividad

  END
  ELSE
  BEGIN
    --DECLARE @DesencadenaProceso INT, @IdActividad INT;
    SELECT @DesencadenaProceso = COUNT(1),
	@IdActividad = idactividad,@OrdenActividad=PAM.orden
    FROM #ProcesosActividadesMacro PAM
    JOIN ##OrdenProcesos OP
      ON PAM.idproceso = OP.idproceso
    WHERE OP.ID = @id
    AND bitiniciaproceso = 1
    GROUP BY idactividad,PAM.orden

  SELECT @IdActividadSucesora = idactividad
   FROM #ProcesosActividadesMacro PAM
    JOIN ##OrdenProcesos OP
      ON PAM.idproceso = OP.idproceso AND PAM.orden=(@OrdenActividad+1)
    WHERE OP.ID = @id

    IF (@DesencadenaProceso >= 1)--1	11165
    BEGIN
     
      SELECT TOP 1 @FechaCalculo = DATEADD(DAY, -1, MIN(FechaInicial)),
                   @FechaCalculoAdelante = MIN(FechaInicial)
      FROM ##FechasGenerados  FG
	  JOIN ##OrdenProcesos OP
      ON FG.idproceso = OP.idproceso
    WHERE OP.ID=@id-1 ;

     INSERT INTO ##FechasGenerados (idproceso, DescripcionProceso, idContrato, orden, idactividad, nombreactividad, dias, diasnaturales, FechaInicial, FechaLimite, idActividadPredecesora, idActividadSucesora)
      EXEC sp_CalculoFechasProcesosPorActividadFechaFinal 
											    @idContrato,
                                                @idUsuario,
                                                @FechaCalculo,
                                                @idProceso,
                                                @IdActividad--,'FECHA FINAL';

      INSERT INTO ##FechasGenerados (idproceso, DescripcionProceso, idContrato, orden, idactividad, nombreactividad, dias, diasnaturales, FechaInicial, FechaLimite, idActividadPredecesora, idActividadSucesora)
      EXEC sp_CalculoFechasProcesosPorActividadFechaInicio  
													       @idContrato,
                                                           @idUsuario,
                                                           @FechaCalculoAdelante,
                                                           @idProceso,
                                                           @IdActividadSucesora--,'FECHA INICIAL';

    END
    ELSE
    BEGIN
      SELECT TOP 1 @FechaCalculo =
        DATEADD(DAY, -1, MIN(FechaInicial))
     FROM ##FechasGenerados  FG
	  JOIN ##OrdenProcesos OP
      ON FG.idproceso = OP.idproceso
    WHERE OP.ID=@id-1 ;

      INSERT INTO ##FechasGenerados (idproceso, DescripcionProceso, idContrato, orden, idactividad, nombreactividad, dias, diasnaturales, FechaInicial, FechaLimite, idActividadPredecesora, idActividadSucesora)
      EXEC sp_CalculoFechasProcesosPorActividadFechaFinal @idContrato,
														  @idUsuario,
														  @FechaCalculo,
														  @idProceso,
														  @IdActividad


    END
  END

  UPDATE ##OrdenProcesos
  SET BitGenerado = 1
  WHERE idproceso = @idProceso;

  UPDATE FG
  set FG.idInstanciaProceso=OP.idInstanciaProceso
  FROM ##FechasGenerados FG 
  JOIN ##OrdenProcesos OP ON FG.IdProceso=OP.idproceso

END
   
   
  ALTER TABLE ##OrdenProcesos
  ADD EsProcesoParaCopia bit;

  ALTER TABLE ##OrdenProcesos
  ADD NombreCInstalacion varchar(max);

  ALTER TABLE ##OrdenProcesos
  ADD IdProcesoCreado int;

  ALTER TABLE ##FechasGenerados
  ADD IdActividadCreada int;


 if(@guardar=1)
	BEGIN

	EXEC [sp_GeneraFechasProcesosGuardaMacroproceso] 
		@idContrato ,
		@idUsuario ,
		@DescripcionCalculo,0;

		   IF @@ERROR <> 0 
			BEGIN 
				SELECT Cast(@@ERROR AS NVARCHAR(8)) AS error; 
			END 
		  ELSE 
			BEGIN 
				select '' as error
			END 
	END
	ELSE
	BEGIN
						SELECT
						pam.idproceso,
						'' as DescripcionProceso,
						@idContrato,
						FG.orden,
						FG.idactividad, 
						FG.NombreActividad,
						FG.Dias,
						FG.DiasNaturales,
						FechaInicial AS Fecha,
						DescripcionProceso AS Descripcion,
						FechaInicial,
						FechaLimite,
						0 as IdActividadPredecesora,
						0 as IdActividadSucesora,
						0 as Banderas,
						ROW_NUMBER() OVER (ORDER BY FechaInicial ASC) AS c,
						PAM.nombreproceso as NombreProceso,
						ISNULL(R.Regulador,'') AS Regulador,
						'false' as FechaRealActividad
			 FROM 
				##FechasGenerados FG
			JOIN 
				#ProcesosActividadesMacro PAM 
				on FG.idProceso=PAM.idproceso
			JOIN 
				EN_Actividades	A
				ON	FG.IdActividad	=	A.IdActividad
			LEFT JOIN 
				CO_Regulador	R
				ON A.IdRegulador	=	R.IdRegulador
			Group by pam.idproceso,
						FG.orden,
						FG.idactividad, 
						FG.NombreActividad,
						FG.Dias,
						FG.DiasNaturales,
						FechaInicial,
						FechaLimite,
						DescripcionProceso,
						PAM.nombreproceso,
						ISNULL(R.Regulador,'')
			ORDER BY FechaLimite ASC

		END


END;


