-- =============================================
-- Author:  Reyna Olvera
-- Create date: 20181023
-- Description: Genera Calculo de fechas
-- =============================================
CREATE PROCEDURE [DBO].[sp_ExtraeDetalleFechasProceso]--3,10061,12147,0,11477--SIMULACION
@idContrato int,
@idUsuario int,
@idProceso int,
@idInstanciaProceso int,
@idInstalacion int = 0
AS
BEGIN
  CREATE TABLE #actividadesguarda (
    idproceso int,
    descripcionproceso varchar(500),
    idcontrato int,
    orden int,
    idactividad int,
    nombreactividad varchar(500),
    dias int,
    diasnaturales bit,
    fechainicial date,
    fechalimite date,
    idactividadpredecesora int,
    idactividadsucesora int
  );
  CREATE TABLE #procesosdemacro (
    id int IDENTITY (1, 1),
    idproceso int
  );
  CREATE TABLE #instanciasprocesos (
    id int IDENTITY (1, 1),
    idinstanciaproceso int
  );
  CREATE TABLE #selectfinal (
    idproceso int,
    descripcionproceso varchar(500),
    idcontrato int,
    orden int,
    idactividad int,
    nombreactividad varchar(500),
    dias int,
    diasnaturales bit,
    fechainicial date,
    fechalimite date,
    idactividadpredecesora int,
    idactividadsucesora int,
    fecha date,
    fechainicialbit bit,
    descripcion varchar(1000),
    idtipoproceso int,
    idinstalacion int,
    banderas int,
    idinstanciaactividad int,
    fecharealactividad bit,
    sepuedemodificar bit
  );
  CREATE TABLE #fechasrepetidass (
    banderacount int,
    fechalimite date
  );

  DECLARE @Fecha date,
          @FechaSeleccionada int,
          @CountProcesos int,
          @idTipoProceso int,
          @contador int = 1,
          @idProcecito int,
          @IdInstanciasProcesos int,
          @idinstanciaActividadRecalcular int, @FechaMacro DATE;

  SELECT @idtipoproceso = idtipoproceso
  FROM dbo.en_procesos
  WHERE idproceso = @idproceso;

  IF (@idTipoProceso = 10000)
  BEGIN

    SELECT @Fecha = fecha,
           @FechaSeleccionada = fechainicial
    FROM 
		en_instanciasprocesosfecha
    WHERE 
		idcontrato = @idContrato
		AND idproceso = @idProceso
		AND idinstanciasprocesos = @idInstanciaProceso;


    INSERT INTO #selectfinal (idproceso,
		descripcionproceso,
		idcontrato,
		orden,
		idactividad,
		nombreactividad,
		dias,
		diasnaturales,
		fechainicial,
		fechalimite,
		idactividadpredecesora,
		idactividadsucesora,
		fecha,
		fechainicialbit,
		descripcion,
		idtipoproceso,
		idinstalacion,
		banderas,
		idinstanciaactividad,
		fecharealactividad,
		sepuedemodificar)
      SELECT p.idproceso,
             p.descripcion,
             p.idcontrato,
             pa.orden,
             a.idactividad,
             a.nombreactividad,
             a.dias,
             a.diasnaturales,
             IA.fechainicioactividad,
             CASE ISNULL(IA.fecharealactividad, '')
               WHEN '' THEN IA.fechaactividad
               ELSE IA.fecharealactividad
             END AS FechaLimite,
             0,
             0,
             p.fecha,
             p.fechainicial,
             p.descripcion,
             @idtipoproceso,
             pr.idinstalacion,
             NULL,
             IA.idinstanciaactividad AS IdInstanciaActividad,
             CASE ISNULL(IA.fecharealactividad, '')
               WHEN '' THEN 'False'
               ELSE 'True'
             END AS FechaRealActividad,
             'False'
      FROM 
		dbo.en_instanciasactividades IA

      JOIN 
		dbo.en_actividades a
        ON IA.idactividad = a.idactividad

      JOIN 
		dbo.en_procesosactividades pa
        ON IA.idactividad = pa.idactividad
        AND pa.idproceso = @idproceso

      JOIN 
		dbo.en_instanciasprocesosfecha p
        ON IA.idinstanciasprocesos = p.idinstanciasprocesos
        AND p.idcontrato = @idcontrato
        AND p.idproceso = @idproceso
		AND p.idinstanciasprocesos = @idinstanciaproceso

      JOIN 
		dbo.en_procesos pr
        ON p.idproceso = pr.idproceso;


    INSERT INTO #fechasrepetidass (banderacount,fechalimite)
      SELECT COUNT(*),
             fechalimite
      FROM 
		#selectfinal
      GROUP BY 
		fechalimite
      HAVING COUNT(*) > 1;

    UPDATE sf
		SET banderas = ISNULL(fr.banderacount, 0)
    FROM 
		#selectfinal sf
    LEFT JOIN 
		#fechasrepetidass fr
		ON fr.fechalimite = sf.fechalimite;


    SELECT 
		TOP 1 @idinstanciaActividadRecalcular = idinstanciaactividad
    FROM 
		#selectfinal s
    WHERE 
		fecharealactividad = 0
    ORDER BY fechalimite ASC;


    UPDATE #selectfinal
		SET sepuedemodificar = 1
    WHERE 
		idinstanciaactividad = @idinstanciaactividadrecalcular;


    SELECT s.*,
           ROW_NUMBER() OVER (ORDER BY fechalimite ASC) AS c,
           p.nombreproceso,
           'False' AS ismacroproceso,
           s.idinstanciaactividad,
           s.fecharealactividad,
           '1',
           COUNT(ieia.idinstanciaentregable) iscontieneentregables,
		   ISNULL(R.Regulador,'') AS Regulador
    FROM 
		#selectfinal s

    JOIN 
		dbo.en_procesos p
		ON s.idproceso = p.idproceso

    LEFT JOIN 
		dbo.en_instanciasentregables_instanciaactividad ieia
		ON s.idinstanciaactividad = ieia.idinstanciaactividad
	JOIN 
		EN_Actividades	A
		ON	S.IdActividad	=	A.IdActividad
	LEFT JOIN 
		CO_Regulador	R
		ON A.IdRegulador	=	R.IdRegulador
    GROUP BY s.idproceso,
             s.descripcionproceso,
             s.idcontrato,
             s.orden,
             s.idactividad,
             s.nombreactividad,
             s.dias,
             s.diasnaturales,
             s.fechainicial,
             s.fechalimite,
             s.idactividadpredecesora,
             s.idactividadsucesora,
             s.fecha,
             s.fechainicialbit,
             s.descripcion,
             s.idtipoproceso,
             s.idinstalacion,
             s.banderas,
             s.idinstanciaactividad,
             s.fecharealactividad,
             s.sepuedemodificar,
             p.nombreproceso,
			 ISNULL(R.Regulador,'')
    ORDER BY fechalimite ASC;
  END;
  ELSE
  IF (@idTipoProceso = 10002)
  BEGIN
    SELECT @CountProcesos = COUNT(*)
    FROM en_macroprocesosrelacion mpc
    JOIN EN_Procesos p
      ON mpc.idProcesoHijo = p.idproceso
      AND p.IdInstalacion = @idInstalacion
    WHERE idmacroproceso = @idProceso;

    INSERT INTO #procesosdemacro (idproceso)
      SELECT p.idproceso
      FROM 
		en_macroprocesosrelacion mpc
      JOIN 
		EN_Procesos p
        ON mpc.idProcesoHijo = p.idproceso
        AND p.IdInstalacion = @idInstalacion
      WHERE 
		idmacroproceso = @idProceso;


    WHILE (@contador <= @CountProcesos)
    BEGIN
      SELECT @idProcecito = idproceso
      FROM #procesosdemacro
      WHERE id = @contador;

      SET @idinstanciasprocesos = 0;

      SET @idinstanciasprocesos = (SELECT TOP 1
        (idinstanciasprocesos)
      FROM 
		en_instanciasprocesosfecha
      WHERE 
		  idcontrato = @idcontrato
		  AND idproceso = @idprocecito
      ORDER BY 
		idinstanciasprocesos DESC);

      INSERT INTO #instanciasprocesos (idinstanciaproceso)
        VALUES (@idinstanciasprocesos);

      SELECT --*
        @fecha = fecha,
        @fechaseleccionada = fechainicial
      FROM 
		en_instanciasprocesosfecha
      WHERE 
		idcontrato = @idcontrato
		AND idproceso = @idprocecito
		AND idinstanciasprocesos = @idinstanciasprocesos;

      IF (@IdInstanciasProcesos <> 0)
      BEGIN

        INSERT INTO #actividadesguarda (idproceso,
        descripcionproceso,
        idcontrato,
        orden,
        idactividad,
        nombreactividad,
        dias,
        diasnaturales,
        fechainicial,
        fechalimite,
        idactividadpredecesora,
        idactividadsucesora)
          SELECT ipf.idproceso,
                 ipf.descripcion,
                 ipf.idcontrato,
                 pa.orden,
                 ia.idactividad,
                 P.NombreProceso + ', Actividad: ' + a.nombreactividad,
                 a.dias,
				 a.diasnaturales,
                 ia.fechainicioactividad,
                 ia.fechaactividad,
                 0,
                 0
          FROM 
			dbo.en_instanciasactividades ia
          JOIN 
			dbo.en_actividades a
            ON ia.idactividad = a.idactividad
          JOIN 
			dbo.en_procesosactividades pa
            ON ia.idactividad = pa.idactividad
            AND pa.idproceso = @idProcecito
          JOIN 
			dbo.en_instanciasprocesosfecha ipf
            ON ia.idinstanciasprocesos = ipf.idinstanciasprocesos
            AND ipf.idcontrato = @idContrato
            AND ipf.idproceso = @idProcecito
            AND ipf.idinstanciasprocesos = @IdInstanciasProcesos
          JOIN 
			EN_Procesos p
            ON ipf.IdProceso = p.IdProceso;
      END;

      SET @contador = @contador + 1;
    END;

    INSERT INTO #selectfinal (idproceso,
    descripcionproceso,
    idcontrato,
    orden,
    idactividad,
    nombreactividad,
    dias,
    diasnaturales,
    fechainicial,
    fechalimite,
    idactividadpredecesora,
    idactividadsucesora,
    fecha,
    fechainicialbit,
    descripcion,
    idtipoproceso,
    idinstalacion,
    banderas,
    idinstanciaactividad,
    fecharealactividad,
    sepuedemodificar)
      SELECT A.idproceso,
             A.descripcionproceso,
             A.idcontrato,
             A.orden,
             A.idactividad,
             A.nombreactividad,
             A.dias,
             A.diasnaturales,
             A.fechainicial,
             CASE ISNULL(IA.fecharealactividad, '')
               WHEN '' THEN A.fechalimite
               ELSE IA.fecharealactividad
             END AS FechaLimite,
             A.idactividadpredecesora,
             A.idactividadsucesora,
             --  A.*,
             P.fecha,
             P.fechainicial,
             P.descripcion,
             @idtipoproceso AS idtipoProceso,
             '0',
             NULL,
             IA.idinstanciaactividad,
             CASE ISNULL(IA.fecharealactividad, '')
               WHEN '' THEN 'False'
               ELSE 'True'
             END AS FechaRealActividad,
             'False'
      FROM #actividadesguarda A
      JOIN en_instanciasprocesosfecha P
        ON P.idproceso = A.idproceso
        AND P.idcontrato = @idcontrato
      JOIN #instanciasprocesos I
        ON P.idinstanciasprocesos = I.idinstanciaproceso
      JOIN dbo.en_instanciasactividades IA
        ON P.idinstanciasprocesos = IA.idinstanciasprocesos
        AND A.fechalimite = IA.fechaactividad
        AND IA.activo = 1
        AND A.idactividad = IA.idactividad
      ORDER BY A.fechalimite ASC;

    INSERT INTO #fechasrepetidass (banderacount,
    fechalimite)
      SELECT COUNT(*),
             fechalimite
      FROM #selectfinal
      GROUP BY fechalimite
      HAVING COUNT(*) > 1;

    UPDATE sf
    SET banderas = ISNULL(fr.banderacount, 0)
    FROM #selectfinal sf
    LEFT JOIN #fechasrepetidass fr
      ON fr.fechalimite = sf.fechalimite;

	    SELECT 
           @FechaMacro=LTRIM(DAY(MAX(FechaActividad))) + '-' + DATENAME(MONTH, MAX(FechaActividad)) + '-' + LTRIM(YEAR(MAX(FechaActividad)))
    FROM EN_MacroProcesosRelacion mpr
    JOIN EN_Procesos p
      ON mpr.idProcesoHijo = p.IdProceso and mpr.IdprocesoOriginal is not null
    JOIN EN_InstanciasProcesosFecha ipf
      ON p.IdProceso = ipf.IdProceso  and p.IdInstalacion=@idInstalacion
    JOIN EN_InstanciasActividades a
      ON ipf.IdInstanciasProcesos = a.IdInstanciasProcesos 
    WHERE mpr.idMacroProceso =@idProceso
    GROUP BY ipf.Descripcion,
             p.IdInstalacion

    SELECT s.idproceso,
           s.descripcionproceso,
           s.idcontrato,
           s.orden,
           s.idactividad,
           s.nombreactividad,
           s.dias,
           s.diasnaturales,
           s.fechainicial,
           s.fechalimite,
           s.idactividadpredecesora,
			s.idactividadsucesora,
		   @FechaMacro fecha,
           s.fechainicialbit,
           s.descripcion,
           s.idtipoproceso,
           p.idinstalacion,
           s.banderas,
           s.idinstanciaactividad,
           s.fecharealactividad,
           s.sepuedemodificar,
           ROW_NUMBER() OVER (ORDER BY fechalimite ASC) AS c,
           p.nombreproceso,
           'True' AS ismacroproceso,
           s.idinstanciaactividad AS idinstanciaactividad,
           s.fecharealactividad,
           '2',
           COUNT(ieia.idinstanciaentregable) iscontieneentregables,
		   ISNULL(R.Regulador,'') AS Regulador
    FROM 
		#selectfinal s
    JOIN 
		dbo.en_procesos p
		ON p.idproceso = @idProceso
    LEFT JOIN 
		dbo.en_instanciasentregables_instanciaactividad ieia
		ON s.idinstanciaactividad = ieia.idinstanciaactividad
	JOIN 
		EN_Actividades	A
		ON	S.IdActividad	=	A.IdActividad
	LEFT JOIN 
		CO_Regulador	R
		ON A.IdRegulador	=	R.IdRegulador
    GROUP BY s.idproceso,
             s.descripcionproceso,
             s.idcontrato,
             s.orden,
             s.idactividad,
             s.nombreactividad,
             s.dias,
             s.diasnaturales,
             s.fechainicial,
             s.fechalimite,
             s.idactividadpredecesora,
             s.idactividadsucesora,
             s.fechainicialbit,
             s.descripcion,
             s.idtipoproceso,
             s.banderas,
             s.idinstanciaactividad,
             s.fecharealactividad,
             s.sepuedemodificar,
             p.nombreproceso,
             p.idinstalacion,
			 ISNULL(R.Regulador,'') 
    ORDER BY fechalimite ASC;
  END
  ELSE
  BEGIN
    SELECT @CountProcesos = COUNT(*)
    FROM en_macroprocesosrelacion
    WHERE idmacroproceso = @idProceso;
    IF ((SELECT
        idinstalacion
      FROM en_procesos
      WHERE idproceso = @idProceso)
      IS NULL)
    BEGIN
      INSERT INTO #procesosdemacro (idproceso)
        (
        SELECT
          idprocesohijo
        FROM dbo.en_macroprocesosrelacion
        WHERE idmacroproceso = @idProceso);
    END
    ELSE
    BEGIN

      INSERT INTO #procesosdemacro (idproceso)
        SELECT pi.idproceso
        FROM dbo.en_macroprocesosrelacion mpc
        JOIN EN_Procesos MC
          ON mpc.idMacroProceso = MC.IdProceso
        JOIN en_procesos p
          ON mpc.idprocesohijo = p.idproceso
        LEFT JOIN en_procesos PI
          ON PI.nombreproceso LIKE '%' + p.nombreproceso + '%'--
          AND pi.idinstalacion = MC.IdInstalacion
        WHERE mpc.idmacroproceso = @idProceso
    END

    WHILE
      (
      @contador <= @CountProcesos
      )
    BEGIN

      SELECT @idProcecito = idproceso
      FROM #procesosdemacro
      WHERE id = @contador;

      SET @idinstanciasprocesos = 0;
      SET @idinstanciasprocesos = (SELECT TOP 1
        (idinstanciasprocesos)
      FROM en_instanciasprocesosfecha
      WHERE idcontrato = @idcontrato
      AND idproceso = @idprocecito
      ORDER BY idinstanciasprocesos DESC);

      INSERT INTO #instanciasprocesos (idinstanciaproceso)
        VALUES (@idinstanciasprocesos);

      SELECT --*
        @fecha = fecha,
        @fechaseleccionada = fechainicial
      FROM en_instanciasprocesosfecha
      WHERE idcontrato = @idcontrato
      AND idproceso = @idprocecito
      AND idinstanciasprocesos = @idinstanciasprocesos;
      IF (@IdInstanciasProcesos <> 0)
      BEGIN

        INSERT INTO #actividadesguarda (idproceso,
        descripcionproceso,
        idcontrato,
        orden,
        idactividad,
        nombreactividad,
        dias,
        diasnaturales,
        fechainicial,
        fechalimite,
        idactividadpredecesora,
        idactividadsucesora)
          SELECT ipf.idproceso,
                 ipf.descripcion,
                 ipf.idcontrato,
                 pa.orden,
                 ia.idactividad,
                 P.NombreProceso + ', Actividad: ' + a.nombreactividad,
                 a.dias,
                 a.diasnaturales,
                 ia.fechainicioactividad,
				 ia.fechaactividad,
                 0,
                 0
          FROM dbo.en_instanciasactividades ia
          JOIN dbo.en_actividades a
            ON ia.idactividad = a.idactividad
          JOIN dbo.en_procesosactividades pa
            ON ia.idactividad = pa.idactividad
            AND pa.idproceso = @idProcecito
          JOIN dbo.en_instanciasprocesosfecha ipf
            ON ia.idinstanciasprocesos = ipf.idinstanciasprocesos
            AND ipf.idcontrato = @idContrato
            AND ipf.idproceso = @idProcecito
            AND ipf.idinstanciasprocesos = @IdInstanciasProcesos
          JOIN EN_Procesos p
            ON ipf.IdProceso = p.IdProceso;
      END;

      SET @contador = @contador + 1;
    END;

    INSERT INTO #selectfinal (idproceso,
    descripcionproceso,
    idcontrato,
    orden,
    idactividad,
    nombreactividad,
    dias,
    diasnaturales,
    fechainicial,
    fechalimite,
    idactividadpredecesora,
    idactividadsucesora,
    fecha,
    fechainicialbit,
    descripcion,
    idtipoproceso,
    idinstalacion,
    banderas,
    idinstanciaactividad,
    fecharealactividad,
    sepuedemodificar)
      SELECT A.idproceso,
             A.descripcionproceso,
             A.idcontrato,
             A.orden,
             A.idactividad,
             A.nombreactividad,
             A.dias,
             A.diasnaturales,
             A.fechainicial,
             CASE ISNULL(IA.fecharealactividad, '')
               WHEN '' THEN A.fechalimite
               ELSE IA.fecharealactividad
             END AS FechaLimite,
             A.idactividadpredecesora,
             A.idactividadsucesora,
             --  A.*,
             P.fecha,
             P.fechainicial,
             P.descripcion,
             @idtipoproceso AS idtipoProceso,
             '0',
             NULL,
             IA.idinstanciaactividad,
             CASE ISNULL(IA.fecharealactividad, '')
               WHEN '' THEN 'False'
               ELSE 'True'
             END AS FechaRealActividad,
             'False'
      FROM #actividadesguarda A
      JOIN en_instanciasprocesosfecha P
        ON P.idproceso = A.idproceso
        AND P.idcontrato = @idcontrato
      JOIN #instanciasprocesos I
        ON P.idinstanciasprocesos = I.idinstanciaproceso
      JOIN dbo.en_instanciasactividades IA
        ON P.idinstanciasprocesos = IA.idinstanciasprocesos
        AND A.fechalimite = IA.fechaactividad
        AND IA.activo = 1
        AND A.idactividad = IA.idactividad
      ORDER BY A.fechalimite ASC;

    INSERT INTO #fechasrepetidass (banderacount,
    fechalimite)
      SELECT COUNT(*),
             fechalimite
      FROM #selectfinal
      GROUP BY fechalimite
      HAVING COUNT(*) > 1;
    UPDATE sf

    SET banderas = ISNULL(fr.banderacount, 0)
    FROM #selectfinal sf
    LEFT JOIN #fechasrepetidass fr
      ON fr.fechalimite = sf.fechalimite;

    SELECT s.*,
           ROW_NUMBER() OVER (ORDER BY fechalimite ASC) AS c,
           p.nombreproceso,
           'True' AS ismacroproceso,
           s.idinstanciaactividad AS idinstanciaactividad,
           s.fecharealactividad,
           '2',
           COUNT(ieia.idinstanciaentregable) iscontieneentregables,
		   ISNULL(R.Regulador,'') AS Regulador
    FROM 
		#selectfinal s
    JOIN 
		dbo.en_procesos p
		ON p.idproceso = @idProceso
    LEFT JOIN 
		dbo.en_instanciasentregables_instanciaactividad ieia
		ON s.idinstanciaactividad = ieia.idinstanciaactividad
	JOIN 
		EN_Actividades	A
		ON	S.IdActividad	=	A.IdActividad
	LEFT JOIN 
		CO_Regulador	R
		ON A.IdRegulador	=	R.IdRegulador
    GROUP BY s.idproceso,
             s.descripcionproceso,
             s.idcontrato,
             s.orden,
             s.idactividad,
             s.nombreactividad,
             s.dias,
             s.diasnaturales,
             s.fechainicial,
             s.fechalimite,
             s.idactividadpredecesora,
             s.idactividadsucesora,
             s.fecha,
             s.fechainicialbit,
             s.descripcion,
             s.idtipoproceso,
             s.idinstalacion,
             s.banderas,
             s.idinstanciaactividad,
             s.fecharealactividad,
             s.sepuedemodificar,
             p.nombreproceso,
			 ISNULL(R.Regulador,'')
    ORDER BY fechalimite ASC;
  END;
END;

