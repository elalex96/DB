CREATE PROCEDURE dbo.SP_PC_GeneraComercializaciones
	@IdContrato INT,
    @MesReporte VARCHAR(10),
	@Usuario	INT,
	@Debug		BIT
AS
BEGIN
-- =============================================
-- Author:		Barbara Arrañaga
-- Create date: 2018-03-20
-- Description:	Procedimiento que genera las comercialicaciones de todos los hidrocarburos
-- Parametros de Entrada:	Numero de Contrato y Mes de Calculo
-- =============================================
SET NOCOUNT ON
-- =============================================
CREATE TABLE #DiasHabiles
(
	Fecha	DATETIME,
	Anio	INT,
	Mes		INT,
	Dia		INT,
	NumDiaHabil	INT
)

DECLARE
	@FechaLimite	DATETIME,
	@NumError	INT,
	@MensajeError	VARCHAR(500),
	@Mes	DATE

SELECT @Mes = DATEFROMPARTS( SUBSTRING( @MesReporte, 7, 4 ), SUBSTRING( @MesReporte, 4, 2 ), SUBSTRING( @MesReporte, 1, 2 ) )

-- SE VALIDA QUE EL CONTRATO DEL QUE SE ESTA GENERANDO LA INFORMACIÓN SEA DE CONSORCIO CON PEMEX
IF 1 = (SELECT ISNULL(isPC,0) 
			FROM dbo.CO_Contrato
			WHERE IdContrato = @IdContrato)
BEGIN
	-- SE VALIDA QUE EL REPORTE SE ESTE GENERANDO DURANTE LOS PRIMEROS 10 DIAS HABILES DEL SIGUIENTE MES
	INSERT INTO #DiasHabiles
	(
		Fecha,
		Anio,
		Mes,
		Dia,
		NumDiaHabil
	)
	SELECT
		IdFecha,
		Anio,
		Mes,
		Dia,
		ROW_NUMBER() OVER (ORDER BY Dia) AS NumDiaHabil
	  FROM
		dbo.AP_Calendario
	 WHERE
		PrimerDiaMes  = DATEADD( MONTH, 1, @Mes )
	   AND NombreDia NOT IN ( 'Sábado', 'Domingo' )
	   AND DiaFeriado <> 1
	 ORDER BY
		Dia
	
	SELECT 
		@FechaLimite = IdFecha
	FROM
		AP_Calendario
	WHERE
		Descripcion = 'Recepción de Información para el cálculo de contraprestaciones'
		AND
		Anio = YEAR(@Mes)
		AND 
		Mes	=	MONTH( DATEADD( MONTH, 1, @Mes ))

	-- Verificamos que no haya ocurrido ningun Error
	SELECT @NumError = @@ERROR
	IF @NumError <> 0
	BEGIN
		SELECT @MensajeError = 'Error al insertar en #DiasHabiles'+
		'En el Stored Procedure: dbo.SP_PC_GeneraComercializaciones '+
		'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
		GOTO ERROR
	END	-- IF @NumError <> 0

	SELECT
		@FechaLimite	=	DATEADD (MINUTE, 59, DATEADD(HOUR, 23, @FechaLimite))
	--FROM
	--	#DiasHabiles
	--WHERE
	--	NumDiaHabil	=	10

	--Calculo del volumen de crudo a vender basado en reparticion preliminar
	IF @FechaLimite >= GETDATE()
	BEGIN

		DELETE FROM	PC_Volumenes
		WHERE
			IdContrato = @IdContrato
			AND Mes     = @Mes	--@MesReporte

		SELECT @NumError = @@ERROR
		IF @NumError <> 0
		BEGIN
			SELECT @MensajeError = 'Error al eliminar en PC_Volumenes'+
			'En el Stored Procedure: dbo.SP_PC_GeneraComercializaciones '+
			'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
			GOTO ERROR
		END	-- IF @NumError <> 0

		-- SI EL CONTRATO ES DE PRODUCCION COMPARTIDA, SE GENERA LA INFORMACION DE LOS VOLUMENES A PARTIR DE LOS PERIODOS Y DE LAS COMPENSACIONES
		IF 2 = (SELECT ISNULL(IdTipoContrato,0) 
			FROM dbo.CO_Contrato
			WHERE IdContrato = @IdContrato)
		BEGIN
			-- SE EJECUTA PROCEDIMIENTO PARA LA GENERACION DE LAS TABLAS PR_VolumenMensualProduccionPetroleo Y SIPAC_RM_FMP_53_M
			-- Necesarias para el calculo de la tabla PC_Volumenes
			EXEC PC_Generar_VolMensualProduccion_RM53 @IdContrato, @Mes, @Usuario, @FechaLimite, @Debug

			INSERT INTO dbo.PC_Volumenes
			(
				IdContrato,
				Mes,
				Petroleo,
				Condensado,
				C1,
				C2,
				C3,
				C4,
				C5
			)
			SELECT
				@IdContrato,
				@Mes,
				--CASE    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo < 0 THEN
				ROUND( (VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100))	+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo, 0 )
				--		ELSE	ROUND( (((VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100)))),0)
				--END 
				AS Crudo,
				--CASE	WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado < 0 THEN
				ROUND( (((VMPPG.VolumenCondensadoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100))	+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado )),0)
				--		ELSE		ROUND( ((VMPPG.VolumenCondensadoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100))),0)
				--END
				AS Condensado,
				--CASE	WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1 < 0 THEN
				ROUND( ((VMPPG.MetanoC1 * (FMP53.NuevaDistribucionProvisionalContratistaC1 / 100))	+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1),0)
				--		ELSE ROUND(((VMPPG.MetanoC1 * (FMP53.NuevaDistribucionProvisionalContratistaC1 / 100))), 0 )
				--END
				AS C1,
				--CASE	WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2 < 0 THEN
				ROUND( ((VMPPG.EtanoC2 * (FMP53.NuevaDistribucionProvisionalContratistaC2 / 100) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2)),0)
				--		ELSE ROUND(((VMPPG.EtanoC2 * (FMP53.NuevaDistribucionProvisionalContratistaC2 / 100))), 0 )
				--END
				AS C2,
				--CASE	WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3 < 0 THEN
				ROUND( (((VMPPG.PropanoC3 * (FMP53.NuevaDistribucionProvisionalContratistaC3 / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3)),0)
				--		ELSE ROUND(((VMPPG.PropanoC3 * (FMP53.NuevaDistribucionProvisionalContratistaC3 / 100))), 0 )
				--END
				AS C3,
				--CASE	WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 < 0 THEN
				ROUND( (((VMPPG.ButanoC4 * (FMP53.NuevaDistribucionProvisionalContratistaC4 / 100))	+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4)),0)
				--		ELSE ROUND(((VMPPG.ButanoC4 * (FMP53.NuevaDistribucionProvisionalContratistaC4 / 100))), 0 )
				--END 
				AS C4,
				ROUND( (((VMPPG.VolumenCondensablePuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratistaC5 / 100)) )),0)
			FROM
				PR_VolumenMensualProduccionPetroleo VMPPG
			LEFT JOIN
				CO_Contrato                         C
				ON VMPPG.IdContrato            = C.IdContrato
			LEFT JOIN
				CO_Contratista                      Ca
				ON C.IdContratista             = Ca.IdContratista
			LEFT JOIN
				SIPAC_RM_FMP_53_M                   FMP53
				ON FMP53.IdContrato            = @IdContrato
				AND DATEADD( MONTH, 1, DATEFROMPARTS( FMP53.AnioReporte, FMP53.MesReporte, 1 )) = @Mes	--@MesReporte
			WHERE
				VMPPG.IdContrato    = @IdContrato
				AND VMPPG.MesReporte = @Mes	--@MesReporte

			SELECT @NumError = @@ERROR
			IF @NumError <> 0
			BEGIN
				SELECT @MensajeError = 'Error al insertar en PC_Volumenes'+
				'En el Stored Procedure: dbo.SP_PC_GeneraComercializaciones '+
				'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
				GOTO ERROR
			END	-- IF @NumError <> 0
		END
		ELSE		-- ES CONTRATO DE LICENCIA EN CONSORCIO CON PEMEX
		BEGIN
			INSERT INTO dbo.PC_Volumenes
				(
					IdContrato,
					Mes,
					Petroleo,
					Condensado,
					C1,
					C2,
					C3,
					C4,
					C5
				)
			SELECT
				IdContrato,
				MesReporte,
				ROUND(VolumenPetroleoPuntoMedicion,0),
				ROUND(VolumenCondensadoPuntoMedicion,0),
				ROUND(MetanoC1,0),
				ROUND(EtanoC2,0),
				ROUND(PropanoC3,0),
				ROUND(ButanoC4,0),
				ROUND(VolumenCondensablePuntoMedicion,0)
			FROM
				PR_VolumenMensualProduccionPetroleo
			WHERE
				IdContrato	=	@IdContrato
				AND
				MesReporte	=	@Mes	--@MesReporte

			SELECT @NumError = @@ERROR
			IF @NumError <> 0
			BEGIN
				SELECT @MensajeError = 'Error al insertar en PC_Volumenes'+
				'En el Stored Procedure: dbo.SP_PC_GeneraComercializaciones '+
				'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
				GOTO ERROR
			END	-- IF @NumError <> 0
		END

		-- SE EJECUTA PROCEDIMIENTO PARA GENERAR LA CROMATOGRAFIA DE LOS COMPONENTES DEL GAS DE ACUERDO A LO REGISTRADO EN LAS FACTURAS
		EXEC SP_PC_GenerarCFDICromatografia @IdContrato, @Mes, @Usuario

		-- SE EJECUTA EL PROCEDIMIENTO SI EL CONTRATO CUENTA CON VOLUMEN DE PRODUCCION DE PETROLEO
		IF 0 < (SELECT ISNULL(Petroleo,0)
				FROM PC_Volumenes 
				WHERE IdContrato = @IdContrato
				AND Mes = @Mes	--@MesReporte
				)
		BEGIN
			-- SE EJECUTA EL CALCULO DE COMERCIALIZACIONES PARA PETROLEO
			EXEC SP_PC_GenerarComercializacionesPetroleo @IdContrato, @Mes, @Usuario, @FechaLimite, @Debug
		END
   
		IF 0 < (SELECT ISNULL(C1,0)
				FROM PC_Volumenes 
				WHERE IdContrato = @IdContrato
				AND Mes = @Mes	--@MesReporte
				)
		BEGIN
			-- SE EJECUTA EL CALCULO DE COMERCIALIZACIONES PARA COMPONENTE DEL GAS
			EXEC dbo.sp_COM_CalculaComercializacionesGasyCondensable @IdContrato, @Mes, @Usuario, @FechaLimite, @Debug
		END
				-- SE EJECUTA EL PROCEDIMIENTO SI EL CONTRATO CUENTA CON VOLUMEN DE PRODUCCION DE PETROLEO
		IF 0 < (SELECT ISNULL(Condensado,0)
				FROM PC_Volumenes 
				WHERE IdContrato = @IdContrato
				AND Mes = @Mes	--@MesReporte
				)
		BEGIN
			-- SE EJECUTA EL CALCULO DE COMERCIALIZACIONES PARA CONDENSADO
			EXEC SP_PC_GenerarComercializacionesCondensado @IdContrato, @Mes, @Usuario, @FechaLimite, @Debug
		END
	END	-- END IF @FechaLimite <= GETDATE()
END

GOTO FIN
-- -----------------------------------------------------------------------------------------
ERROR:
-- -----------------------------------------------------------------------------------------
RAISERROR(@MensajeError, 16, 1)
--RETURN 1	    -- Error
-- -----------------------------------------------------------------------------------------
FIN:
--RETURN 0
END	-- END PROCEDURE
