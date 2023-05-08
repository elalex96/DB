-- =============================================
-- Author:		Alexander Gomez
-- Create date: 15/05/2019
-- Description:	Consulta y calculo de los conceptos calsificados en el reporte de porcentaje de contneido nacional
-- =============================================
CREATE PROCEDURE [dbo].[SP_CN_RPT_MontosConceptoCNH] --3,3
	-- Add the parameters for the stored procedure here
	@IdContrato    INT,
	@IdPresupuesto INT,
	@Anio int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	--CONCEPTOS CN
	DECLARE @CNB FLOAT;
	DECLARE @CNMO FLOAT;
	DECLARE @CNS FLOAT;
	DECLARE @CNC FLOAT;
	DECLARE @TT FLOAT;
	DECLARE @I FLOAT;
	DECLARE @B FLOAT;
	DECLARE @S FLOAT;
	DECLARE @MO FLOAT;
	DECLARE @C FLOAT;

	DECLARE @FECHAINICIO DATE = CAST(@Anio AS NVARCHAR(50)) +'-01-01';
	 DECLARE @FECHAFIN DATETIME = CAST(@Anio AS NVARCHAR(50)) +'-12-01';

	CREATE TABLE #Presupuestos ( IdPresupuesto INT);
	
	--ANEXO 2
	SELECT ISNULL(A.Codigo, 'SinClasificar') AS Codigo, 
           R.Comentarios AS Descripcion, 
           S.RazonSocial AS RazonSocial, 
           S.RFC AS RFC, 
           CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)) AS SubTotal, 
           ISNULL(R.PCN, 0) AS PCN, 
           CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)) AS CN,
           ROW_NUMBER() OVER(ORDER BY F.IdFactura) AS ID, 
           ROW_NUMBER() OVER(PARTITION BY F.IdFactura, 
           S.RFC ORDER BY R.Comentarios) AS Repetido, 
           F.IdFactura
    INTO #DATOSANEXO2
    FROM Adinco.dbo.CO_Registro R
                      JOIN Adinco.dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
                      JOIN Adinco.dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
                      JOIN Adinco.dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                      JOIN Adinco.dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                      LEFT JOIN Adinco.dbo.CO_PCNPorPeriodos PPP ON PPP.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
                      LEFT JOIN Adinco.dbo.FI_Factura F ON F.IdFactura = R.IdFactura
                      LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                               AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                               AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                               AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                      LEFT JOIN Adinco.dbo.PV_Subcontratista S ON S.IdSubcontratista = F.IdSubcontratista
                      LEFT JOIN Adinco.dbo.MM_BS_Actividad A ON R.IdCBSISH = A.IdActividad
                      LEFT JOIN Adinco.dbo.CO_Servicio SE ON SE.IdServicio = L.IdServicio
                 WHERE (F.Fecha >= @FECHAINICIO
                            AND F.Fecha <= EOMONTH(@FECHAFIN))
                       AND R.IdGastoRubro = 2
					   AND F.IdContrato = @IdContrato
					   AND ISNULL(R.PCN,0) <> 0
                 GROUP BY ISNULL(A.Codigo, 'SinClasificar'), 
                          R.Comentarios, 
                          S.RazonSocial, 
                          S.RFC, 
                          CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)), 
                          ISNULL(R.PCN, 0), 
                          CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)), 
                          --R.MesPresentacion,
                          F.IdFactura
                 ORDER BY S.RFC

	SET @CNB = (SELECT SUM(SubTotal)  FROM #DATOSANEXO2);
	SET @B = (SELECT SUM(CN)  FROM #DATOSANEXO2);

	--ANEXO 3
	DECLARE @TOTALFACTURADO FLOAT;
	DECLARE @TOTALCNMONT FLOAT;
	DECLARE @TOTALCN FLOAT;

	CREATE TABLE #ANEXO3 (
	Codigo NVARCHAR(100),
	Descripcion NVARCHAR(MAX),
	RazonSocial NVARCHAR(MAX),
	RFC NVARCHAR(100),
	Subtotal FLOAT,
	PCN FLOAT,
	CN FLOAT,
	ID INT,
	Repetido INT,
	IdFactura INT
	);

	INSERT INTO #ANEXO3
    SELECT ISNULL(A.Codigo, 'SinClasificar') AS Codigo, 
           R.Comentarios AS Descripcion, 
           S.RazonSocial AS RazonSocial, 
           S.RFC AS RFC, 
           SUM(CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))) AS SubTotal, 
           ISNULL(R.PCN, 0) AS PCN, 
           SUM(CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))) AS CN,  
           ROW_NUMBER() OVER(ORDER BY F.IdFactura) AS ID, 
           ROW_NUMBER() OVER(PARTITION BY F.IdFactura, 
           S.RFC ORDER BY R.Comentarios) AS Repetido, 
           F.IdFactura
     FROM Adinco.dbo.CO_Registro R
                      JOIN Adinco.dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
                      JOIN Adinco.dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
                      JOIN Adinco.dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                      JOIN Adinco.dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                      LEFT JOIN Adinco.dbo.CO_PCNPorPeriodos PPP ON PPP.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
                      LEFT JOIN Adinco.dbo.FI_Factura F ON F.IdFactura = R.IdFactura
                      LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                               AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                               AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                               AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                      LEFT JOIN Adinco.dbo.PV_Subcontratista S ON S.IdSubcontratista = F.IdSubcontratista
                      LEFT JOIN Adinco.dbo.MM_BS_Actividad A ON R.IdCBSISH = A.IdActividad
                      LEFT JOIN Adinco.dbo.CO_Servicio SE ON SE.IdServicio = L.IdServicio
                 WHERE 
                       (F.Fecha >= @FECHAINICIO
                            AND F.Fecha <= EOMONTH(@FECHAFIN))
                       AND R.IdGastoRubro = 3
                       AND F.IdContrato = @IdContrato
                       AND ISNULL(R.PCN,0) <> 0
                 AND PPP.IdContrato = @IdContrato
                 GROUP BY ISNULL(A.Codigo, 'SinClasificar'), 
                          R.Comentarios, 
                          S.RazonSocial, 
                          S.RFC, 
                          CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)), 
                          ISNULL(R.PCN, 0), 
                          CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)), 
                          F.IdFactura
                 ORDER BY S.RFC;

		SET @TOTALFACTURADO = (SELECT SUM(SubTotal) FROM #ANEXO3);

		SET @TOTALCNMONT = (SELECT SUM(CN) FROM #ANEXO3);

		SET @TOTALCN = ((100 * @TOTALCNMONT) / @TOTALFACTURADO);
		
		SET @CNS = @TOTALCNMONT;
		SET @S = @TOTALFACTURADO;
		
		--ANEXO 4

		SELECT SUM(CASE
                        WHEN R.IdGastoRubro = 1
                             AND R.CvTipoDocFacturacion = 1
                        THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        WHEN R.IdGastoRubro = 2
                             AND R.CvTipoDocFacturacion = 1
                        THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        WHEN R.IdGastoRubro = 3
                             AND R.CvTipoDocFacturacion = 1
                        THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        WHEN R.IdGastoRubro = 4
                             AND R.CvTipoDocFacturacion = 1
                        THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        WHEN R.IdGastoRubro = 5
                             AND R.CvTipoDocFacturacion = 1
                        THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        ELSE 0
                    END) AS SueldosSalarios, 
                SUM(CASE
                        WHEN R.IdGastoRubro = 1
                             AND R.CvTipoDocFacturacion = 1
                        THEN CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        WHEN R.IdGastoRubro = 2
                             AND R.CvTipoDocFacturacion = 1
                        THEN CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        WHEN R.IdGastoRubro = 3
                             AND R.CvTipoDocFacturacion = 1
                        THEN CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        WHEN R.IdGastoRubro = 4
                             AND R.CvTipoDocFacturacion = 1
                        THEN CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        WHEN R.IdGastoRubro = 5
                             AND R.CvTipoDocFacturacion = 1
                        THEN CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        ELSE 0
                    END) AS SueldosSalariosNacional, 
                GR.IdGastoRubro
         INTO #ANEXO4
         FROM Adinco.dbo.CO_Registro R
              JOIN Adinco.dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
              JOIN Adinco.dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
              JOIN Adinco.dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
              JOIN Adinco.dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
              LEFT JOIN Adinco.dbo.FI_Factura F ON F.IdFactura = R.IdFactura
              LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                       AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                       AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                       AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
              LEFT JOIN Adinco.dbo.PV_Subcontratista S ON S.IdSubcontratista = F.IdSubcontratista
              LEFT JOIN Adinco.dbo.CO_Servicio SE ON SE.IdServicio = L.IdServicio
              RIGHT OUTER JOIN Adinco.dbo.CO_GastosRubro GR ON GR.IdGastoRubro = R.IdGastoRubro
         WHERE 
			    (F.Fecha >= @FECHAINICIO
                    AND F.Fecha <= EOMONTH(@FECHAFIN))
               AND GR.IdGastoRubro = 1 
			   AND F.IdContrato = @IdContrato
         GROUP BY GR.IdGastoRubro;

		 SELECT ISNULL(D.SueldosSalarios, 0) AS SueldosSalarios, 
                ISNULL(D.SueldosSalariosNacional, 0) AS SueldosSalariosNacional, 
                GR.IdGastoRubro
		INTO #DATOSANEXO4
         FROM #ANEXO4 D
              RIGHT JOIN Adinco.dbo.CO_GastosRubro GR ON D.IdGastoRubro = GR.IdGastoRubro
         WHERE GR.IdGastoRubro <> 6
         ORDER BY GR.IdGastoRubro DESC;

		 SET @CNMO = (SELECT SUM(SueldosSalariosNacional) FROM #DATOSANEXO4);


		SET @MO = (SELECT SUM(SueldosSalarios) FROM #DATOSANEXO4);

		--ANEXO 5

		SELECT ROW_NUMBER() OVER(ORDER BY R.Comentarios) AS NoCapacitacion, 
                R.Comentarios AS Descripcion, 
                S.RazonSocial AS RazonSocial, 
                S.RFC AS RFC, 
                CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)) AS SubTotal, 
                ISNULL(R.PCN, 0) AS PCN, 
                CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)) AS CN, 
                ROW_NUMBER() OVER(ORDER BY F.IdFactura) AS ID, 
                ROW_NUMBER() OVER(PARTITION BY F.IdFactura, 
                                               S.RFC ORDER BY R.Comentarios) AS Repetido, 
                F.IdFactura
		INTO #ANEXO5
         FROM Adinco.dbo.CO_Registro R
              JOIN Adinco.dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
              JOIN Adinco.dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
              JOIN Adinco.dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
              JOIN Adinco.dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
              LEFT JOIN Adinco.dbo.CO_PCNPorPeriodos PPP ON PPP.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
              LEFT JOIN Adinco.dbo.FI_Factura F ON F.IdFactura = R.IdFactura
              LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                       AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                       AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                       AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
              LEFT JOIN Adinco.dbo.PV_Subcontratista S ON S.IdSubcontratista = F.IdSubcontratista
              LEFT JOIN Adinco.dbo.MM_BS_Actividad A ON R.IdCBSISH = A.IdActividad
              LEFT JOIN Adinco.dbo.CO_Servicio SE ON SE.IdServicio = L.IdServicio
         WHERE (F.Fecha >= @FECHAINICIO
                    AND F.Fecha <= EOMONTH(@FECHAINICIO))
               AND R.IdGastoRubro = 4
			   AND F.IdContrato = @IdContrato
         GROUP BY ISNULL(A.Codigo, 'SinClasificar'), 
                  R.Comentarios, 
                  S.RazonSocial, 
                  S.RFC, 
                  CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)), 
                  ISNULL(R.PCN, 0), 
                  CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)), 
				  F.IdFactura
         ORDER BY F.IdFactura;

		 SET @C = (SELECT SUM(SubTotal) FROM #ANEXO5);

		 SET @CNC = (SELECT SUM(CN) FROM #ANEXO5);

		 --ANEXO 6

		 SELECT ROW_NUMBER() OVER(ORDER BY R.Comentarios) AS NoGasto, 
                R.Comentarios AS Descripcion, 
                ISNULL(CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)), 0) AS SubTotal
		INTO #ANEXO6
         FROM Adinco.dbo.CO_Registro R
              JOIN Adinco.dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
              JOIN Adinco.dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
              JOIN Adinco.dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
              JOIN Adinco.dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
              LEFT JOIN Adinco.dbo.CO_PCNPorPeriodos PPP ON PPP.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
              LEFT JOIN Adinco.dbo.FI_Factura F ON F.IdFactura = R.IdFactura
              LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                       AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                       AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                       AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
              LEFT JOIN Adinco.dbo.PV_Subcontratista S ON S.IdSubcontratista = F.IdSubcontratista
              LEFT JOIN Adinco.dbo.CO_Servicio SE ON SE.IdServicio = L.IdServicio
         WHERE (F.Fecha >= @FECHAINICIO
                    AND F.Fecha <= EOMONTH(@FECHAFIN))
               AND R.IdGastoRubro = 5
			   AND F.IdContrato = @IdContrato

		SET @TT = (SELECT SUM(SubTotal) FROM #ANEXO6);

		--ANEXO 7

		SELECT ROW_NUMBER() OVER(ORDER BY R.Comentarios) AS NoGasto, 
                R.Comentarios AS Descripcion,  
                ISNULL(CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)), 0) AS SubTotal
		INTO #ANEXO7
         FROM Adinco.dbo.CO_Registro R
              JOIN Adinco.dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
              JOIN Adinco.dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
              JOIN Adinco.dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
              JOIN Adinco.dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
              LEFT JOIN Adinco.dbo.CO_PCNPorPeriodos PPP ON PPP.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
              LEFT JOIN Adinco.dbo.FI_Factura F ON F.IdFactura = R.IdFactura
              LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                       AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                       AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                       AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
              LEFT JOIN Adinco.dbo.PV_Subcontratista S ON S.IdSubcontratista = F.IdSubcontratista
              LEFT JOIN Adinco.dbo.CO_Servicio SE ON SE.IdServicio = L.IdServicio
         WHERE (F.Fecha >= @FECHAFIN
                    AND F.Fecha <= EOMONTH(@FECHAFIN))
               AND R.IdGastoRubro = 6
			   AND F.IdContrato = @IdContrato

		SET @I = (SELECT SUM(SubTotal) FROM #ANEXO7);

		--RESULTADOS DE LOS CONCEPTOS CN

		SELECT
			ISNULL(@CNB,0) AS CNB,
			ISNULL(@CNMO,0) AS CNMO,
			ISNULL(@CNS,0) AS CNS,
			ISNULL(@CNC,0) AS CNC,
			ISNULL(@TT,0) AS TT,
			ISNULL(@I,0) AS I,
			ISNULL(@B,0) AS B,
			ISNULL(@S,0) AS S,
			ISNULL(@MO,0) AS MO,
			ISNULL(@C,0) AS C
END
