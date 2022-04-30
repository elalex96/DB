-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-10-02
-- Description:	
-- ============================================
-- Modificado Por:	Reyna 
-- Create date:		12 de Abril del 2022
-- Description:		se Actualiza el stored procedure  
--					para tomar en cuenta gastos con PCN >=0,
--				    tambien para poder retornar montos cuando el usuario selecciona Presupuesto: TODOS
--					tambien se modifica la conversión de dolares a pesor, ya que los montos no cuadraban con lo que se mostraba en las hojas
--					(issue 1890 adinco)
-- ============================================
-- Modificado Por:	Reyna 
-- Create date:		28 de Abril del 2022
-- Description:		Manda a llamar el nuevo sp para contratos de murphy
-- ============================================
CREATE PROCEDURE [dbo].[SP_SE_TotalFacturadoRubro] 
-- [SP_SE_TotalFacturadoRubro] 10018,1,10079,'2019-01-01','2019-12-01',2 --BIENES
-- [SP_SE_TotalFacturadoRubro] 10018,1,10079,'2019-01-01','2019-12-01',3 --SERVICIOS
-- Add the parameters for the stored procedure here
@IdContrato    INT, 
@IdUsuario     INT, 
@IdPresupuesto INT, 
@FInicio       DATE, 
@FFin          DATE, 
@IdRubro       INT,
@IdPeriodo INT,
@Etapa VARCHAR(20)
AS
     BEGIN
         SET NOCOUNT ON;
         /* SE AGREGA LA LLAMADA DEL NUEVO STORED PROCEDURE PARA MURPHY, DONDE MANDA A LLAMAR DATOS DE PROCURA/PETROVENDOR*/
		DECLARE @RazonSocial VARCHAR(100)='';
		SELECT @RazonSocial = CA.RazonSocial
		 FROM CO_CONTRATO	C
		 JOIN
			CO_CONTRATISTA CA
			ON	C.IdContratista	=	CA.IdContratista
			AND C.IdContrato	=	@IdContrato
			WHERE C.IdContrato	=	@IdContrato
		

		 IF(@RazonSocial = 'Murphy Sur, S. de R.L. de C.V.')
		 BEGIN
			EXEC [SP_SE_TotalFacturadoRubro_MPY]@IdContrato,@IdUsuario,@IdPresupuesto,@FInicio,@FFin,@IdRubro,@IdPeriodo,@Etapa;
		 END
		 ELSE
		 BEGIN
		  -- SE AGREGA LA OPCIÓN DE PRESUPUESTOS TODOS ISSUE 1890 RO
		 CREATE TABLE #Presupuestos(IdPresupuesto INT);
         CREATE TABLE #RFC(RFC VARCHAR(25));
	     CREATE TABLE #DATOS2
        (	Codigo                    VARCHAR(50), 
			Descripcion               VARCHAR(300), 
			RazonSocial               VARCHAR(300), 
			RFC                       VARCHAR(100), 
			SubTotal                  FLOAT, 
			SubTotalOriginal          FLOAT, 
			PCN                       FLOAT, 
			IdFactura                 INT, 
			IdAceptacionPedidoDetalle INT, 
			IdGastoRubro              INT, 
			IdRegistro                INT
        )

		  IF (@IdPresupuesto = 0) -- TODOS
			BEGIN
					IF 1 =
					 (
						 SELECT COUNT(1)
						 FROM dbo.CO_Presupuesto P (NOLOCK)
							  JOIN dbo.CO_AnioContractual AC (NOLOCK)
								ON P.IdAnioContractual = AC.IdAnioContractual
								AND P.idpresupuesto = @IdPresupuesto
							  JOIN dbo.CO_Contrato C (NOLOCK)
								ON AC.IdContrato = C.IdContrato
						 WHERE P.idpresupuesto = @IdPresupuesto
							   AND P.nombre LIKE '%exploración%'
							   AND C.IdContratista IN(10005, 10006)
					 )
						 BEGIN
							 INSERT INTO #Presupuestos(IdPresupuesto)
									SELECT P.IdPresupuesto
									FROM 
										CO_ProgramaActividad CPA (NOLOCK)
									JOIN 
										CO_PeriodoContrato CPC (NOLOCK)
										ON CPA.IdPeriodoContrato = CPC.IdPeriodo
									JOIN 
										CO_Presupuesto P (NOLOCK)
										ON CPA.IdProgramaActividad = P.IdProgramaActividad
									JOIN
										dbo.CO_AnioContractual AC (NOLOCK)
										ON P.IdAnioContractual = AC.IdAnioContractual
										AND P.nombre LIKE '%exploración%'
									JOIN 
										dbo.CO_Contrato C (NOLOCK)
										ON AC.IdContrato = C.IdContrato
									WHERE C.IdContrato = @IdContrato
										  AND P.nombre LIKE '%exploración%'
										  AND C.IdContratista IN(10005, 10006)
										 AND CPC.IdPeriodo = @IdPeriodo
										 AND P.Activo = 1
						 END;
						 ELSE
						 BEGIN
              
							INSERT INTO #Presupuestos
							(
								IdPresupuesto
							)
							SELECT CP.IdPresupuesto
							FROM CO_ProgramaActividad CPA (NOLOCK)
								INNER JOIN CO_PeriodoContrato CPC (NOLOCK)
									ON CPA.IdPeriodoContrato = CPC.IdPeriodo
								INNER JOIN CO_Presupuesto CP (NOLOCK)
									ON CPA.IdProgramaActividad = CP.IdProgramaActividad
							WHERE CPC.IdPeriodo = @IdPeriodo
								  AND CP.Activo = 1
						 END;
			END
			ELSE
			BEGIN --VERSION ANTERIOR (SOLO CON UN PRESUPUESTO)
				 IF 1 =
				 (
					 SELECT COUNT(1)
					 FROM dbo.CO_Presupuesto P (NOLOCK)
						  JOIN dbo.CO_AnioContractual AC (NOLOCK)
							ON P.IdAnioContractual = AC.IdAnioContractual
							AND P.idpresupuesto = @IdPresupuesto
						  JOIN dbo.CO_Contrato C (NOLOCK)
							ON AC.IdContrato = C.IdContrato
					 WHERE P.idpresupuesto = @IdPresupuesto
						   AND P.nombre LIKE '%exploración%'
						   AND C.IdContratista IN(10005, 10006)
				 )
					 BEGIN
						 INSERT INTO #Presupuestos(IdPresupuesto)
								SELECT P.IdPresupuesto
								FROM dbo.CO_Presupuesto P (NOLOCK)
									 JOIN dbo.CO_AnioContractual AC (NOLOCK)
										ON P.IdAnioContractual = AC.IdAnioContractual
										AND P.nombre LIKE '%exploración%'
									 JOIN dbo.CO_Contrato C (NOLOCK)
										ON AC.IdContrato = C.IdContrato
								WHERE C.IdContrato = @IdContrato
									  AND P.nombre LIKE '%exploración%'
									  AND C.IdContratista IN(10005, 10006);
					 END;
					 ELSE
					 BEGIN
					  INSERT INTO #Presupuestos(IdPresupuesto)
					 SELECT @IdPresupuesto;
					 END;
			END

				 /**/
				 INSERT INTO #RFC(RFC)
						SELECT 'FMP140930MW3'
						UNION
						SELECT 'SAT970701NN3';
						/**/
				 IF 1 =
				 (
					 SELECT COUNT(1)
					 FROM dbo.CO_Presupuesto P (NOLOCK)
						  JOIN dbo.CO_AnioContractual AC (NOLOCK)
							ON P.IdAnioContractual = AC.IdAnioContractual
							AND P.idpresupuesto = @IdPresupuesto
						  JOIN dbo.CO_Contrato C (NOLOCK)
							ON AC.IdContrato = C.IdContrato
					 WHERE P.idpresupuesto = @IdPresupuesto
						   AND C.IdContratista IN(10005, 10006)
				 )
					 BEGIN
						 INSERT INTO #RFC(RFC)
								SELECT 'FMO930803PB1'
								UNION
								SELECT 'GMS971110BTA';
					 END;

				 /*Consulta final*/

				 IF(@FFin <= '2018-12-01')
					 BEGIN
						 SELECT ISNULL(A.Codigo, 'SinClasificar') AS Codigo, 
								R.Comentarios AS Descripcion, 
								S.RazonSocial AS RazonSocial, 
								S.RFC AS RFC, 
								SUM(CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(20, 2))) AS SubTotal, 
								ISNULL(R.PCN, 0) AS PCN, 
								SUM(CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(20, 2))) AS CN, 
								ROW_NUMBER() OVER(ORDER BY F.IdFactura) AS ID, 
								ROW_NUMBER() OVER(PARTITION BY F.IdFactura, 
															   S.RFC ORDER BY R.Comentarios) AS Repetido, 
								F.IdFactura, 
								R.IdGastoRubro
						 INTO #DATOS
		   FROM	#Presupuestos PP (NOLOCK)
							 JOIN dbo.CO_LineaPresupuestoMes L (NOLOCK)
								ON PP.IdPresupuesto = L.IdPresupuesto
							JOIN dbo.CO_Registro R (NOLOCK)
								ON L.IdLineaPresupuestoMes = R.IdPrograma
							JOIN dbo.CO_Presupuesto P (NOLOCK)
								ON P.IdPresupuesto = PP.IdPresupuesto
							JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
								ON PA.IdProgramaActividad = P.IdProgramaActividad
							JOIN dbo.CO_TipoProgramaActividad TPA (NOLOCK)
								ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
							LEFT JOIN dbo.CO_PCNPorPeriodos PPP (NOLOCK)
								ON PPP.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
							LEFT JOIN dbo.FI_Factura F (NOLOCK)
								ON F.IdFactura = R.IdFactura
							LEFT JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK)
								ON F.IdMoneda <> TCD.IdMoneda
																	AND DAY(TCD.Fecha) = DAY(F.Fecha)
																	AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
																	AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
							LEFT JOIN dbo.PV_Subcontratista S (NOLOCK)
								ON S.IdSubcontratista = F.IdSubcontratista
							LEFT JOIN dbo.MM_BS_Actividad A (NOLOCK)
								ON R.IdCBSISH = A.IdActividad
						 WHERE(CAST(F.Fecha AS DATE) >= @FInicio
							   AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
							  AND S.RFC NOT IN
						 (
							 SELECT RFC
							 FROM #RFC
						 )
							  AND F.IdContrato = @IdContrato
							  AND PPP.IdContrato = @IdContrato
						 GROUP BY ISNULL(A.Codigo, 'SinClasificar'), 
								  R.Comentarios, 
								  S.RazonSocial, 
								  S.RFC, 
								  CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(20, 2)), 
								  ISNULL(R.PCN, 0), 
								  CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(20, 2)), 
								  F.IdFactura, 
								  R.IdGastoRubro
						 ORDER BY S.RFC;

						 /*RESUMEN*/

				IF(@IdRubro = 2)
							 BEGIN
								 SELECT CAST(ISNULL(SUM(SubTotal), 0) AS DECIMAL(20, 2)) AS SubTotalGastos, 
										IdGastoRubro AS IdRubroGasto
								 FROM #DATOS
								 WHERE IdGastoRubro = 2
								 GROUP BY IdGastoRubro;
							 END;
							 ELSE
							 BEGIN
								 SELECT CAST(ISNULL(SUM(SubTotal), 0) AS DECIMAL(20, 2)) AS SubTotalGastos, 
										IdGastoRubro AS IdRubroGasto
								 FROM #DATOS
								 WHERE IdGastoRubro = 3
								 GROUP BY IdGastoRubro;
							 END;
					 END;
					 ELSE
					 BEGIN

						 INSERT INTO #DATOS2
						 (Codigo, 
						  Descripcion, 
						  RazonSocial, 
						  RFC, 
						  SubTotal, 
						  SubTotalOriginal, 
						  PCN, 
						  IdFactura, 
						  IdAceptacionPedidoDetalle, 
						  IdGastoRubro, 
						  IdRegistro
						 )
						 SELECT DISTINCT 
								ISNULL(A.Codigo, 'SinClasificar') AS Codigo, 
								ISNULL(A.Nombre, 'SinClasificar') AS Descripcion, 
								S.RazonSocial AS RazonSocial, 
								S.RFC AS RFC, 
								CASE
								   WHEN f.IdMoneda <> 1 then
									   CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, f.Fecha) AS DECIMAL(20, 2))
								   ELSE
									   ISNULL(R.MontoRegistro, 0)
							   END AS SubTotal,
								F.SubTotal AS SubTotalOriginal, 
								R.PCN AS PCN, 
								F.IdFactura, 
								R.IdAceptacionPedidoDetalle, 
								R.IdGastoRubro, 
								R.IdRegistro
						 FROM 
							#Presupuestos PP
						JOIN dbo.CO_LineaPresupuestoMes L (NOLOCK)
							ON PP.IdPresupuesto = L.IdPresupuesto
						JOIN dbo.CO_Registro R (NOLOCK)
							ON L.IdLineaPresupuestoMeS = R.IdPrograma
							AND R.IdGastoRubro IN(2, 3)
						JOIN dbo.CO_Presupuesto P (NOLOCK)
							ON L.IdPresupuesto = P.IdPresupuesto
						JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
							ON P.IdProgramaActividad = PA.IdProgramaActividad
						JOIN dbo.CO_TipoProgramaActividad TPA (NOLOCK)
							ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
						LEFT JOIN dbo.FI_Factura F (NOLOCK)
							ON R.IdFactura = F.IdFactura
						LEFT JOIN dbo.PV_Subcontratista S (NOLOCK)
							ON F.IdSubcontratista = S.IdSubcontratista
							AND S.TipoPersonaFiscalID = 2
						LEFT JOIN dbo.MM_BS_Actividad A ON R.IdCBSISH = A.IdActividad
						 WHERE(CAST(F.Fecha AS DATE) >= @FInicio
							   AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
							  AND S.RFC NOT IN
						 (
							 SELECT RFC
							 FROM #RFC
						 )
							  AND F.IdContrato = @IdContrato
							  AND F.IdMoneda IN(1, 2)
							  AND R.IdGastoRubro IN(2, 3)
							  AND ISNULL(R.PCN, 0) >= 0
						 --ORDER BY ISNULL(A.Nombre, 'SinClasificar')
						 --
						 UNION
						 --
						 SELECT DISTINCT 
								ISNULL(A.Codigo, 'SinClasificar') AS Codigo, 
								ISNULL(A.Nombre, 'SinClasificar') AS Descripcion, 
								S.RazonSocial AS RazonSocial, 
								S.RFC AS RFC, 
							  CASE
								   WHEN f.IdMoneda <> 1 then
									   CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, f.Fecha) AS DECIMAL(20, 2))
								   ELSE
									   ISNULL(R.MontoRegistro, 0)
							   END AS SubTotal,
								F.SubTotal AS SubTotalOriginal, 
								R.PCN AS PCN, 
							 F.IdFactura, 
								R.IdAceptacionPedidoDetalle, 
								R.IdGastoRubro, 
								R.IdRegistro
						 FROM
							#Presupuestos PP
						JOIN dbo.CO_LineaPresupuestoMes L (NOLOCK)
							ON PP.IdPresupuesto = L.IdPresupuesto
						JOIN dbo.CO_Registro R (NOLOCK)
							ON L.IdLineaPresupuestoMeS = R.IdPrograma
							AND R.IdGastoRubro IN (2, 3)
						JOIN dbo.CO_Presupuesto P (NOLOCK)
							ON L.IdPresupuesto = P.IdPresupuesto
						JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
							ON P.IdProgramaActividad = PA.IdProgramaActividad
						JOIN dbo.CO_TipoProgramaActividad TPA (NOLOCK)
							ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
						LEFT JOIN dbo.FI_Factura F (NOLOCK)
							ON R.IdFactura = F.IdFactura
						LEFT JOIN dbo.PV_Subcontratista S (NOLOCK)
							ON F.IdSubcontratista = S.IdSubcontratista
															AND S.TipoPersonaFiscalID = 1
						LEFT JOIN dbo.MM_BS_Actividad A (NOLOCK)
							ON R.IdCBSISH = A.IdActividad
						 WHERE(CAST(F.Fecha AS DATE) >= @FInicio
							   AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
							  AND S.RFC NOT IN
						 (
							 SELECT RFC
							 FROM #RFC
						 )
							  AND F.IdContrato = @IdContrato
							  AND F.IdMoneda IN(1, 2)
							  AND R.IdGastoRubro IN(2, 3)
							 AND ISNULL(R.PCN, 0) >= 0
						 ORDER BY ISNULL(A.Nombre, 'SinClasificar')

						 /*RESUMEN*/

						 IF(@IdRubro = 2)
							 BEGIN
								 SELECT CAST(ISNULL(SUM(SubTotal), 0) AS DECIMAL(20, 2)) AS SubTotalGastos, 
										IdGastoRubro AS IdRubroGasto
								 FROM #DATOS2
								 WHERE IdGastoRubro = 2
								 GROUP BY IdGastoRubro;
							 END;
							 ELSE
							 BEGIN
								 SELECT CAST(ISNULL(SUM(SubTotal), 0) AS DECIMAL(20, 2)) AS SubTotalGastos, 
										IdGastoRubro AS IdRubroGasto
								 FROM #DATOS2
								 WHERE IdGastoRubro = 3
								 GROUP BY IdGastoRubro;
							 END;
					 END;
		END
     END;

