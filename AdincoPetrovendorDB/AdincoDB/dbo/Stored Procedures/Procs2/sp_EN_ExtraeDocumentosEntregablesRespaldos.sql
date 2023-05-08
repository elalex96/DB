-- =============================================
-- 24/11/2021 MC quitar prints ISSUE 383 adincopetrodb
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeDocumentosEntregablesRespaldos]--3,10061,'20200101','20200331','Descarga todos los archiOs'--24
    @IdContrato		INT,
    @idUsuario		INT,
	@FechaInicio	DATETIME,
	@FechaFin		DATETIME,
	@Opcion			VARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;

	--declare @IsEquinor bit
	
	--if exists(
	--	select		ct.* 
	--	from		CO_Contrato			c
	--	inner join	CO_Contratista		ct
	--	on			c.IdContratista		=		ct.IdContratista
	--	where		IdContrato			=		@IdContrato
	--	and			NombreContratista	like	'%Equinor%'-- Cambiar por 'Equinor'
	--)
	--begin
	--	select @IsEquinor	=	cast(1 as bit)
	--end
	--else
	--begin
	--	select @IsEquinor	=	cast(0 as bit)
	--end
	
	----select * from #isEquinor

	IF @IdContrato = 10054
	BEGIN
		EXEC sp_EN_ExtraeDocumentosEntregablesRespaldos_ENI @IdContrato, @idUsuario, @FechaInicio, @FechaFin, @Opcion
		RETURN
	END

	CREATE TABLE #EN_InstanciaPeriodo (IdInstanciaEntregable INT, Nombre VARCHAR(250));
	CREATE TABLE #EN_InstanciaRespaldo (IdInstanciaEntregable INT);

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
			EN_ContratoEntregable CE (NOLOCK)
			ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
			AND	CE.IdContrato	=	@IdContrato
			AND	ISNULL(IE.Activo,1)	=	1
			AND	ISNULL(CE.Activo,1)	=	1
	JOIN
		EN_Entregable E (NOLOCK)
		ON	CE.IdEntregable	=	E.IdEntregable
		AND E.BitJOA	=	0											--JOA
	JOIN
		EN_HistorialAprobacionesLineaTiempo	FINR	(NOLOCK)
		ON	IE.idInstanciaEntregable	=	FINR.idInstanciaEntregable
		AND FINR.idTipoOperacion IN ( 2,3,4)
	JOIN
		EN_DocumentoVersion	DV (NOLOCK)
		ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
		AND FINR.IdLineaTiempo	=	DV.N_version
		AND DV.Activo = 1
	LEFT JOIN
		EN_ContratoEntregableProgramaImplementaAcciones	ENT_ACC (NOLOCK)
		ON CE.IdContratoEntregable	=	ENT_ACC.IdContratoEntregable		--SASISOPA NULL
	WHERE
		CE.IdContrato	=	@IdContrato
	AND
			ENT_ACC.IdProgramaImplementaAccion IS NULL
	AND
			E.BitJOA	=	0												--JOA
		AND
			IE.FechaCalculadaEntregaReg BETWEEN  @FechaInicio AND @FechaFin;

	IF(@Opcion = 'Descarga todos los archivos')
	BEGIN
		----Si el contrato es Equinor...
		--if(@IsEquinor=1)
		--begin
		--	/*Solo devolver registros de tipo acuse*/

		--	--Obtenemos los IdInstancias de los registros Tipo acuse y los guardamos en una temporal
		--	select		t1.IdInstanciaEntregable
		--	into		#tmpAcuses 
		--	from		#EN_InstanciaPeriodo		t1
		--	inner join	EN_EntregableDocumento		t2
		--	on			t1.IdInstanciaEntregable	=	t2.idInstanciaEntregable
		--	where		t2.idTipoArchivo			in	(10001, 10002)-- acuse --select * from EN_TipoArchivo 
		--	--Obtenemos los IdInstancias de los registros Tipo entregable y los guardamos en una temporal
		--	select distinct		t1.IdInstanciaEntregable
		--	into		#tmpEntregables
		--	from		#EN_InstanciaPeriodo		t1
		--	inner join	EN_EntregableDocumento		t2
		--	on			t1.IdInstanciaEntregable	=	t2.idInstanciaEntregable
		--	where		t2.idTipoArchivo			in	(10000,10003,10004,10005)
			
		--	if exists (select * from #tmpAcuses )
		--	begin
		--		--select * from #tmpAcuses
		--		--solo considere archivos de tipo acuse
		--		delete 
		--		from	#EN_InstanciaPeriodo
		--		where	IdInstanciaEntregable	not in (select IdInstanciaEntregable from #tmpAcuses)-- :. Borramos del resultado final aquellos registros que NO sean tipo acuse
		--	end
		--	else
		--	begin
		--		--sino contiene acuses se omiten todos lo que no sean tipo entregables
		--		delete 
		--		from	#EN_InstanciaPeriodo
		--		where	IdInstanciaEntregable	not in (select IdInstanciaEntregable from #tmpEntregables)

		--	end
		--end
		--select * from EN_EntregableDocumento  --select * from EN_TipoArchivo 
		SELECT * FROM #EN_InstanciaPeriodo

	END
	ELSE
	BEGIN
	--SACA LAS INSTANCIAS QUE YA SE RESPALDARON ANTERIORIMENTE EN EL RANGO DE FECHAS ESTABLECIDO
		INSERT INTO		#EN_InstanciaRespaldo (IdInstanciaEntregable )
		SELECT DISTINCT IER.IdInstanciaEntregable
		FROM 			EN_InstanciasBitacoraRespaldos	IER (NOLOCK)
		JOIN			EN_InstanciasEntregable			IE (NOLOCK)
		ON				IER.IdInstanciaEntregable		=			IE.IdInstanciaEntregable
		JOIN			EN_ContratoEntregable			CE (NOLOCK)
		ON				IE.IdContratoEntregable			=			CE.IdContratoEntregable
		WHERE			CE.IdContrato					=			@IdContrato
		AND				IE.FechaCalculadaEntregaReg		BETWEEN		@FechaInicio	
														AND			@FechaFin

		SELECT		IP.IdInstanciaEntregable, 
					Nombre						=	LTRIM(IP.idInstanciaEntregable) + '.zip'	
		FROM		#EN_InstanciaPeriodo		IP
		LEFT JOIN	#EN_InstanciaRespaldo		IR
		ON			IP.IdInstanciaEntregable	=	IR.IdInstanciaEntregable
		WHERE 		IR.IdInstanciaEntregable	IS	NULL
	END

END