-- =============================================
-- Author:    Reyna Olvera
-- Create date:  20/06/2017
-- Description:	Graficas
--=============================================

CREATE PROCEDURE [dbo].[sp_DG_InformacionGrafica_R]--3,24,1,10061
 @IdContrato int,
@IdGrafica AS int,
@Language AS int,
@IdUsuario int = 0
AS
BEGIN
  SET NOCOUNT ON;
  SET LANGUAGE spanish;

END;

IF OBJECT_ID('tempdb.dbo.#SumaNominacion', 'U') IS NOT NULL
DROP TABLE #SumaNominacion
CREATE TABLE #SumaNominacion
(
	Suma Float,
	idFecha DATE
)

  DECLARE @DiaPrimeroMes date;
  DECLARE @FechaActual date;

  SET @FechaActual = GETDATE();
  --SET @FechaActual = '2018-06-09';

  SELECT TOP 1
    @DiaPrimeroMes = PrimerDiaMes
  FROM AP_CALENDARIO
  WHERE MONTH(GETDATE()) = MONTH(PrimerDiaMes)
  AND YEAR(GETDATE()) = YEAR(PrimerDiaMes);

  DECLARE @FechaLimite datetime

  CREATE TABLE #DiasHabiles (
    Fecha datetime,
    Anio int,
    Mes int,
    Dia int,
    NumDiaHabil int
  );

  INSERT INTO #DiasHabiles (Fecha,
  Anio,
  Mes,
  Dia,
  NumDiaHabil)
    SELECT
      IdFecha,
      Anio,
      Mes,
      Dia,
      ROW_NUMBER() OVER (ORDER BY Dia) AS NumDiaHabil
    FROM dbo.AP_Calendario
    WHERE PrimerDiaMes = DATEADD(MONTH, 0, @DiaPrimeroMes)
    AND NombreDia NOT IN ('Sábado', 'Domingo')
    AND DiaFeriado <> 1
    ORDER BY Dia


  /*=================================================================================================
  								Tipo de Cambio Solo consulta ---IdGrafica 20
   ================================================================================================== */
  IF (@IdGrafica = 20)
  BEGIN
    SELECT TOP 500
      DATENAME(DAY, fecha) + ' ' + DATENAME(MONTH, fecha) + ' ' + DATENAME(YEAR, fecha) AS Fecha,
      TipoCambio,
      CASE @Language
        WHEN 1 THEN G.Titulo
        ELSE G.Title
      END AS Titulo,

      CASE @Language
        WHEN 1 THEN G.Titulo_yAxis
        ELSE G.Title_yAxis
      END AS Titulo_yAxis,
      'area' AS SerieType0,
      'datos' AS SerieName0
    FROM co_tipoCambioDiario
    LEFT OUTER JOIN DG_Grafica G
      ON @IdGrafica = G.Id_Grafica
    WHERE idMoneda = 1
    ORDER BY idTipoCambio DESC
  END
  ELSE

  /*==================================================================================================================
		Presupuesto     **No ordenado por fecha**  **y realizacion al momento** ----Grafica 2
 =====================================================================================================================*/
  IF (@IdGrafica = 2)
  BEGIN

    EXEC sp_DG_CalculoGrafica_R @IdContrato,
                                @IdGrafica,
                                @Language;  -- realiza calculo al momento

    SELECT
      *
    FROM DG_DatosGrafica
    WHERE IdGrafica = @IdGrafica
    AND Lenguaje = @Language
    AND IdContrato = @IdContrato
  END
  ELSE

  IF (@IdGrafica = 1)
  BEGIN
    --===========================================================================================================
    --							Grafica 1			 Precio WTS  Cada 5 día habil
    --===========================================================================================================

    SELECT
      @FechaLimite = DATEADD(MINUTE, 59, DATEADD(HOUR, 23, Fecha))
    FROM #DiasHabiles
    WHERE NumDiaHabil = 5

    IF @FechaLimite <= @FechaActual
    BEGIN
      EXEC sp_DG_CalculoGrafica_R @IdContrato,
                                  1,
                                 @Language;
 
    END


    SELECT
      *
    FROM DG_DatosGrafica
    WHERE IdGrafica = @IdGrafica
    AND Lenguaje = @Language
    AND IdContrato = @IdContrato
    ORDER BY Fecha;
  -- Busca en la tabla donde estan la informacion para las graficas por contrato

  END
  ELSE
   --===========================================================================================================
    --							Grafica 8			Porcentaje de Contenido Nacional
    --===========================================================================================================

    IF (@IdGrafica = 8)
  BEGIN
   
      EXEC sp_DG_CalculoGrafica_R @IdContrato,
                                  8,
                                 @Language;
	 
    SELECT
      *
    FROM DG_DatosGrafica
    WHERE IdGrafica = @IdGrafica
    AND Lenguaje = @Language
    AND IdContrato = @IdContrato
    ORDER BY Fecha;
  -- Busca en la tabla donde estan la informacion para las graficas por contrato

  END
   ELSE
       --===========================================================================================================
    --							Grafica 21			Porcentaje de Contenido Nacional Mensual
    --===========================================================================================================

    IF (@IdGrafica = 21)
  BEGIN

      EXEC sp_DG_CalculoGrafica_R @IdContrato,
                                  21,
                                 @Language;
	 
    SELECT
      *
    FROM DG_DatosGrafica
    WHERE IdGrafica = @IdGrafica
    AND Lenguaje = @Language
    AND IdContrato = @IdContrato
    ORDER BY Fecha;

  END
  ELSE
    --===========================================================================================================
    --							Grafica 22		Grafica para total produccion gas
    --===========================================================================================================

    IF (@IdGrafica = 22)
  BEGIN
  
      EXEC sp_DG_CalculoGrafica_R @IdContrato,
                                  22,
                                 @Language;
	 
    SELECT
      *
    FROM DG_DatosGrafica
    WHERE IdGrafica = @IdGrafica
    AND Lenguaje = @Language
    AND IdContrato = @IdContrato
    ORDER BY Fecha;
  
  END
  ELSE
   --===========================================================================================================
    --Graficas para los 10 días habiles
    --===========================================================================================================

  IF (@IdGrafica >= 11
    AND @IdGrafica <= 19)
  BEGIN
   
    SELECT
      @FechaLimite = DATEADD(MINUTE, 59, DATEADD(HOUR, 23, Fecha))
    FROM #DiasHabiles
    WHERE NumDiaHabil = 10

    IF @FechaLimite <= @FechaActual
    BEGIN

      EXEC [sp_DG_CalculoGraficaContrato_R] @IdContrato,
                                             @Language;
   
    END


    SELECT
      *
    FROM DG_DatosGrafica
    WHERE IdGrafica = @IdGrafica
    AND Lenguaje = @Language
    AND IdContrato = @IdContrato
    ORDER BY Fecha;

  END

    ELSE
  --**********************************GRAFICAS PARA JAGUAR ACEITE BPD
 IF (@IdGrafica = 23)
  BEGIN
  
Insert into #SumaNominacion
(
	Suma,
	idFecha
)
SELECT TOP 500
       SUM(VolumenProgramado),
       idFecha
FROM CO_NominacionVolumen N
    JOIN CO_PuntosdeEntregaContrato PTC
        ON N.puntoEntregaId = PTC.PuntoEntregaID
           AND n.idProductoNominacion = 1001
WHERE N.idContrato = @IdContrato
      AND PTC.idContrato = @IdContrato
      AND DATEADD(YEAR, -1, IdFecha) <= IdFecha
GROUP BY idFecha
ORDER BY idFecha ASC;


SELECT TOP 500
      
	   DATENAME(DAY, IDfecha) + ' ' + DATENAME(MONTH, IDfecha) + ' ' + DATENAME(YEAR, IDfecha) AS Fecha,
       2 AS CantidadSeries,
       CASE @Language
           WHEN 1 THEN
               G.Titulo
           ELSE
               G.Title
       END AS Titulo,
       CASE @Language
           WHEN 1 THEN
               G.Titulo_yAxis
           ELSE
               G.Title_yAxis
       END AS Titulo_yAxis,
       SUM(ProdAceiteNeto) AS SerieValues0,
       'area' AS SerieType0,
       'Producción' AS SerieName0,
      '#5e5965' as SerieColor0,
       ' BDP' AS valueSuffix,
       S.SUMA AS SerieValues1,
       'spline' AS SerieType1,
       'Proyección' AS SerieName1,
       '#000000' AS SerieColor1
FROM PR_ProdDiariaPozo_Previo prPre
    JOIN Pr_pozo pr
        ON prPre.Pozo = pr.id
    JOIN CO_PuntosdeEntregaContrato PTC
        ON pr.puntoEntregaId = PTC.PuntoEntregaID
    JOIN #SumaNominacion s
        ON s.idFecha = Fecha
    LEFT OUTER JOIN DG_Grafica G
        ON @IdGrafica = G.Id_Grafica
WHERE PTC.idContrato = @IdContrato
      AND DATEADD(YEAR, -1, IdFecha) <= IdFecha
      AND PTC.Activo = 1
GROUP BY IDfecha,
         S.SUMA,
         Titulo,
         title,
         G.Titulo_yAxis,
         Title_yAxis;

  END;

    ELSE
  IF (@IdGrafica = 24)
  BEGIN

Insert into #SumaNominacion
(
	Suma,
	idFecha
)
SELECT TOP 500
       SUM(VolumenProgramado),
       idFecha
FROM CO_NominacionVolumen N
    JOIN CO_PuntosdeEntregaContrato PTC
        ON N.puntoEntregaId = PTC.PuntoEntregaID
           AND n.idProductoNominacion = 1000
WHERE N.idContrato = @IdContrato
      AND PTC.idContrato = @IdContrato
      AND DATEADD(YEAR, -1, IdFecha) <= IdFecha
GROUP BY idFecha
ORDER BY idFecha ASC;


SELECT TOP 500
       DATENAME(DAY, IDfecha) + ' ' + DATENAME(MONTH, IDfecha) + ' ' + DATENAME(YEAR, IDfecha) AS Fecha,
       2 AS CantidadSeries,
       CASE @Language
           WHEN 1 THEN
               G.Titulo
           ELSE
               G.Title
       END AS Titulo,
       CASE @Language
           WHEN 1 THEN
               G.Titulo_yAxis
           ELSE
               G.Title_yAxis
       END AS Titulo_yAxis,
       SUM(GastoGas) AS SerieValues0,
       'area' AS SerieType0,
       'Producción' AS SerieName0,
       '#B00A0A' AS SerieColor0,
       ' MMPCD' AS valueSuffix,
       S.SUMA AS SerieValues1,
       'spline' AS SerieType1,
       'Proyección' AS SerieName1,
       '#000000' AS SerieColor1
FROM PR_ProdDiariaPozo_Previo prPre
    JOIN Pr_pozo pr
        ON prPre.Pozo = pr.id
    JOIN CO_PuntosdeEntregaContrato PTC
        ON pr.puntoEntregaId = PTC.PuntoEntregaID
    JOIN #SumaNominacion s
        ON s.idFecha = Fecha
    LEFT OUTER JOIN DG_Grafica G
        ON @IdGrafica = G.Id_Grafica
WHERE PTC.idContrato = @IdContrato
      AND DATEADD(YEAR, -1, IdFecha) <= IdFecha
      AND PTC.Activo = 1
GROUP BY IDfecha,
         S.SUMA,
         Titulo,
         title,
         G.Titulo_yAxis,
         Title_yAxis;


  END
  --********************************************************************************


  
