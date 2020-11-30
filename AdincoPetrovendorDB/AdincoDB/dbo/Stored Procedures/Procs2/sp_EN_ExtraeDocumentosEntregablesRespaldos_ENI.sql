CREATE PROCEDURE dbo.sp_EN_ExtraeDocumentosEntregablesRespaldos_ENI--	 3,10061,'20200101','20200331','Descarga todos los archiOs'--24
    @IdContrato INT,
    @idUsuario INT,
	@FechaInicio DATETIME,
	@FechaFin	DATETIME,
	@Opcion VARCHAR(250)
AS
BEGIN

SET NOCOUNT ON;

	CREATE TABLE #EN_InstanciaPeriodo (IdInstanciaEntregable INT, Nombre VARCHAR(250));
	CREATE TABLE #EN_InstanciaRespaldo (IdInstanciaEntregable INT);

select @Opcion = 'Descarga todos los archivos'

	--TODOS LAS INSTANCIAS CON ARCHIVO DE RANGO DE FECHAS
	INSERT INTO #EN_InstanciaPeriodo (
								IdInstanciaEntregable ,
								Nombre
								)
	SELECT DISTINCT IE.idInstanciaEntregable AS IdInstanciaEntregable,
			LTRIM(IE.idInstanciaEntregable) + '.zip' AS Nombre
	FROM
		EN_InstanciasEntregable	IE (NOLOCK)
	JOIN
			EN_ContratoEntregable	CE	(NOLOCK)
			ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
			AND	CE.IdContrato	=	@IdContrato
			AND	ISNULL(IE.Activo,1)	=	1
			AND	ISNULL(CE.Activo,1)	=	1
			AND IE.FechaCalculadaEntregaReg BETWEEN '20180701' AND '20191231'
		AND ie.idinstanciaentregable not in (35737	,35738	,35739	,35740	,35741	,35742	,35743	,35744	,
35745	,35746	,35747	,35748	,35749	,35750	,35751	,35752	,35753	,35754	,35478	,35479	,35480	,35481	,35482	,35483	,
35484	,35485	,35486	,35487	,35488	,35489	,35490	,35491	,35492	,35493	,35494	,35495	,40356	,34961	,34962	,34963	,
34964	,34965	,34966	,34967	,34968	,34969	,34970	,34971	,34972	,34973	,34974	,34975	,34976	,34977	,39103	,39104	,
39105	,39106	,39107	,510770	,510772	,510774	,509142	,509143	,509913	,507517	,508692	,510817	,510819	,510821	,131117	,510575	,
39619	,39620	,39621	,39622	,39623	,527856	,527857	,527858	,507433	,38069	,38070	,38071	,38072	,38073	,38074	,38327	,
38328	,140362	,140363	,140364	,40657	,40548	,40549	,527478	,527479	,553841	,523698	,523700	,523703	,523706	,523707	,523708	,
523709	,523710	,523711	,556262	,110465	,110466	,110467	,110468	,110469	,110470	,110471	,110472	,110473	,110474	,110475	,110476	,
110477	,110478	,110479	,110480	,559508	,559509	,559510	,559511	,559512	,559513	,559514,
-- 7 nov
40440,559773,559774,559775,562064,562046,562050,562047,562051,562055,38075,140365,140366,39447,40526)
	JOIN
		EN_Entregable	E
		ON	CE.IdEntregable	=	E.IdEntregable
		AND E.BitJOA	=	0										--JOA
		AND E.CONSECUTIVO IN ('ADINCO-CN005','ADINCO-GAS005','ADINCO-GENR005','ADINCO-GENR021',
'ADINCO-MEDI006','ADINCO-MEDI007','ADINCO-MEDI009','ADINCO-MEDI010',
'ADINCO-MIA008','ADINCO-PERFO008','ADINCO-PERFO015','ADINCO-PERFO107',
'ADINCO-PERFO503','ADINCO-PERFO505','ADINCO-PLANES110','ADINCO-PLANES174',
'ADINCO-PLANES175','ADINCO-PLANES182','ADINCO-R1L2036','ADINCO-R1L2099',
'ADINCO-R1L2106','ADINCO-R1L2107','ADINCO-R1L2108','ADINCO-RESER002',
'ADINCO-RESER006','ADINCO-SAR0015','ENI-0091','ENI-0122' ,
-- LOS QUE ME FALTARON 9-NOV
'ADINCO-MIA001','ADINCO-MIA002','ADINCO-MIA003','ADINCO-MIA005','ADINCO-MIA009','ADINCO-PERFO507','ADINCO-R1L2052','ADINCO-R1L2159','ADINCO-RESER013')
	JOIN
		EN_HistorialAprobacionesLineaTiempo	FINR	(NOLOCK)
		ON	IE.idInstanciaEntregable	=	FINR.idInstanciaEntregable
		AND FINR.idTipoOperacion IN (2,3, 4)
	JOIN
		EN_DocumentoVersion	DV
		ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
		AND FINR.IdLineaTiempo	=	DV.N_version
		AND DV.Activo = 1
	LEFT JOIN
		EN_ContratoEntregableProgramaImplementaAcciones	ENT_ACC
		ON CE.IdContratoEntregable	=	ENT_ACC.IdContratoEntregable		--SASISOPA NULL
	WHERE
		CE.IdContrato	=	@IdContrato
	AND			ENT_ACC.IdProgramaImplementaAccion IS NULL
	AND			E.BitJOA	=	0												--JOA

	IF(@Opcion = 'Descarga todos los archivos')
	BEGIN
		SELECT * FROM #EN_InstanciaPeriodo
	END
	ELSE
	BEGIN
	--SACA LAS INSTANCIAS QUE YA SE RESPALDARON ANTERIORIMENTE EN EL RANGO DE FECHAS ESTABLECIDO
		INSERT INTO  #EN_InstanciaRespaldo (IdInstanciaEntregable )
		SELECT DISTINCT IER.IdInstanciaEntregable
		FROM 
			EN_InstanciasBitacoraRespaldos IER
		JOIN
			EN_InstanciasEntregable	IE
			ON	IER.IdInstanciaEntregable	=	IE.IdInstanciaEntregable
		JOIN
			EN_ContratoEntregable	CE
			ON IE.IdContratoEntregable	=	CE.IdContratoEntregable
		WHERE
			CE.IdContrato	=	@IdContrato
			AND IE.FechaCalculadaEntregaReg BETWEEN  @FechaInicio AND @FechaFin;

		SELECT IP.IdInstanciaEntregable, LTRIM(IP.idInstanciaEntregable) + '.zip' AS Nombre
		FROM 
			#EN_InstanciaPeriodo IP
		LEFT JOIN
			#EN_InstanciaRespaldo	IR
			ON IP.IdInstanciaEntregable	=	IR.IdInstanciaEntregable
		WHERE 
			IR.IdInstanciaEntregable IS NULL
	END

END