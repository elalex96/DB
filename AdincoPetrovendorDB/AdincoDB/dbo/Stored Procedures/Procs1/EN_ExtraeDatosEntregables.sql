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
-- =============================================
-- Author:  Luis David 
-- Create date: 28/09/22
-- Description: Se eliminan subconsultas, reacomodo de tablas según su declaración y su cantidad de datos Issue#809(Entregables)
-- =============================================
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    DROP TABLE IF EXISTS #TempInstancias;
    DROP TABLE IF EXISTS #TempInstanciasRevisa;
    DROP TABLE IF EXISTS #TempInstanciasAprueba;
	DROP TABLE IF EXISTS #TempInstanciasAprobacion;
    ------------------------------------Create tables------------------------------------------------
	CREATE TABLE #TempInstancias (
                                  FechasLimiteElaboracion DATE,
                                  idEntregable INT);
	CREATE NONCLUSTERED INDEX ix_tempTempInstancias ON #TempInstancias (FechasLimiteElaboracion);
    CREATE TABLE #TempInstanciasRevisa (
                                  FechasLimiteRevision DATE,
                                  idEntregable INT);
	CREATE NONCLUSTERED INDEX ix_tempTempInstanciasRevisa ON #TempInstanciasRevisa (FechasLimiteRevision);
	CREATE TABLE #TempInstanciasAprobacion (
                                  FechasLimiteAprobacion DATE,
                                  idEntregable INT);
	CREATE NONCLUSTERED INDEX ix_tempTempInstanciasAprobacion ON #TempInstanciasAprobacion (FechasLimiteAprobacion);
    ----------------------------------------------------Inserts-----------------------------------------------------------------    
    INSERT INTO #TempInstancias (FechasLimiteElaboracion,
                                 idEntregable)

    SELECT MIN(IE.FechasLimiteElaboracion),
           CE.IdEntregable
      FROM EN_ContratoEntregable CE (NOLOCK)
      JOIN EN_InstanciasEntregable IE	(NOLOCK)
        ON CE.IdContratoEntregable = IE.IdContratoEntregable
       AND CE.IdContrato = @IdContrato				      
      JOIN dbo.EN_Actividad	(NOLOCK)
        ON IE.ActividadID = EN_Actividad.ActividadID 
      LEFT JOIN dbo.EN_ExcepcionesActividad EXAR 
        ON EN_Actividad.ActividadID = EXAR.ActividadIDExcepcion 
       AND IE.idInstanciaEntregable  = EXAR.IdInstanciasEntregables 
     WHERE (   EN_Actividad.idUsuario = @idUsuario 
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
      FROM EN_ContratoEntregable CE	(NOLOCK)
      JOIN EN_InstanciasEntregable IE	(NOLOCK)
        ON CE.IdContratoEntregable = IE.IdContratoEntregable   
       AND CE.IdContrato = @IdContrato				 
      JOIN dbo.EN_Actividad A	(NOLOCK)
        ON IE.ActividadID = A.ActividadID 
      LEFT JOIN dbo.EN_ExcepcionesActividad EXAR 
        ON A.ActividadID = EXAR.ActividadIDExcepcion 
       AND IE.idInstanciaEntregable = EXAR.IdInstanciasEntregables 
     WHERE   
	   (A.idUsuario =@idUsuario --********************************
	   AND EXAR.IdInstanciasEntregables is null  AND  A.EstadoID = 10001) or--********************************
	   (EXAR.idUsuario=@idUsuario --********************************
	   AND EXAR.IdInstanciasEntregables is not null AND  EXAR.EstadoID = 10001)--********************************
       AND CE.IdContrato              = @IdContrato
     GROUP BY CE.IdEntregable;

	INSERT INTO #TempInstanciasAprobacion(FechasLimiteAprobacion,
                                 idEntregable)
    SELECT MIN(IE.FechasLimiteAprobacion),
           CE.IdEntregable
      FROM EN_ContratoEntregable CE	(NOLOCK)
      JOIN EN_InstanciasEntregable IE	(NOLOCK)
        ON CE.IdContratoEntregable = IE.IdContratoEntregable
       AND CE.IdContrato = @IdContrato
      JOIN dbo.EN_Actividad A	(NOLOCK)
        ON IE.ActividadID = A.ActividadID 
      LEFT JOIN dbo.EN_ExcepcionesActividad EXAR 
        ON A.ActividadID = EXAR.ActividadIDExcepcion
		AND IE.idInstanciaEntregable  = EXAR.IdInstanciasEntregables
       WHERE     
	   (A.idUsuario =@idUsuario
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
      JOIN dbo.EN_Actividad	(NOLOCK)
        ON IE.ActividadID             = EN_Actividad.ActividadID
       AND @idUsuario				  = EN_Actividad.idUsuario     
       AND 10000					  = EN_Actividad.EstadoID      
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EN_Actividad.EstadoID      = EN_Estado.EstadoID
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable    = CE.IdContratoEntregable
       AND TI.idEntregable            = CE.IdEntregable
       AND CE.IdContrato              = @IdContrato
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
		AND 0						  = EN.BITJOA 
	  JOIN en_etapa Et (NOLOCK)
		ON EN.IdEtapa=Et.IdEtapa
	  JOIN dbo.EN_FrecuenciaEntregable f	(NOLOCK)
        ON EN.IdFrecuenciaEntregable  = f.IdFrecuenciaEntregable
	  JOIN dbo.CO_Regulador R	(NOLOCK)
        ON EN.IdRegulador             = R.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON EN.IdMarcoLegal			  = M.IdMarcoLegal

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
      JOIN EN_ExcepcionesActividad EXACT	(NOLOCK)
        ON IE.idInstanciaEntregable   = EXACT.IdInstanciasEntregables
       AND 10000					  = EXACT.EstadoID
       AND @idUsuario				  = EXACT.idUsuario
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EXACT.EstadoID             = EN_Estado.EstadoID
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable	  = CE.IdContratoEntregable
       AND TI.idEntregable            = CE.IdEntregable
       AND @IdContrato				  = CE.IdContrato
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
	  JOIN en_etapa Et 
		ON EN.IdEtapa=Et.IdEtapa
      JOIN dbo.EN_FrecuenciaEntregable F	(NOLOCK)
        ON EN.IdFrecuenciaEntregable  = F.IdFrecuenciaEntregable
		AND EN.BITJOA = 0 
      JOIN dbo.CO_Regulador R	(NOLOCK)
        ON EN.IdRegulador             = R.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON EN.IdMarcoLegal            = M.IdMarcoLegal
   
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
      JOIN dbo.EN_Actividad	(NOLOCK)
        ON IE.ActividadID             = EN_Actividad.ActividadID
       AND @idUsuario				  = EN_Actividad.idUsuario
       AND 10001					  = EN_Actividad.EstadoID
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EN_Actividad.EstadoID      = EN_Estado.EstadoID
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable    = CE.IdContratoEntregable
       AND TI.idEntregable            = CE.IdEntregable
       AND @IdContrato				  = CE.IdContrato
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
	  JOIN en_etapa Et	(NOLOCK)
	  ON EN.IdEtapa=Et.IdEtapa
		AND EN.BITJOA = 0
      JOIN dbo.EN_FrecuenciaEntregable f	(NOLOCK)
        ON EN.IdFrecuenciaEntregable = f.IdFrecuenciaEntregable
      JOIN dbo.CO_Regulador R	(NOLOCK)
        ON EN.IdRegulador			  = R.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON EN.IdMarcoLegal			  = M.IdMarcoLegal
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
      JOIN EN_ExcepcionesActividad EXACT	(NOLOCK)
        ON IE.idInstanciaEntregable   = EXACT.IdInstanciasEntregables
       AND 10001					  = EXACT.EstadoID
       AND @idUsuario				  =	EXACT.idUsuario
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EXACT.EstadoID             = EN_Estado.EstadoID
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable	  = CE.IdContratoEntregable
       AND TI.idEntregable            = CE.IdEntregable
       AND @IdContrato				  = CE.IdContrato
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
		AND 0						  = EN.BITJOA
	  JOIN en_etapa Et	(NOLOCK)
		ON EN.IdEtapa=Et.IdEtapa
      JOIN dbo.EN_FrecuenciaEntregable F	(NOLOCK)
        ON EN.IdFrecuenciaEntregable  = F.IdFrecuenciaEntregable
      JOIN dbo.CO_Regulador R	(NOLOCK)
        ON EN.IdRegulador             = R.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON EN.IdMarcoLegal            = M.IdMarcoLegal

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
          FROM #TempInstanciasAprobacion TI
      JOIN EN_InstanciasEntregable IE	(NOLOCK)
        ON TI.FechasLimiteAprobacion = IE.FechasLimiteAprobacion
      JOIN dbo.EN_Actividad	(NOLOCK)
        ON IE.ActividadID             = EN_Actividad.ActividadID
       AND @idUsuario				  =	EN_Actividad.idUsuario     
       AND 10002					  = EN_Actividad.EstadoID      
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EN_Actividad.EstadoID      = EN_Estado.EstadoID
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable    = CE.IdContratoEntregable
       AND TI.idEntregable            = CE.IdEntregable
       AND @IdContrato				  = CE.IdContrato              
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
		AND 0						  = EN.BITJOA 
	  JOIN en_etapa Et	(NOLOCK)
		ON EN.IdEtapa=Et.IdEtapa
      JOIN dbo.EN_FrecuenciaEntregable f	(NOLOCK)
        ON EN.IdFrecuenciaEntregable = f.IdFrecuenciaEntregable   
      JOIN dbo.CO_Regulador R	(NOLOCK)
        ON EN.IdRegulador             = R.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON EN.IdMarcoLegal			  = M.IdMarcoLegal             
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
          FROM #TempInstanciasAprobacion TI
      JOIN EN_InstanciasEntregable IE	(NOLOCK)
        ON TI.FechasLimiteAprobacion = IE.FechasLimiteAprobacion
      JOIN EN_ExcepcionesActividad EXACT	(NOLOCK)
        ON IE.idInstanciaEntregable   = EXACT.IdInstanciasEntregables
       AND 10002					  = EXACT.EstadoID             
       AND @idUsuario				  = EXACT.idUsuario            
      JOIN dbo.EN_Estado	(NOLOCK)
        ON EXACT.EstadoID             = EN_Estado.EstadoID
      JOIN EN_ContratoEntregable CE	(NOLOCK)
        ON IE.IdContratoEntregable	  = CE.IdContratoEntregable    
       AND TI.idEntregable            = CE.IdEntregable
       AND @IdContrato				  = CE.IdContrato              
      JOIN EN_Entregable EN	(NOLOCK)
        ON CE.IdEntregable            = EN.IdEntregable
		AND 0						  = EN.BITJOA 
	  JOIN en_etapa Et (NOLOCK)
		ON EN.IdEtapa=Et.IdEtapa	
      JOIN dbo.EN_FrecuenciaEntregable F	(NOLOCK)
        ON EN.IdFrecuenciaEntregable  = F.IdFrecuenciaEntregable
      JOIN dbo.CO_Regulador R	(NOLOCK)
        ON EN.IdRegulador             = R.IdRegulador
      JOIN dbo.EN_MarcoLegal M	(NOLOCK)
        ON EN.IdMarcoLegal            = M.IdMarcoLegal
     ORDER BY IE.FechasLimiteElaboracion ASC;
END;