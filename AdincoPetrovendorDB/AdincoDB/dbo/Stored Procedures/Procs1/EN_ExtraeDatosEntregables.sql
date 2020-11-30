CREATE PROCEDURE [dbo].[EN_ExtraeDatosEntregables] -- '20190225',3,10061
    @fechaActual DATE,
    @idContrato INT,
    @idUsuario INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 22/05/18
-- Description:para la pagina de default muestra los entregables de ese mes
-- =============================================
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    IF OBJECT_ID('tempdb..#TempInstancias') IS NOT NULL
        DROP TABLE #TempInstancias;
    IF OBJECT_ID('tempdb..#TempInstanciasRevisa') IS NOT NULL
        DROP TABLE #TempInstanciasRevisa;
    IF OBJECT_ID('tempdb..#TempInstanciasAprueba') IS NOT NULL
        DROP TABLE #TempInstanciasAprueba;
    ------------------------------------Create tables------------------------------------------------
     CREATE TABLE #TempInstancias (id INT PRIMARY KEY IDENTITY(1, 1),
                                  FechasLimiteElaboracion DATE,
                                  idEntregable INT);

     CREATE TABLE #TempInstanciasRevisa (id INT PRIMARY KEY IDENTITY(1, 1),
                                  FechasLimiteRevision DATE,
                                  idEntregable INT);

	 CREATE TABLE #TempInstanciasAprobación (id INT PRIMARY KEY IDENTITY(1, 1),
                                  FechasLimiteAprobacion DATE,
                                  idEntregable INT);
    ----------------------------------------------------Inserts-----------------------------------------------------------------    

    INSERT INTO #TempInstancias (FechasLimiteElaboracion,
                                 idEntregable)
    SELECT MIN(IE.FechasLimiteElaboracion),
           CE.IdEntregable
      FROM EN_InstanciasEntregable IE	(NOLOCK)
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable   = CE.IdContratoEntregable
       AND CE.IdContrato             = @IdContrato
      JOIN dbo.EN_Actividad	(NOLOCK)
        ON EN_Actividad.ActividadID  = IE.ActividadID
      LEFT JOIN --********************************
           dbo.EN_ExcepcionesActividad EXAR --********************************
        ON EXAR.ActividadIDExcepcion = EN_Actividad.ActividadID --********************************
       AND IE.idInstanciaEntregable  = EXAR.IdInstanciasEntregables --********************************

     WHERE (   EN_Actividad.idUsuario = @idUsuario --********************************
         AND   EXAR.IdInstanciasEntregables IS NULL
         AND   EN_Actividad.EstadoID  = 10000)
        OR --********************************
           (   EXAR.idUsuario            = @idUsuario --********************************
         AND   EXAR.IdInstanciasEntregables IS NOT NULL
         AND   EXAR.EstadoID             = 10000) --********************************
       AND CE.IdContrato              = @IdContrato
     GROUP BY CE.IdEntregable;

    INSERT INTO #TempInstanciasRevisa (FechasLimiteRevision,
                                 idEntregable)
    SELECT MIN(IE.FechasLimiteRevision),
           CE.IdEntregable
      FROM EN_InstanciasEntregable IE	(NOLOCK)
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable   = CE.IdContratoEntregable
       AND CE.IdContrato             = @IdContrato
      JOIN dbo.EN_Actividad A	(NOLOCK)
        ON A.ActividadID  = IE.ActividadID
      LEFT JOIN --********************************
           dbo.EN_ExcepcionesActividad EXAR --********************************
        ON EXAR.ActividadIDExcepcion = A.ActividadID --********************************
       AND IE.idInstanciaEntregable  = EXAR.IdInstanciasEntregables --********************************

     WHERE   
	   (A.idUsuario =@idUsuario --********************************
	   AND EXAR.IdInstanciasEntregables is null  AND  A.EstadoID = 10001) or--********************************
	   (EXAR.idUsuario=@idUsuario --********************************
	   AND EXAR.IdInstanciasEntregables is not null AND  EXAR.EstadoID = 10001)--********************************

       AND CE.IdContrato              = @IdContrato
     GROUP BY CE.IdEntregable;

	INSERT INTO #TempInstanciasAprobación(FechasLimiteAprobacion,
                                 idEntregable)
    SELECT MIN(IE.FechasLimiteAprobacion),
           CE.IdEntregable
      FROM EN_InstanciasEntregable IE	(NOLOCK)
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable   = CE.IdContratoEntregable
       AND CE.IdContrato             = @IdContrato
      JOIN dbo.EN_Actividad A	(NOLOCK)
        ON A.ActividadID  = IE.ActividadID
      LEFT JOIN --********************************
           dbo.EN_ExcepcionesActividad EXAR --********************************
        ON EXAR.ActividadIDExcepcion = A.ActividadID --********************************
       AND IE.idInstanciaEntregable  = EXAR.IdInstanciasEntregables --********************************
       WHERE     
	   (A.idUsuario =@idUsuario --********************************
	   AND EXAR.IdInstanciasEntregables is null AND A.EstadoID = 10002) or--********************************
	  (EXAR.idUsuario=@idUsuario --********************************
	  AND EXAR.IdInstanciasEntregables is not null AND EXAR.EstadoID=10002 )--********************************

       AND CE.IdContrato              = @IdContrato
     GROUP BY CE.IdEntregable;

	/*-------------------------Elaboración-----------------*/
	SELECT  IE.idInstanciaEntregable AS idInstanciaEntregable,
           CONCAT(
               RIGHT('00' + CAST(DAY(IE.FechasLimiteElaboracion) AS VARCHAR(2)), 2),
               ' ',
               DATENAME(MONTH, IE.FechasLimiteElaboracion),
               ' ',
               YEAR(IE.FechasLimiteElaboracion)),
           DocumentoEntregable,
           EN_Estado.NombreEstado,
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteElaboracion) >= 0 THEN
                    DATEDIFF(DAY, @fechaActual, IE.FechasLimiteElaboracion) --dias restantes si son mayor a uno
                ELSE 0 END AS 'días restantes',
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteElaboracion) <= 7 THEN 'red'
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteElaboracion) > 7
                 AND DATEDIFF(DAY, @fechaActual, IE.FechasLimiteElaboracion) <= 15 THEN 'yellow'
                ELSE 'green' END AS 'Color',
           CE.IdEntregable AS IdEntregable,
           CE.IdContratoEntregable AS IdContratoEntregable,
           EN.IdRegulador AS idRegulador,
           '',
           DocumentoEntregable,
           R.Regulador AS Regulador,
           M.MarcoLegal AS MarcoLegal,
           IE.FechasLimiteElaboracion,
           IE.FechasLimiteRevision,
           IE.FechasLimiteAprobacion,
           f.FrecuenciaEntregable AS FrecuenciaEntregable,
           EN_Estado.NombreEstado,
           '#4d98dc'
      FROM #TempInstancias TI
      JOIN EN_InstanciasEntregable IE	(NOLOCK)
        ON TI.FechasLimiteElaboracion = IE.FechasLimiteElaboracion
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable    = CE.IdContratoEntregable
       AND TI.idEntregable            = CE.IdEntregable
       AND CE.IdContrato              = @IdContrato
      JOIN dbo.EN_Actividad	(NOLOCK)
        ON IE.ActividadID             = EN_Actividad.ActividadID
       AND EN_Actividad.idUsuario     = @idUsuario
       AND EN_Actividad.EstadoID      = 10000
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EN_Actividad.EstadoID      = EN_Estado.EstadoID
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
		AND EN.BITJOA = 0
      JOIN dbo.CO_Regulador R	(NOLOCK)
        ON R.IdRegulador              = EN.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON M.IdMarcoLegal             = EN.IdMarcoLegal
      JOIN dbo.EN_FrecuenciaEntregable f	(NOLOCK)
        ON f.IdFrecuenciaEntregable   = EN.IdFrecuenciaEntregable
	  JOIN en_etapa Et	(NOLOCK)
	  ON EN.IdEtapa=Et.IdEtapa

 -- LAS EXCEPCIONES QUE SE LE ASIGNACION AL USUARIO

    UNION
    SELECT  IE.idInstanciaEntregable AS idInstanciaEntregable,
           CONCAT(
               RIGHT('00' + CAST(DAY(IE.FechasLimiteElaboracion) AS VARCHAR(2)), 2),
               ' ',
               DATENAME(MONTH, IE.FechasLimiteElaboracion),
               ' ',
               YEAR(IE.FechasLimiteElaboracion)),
           DocumentoEntregable,
           EN_Estado.NombreEstado,
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteElaboracion) >= 0 THEN
                    DATEDIFF(DAY, @fechaActual, IE.FechasLimiteElaboracion) --dias restantes si son mayor a uno
                ELSE 0 END AS 'días restantes',
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteElaboracion) <= 7 THEN 'red'
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteElaboracion) > 7
                 AND DATEDIFF(DAY, @fechaActual, IE.FechasLimiteElaboracion) <= 15 THEN 'yellow'
                ELSE 'green' END AS 'Color',
           CE.IdEntregable AS IdEntregable,
           CE.IdContratoEntregable AS IdContratoEntregable,
           EN.IdRegulador AS idRegulador,
           '',
           DocumentoEntregable,
           R.Regulador AS Regulador,
           M.MarcoLegal AS MarcoLegal,
           IE.FechasLimiteElaboracion,
           IE.FechasLimiteRevision,
           IE.FechasLimiteAprobacion,
           f.FrecuenciaEntregable AS FrecuenciaEntregable,
           EN_Estado.NombreEstado,
           '#4d98dc'
      FROM #TempInstancias TI
      JOIN EN_InstanciasEntregable IE	(NOLOCK)
        ON TI.FechasLimiteElaboracion = IE.FechasLimiteElaboracion
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON CE.IdContratoEntregable    = IE.IdContratoEntregable
       AND TI.idEntregable            = CE.IdEntregable
       AND CE.IdContrato              = @IdContrato
      JOIN EN_ExcepcionesActividad EXACT	(NOLOCK)
        ON IE.idInstanciaEntregable   = EXACT.IdInstanciasEntregables
       AND EXACT.EstadoID             = 10000
       AND EXACT.idUsuario            = @idUsuario
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EXACT.EstadoID             = EN_Estado.EstadoID
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
		AND EN.BITJOA = 0 
      JOIN dbo.CO_Regulador R	(NOLOCK)
        ON EN.IdRegulador             = R.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON EN.IdMarcoLegal            = M.IdMarcoLegal
      JOIN dbo.EN_FrecuenciaEntregable F	(NOLOCK)
        ON EN.IdFrecuenciaEntregable  = F.IdFrecuenciaEntregable
		  JOIN en_etapa Et 
	  ON EN.IdEtapa=Et.IdEtapa
   
    UNION

	/*-------------------------Revisión-----------------*/
    SELECT IE.idInstanciaEntregable AS idInstanciaEntregable,
           CONCAT(
               RIGHT('00' + CAST(DAY(IE.FechasLimiteRevision) AS VARCHAR(2)), 2),
               ' ',
               DATENAME(MONTH, IE.FechasLimiteRevision),
               ' ',
               YEAR(IE.FechasLimiteRevision)),
           DocumentoEntregable,
           EN_Estado.NombreEstado,
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteRevision) >= 0 THEN
                    DATEDIFF(DAY, @fechaActual, IE.FechasLimiteRevision) --dias restantes si son mayor a uno
                ELSE 0 END AS 'días restantes',
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteRevision) <= 7 THEN 'red'
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteRevision) > 7
                 AND DATEDIFF(DAY, @fechaActual, IE.FechasLimiteRevision) <= 15 THEN 'yellow'
                ELSE 'green' END AS 'Color',
           CE.IdEntregable AS IdEntregable,
           CE.IdContratoEntregable AS IdContratoEntregable,
           EN.IdRegulador AS idRegulador,
           '',
           DocumentoEntregable,
           R.Regulador AS Regulador,
           M.MarcoLegal AS MarcoLegal,
     IE.FechasLimiteElaboracion,
  IE.FechasLimiteRevision,
           IE.FechasLimiteAprobacion,
           f.FrecuenciaEntregable AS FrecuenciaEntregable,
           EN_Estado.NombreEstado,
           '#4ddc91'
     FROM #TempInstanciasRevisa TI
      JOIN EN_InstanciasEntregable IE	(NOLOCK)
        ON TI.FechasLimiteRevision = IE.FechasLimiteRevision
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable    = CE.IdContratoEntregable
       AND TI.idEntregable            = CE.IdEntregable
       AND CE.IdContrato              = @IdContrato
      JOIN dbo.EN_Actividad	(NOLOCK)
        ON IE.ActividadID             = EN_Actividad.ActividadID
       AND EN_Actividad.idUsuario     = @idUsuario
       AND EN_Actividad.EstadoID      = 10001
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EN_Actividad.EstadoID      = EN_Estado.EstadoID
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
		AND EN.BITJOA = 0
      JOIN dbo.CO_Regulador R	(NOLOCK)
        ON R.IdRegulador              = EN.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON M.IdMarcoLegal             = EN.IdMarcoLegal
      JOIN dbo.EN_FrecuenciaEntregable f	(NOLOCK)
        ON f.IdFrecuenciaEntregable   = EN.IdFrecuenciaEntregable
	  JOIN en_etapa Et	(NOLOCK)
	  ON EN.IdEtapa=Et.IdEtapa
	  UNION
	   SELECT IE.idInstanciaEntregable AS idInstanciaEntregable,
           CONCAT(
               RIGHT('00' + CAST(DAY(IE.FechasLimiteRevision) AS VARCHAR(2)), 2),
               ' ',
               DATENAME(MONTH, IE.FechasLimiteRevision),
               ' ',
               YEAR(IE.FechasLimiteRevision)),
           DocumentoEntregable,
           EN_Estado.NombreEstado,
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteRevision) >= 0 THEN
                    DATEDIFF(DAY, @fechaActual, IE.FechasLimiteRevision) --dias restantes si son mayor a uno
                ELSE 0 END AS 'días restantes',
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteRevision) <= 7 THEN 'red'
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteRevision) > 7
                 AND DATEDIFF(DAY, @fechaActual, IE.FechasLimiteRevision) <= 15 THEN 'yellow'
                ELSE 'green' END AS 'Color',
           CE.IdEntregable AS IdEntregable,
           CE.IdContratoEntregable AS IdContratoEntregable,
           EN.IdRegulador AS idRegulador,
           '',
           DocumentoEntregable,
           R.Regulador AS Regulador,
           M.MarcoLegal AS MarcoLegal,
           IE.FechasLimiteElaboracion,
           IE.FechasLimiteRevision,
           IE.FechasLimiteAprobacion,
           f.FrecuenciaEntregable AS FrecuenciaEntregable,
           EN_Estado.NombreEstado,
           '#4ddc91'
      FROM #TempInstanciasRevisa TI
      JOIN EN_InstanciasEntregable IE	(NOLOCK)
        ON TI.FechasLimiteRevision = IE.FechasLimiteRevision
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON CE.IdContratoEntregable    = IE.IdContratoEntregable
       AND TI.idEntregable            = CE.IdEntregable
       AND CE.IdContrato              = @IdContrato
      JOIN EN_ExcepcionesActividad EXACT	(NOLOCK)
        ON IE.idInstanciaEntregable   = EXACT.IdInstanciasEntregables
       AND EXACT.EstadoID             = 10001
       AND EXACT.idUsuario            = @idUsuario
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EXACT.EstadoID             = EN_Estado.EstadoID
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
		AND EN.BITJOA = 0
      JOIN dbo.CO_Regulador R	(NOLOCK)
        ON EN.IdRegulador             = R.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON EN.IdMarcoLegal            = M.IdMarcoLegal
      JOIN dbo.EN_FrecuenciaEntregable F	(NOLOCK)
        ON EN.IdFrecuenciaEntregable  = F.IdFrecuenciaEntregable
		  JOIN en_etapa Et	(NOLOCK)
	  ON EN.IdEtapa=Et.IdEtapa

    UNION
	/*-------------------------Aprobación-----------------*/
	   SELECT IE.idInstanciaEntregable AS idInstanciaEntregable,
           CONCAT(
               RIGHT('00' + CAST(DAY(IE.FechasLimiteAprobacion) AS VARCHAR(2)), 2),
               ' ',
               DATENAME(MONTH, IE.FechasLimiteAprobacion),
               ' ',
               YEAR(IE.FechasLimiteAprobacion)),
           DocumentoEntregable,
           EN_Estado.NombreEstado,
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteAprobacion) >= 0 THEN
                    DATEDIFF(DAY, @fechaActual, IE.FechasLimiteAprobacion) --dias restantes si son mayor a uno
                ELSE 0 END AS 'días restantes',
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteAprobacion) <= 7 THEN 'red'
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteAprobacion) > 7
                 AND DATEDIFF(DAY, @fechaActual, IE.FechasLimiteAprobacion) <= 15 THEN 'yellow'
                ELSE 'green' END AS 'Color',
           CE.IdEntregable AS IdEntregable,
           CE.IdContratoEntregable AS IdContratoEntregable,
           EN.IdRegulador AS idRegulador,
           '',
           DocumentoEntregable,
           R.Regulador AS Regulador,
           M.MarcoLegal AS MarcoLegal,
           IE.FechasLimiteElaboracion,
           IE.FechasLimiteRevision,
           IE.FechasLimiteAprobacion,
           f.FrecuenciaEntregable AS FrecuenciaEntregable,
           EN_Estado.NombreEstado,
           '#4d51dc'
          FROM #TempInstanciasAprobación TI
      JOIN EN_InstanciasEntregable IE	(NOLOCK)
        ON TI.FechasLimiteAprobacion = IE.FechasLimiteAprobacion
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable    = CE.IdContratoEntregable
       AND TI.idEntregable            = CE.IdEntregable
       AND CE.IdContrato              = @IdContrato
      JOIN dbo.EN_Actividad	(NOLOCK)
        ON IE.ActividadID             = EN_Actividad.ActividadID
       AND EN_Actividad.idUsuario     = @idUsuario
       AND EN_Actividad.EstadoID      = 10002
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EN_Actividad.EstadoID      = EN_Estado.EstadoID
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
		AND EN.BITJOA = 0
      JOIN dbo.CO_Regulador R	(NOLOCK)
        ON R.IdRegulador              = EN.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON M.IdMarcoLegal             = EN.IdMarcoLegal
      JOIN dbo.EN_FrecuenciaEntregable f	(NOLOCK)
        ON f.IdFrecuenciaEntregable   = EN.IdFrecuenciaEntregable
	  JOIN en_etapa Et	(NOLOCK)
	  ON EN.IdEtapa=Et.IdEtapa
		   UNION
    SELECT IE.idInstanciaEntregable AS idInstanciaEntregable,
           CONCAT(
               RIGHT('00' + CAST(DAY(IE.FechasLimiteAprobacion) AS VARCHAR(2)), 2),
               ' ',
               DATENAME(MONTH, IE.FechasLimiteAprobacion),
               ' ',
               YEAR(IE.FechasLimiteAprobacion)),
           DocumentoEntregable,
           EN_Estado.NombreEstado,
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteAprobacion) >= 0 THEN
                    DATEDIFF(DAY, @fechaActual, IE.FechasLimiteAprobacion) --dias restantes si son mayor a uno
                ELSE 0 END AS 'días restantes',
           CASE
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteAprobacion) <= 7 THEN 'red'
                WHEN DATEDIFF(DAY, @fechaActual, IE.FechasLimiteAprobacion) > 7
                 AND DATEDIFF(DAY, @fechaActual, IE.FechasLimiteAprobacion) <= 15 THEN 'yellow'
                ELSE 'green' END AS 'Color',
           CE.IdEntregable AS IdEntregable,
           CE.IdContratoEntregable AS IdContratoEntregable,
           EN.IdRegulador AS idRegulador,
           '',
           DocumentoEntregable,
           R.Regulador AS Regulador,
           M.MarcoLegal AS MarcoLegal,
           IE.FechasLimiteElaboracion,
           IE.FechasLimiteRevision,
           IE.FechasLimiteAprobacion,
           f.FrecuenciaEntregable AS FrecuenciaEntregable,
           EN_Estado.NombreEstado,
           '#4d51dc'
          FROM #TempInstanciasAprobación TI
      JOIN EN_InstanciasEntregable IE	(NOLOCK)
        ON TI.FechasLimiteAprobacion = IE.FechasLimiteAprobacion
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON CE.IdContratoEntregable    = IE.IdContratoEntregable
       AND TI.idEntregable            = CE.IdEntregable
       AND CE.IdContrato              = @IdContrato
      JOIN EN_ExcepcionesActividad EXACT	(NOLOCK)
        ON IE.idInstanciaEntregable   = EXACT.IdInstanciasEntregables
       AND EXACT.EstadoID             = 10002
       AND EXACT.idUsuario            = @idUsuario
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EXACT.EstadoID             = EN_Estado.EstadoID
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
		AND EN.BITJOA = 0
      JOIN dbo.CO_Regulador R	(NOLOCK)
        ON EN.IdRegulador             = R.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON EN.IdMarcoLegal            = M.IdMarcoLegal
      JOIN dbo.EN_FrecuenciaEntregable F	(NOLOCK)
        ON EN.IdFrecuenciaEntregable  = F.IdFrecuenciaEntregable
		  JOIN en_etapa Et (NOLOCK)
	  ON EN.IdEtapa=Et.IdEtapa	
     ORDER BY IE.FechasLimiteElaboracion ASC;

END;
