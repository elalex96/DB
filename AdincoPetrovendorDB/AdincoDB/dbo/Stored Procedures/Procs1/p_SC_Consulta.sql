-- p_SC_Consulta 10013,10038,10
alter Proc p_SC_Consulta
@pIdContratista int,
@pIdContrato int,
@pUsuarioId int
as

	declare @idMonedaDefault int

	select @idMonedaDefault = max(mae.IdMoneda)
	from SC_Materiales mat
	inner join Petrovendor..MM_Material mm on mm.IdMaterial = mat.IdMaestro
	inner join Petrovendor..MM_Maestro mae on mae.IdMaestro = mm.IdMaestro

	--SUBCONTRATOS
	select sc.IdSubContrato,
		Total = SUM(mat.Cantidad * mat.PrecioUnitario)
	into #tmpSCTotales
	from SC_Subcontrato sc
	inner join SC_Materiales mat on mat.IdSubcontrato = sc.IdSubcontrato
	left join [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = @pUsuarioId and
											ucc.IdCentroCosto in (0,sc.IdCentroCosto)
	where sc.IdContratista = @pIdContratista AND
	isnull(SC.isActivo,0) = 1 and 
	ISNULL(SC.isEliminado,0) = 0  and
	sc.IdContrato = @pIdContrato
	group by sc.IdSubContrato	

	

	select tmp.IdSubcontrato,
		TotalSC =max(tmp.Total),
		TotalEst = Sum(est.Total),
		Avance = (Sum(est.Total) / max(tmp.Total))
	into #tmpTotales
	from #tmpSCTotales tmp
	left join OT_Solicitud ot on ot.IdSubcontrato = tmp.IdSubcontrato
	left join OT_Estimacion est on est.IdOTSolicitud = ot.IdOTSolicitud	and isnull(est.Cancelada,0) = 0
	group by tmp.IdSubcontrato



	SELECT distinct
	SC.[NumeroSubContrato], SC.[IdSubContratista], SC.[IdSubContrato], SC.[IdContratista], 
	SC.[IsActivo], SC.[IsEliminado], SC.[CreadoPor],FechaRegistro= SC.[CreadoEl], 
	SC.[ModificadoPor], SC.[ModificadoEl] ,
	Moneda = isnull(TipoMonedaCorto,'NO DEFINIDA'),
	AFinanciero = cast(isnull(tot.Avance,0) as decimal(5,2)), -- 1 = 100%
	tot.TotalSC
	FROM [SC_SubContrato] SC
	INNER JOIN dbo.CO_Contrato  c ON c.IdContratista = sc.IdContratista
	left join Petrovendor.dbo.MM_Pedido ped on ped.IdPedido = sc.Idpedido
	left join Petrovendor.dbo.PV_TipoMoneda moneda on moneda.idMoneda = isnull(sc.IdMoneda,@idMonedaDefault)
	left join #tmpTotales tot on tot.IdSubcontrato = SC.IdSubcontrato
	WHERE isnull(SC.isActivo,0) = 1 and 
	ISNULL(SC.isEliminado,0) = 0 AND
	c.IdContratista = @pIdContratista and
	sc.IdContrato = @pIdContrato
	ORDER BY  [IdSubContrato] desc









