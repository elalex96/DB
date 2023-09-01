USE [Adinco]
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'RPT_ControlPresupuestal'
)
    DROP PROCEDURE RPT_ControlPresupuestal
GO
CREATE PROCEDURE  [dbo].[RPT_ControlPresupuestal]
	@IdUsuario INT,
	@IdPresupuesto INT,
	@IdContrato INT
AS    
BEGIN      
	IF OBJECT_ID(N'tempdb..#TMP_GastosAmamtitlan') IS NOT NULL
	BEGIN
	DROP TABLE #TMP_GastosAmamtitlan
	END

	CREATE TABLE #TMP_GastosAmamtitlan(
	IdRegistro INT, Servicio VARCHAR(8000), InstalacionPresupuestada VARCHAR(8000), 
	FechaInicio Date, FechaFin Date, TipoDocumento VARCHAR(2), Numero VARCHAR(8000), FechaDocumento DATETIME, 
	MontoUSD DECIMAL(30, 8), MontoUSDConMarkup DECIMAL (36, 2), Subcontratista VARCHAR(8000),
	InstalacionRegistro VARCHAR(8000), InicioEjecucion DATE, FinEjecucion DATE, CreadoPor VARCHAR(8000),
	MontoRegistro DECIMAL(20, 4), Moneda VARCHAR(8000), MesPresentacion DATE, TipoDeServicio VARCHAR(8000),
	Actividad VARCHAR(8000), SubActividad VARCHAR(8000), EstadoValidacion VARCHAR(8000), Area VARCHAR(8000),
	Comentarios VARCHAR(8000), Anexo4 VARCHAR(8000), Identificador INT, LineaPresupuesto INT,
	Presupuesto VARCHAR(8000), TipoCambio MONEY, [UUID FACTURA PROVEEDOR PRIMARIO] VARCHAR(500),
	Porcentaje FLOAT, [Estatus Certificado] VARCHAR(8000), [CGE Aprobado Pemex] VARCHAR(24),
	ImporteEstimadoParcialUSD DECIMAL(36, 2))

	CREATE TABLE #TMP_AgrupadoMensual(AC_PRESUP_MES date, [Real] DECIMAL(30, 8))

	INSERT INTO #TMP_GastosAmamtitlan(IdRegistro, Servicio, InstalacionPresupuestada, FechaInicio, FechaFin, TipoDocumento, Numero, FechaDocumento, MontoUSD, MontoUSDConMarkup, Subcontratista, InstalacionRegistro, InicioEjecucion, FinEjecucion,
	CreadoPor, MontoRegistro, Moneda, MesPresentacion, TipoDeServicio, Actividad, SubActividad, EstadoValidacion, Area, Comentarios, Anexo4, Identificador, LineaPresupuesto, Presupuesto, TipoCambio, [UUID FACTURA PROVEEDOR PRIMARIO], Porcentaje,
	[Estatus Certificado], [CGE Aprobado Pemex], ImporteEstimadoParcialUSD)
	EXEC p_GastosAmatitlan2020_SEL @IdContrato, @IdUsuario

	INSERT INTO #TMP_AgrupadoMensual(AC_PRESUP_MES, [Real])
	SELECT DATEADD(DAY,1,EOMONTH(#TMP_GastosAmamtitlan.FinEjecucion,-1)),  SUM(#TMP_GastosAmamtitlan.MontoUSD)
	FROM #TMP_GastosAmamtitlan
	GROUP BY DATEADD(DAY,1,EOMONTH(#TMP_GastosAmamtitlan.FinEjecucion,-1))


	SELECT CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
		   CO_Presupuesto.IdPresupuesto,
		   CASE
			   WHEN CO_Contrato.IdTipoContrato = 1 THEN
				   CO_TipoServicio.NombreTipoServicio
			   ELSE
				   CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
		   END AS NombreTipoServicio,
		   CASE
			   WHEN CO_Contrato.IdTipoContrato = 1 THEN
				   CO_ActividadCIEP.NombreActividad
			   ELSE
				   CO_SubactividadPetrolera.SubactividadPetrolera
		   END AS NombreActividad,
		   CASE
			   WHEN CO_Contrato.IdTipoContrato = 1 THEN
				   CO_RubroInterno.NombreRubro
			   ELSE
				   CO_TareaPetrolera.TareaPetrolera
		   END AS RubroInterno,
		   CO_Instalacion.NombreInstalacion,
		   #TMP_AgrupadoMensual.AC_PRESUP_MES,
		   #TMP_GastosAmamtitlan.MontoUSD AS Presupuesto,
		   #TMP_AgrupadoMensual.[Real],
		   #TMP_AgrupadoMensual.[Real] - #TMP_GastosAmamtitlan.MontoUSD AS [Var],
		   #TMP_GastosAmamtitlan.Servicio
	FROM CO_LineaPresupuestoMes (NOLOCK)
		LEFT JOIN CO_Instalacion (NOLOCK)
			ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
		LEFT JOIN CO_RubroInterno (NOLOCK)
			ON CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
		LEFT JOIN CO_ActividadCIEP (NOLOCK)
			ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
			   AND CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
		LEFT JOIN CO_Presupuesto (NOLOCK)
			ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
		LEFT JOIN CO_TipoServicio (NOLOCK)
			ON CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.IdTipoServicio
		LEFT JOIN dbo.CO_ActividadPetroleraCNH (NOLOCK)
			ON CO_ActividadPetroleraCNH.IdActividadPetrolera = dbo.CO_LineaPresupuestoMes.IdActividadPetrolera
		LEFT JOIN dbo.CO_SubactividadPetrolera (NOLOCK)
			ON CO_SubactividadPetrolera.IdSubactividadPetrolera = dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera
		LEFT JOIN dbo.CO_TareaPetrolera (NOLOCK)
			ON CO_TareaPetrolera.IdTareaPetrolera = dbo.CO_LineaPresupuestoMes.IdTareaPetrolera
		LEFT JOIN dbo.CO_AnioContractual (NOLOCK)
			ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual
		LEFT JOIN dbo.CO_Contrato (NOLOCK)
			ON CO_Contrato.IdContrato = CO_AnioContractual.IdContrato
		INNER JOIN #TMP_GastosAmamtitlan
			ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = #TMP_GastosAmamtitlan.LineaPresupuesto
		INNER JOIN #TMP_AgrupadoMensual
			ON DATEADD(DAY, 1, EOMONTH(#TMP_GastosAmamtitlan.FinEjecucion, -1)) = #TMP_AgrupadoMensual.AC_PRESUP_MES
	WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto

END





