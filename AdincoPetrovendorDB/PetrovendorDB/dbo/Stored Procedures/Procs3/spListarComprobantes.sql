
CREATE PROCEDURE spListarComprobantes
	@IdContrato		int,
	@IdUsuario		int,
	@FechaIni		datetime,
	@FechaFin		dateTime
AS
BEGIN


	select		faws.IdComprobante
	into		#tmpFiles
	from		adinco..ComprobantesAWSDocumentos	faws
	inner join	adinco..AWS_Documentos				awsd
	on			faws.AWSDocumentoId		=	awsd.AWSDocumentoId
	group by	faws.IdComprobante

	SELECT 
				--R						=	ROW_NUMBER() OVER(PARTITION BY APC.IdPedimentoComprobante ORDER BY APC.IdPedimentoComprobante DESC),
				IdComprobante			=	PC.IdPedimentoComprobante,
				PC.FolioComprobante,
				PC.FechaPago,
				Exportador				=	SUBSTRING(SE.RazonSocial, 0, 30),
				ClaseBienServicio		=	CASE	WHEN LEN(ISNULL(PCD.ClaseBienServicio,'')) > 50 THEN SUBSTRING(ISNULL(PCD.ClaseBienServicio,''),1,48) + '..'
													ELSE ISNULL(PCD.ClaseBienServicio,'') 
													END,
				UnidadMedida			=	SUBSTRING(MU.Unidad, 0, 30),
				TM.TipoMonedaCorto,
				PCD.PrecioUnitario,
				PCD.Cantidad,
				PCD.ImporteTotal,
				FormaDePago				=	L.Nombre,
				CreadoPor				=	UC.Nombre,
				PC.CreadoEn,
				ModificadoPor			=	UM.Nombre,
				PC.ModificadoEn,
				PC.NumFacturaC,
				EsnotaCredito			=	CASE	WHEN ISNULL(PC.EsnotaCredito,0) = 0 THEN  'No'
													ELSE 'Si'
													END,
				Estatus					=	TE.Nombre,
				CC.CentroCosto,
				CuentaContable			=	CO.Numero + ' - ' + CO.Descripcion,
				TieneArchivos			=	case when t1.IdComprobante	is null then cast(0 as bit) else cast(1 as bit) end
    FROM		dbo.FI_PedimentoComprobante						PC
	LEFT JOIN	dbo.FI_PedimentoComprobanteDetalle				PCD		ON	PC.IdPedimentoComprobante				=	PCD.IdPedimentoComprobante 
																		and pc.IdContrato							=	@IdContrato
																		and	PC.CvTipoDocFacturacion					=	3
																		and	ISNULL(PC.IdEstatusEliminado,0)			=	0
	LEFT JOIN	Adinco.dbo.PV_Subcontratista					SI		ON	PC.IdSubcontratistaImportador			=	SI.IdSubcontratista
	LEFT JOIN	Adinco.dbo.PV_Subcontratista					SE		ON	PC.IdSubcontratistaExportador			=	SE.IdSubcontratista
	LEFT JOIN	Adinco.dbo.PV_TipoMoneda						TM		ON	PC.IdMoneda								=	TM.IdMoneda
	LEFT JOIN	dbo.S_Usuario									UC		ON	PC.CreadoPor							=	UC.IdUsuario
	LEFT JOIN	dbo.S_Usuario									UM		ON	PC.ModificadoPor						=	UM.IdUsuario
	LEFT JOIN	Adinco.dbo.AP_Lista								L		ON	PC.IdFormaPago							=	L.IdClave	
																		AND	L.IdGrupo								=	10001
	LEFT JOIN	Adinco.dbo.PV_MM_MaterialUnidad					MU		ON	PCD.IdUnidadMedida						=	MU.IdUnidad
	LEFT JOIN	dbo.FI_Documento								D		ON	PC.IdPedimentoComprobante				=	D.IdPedimentoComprobante
	inner JOIN	dbo.FI_AceptacionPedido_PedimentoComprobante	APC		ON	APC.IdPedimentoComprobante				=	PC.IdPedimentoComprobante
	inner JOIN	dbo.TA_Operacion								OP		ON	OP.IdDocumento							=	APC.IdAceptacionPedidoPedimentoComprobante	
																		AND OP.IdTipoOperacion						=	19	
																		AND OP.IdProveedor							=	APC.IdProveedor
	LEFT JOIN	dbo.FI_RelacionAdincoPedimentoComprobante		RAPC	ON	RAPC.IdPedimentoComprobantePetrovendor	=	PC.IdPedimentoComprobante
	inner JOIN	dbo.TA_Estatus									TE		ON	TE.IdEstatus							=	OP.IdEstatusOperacion
	LEFT JOIN	dbo.CC_CentroCosto								CC		ON	CC.IdCentroCosto						=	PC.IdCentroCosto
	LEFT JOIN	dbo.DG_CuentaContable							CO		ON	CO.Id									=	PC.IdCuentaContable
	left join	#tmpFiles										t1		on	PC.IdPedimentoComprobante				=	t1.IdComprobante
    WHERE		PC.CvTipoDocFacturacion							=		3
    AND			ISNULL(PC.IdEstatusEliminado,0)					=		0
	and			PC.IdContrato									=		@IdContrato
	and			PC.FechaPago									between	@FechaIni	
																and		@FechaFin
	--AND			APC.IdProveedor									=		@IdProveedor
	
		   
end

