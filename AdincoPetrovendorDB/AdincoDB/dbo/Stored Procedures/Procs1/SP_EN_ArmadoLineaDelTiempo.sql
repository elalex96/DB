-- =============================================
-- Author: Daniel Ac
-- Create date: 20-11-2020
-- Description: Se actualizo filtros de entregables
-- =============================================
-- Author: Alexander Gomez
-- Create date: 09/06/2021
-- Description: Se actualizan los colores de las cards
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ArmadoLineaDelTiempo] --3,12
-- ============================================= 
--[dbo].[SP_EN_ArmadoLineaDelTiempo] 0,0
-- ============================================= 
@IdContrato INT, 
@IdUsuario  INT
AS
BEGIN
SET NOCOUNT ON

create table #tmp
(   
	IdInstanciaEntregable	INT,
	FechaEntrega			DATE,
	DocumentoEntregable		VARCHAR(max),
	Anio					INT,
	Consecutivo varchar(200),
	Pozo varchar(200)
)

--OBTIENE LISTA DE ENTREGABLES APROBADOS INTERNAMENTE CLASIFICADOS POR AÑO Y QUE TIENEN BIT DE MOSTRAR EN LINEA DE TIEMPO
INSERT INTO #tmp
(   
	IdInstanciaEntregable,
	FechaEntrega,
	DocumentoEntregable,
	Anio
)
exec SP_ENI_LineaTiempo @IdContrato,@IdUsuario--=10

--OBTENER CONSECUTIVO DEL ENTREGABLE INSTANCIA 

--OBTENER CONSECUTICO Y POZO DE LOS ENTREGABLES 
UPDATE Temp
SET Temp.Consecutivo=E.Consecutivo,
Temp.Pozo=ISNULL(I.NombreInstalacion,'')
FROM #tmp Temp
JOIN  dbo.EN_InstanciasEntregable    EI   
  ON   Temp.IdInstanciaEntregable=EI.idInstanciaEntregable
JOIN EN_ContratoEntregable    CE  
  ON EI.IdContratoEntregable=CE.IdContratoEntregable 
JOIN  dbo.EN_Entregable      E   
  ON   CE.IdEntregable = E.IdEntregable 
LEFT JOIN        EN_InstanciasEntregables_InstanciaActividad IEIA
ON   EI.idInstanciaEntregable = IEIA.idInstanciaEntregable
LEFT JOIN        EN_InstanciasActividades  IA
ON  IEIA.idInstanciaActividad =  IA.idInstanciaActividad
LEFT JOIN EN_InstanciasProcesosFecha  IPF
ON  IA.IdInstanciasProcesos  =  IPF.IdInstanciasProcesos
LEFT JOIN EN_Procesos P
ON  IPF.IdProceso = P.IdProceso
LEFT JOIN  CO_Instalacion I
ON  P.IdInstalacion = I.IdInstalacion


--OBTIENE DOCUMENTOS DE LAS INSTANCIAS FILTRADOS POR LOS DOCUMENTOS QUE SE VAN UTIZAR 
select  idInstanciaEntregable,
DocumentoEntregable = case        
		when        Consecutivo in ('ADINCO-R2L2034','ADINCO-R2L3034','ADINCO-R2L10182','ADINCO-R1L4029','ADINCO-R2L10029','ADINCO-R2L40028','ADINCO-R3L10029', 'ADINCO-PLANES134','ADINCO-PLANES168') -- AQUI SE AGREGARON LOS ULTIMOS DOS
        then        'Fecha del descubrimiento de Pozo '+Pozo+'('+DocumentoEntregable+')'
        when        Consecutivo in ('ADINCO-R1L3107','ADINCO-R2L2112','ADINCO-R2L3112','ADINCO-R1L4118','ADINCO-R1L2089','ADINCO-R2L10116','ADINCO-R2L40113','ADINCO-R3L10121','Farmout-12086') 
        then        'Fecha de convenio modificatorio del Contrato ('+DocumentoEntregable+')'
		WHEN        Consecutivo in ('ADINCO-R2L40010','ADINCO-R3L10012','ADINCO-R2L3017','ADINCO-R2L2017','ADINCO-R2L10219','ADINCO-R2L10013','ADINCO-R1L3026','ADINCO-R1L2022','Farmout-12018') -- AQUI SE AGREGARON LOS ULTIMOS DOS
        then        'Fecha de Inicio del Periodo de Exploración'
        when        Consecutivo in ('ADINCO-R2L10221','ADINCO-R1L4012','ADINCO-R2L10015','ADINCO-R2L40013','ADINCO-R3L10015','ADINCO-R2L2019','ADINCO-R2L3019') 
        then        'Fecha del Primer Periodo Adicional de Exploración'
        when        Consecutivo in ('ADINCO-R3L10018','ADINCO-R2L10018','ADINCO-R2L40016','ADINCO-R2L10224','ADINCO-R1L4015') 
        then        'Fecha del Segundo Periodo Adicional de Exploración'
--        when        Consecutivo in ('ADINCO-PERFO503') 
        --then        'Fecha de Perforación del pozo '+Pozo
        when        Consecutivo in ('ADINCO-R2L2028','ADINCO-R2L3028','ADINCO-R2L10230','ADINCO-R1L4022','ADINCO-R2L10024','ADINCO-R2L40022','ADINCO-R3L10024') 
        then        'Fecha de confirmación de existencia del descubrimiento'
		WHEN		DocumentoEntregable LIKE 'Perforación del Pozo:%'
		then		DocumentoEntregable
		WHEN		DocumentoEntregable LIKE '%Resolu%Impacto%Ambiental%'
		then		DocumentoEntregable
		WHEN		DocumentoEntregable LIKE '%Autor%SASISOPA%'
		then		DocumentoEntregable
        else        ''
        end,
		FechaEntrega,
		Anio,
		Consecutivo
into    #tmpEntregables
from    #tmp 

--AGREGAR SOLO AQUELLOS ENTREGABLES QUE ESTAN EN LOS EN LAS CONDICIONES 
select * 
into  #tmpEntregablesFinal
from #tmpEntregables
where DocumentoEntregable<>''
order by FechaEntrega asc 


    --OBTIENE EL ARCHIVO POR ENTREGABLE INSTANCIA DONDE LA VERSION SEA LA MAS RECIENTE 
	-- Insert statements for procedure here
	SELECT	ED.DocumentoEntregableId, 
			ED.NombreArchivo, 
			MAX(HALT.IdLineaTiempo) AS Versionn, 
			ED.Bucket, 
			ED.Folder, 
			ED.UUIDAmazon, 
			IE.idInstanciaEntregable, 
			LTRIM(RTRIM(SUBSTRING(ED.NombreArchivo, CHARINDEX('.',ED.NOMBREARCHIVO,LEN(ED.NOMBREARCHIVO)-5), LEN(ED.NombreArchivo)))) AS TipoArchivo
	into	#tmpDocumentos
	FROM	dbo.EN_InstanciasEntregable IE
	JOIN	dbo.EN_HistorialAprobacionesLineaTiempo		HALT 
	ON		IE.idInstanciaEntregable					=	HALT.idInstanciaEntregable
	AND		HALT.Rechazado								=	0
	JOIN	dbo.EN_DocumentoVersion						DE 
	ON		HALT.idInstanciaEntregable					=	DE.idInstanciaEntregable
	JOIN	dbo.EN_EntregableDocumento					ED	
	ON		DE.DocumentoEntregableId					=	ED.DocumentoEntregableId
	AND		ED.idTipoArchivo							IN (	10000, 10002)
	AND		ED.Activo = 1
	GROUP BY ED.DocumentoEntregableId, 
	ED.NombreArchivo, 
	ED.Bucket, 
	ED.Folder, 
	ED.UUIDAmazon, 
	IE.idInstanciaEntregable, 
	LTRIM(RTRIM(SUBSTRING(ED.NombreArchivo, CHARINDEX('.',ED.NOMBREARCHIVO,LEN(ED.NOMBREARCHIVO)-5), LEN(ED.NombreArchivo))))

	--AGREGAR FECHA EFECTIVA =FECHA INICIO DEL CONTRATO
	INSERT INTO #tmpEntregablesFinal(IdInstanciaEntregable,DocumentoEntregable,FechaEntrega,Anio)
	SELECT -1, 'Fecha Efectiva (Fecha de Firma del Contrato)' ,CAST(FechaFirma AS DATE), YEAR(CAST(FechaFirma AS DATE))   
	FROM CO_Contrato 
	WHERE IdContrato=@IdContrato

	--AGREGAR FECHA DE INICIO DE ETAPA DE TANSICIÓN DE ARRANQUE ETA   (Esta fecha es calculada, se suman 120 dias habiles a la fecha de la firma del contrato (fechafirma de co_contrato), para la suma, usar la funcion FN_EN_SumaDiasHabiles)
	INSERT INTO #tmpEntregablesFinal(IdInstanciaEntregable,DocumentoEntregable,FechaEntrega,Anio)
	SELECT -2, 'Fecha de Inicio de Etapa de transición de arranque ETA',CAST(dbo.FN_EN_SumaDiasHabiles(FechaFirma,120) AS DATE), YEAR(CAST(dbo.FN_EN_SumaDiasHabiles(FechaFirma,120) AS DATE))   
	FROM CO_Contrato 
	WHERE IdContrato=@IdContrato

	--AGREGAR FECHA FIN DEL CONTRATO 
	INSERT INTO #tmpEntregablesFinal(IdInstanciaEntregable,DocumentoEntregable,FechaEntrega,Anio)
	SELECT -3, 'Fecha Fin del contrato ',CAST(FinVigencia AS DATE), YEAR(CAST(FinVigencia AS DATE))   
	FROM CO_Contrato 
	WHERE IdContrato=@IdContrato

	--ACTUALIZAR EL ENTREGABLE FECHA DE PERFORACIÓN 
	--(A la fecha que se obtenga de este entregable, se le suman 5 dias hábiles y esa es la fecha de perforación)
		
	UPDATE #tmpEntregablesFinal
	SET FechaEntrega =(dbo.FN_EN_SumaDiasHabiles(FechaEntrega,5))
	WHERE Consecutivo='ADINCO-PERFO503'

	
	alter table #tmpEntregablesFinal add DataArchivo varchar(20)
	alter table #tmpEntregablesFinal add DocumentoEntregableId int

	--OBTENER CUANTOS DOCUMENTOS TIENE  LOS ENTREGABLES INSTANCIAS 
	select		t1.idInstanciaEntregable, 
				Cantidad = count(t1.idInstanciaEntregable) 
	into		#tmp1Documento
	from		#tmpDocumentos					t1
	group by	t1.idInstanciaEntregable 
	having		count(t1.idInstanciaEntregable) = 1
	order by	count(t1.idInstanciaEntregable)

	select		t1.idInstanciaEntregable, 
				Cantidad = count(t1.idInstanciaEntregable) 
	into		#tmpNDocumentos
	from		#tmpDocumentos					t1
	group by	t1.idInstanciaEntregable 
	having		count(t1.idInstanciaEntregable) > 1
	order by	count(t1.idInstanciaEntregable)


	--Los que tienen solo 1 archivo PDF
	update		#tmpEntregablesFinal
	set			#tmpEntregablesFinal.DataArchivo = 'pdf',
	#tmpEntregablesFinal.DocumentoEntregableId=t2.DocumentoEntregableId
	from		#tmpEntregablesFinal						t
	inner join	#tmp1Documento				t1
	on			t.IdInstanciaEntregable		=	t1.idInstanciaEntregable
	inner join	#tmpDocumentos				t2
	on			t1.idInstanciaEntregable	=	t2.idInstanciaEntregable
	where		t2.TipoArchivo				=	'.pdf'

	-- Los que tienen solo 1 archivo pero no es PDF
	update		#tmpEntregablesFinal
	set			#tmpEntregablesFinal.DataArchivo = 'archivos'
	from		#tmpEntregablesFinal						t
	inner join	#tmp1Documento				t1
	on			t.IdInstanciaEntregable		=	t1.idInstanciaEntregable
	inner join	#tmpDocumentos				t2
	on			t1.idInstanciaEntregable	=	t2.idInstanciaEntregable
	where		t2.TipoArchivo				<>	'.pdf'

	--Los que tienen mas de 1 archivo
	update		#tmpEntregablesFinal
	set			#tmpEntregablesFinal.DataArchivo = 'archivos'
	
	from		#tmpEntregablesFinal						t
	inner join	#tmpNDocumentos				t1
	on			t.IdInstanciaEntregable		=	t1.idInstanciaEntregable
	inner join	#tmpDocumentos				t2
	on			t1.idInstanciaEntregable	=	t2.idInstanciaEntregable
	--where		t2.TipoArchivo				=	'.pdf'

	--Los que no tienen archivos
	update		#tmpEntregablesFinal
	set			DataArchivo = 'noFile'
	where		DataArchivo is null

	--ACTUALIZAR DataArchivo default para registro donde Fecha Efectiva
	update		#tmpEntregablesFinal
	set			DataArchivo = 'contrato'
	where		IdInstanciaEntregable =-1 --> DONDE IdInstanciaEntregable es de  Fecha Efectiva--> para mostrar contrato

	--CREAR UNA TABLA DE COLORES 
	CREATE TABLE #BulletColor
        (IdBullet INT, 
         bgColor  NVARCHAR(MAX)
        );
        --=============================================    
        INSERT INTO #BulletColor
        VALUES(1, '#C6E5B1'),--VERDE CLARO
        (2, '#BBBBBB'),--GRIS CLARO
        (3, '#9FBAD5'),--AZUL CLARO
        (4, '#91B2FD'),--ROJO CLARO
        (5, '#CAB1CB'),--MORADO CLARO
		(6, '#96BCEB'),--NARANJA CLARO
		(7, '#73B1FF'),--AZUL
		(8, '#BBBBBB'),--GRIS
		(9, '#85689e'),--MORADO
		(10, '#BBBBBB'),--GRISS
		(11, '#73B1FF');--AZUL

    --CREAR UNA TABLA PARA GUARDAR EL COLOR DEL POPUP PERSONALIZADO POR AÑO
	--select * from #BulletColor
	select		Id = ROW_NUMBER() OVER (	ORDER BY Anio   ),
				Anio,
				html = 
				' <div class="tl-row" style="width: 50px">
					<div class="tl-item">
					<div class="tl-bullet" style="background-color:' + '#BulletColor' + '"></div>
					<div class="tl-panel">
					' + CONVERT(NVARCHAR(MAX), Anio) + '
					</div>
					</div>
					</div>'
	into		#tmpAnios
	from		#tmpEntregablesFinal
	group by	Anio

	--select		* 
	--from		#tmpAnios		t1
	--left join	#BulletColor	t2
	--on			t1.Id			=	t2.IdBullet
	alter table #tmpAnios add color varchar(20)

	update		#tmpAnios
	set			html			= replace(html,'#BulletColor',t2.bgColor),
				color			=	t2.bgColor
	from		#tmpAnios		t1
	left join	#BulletColor	t2
	on			t1.Id			=	t2.IdBullet

	
	--select		* 
	--from		#tmpAnios		t1
	--left join	#BulletColor	t2
	--on			t1.Id			=	t2.IdBullet
	
	declare @i		int, 
			@max	int,
			@anio	int

	select	@i = min(id) from #tmpAnios
	select	@max = max(id) from #tmpAnios

	alter table #tmpEntregablesFinal add id int

	DECLARE @id INT 
	SET @id = 0 
		
	update	#tmpEntregablesFinal
	set		@id = Id = @id + 1 

	create table #tmpHtml
	(
		Id		int,
		html	varchar(max)
	)

	declare @row int, @color varchar(20) 

	while (@i<=@max)
	begin

		select @row = isnull(max(Id),0)+1 from #tmpHtml --0026 5090 1128 5989 54

		insert into #tmpHtml
		select		ROW_NUMBER() OVER (	ORDER BY Id   )+@row,
					html
		from		#tmpAnios
		where		Id			=	@i
		
		select		@anio		=	Anio,
					@color		=	color
		from		#tmpAnios
		where		Id			=	@i

		
		insert into #tmpHtml
		select		top 3
					ROW_NUMBER() OVER (	ORDER BY Id   )+@row+1,
					html = 
					case when Id%2 > 0 then 
							'<div class="tl-row" style="width: 300px"><div class="tl-item float-right"><div class="popover bottom"><div class="arrow"></div><div class="popover-content" style="background-color:'+ @color+';">
							<h3 class="tl-title" data-toggle="tooltip" data-placement="top" title="'+DocumentoEntregable+'">' 
							+ cast(DocumentoEntregable as varchar(60)) + '</h3><div class="tl-time"><i class="glyph-icon icon-clock-o"></i>&nbsp;' 
							+ ISNULL(FORMAT(FechaEntrega,'dd-MM-yyyy') ,'')
							+ '</br><button class="btn btn-default btn-xs m-r-5" onclick="go(this);" data-archivo="'+DataArchivo+'" data-documento="'
							+ CASE WHEN DataArchivo='pdf' THEN cast(DocumentoEntregableId as varchar(20)) else  cast(IdInstanciaEntregable as varchar(20)) END+'" type="button">Ver Archivo</button>'
							+'</div></div></div></div></div>'
							else								
							'<div class="tl-row" style="width: 300px"><div class="tl-item"><div class="popover top"><div class="arrow"></div><div class="popover-content" style="background-color:'+ @color+';">
							<h3 class="tl-title" data-toggle="tooltip" data-placement="right" data-container="body" title="'+DocumentoEntregable
							+'">' + cast(DocumentoEntregable as varchar(60))  + '</h3><div class="tl-time"><i class="glyph-icon icon-clock-o"></i>&nbsp;' 
							+ ISNULL(FORMAT(FechaEntrega,'dd-MM-yyyy') ,'')  
							+'</br><button class="btn btn-default btn-xs m-r-5" onclick="go(this);" data-archivo="'+DataArchivo+'" data-documento="'
							+CASE WHEN DataArchivo='pdf' THEN cast(DocumentoEntregableId as varchar(20)) else  cast(IdInstanciaEntregable as varchar(20)) END+'" type="button">Ver Archivo</button>' 
							+ '</div></div></div></div></div>'
							
					end
		from		#tmpEntregablesFinal
		where		Anio = @anio
		
		select	@i = @i + 1
	end

	select @row = isnull(count(Id),1)*350 from #tmpHtml
	
	declare @html varchar(max)

	select @html = coalesce(@html+ html,html) from #tmpHtml order by Id --#TemporalInfoOrdenada
	
    select @html = '<div class="timeline-box timeline-horizontal" style="width: '+cast(@row as varchar(5))+'px;">'+@html+'</div>'

     select HtmlArmado = @html
	
 END;
