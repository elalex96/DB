-- =============================================
-- Author:  	Reyna Olvera
-- Create date: 20181023
-- Description:	Genera y simula Calculo de fechas de macroproceso
-- =============================================
CREATE PROCEDURE sp_GuardaSimulaCalculoFInicialMacro --12147,3,10061,'2019-01-18','prueba',11785,0
@IdMacroproceso int,
@idContrato int,
@idUsuario int,
@FechaSeleccionada date,
@DescripcionCalculo varchar(max),
@idinstalacion int,
@guardar int,
@idActividadComienza INT
AS
BEGIN

--Select * from CO_Instalacion where IdAreaContractual=2

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
          @OrdenMin int,
          @OrdenProceso int,
          @id int,
          @DesencadenaProceso int,
          @DescripcionProcesoCalculo varchar(max),
          @TieneProcesosGenerados int,
          @idInstanciaProceso int,
          @IdActividad int,
          @OrdenActividad int,
          @FechaCalculoAdelante date,
          @IdActividadSucesora int;

  SELECT @TieneProcesosGenerados =
    COUNT(1)
  FROM 
	EN_MacroProcesosRelacion MPR
  JOIN 
	EN_Procesos P
    ON MPR.idProcesoHijo = P.IdProceso
    AND P.IdInstalacion = @idinstalacion
  JOIN 
	EN_ProcesosActividades PA
    ON P.IdProceso = PA.IdProceso
  JOIN 
	EN_Actividades A
    ON PA.idActividad = A.IdActividad
  WHERE 
	idMacroProceso = @IdMacroproceso
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
	--EXEC [Sp_EN_ExtraeActividadesMacroproceso]3,10061,12147
    EXEC [Sp_EN_ExtraeActividadesMacroproceso] @idContrato,
                                               @idUsuario,
                                               @IdMacroproceso;--modificar para extraer el nombre del proceso sin orden
    UPDATE #ProcesosActividadesMacro
    SET idInstanciaProceso = 0

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
    ORDER BY ordenprocesos ASC

  SELECT @OrdenMin =
    MIN(ordenprocesos)
  FROM ##OrdenProcesos

  WHILE (SELECT
      COUNT(1)
    FROM ##OrdenProcesos
    WHERE BitGenerado IS NULL)
    > 0
  BEGIN
    SET @DesencadenaProceso = 0;

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
    ORDER BY ordenprocesos ASC;


    SELECT @OrdenActividad =
      MIN(orden)
    FROM #ProcesosActividadesMacro
    WHERE ordenprocesos = @OrdenProceso

    SELECT @IdActividad =
      idactividad
    FROM #ProcesosActividadesMacro
    WHERE ordenprocesos = @OrdenProceso
    AND orden = @OrdenActividad;

    IF (@OrdenMin = @OrdenProceso)
    BEGIN
      --Select 'entro al if'
      SET @FechaCalculo = @FechaSeleccionada;--FechaIngresada por el usuario

    END
    ELSE
		BEGIN

      SELECT @DesencadenaProceso =
             COUNT(1),
             @OrdenActividad = PAM.orden
      FROM #ProcesosActividadesMacro PAM
      JOIN ##OrdenProcesos OP
        ON PAM.idproceso = OP.idproceso
      WHERE OP.ID = (@id - 1)
      AND bitiniciaproceso = 1
      GROUP BY idactividad,
               PAM.orden

      IF (@DesencadenaProceso >= 1)
      BEGIN
        --Declare @FechaCalculo date;
        SELECT TOP 1 @FechaCalculo = FechaLimite
--20200425          DATEADD(DAY, 1,FechaLimite)-- SE AGREGO 1 DÍA
        FROM #ProcesosActividadesMacro PAM
        JOIN ##FechasGenerados FG
          ON PAM.idproceso = FG.idproceso
          AND PAM.idactividad = FG.idactividad
        JOIN ##OrdenProcesos OP
          ON FG.idproceso = OP.idproceso
          AND OP.ID = (@id - 1)
          AND bitiniciaproceso = 1;


      END
      ELSE
      BEGIN
        SELECT @FechaCalculo =
          DATEADD(DAY, 1, MAX(FechaLimite))
        FROM ##FechasGenerados;
      END


    END

    INSERT INTO ##FechasGenerados (idproceso, DescripcionProceso, idContrato, orden, idactividad, nombreactividad, dias, diasnaturales, FechaInicial, FechaLimite, idActividadPredecesora, idActividadSucesora)
    EXEC sp_CalculoFechasProcesosPorActividadFechaInicio -- 3,10061,'2019-10-13',12488,11169
    @idContrato,
    @idUsuario,
    @FechaCalculo,
    @idProceso,
    @IdActividad--,'FECHA INICIAL';


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

  IF (@guardar = 1)
  BEGIN
    EXEC [sp_GeneraFechasProcesosGuardaMacroproceso] @idContrato,
                                                     @idUsuario,
                                                     @DescripcionCalculo,1;

    IF @@ERROR <> 0
    BEGIN
      SELECT CAST(@@ERROR AS nvarchar(8)) AS error;
    END
    ELSE
    BEGIN
      SELECT '' AS error
    END
  END
  ELSE
  BEGIN
    SELECT pam.idproceso,
           '' AS DescripcionProceso,
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
           0 AS IdActividadPredecesora,
           0 AS IdActividadSucesora,
           0 AS Banderas,
           ROW_NUMBER() OVER (ORDER BY FechaInicial ASC) AS c,
           nombreproceso AS NombreProceso,
		   ISNULL(R.Regulador,'') AS Regulador,
		   'false' as FechaRealActividad
    FROM 
		##FechasGenerados FG
    JOIN 
		#ProcesosActividadesMacro PAM
      ON FG.idProceso = PAM.idproceso
	JOIN 
		EN_Actividades	A
		ON	FG.IdActividad	=	A.IdActividad
	LEFT JOIN 
		CO_Regulador	R
		ON A.IdRegulador	=	R.IdRegulador
    GROUP BY pam.idproceso,
             FG.orden,
             FG.idactividad,
             FG.NombreActividad,
             FG.Dias,
             FG.DiasNaturales,
             FechaInicial,
             FechaLimite,
             DescripcionProceso,
             nombreproceso,
			 ISNULL(R.Regulador,'')
	ORDER BY FechaLimite ASC

  END
END
