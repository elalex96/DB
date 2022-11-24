
create proc spArchivosPozoSel
(
	@IdContrato		int,
	@IdInstalacion	int
)
as
begin
	--select 1

	SELECT		IPF.IdContrato,
				P.IdInstalacion,
				E.DocumentoEntregable,
				ISNULL(IE.FechaRealEntregaRegulador,IE.FechaCalculadaEntregaReg)    AS FechaEntrega,
				ED.DocumentoEntregableId,   
				ED.NombreArchivo,   
				MAX(HALT.IdLineaTiempo) AS Versionn,   
				ED.Bucket,   
				ED.Folder,   
				ED.UUIDAmazon,   
				IE.idInstanciaEntregable,   
				LTRIM(RTRIM(SUBSTRING(ED.NombreArchivo, CHARINDEX('.',ED.NOMBREARCHIVO,LEN(ED.NOMBREARCHIVO)-5), LEN(ED.NombreArchivo)))) AS TipoArchivo ,
				e.Consecutivo
	FROM		EN_Procesos										P		(NOLOCK)
	JOIN		EN_InstanciasProcesosFecha						IPF		(NOLOCK)
	ON			P.IdProceso										=		IPF.IdProceso
	AND			P.IdInstalacion									=		@IdInstalacion	-- 12251 
	AND			IPF.IdContrato									=		@IdContrato		-- 10112   
	and			P.IdInstalacion									=		@IdInstalacion
	AND			IPF.IdContrato									=		@IdContrato
	JOIN		EN_InstanciasActividades						IA		(NOLOCK)
	ON			IPF.IdInstanciasProcesos						=		IA.IdInstanciasProcesos
	JOIN		EN_InstanciasEntregables_InstanciaActividad		IEIA    (NOLOCK)
	ON			IA.idInstanciaActividad							=		IEIA.idInstanciaActividad
	JOIN		EN_InstanciasEntregable							IE		(NOLOCK)
	ON			IEIA.IdInstanciaEntregable						=		IE.IdInstanciaEntregable
	JOIN		EN_ContratoEntregable							CE		(NOLOCK)
	ON			IE.IdContratoEntregable							=		CE.IdContratoEntregable
	JOIN		EN_Entregable									E		(NOLOCK)
	ON			CE.IdEntregable									=		E.IdEntregable
	--AND		E.Consecutivo									=		'ADINCO-PERFO503'   -- @Consecutivo
	--and			e.Consecutivo									in		('ADINCO-PERFO048','ADINCO-PERFO503','ADINCO-PERFO018')
	JOIN		dbo.EN_HistorialAprobacionesLineaTiempo			HALT 
	ON			IE.idInstanciaEntregable						=		HALT.idInstanciaEntregable  
	AND			HALT.Rechazado									=		0  
	JOIN		dbo.EN_DocumentoVersion							DE
	ON			HALT.idInstanciaEntregable						=		DE.idInstanciaEntregable  
	JOIN		dbo.EN_EntregableDocumento						ED
	ON			DE.DocumentoEntregableId						=		ED.DocumentoEntregableId  
	AND			ED.idTipoArchivo								=		10000  
	AND			ED.Activo										=		1  
	GROUP BY    IPF.IdContrato,
				P.IdInstalacion,
				e.Consecutivo,
				E.DocumentoEntregable,
				ISNULL(IE.FechaRealEntregaRegulador,IE.FechaCalculadaEntregaReg),
				ED.DocumentoEntregableId,   
				ED.NombreArchivo,   
				ED.Bucket,   
				ED.Folder,   
				ED.UUIDAmazon,   
				IE.idInstanciaEntregable,   
				LTRIM(RTRIM(SUBSTRING(ED.NombreArchivo, CHARINDEX('.',ED.NOMBREARCHIVO,LEN(ED.NOMBREARCHIVO)-5), LEN(ED.NombreArchivo))))
			
end

