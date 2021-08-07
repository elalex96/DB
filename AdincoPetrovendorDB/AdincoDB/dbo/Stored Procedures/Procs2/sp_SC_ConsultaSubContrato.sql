create Proc sp_SC_ConsultaSubContrato
@pIdSubContrato int
As

	declare @pPuedeModifConvenio bit


	

	select sc.IdSubContrato,
			sc.IdSubContratista,
			sc.IdContratista,
			sc.NumeroSubContrato,
			c.NombreContratista,
			NombreSubContratista = psc.RazonSocial,
			FechaRegistro = sc.CreadoEl,
			sc.Objeto,
			IdPedido = ISNULL(sc.IdPedido,0),
			PrefijoOT = ISNULL(sc.PrefijoOT,''),
			FolioOTSig =ISNULL(sc.PrefijoOT,'') +'-'+ CAST(ISNULL(COUNT(DISTINCT otSol.IdOTSolicitud),0) + 1 AS varchar) ,
			IdPresupuesto = ISNULL(pre.IdPresupuesto,0),
			IdProveedor = prov.IdProveedor,
			FolioPedido = folio.IdPedido,
			sc.FechaInicio,
			sc.FechaFin,
			sc.IdCentroCosto,
			sc.IdMoneda

	from SC_Subcontrato sc
	inner join CO_Contratista c on c.IdContratista = sc.IdContratista
	inner join pv_Subcontratista psc on psc.IdSubContratista = sc.IdSubContratista
	LEFT JOIN dbo.SC_Presupuesto PRE ON PRE.IdSubContrato = SC.IdSubContrato
	LEFT JOIN dbo.OT_Solicitud otSol ON otSol.IdSubContrato = sc.IdSubContrato
	LEFT join Petrovendor.dbo.S_Proveedor prov on prov.RFC collate SQL_Latin1_General_CP1_CI_AS = psc.RFC collate SQL_Latin1_General_CP1_CI_AS
	LEFT join Petrovendor.dbo.MM_Pedidos folio on folio.IdIdentificador = sc.IdPedido
	where sc.IdSubContrato = @pIdSubContrato
	GROUP BY sc.IdSubContrato,
			sc.IdSubContratista,
			sc.IdContratista,
			sc.NumeroSubContrato,
			c.NombreContratista,
			 psc.RazonSocial,
			 sc.CreadoEl,
			sc.Objeto,
			sc.IdPedido,
			sc.PrefijoOT,
			pre.IdPresupuesto,
			prov.IdProveedor,
			folio.IdPedido,
			sc.FechaInicio,
			sc.FechaFin,
			sc.IdCentroCosto,
			sc.IdMoneda



