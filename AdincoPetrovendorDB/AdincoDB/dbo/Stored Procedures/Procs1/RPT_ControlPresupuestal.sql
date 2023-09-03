CREATE PROCEDURE  [dbo].[RPT_ControlPresupuestal]
	@IdUsuario INT,
	@IdPresupuesto INT,
	@IdContrato INT
AS    
BEGIN      

	CREATE TABLE #TMP_DetallePresupuestadoCIEP(
	IdLineaPresupuestoMes INT, Presupuesto NVARCHAR(4000), ID_TIPOSER INT, NombreTipoServicio NVARCHAR(4000),
	Orden INT, ID_CATACTIV NVARCHAR(4000), NombreActividad NVARCHAR(4000), ID_CATSUBACTIV NVARCHAR(4000),
	NombreSubactividad NVARCHAR(4000), NombreClasificacion NVARCHAR(4000), AC_TERMINADO BIT, 
	IdInstalacionPemex NVARCHAR(4000), NombreInstalacion NVARCHAR(4000), EsBolsa BIT, AC_PRESUP_MES DATE,
	NombreServicio VARCHAR(8000), Unidad NVARCHAR(4000), AC_FEC_INI DATE, AC_FEC_FIN DATE, 
	ID_CATACTHC INT, NombreActividadHidrocarburo NVARCHAR(100), ID_PADRE NVARCHAR(100),
	NombreArea NVARCHAR(4000), ID_RUBRO1 NVARCHAR(4000), ID_RUBRO2 NVARCHAR(4000), ID_RUBRO3 NVARCHAR(4000),
	CLAVE_RUBRO NVARCHAR(4000), NombreRubro NVARCHAR(4000), Volumetria REAL, PrecioUnitario DECIMAL(18, 4),
	Monto DECIMAL(30, 4), ClasificacionAnexo4 NVARCHAR(4000), Clave NVARCHAR(4000), RubroInterno NVARCHAR(4000),
	Expr2 NVARCHAR(4000), CPXOPX NCHAR(10),  IdLineaProgramaActividadMes INT
	)
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

	CREATE TABLE #TMP_AgrupadoMensualPresupuestado(AC_PRESUP_MES date, IdLineaPresupuestoMes INT, NombreTipoServicio NVARCHAR(4000), NombreActividad NVARCHAR(4000), NombreServicio NVARCHAR(4000), MontoPresupuestado DECIMAL(30, 4))

	CREATE TABLE #TMP_AgrupadoMensualReal(AC_PRESUP_MES date, IdLineaPresupuestoMes INT, NombreTipoServicio NVARCHAR(4000), NombreActividad NVARCHAR(4000), NombreServicio NVARCHAR(4000), MontoReal DECIMAL(30, 4))

	CREATE TABLE #TMP_Retorno(Fila INT, IdLineaPresupuestoMes INT, NombreTipoServicio NVARCHAR(4000), NombreActividad NVARCHAR(4000), NombreServicio NVARCHAR(4000), AC_PRESUP_MES DATE, MontoPresupuestado DECIMAL(30, 4), [Real] DECIMAL(30, 4), [Var] DECIMAL(30 ,4))

	INSERT INTO #TMP_GastosAmamtitlan(IdRegistro, Servicio, InstalacionPresupuestada, FechaInicio, FechaFin, TipoDocumento, Numero, FechaDocumento, 
	MontoUSD, MontoUSDConMarkup, Subcontratista, InstalacionRegistro, InicioEjecucion, FinEjecucion,
	CreadoPor, MontoRegistro, Moneda, MesPresentacion, TipoDeServicio, Actividad, SubActividad, EstadoValidacion, Area, Comentarios, Anexo4, 
	Identificador, LineaPresupuesto, Presupuesto, TipoCambio, [UUID FACTURA PROVEEDOR PRIMARIO], Porcentaje,
	[Estatus Certificado], [CGE Aprobado Pemex], ImporteEstimadoParcialUSD)
	EXEC p_GastosAmatitlan2020_SEL @IdContrato, @IdUsuario


	INSERT INTO #TMP_DetallePresupuestadoCIEP(IdLineaPresupuestoMes, Presupuesto, ID_TIPOSER, NombreTipoServicio, Orden, ID_CATACTIV, NombreActividad, 
	ID_CATSUBACTIV, NombreSubactividad, NombreClasificacion, AC_TERMINADO, IdInstalacionPemex,
	NombreInstalacion, EsBolsa, AC_PRESUP_MES, NombreServicio, Unidad, AC_FEC_INI, AC_FEC_FIN, ID_CATACTHC, NombreActividadHidrocarburo, ID_PADRE, 
	NombreArea, ID_RUBRO1, ID_RUBRO2, ID_RUBRO3, CLAVE_RUBRO, NombreRubro, Volumetria,
	PrecioUnitario, Monto, ClasificacionAnexo4, Clave, RubroInterno, Expr2, CPXOPX, IdLineaProgramaActividadMes)
	EXEC sp_CO_ConsultaDetallePresupuestoCIEP @IdPresupuesto

	INSERT INTO #TMP_AgrupadoMensualPresupuestado(AC_PRESUP_MES, IdLineaPresupuestoMes, NombreTipoServicio, NombreActividad, NombreServicio, MontoPresupuestado)
	SELECT AC_PRESUP_MES, IdLineaPresupuestoMes, NombreTipoServicio, NombreActividad, NombreServicio, SUM(#TMP_DetallePresupuestadoCIEP.Monto)
	FROM #TMP_DetallePresupuestadoCIEP
	GROUP BY AC_PRESUP_MES, IdLineaPresupuestoMes, NombreTipoServicio, NombreActividad, NombreServicio

	INSERT INTO #TMP_AgrupadoMensualReal(AC_PRESUP_MES, IdLineaPresupuestoMes, NombreTipoServicio, NombreActividad, NombreServicio, MontoReal)
	SELECT DATEADD(DAY,1,EOMONTH(FinEjecucion,-1)), LineaPresupuesto, TipoDeServicio, Actividad, Servicio, SUM(MontoUSD)
	FROM #TMP_GastosAmamtitlan
	GROUP BY DATEADD(DAY,1,EOMONTH(FinEjecucion,-1)), LineaPresupuesto, TipoDeServicio, Actividad, Servicio

	
	INSERT INTO #TMP_Retorno([Fila], AC_PRESUP_MES, IdLineaPresupuestoMes, NombreActividad, NombreServicio, NombreTipoServicio, [Real], MontoPresupuestado, [Var])
	SELECT ROW_NUMBER() OVER(PARTITION BY  #TMP_AgrupadoMensualPresupuestado.AC_PRESUP_MES, #TMP_AgrupadoMensualPresupuestado.IdLineaPresupuestoMes, #TMP_AgrupadoMensualPresupuestado.NombreActividad, 
	#TMP_AgrupadoMensualPresupuestado.NombreServicio, #TMP_AgrupadoMensualPresupuestado.NombreTipoServicio ORDER BY #TMP_AgrupadoMensualPresupuestado.AC_PRESUP_MES),
	#TMP_AgrupadoMensualPresupuestado.AC_PRESUP_MES, #TMP_AgrupadoMensualPresupuestado.IdLineaPresupuestoMes, #TMP_AgrupadoMensualPresupuestado.NombreActividad, 
	#TMP_AgrupadoMensualPresupuestado.NombreServicio, #TMP_AgrupadoMensualPresupuestado.NombreTipoServicio,
	#TMP_AgrupadoMensualReal.MontoReal as [Real],
	#TMP_AgrupadoMensualPresupuestado.MontoPresupuestado,
	#TMP_AgrupadoMensualPresupuestado.MontoPresupuestado - #TMP_AgrupadoMensualReal.MontoReal
	FROM #TMP_AgrupadoMensualPresupuestado
	LEFT JOIN #TMP_AgrupadoMensualReal 
		ON #TMP_AgrupadoMensualPresupuestado.AC_PRESUP_MES = #TMP_AgrupadoMensualReal.AC_PRESUP_MES
		AND #TMP_AgrupadoMensualPresupuestado.NombreActividad = #TMP_AgrupadoMensualReal.NombreActividad
		AND #TMP_AgrupadoMensualPresupuestado.NombreServicio = #TMP_AgrupadoMensualReal.NombreServicio
		AND #TMP_AgrupadoMensualPresupuestado.NombreTipoServicio = #TMP_AgrupadoMensualReal.NombreTipoServicio

	-- Para que el monto no se duplique cuando haya mas de una linea
	UPDATE #TMP_Retorno
	SET MontoPresupuestado = 0
	WHERE Fila > 1

	SELECT * FROM #TMP_Retorno
END





