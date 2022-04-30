
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-10-02
-- Description:	
-- =============================================
-- Modificado Por:	Neri del Angel
-- Create date:		04 de Abril del 2022
-- Description:		Se agrega filtrado de todos
--					los presupuestos del periodo
--					seleccionado
-- ============================================
-- Modificado Por:	Reyna 
-- Create date:		13 de Abril del 2022
-- Description:		se Actualiza el stored procedure para mostrar el nuevo catalogo 
--					de mano de obra y para tomar en cuenta gastos con PCN >=0 (issue 1890 adinco)
-- ============================================
-- Modificado Por:	Reyna 
-- Create date:		28 de Abril del 2022
-- Description:		Manda a llamar el nuevo sp para contratos de murphy
-- ============================================

CREATE PROCEDURE [dbo].[SP_SE_A4]--10038,10109,0,'20210101','20211201',10195,'Exploración'
    @IdContrato INT,
    @IdUsuario INT,
    @IdPresupuesto INT,
    @FInicio DATE,
    @FFin DATE,
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
			 EXEC [SP_SE_A4_MPY]@IdContrato,@IdUsuario,@IdPresupuesto,@FInicio,@FFin,@IdPeriodo,@Etapa;
		 END
		 ELSE
		 BEGIN
			CREATE TABLE #Presupuestos (IdPresupuesto INT);
			CREATE TABLE #RFC (RFC VARCHAR(25));
			CREATE TABLE #Sueldos(SueldosSalarios DECIMAL(20, 2), SueldosSalariosNacional DECIMAL(20, 2), Catalogo VARCHAR(25), CatalogoId INT);


			DECLARE @CatalogoOtrosId int=0;
			SELECT  @CatalogoOtrosId = ID FROM CO_CAT_ManoDeObra

			INSERT INTO #Sueldos(SueldosSalarios, SueldosSalariosNacional, Catalogo, CatalogoId)
			SELECT 0,0,Nombre, Id FROM CO_CAT_ManoDeObra

			IF (@IdPresupuesto = 0)
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
				IF 1 =
				(
					SELECT COUNT(1)
					FROM #Presupuestos T
						JOIN dbo.CO_Presupuesto P (NOLOCK)
							ON T.IdPresupuesto = P.IdPresupuesto
						JOIN dbo.CO_AnioContractual AC (NOLOCK)
							ON P.IdAnioContractual = AC.IdAnioContractual
						JOIN dbo.CO_Contrato C (NOLOCK)
							ON AC.IdContrato = C.IdContrato
					WHERE P.nombre LIKE '%exploración%'
						  AND C.IdContratista IN ( 10005, 10006 )
				)
				BEGIN
					DELETE FROM #Presupuestos
					INSERT INTO #Presupuestos
					(
						IdPresupuesto
					)
					SELECT P.IdPresupuesto
					FROM dbo.CO_Presupuesto P (NOLOCK)
						JOIN dbo.CO_AnioContractual AC (NOLOCK)
							ON P.IdAnioContractual = AC.IdAnioContractual
						JOIN dbo.CO_Contrato C (NOLOCK)
							ON AC.IdContrato = C.IdContrato
					WHERE C.IdContrato = @IdContrato
						  AND P.nombre LIKE '%exploración%'
						  AND C.IdContratista IN ( 10005, 10006 );
				END;
			END
			ELSE
			BEGIN
				IF 1 =
				(
					SELECT COUNT(1)
					FROM dbo.CO_Presupuesto P (NOLOCK)
						JOIN dbo.CO_AnioContractual AC (NOLOCK)
							ON P.IdAnioContractual = AC.IdAnioContractual
						JOIN dbo.CO_Contrato C (NOLOCK)
							ON AC.IdContrato = C.IdContrato
					WHERE P.IdPresupuesto = @IdPresupuesto
						  AND P.Nombre LIKE '%exploración%'
						  AND C.IdContratista IN ( 10005, 10006 )
				)
				BEGIN
					INSERT INTO #Presupuestos
					(
						IdPresupuesto
					)
					SELECT P.IdPresupuesto
					FROM dbo.CO_Presupuesto P (NOLOCK)
						JOIN dbo.CO_AnioContractual AC (NOLOCK)
							ON P.IdAnioContractual = AC.IdAnioContractual
						JOIN dbo.CO_Contrato C (NOLOCK)
							ON AC.IdContrato = C.IdContrato
					WHERE C.IdContrato = @IdContrato
						  AND P.Nombre LIKE '%exploración%'
						  AND C.IdContratista IN ( 10005, 10006 );
				END;
				ELSE
				BEGIN
					INSERT INTO #Presupuestos
					(
						IdPresupuesto
					)
					SELECT @IdPresupuesto;
				END;
			END
			/*RFC*/
			INSERT INTO #RFC
			(
				RFC
			)
			SELECT 'FMP140930MW3'
			UNION
			SELECT 'SAT970701NN3';
			IF 1 =
			(
				SELECT COUNT(1)
			FROM dbo.CO_Presupuesto P (NOLOCK)
					JOIN dbo.CO_AnioContractual AC (NOLOCK)
						ON P.IdAnioContractual = AC.IdAnioContractual
					JOIN dbo.CO_Contrato C (NOLOCK)
						ON AC.IdContrato = C.IdContrato
				WHERE P.idpresupuesto = @IdPresupuesto
					  AND C.IdContratista IN ( 10005, 10006 )
			)
			BEGIN
				INSERT INTO #RFC
				(
					RFC
				)
				SELECT 'FMO930803PB1'
				UNION
				SELECT 'GMS971110BTA';
			END;

			/*Consulta final*/
			SELECT SUM(   CASE
							  WHEN f.IdMoneda <> 1 then
								  CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, f.Fecha) AS DECIMAL(20, 2))
							  ELSE
								  ISNULL(R.MontoRegistro, 0)
						  END
					  ) AS SueldosSalarios,
				   SUM(   CASE
							  WHEN f.IdMoneda <> 1 then
								  CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, f.Fecha) AS DECIMAL(20, 2))
							  ELSE
								  ISNULL(R.MontoRegistro, 0)
						  END * CAST(PCN AS DECIMAL(20, 3))
					  ) AS SueldosSalariosNacional,
				   ISNULL(R.IdCatManoObra,@CatalogoOtrosId) AS IdCatManoObra
			INTO #DATOS
			FROM dbo.CO_Registro R (NOLOCK)
				JOIN dbo.FI_Factura F (NOLOCK)
					ON R.IdFactura = F.IdFactura
				JOIN dbo.PV_Subcontratista S (NOLOCK)
					ON F.IdSubcontratista = S.IdSubcontratista
				JOIN dbo.CO_LineaPresupuestoMes L (NOLOCK)
					ON R.IdPrograma = L.IdLineaPresupuestoMes
				JOIN #Presupuestos PP
					ON L.IdPresupuesto = PP.IdPresupuesto
				JOIN dbo.CO_Presupuesto P (NOLOCK)
					ON PP.IdPresupuesto = P.IdPresupuesto
				JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
					ON P.IdProgramaActividad = PA.IdProgramaActividad
				JOIN dbo.CO_TipoProgramaActividad TPA (NOLOCK)
					ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
			WHERE (
					  CAST(F.Fecha AS DATE) >= @FInicio
					  AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin)
				  )
				  AND R.IdGastoRubro = 1
				  AND S.RFC NOT IN (
									   SELECT RFC FROM #RFC
								   )
				  AND F.IdContrato = @IdContrato
					AND ISNULL(R.PCN, 0) >= 0
				  AND F.IdMoneda IN ( 1, 2 )
			GROUP BY R.IdCatManoObra;

	
			UPDATE S
			SET S.SueldosSalarios = D.SueldosSalarios,
			S.SueldosSalariosNacional = D.SueldosSalariosNacional
			FROM 
				#SUELDOS S
			JOIN
				#DATOS D
				ON	S.CatalogoId	=	D.IdCatManoObra;
		
	
			SELECT SueldosSalarios,SueldosSalariosNacional, Catalogo FROM #SUELDOS;
			END
END;

