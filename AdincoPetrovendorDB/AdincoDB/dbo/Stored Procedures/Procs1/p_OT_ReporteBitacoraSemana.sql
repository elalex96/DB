
-- p_OT_ReporteBitacoraSemana 6,'20190617-20190623'
-- p_OT_ReporteBitacoraSemana 7,''
CREATE Proc [dbo].[p_OT_ReporteBitacoraSemana]
@pIdOTSolicitud int,
@pSemanaID varchar(21)=''
as

	declare @ElaboroOperador varchar(250),
		@ElaboroSubcontratista varchar(250)	

	select @ElaboroOperador = UPPER(usuAdinco.nOMBRE)
	from OT_Solicitud ot
	inner join [dbo].[OT_ProgramaBitacoraSemana] bs on bs.IdOTSolicitud = ot.IdOTSolicitud
	INNER JOIN AP_Usuario usuAdinco ON usuAdinco.UsuarioID = bs.UsuarioAdincoID
	where ot.IdOTSolicitud = @pIdOTSolicitud AND
	@pSemanaID in ('',bs.SemanaID )

	select @ElaboroSubcontratista = upper(usuPet.nOMBRE)
	from OT_Solicitud ot
	inner join [dbo].[OT_ProgramaBitacoraSemana] bs on bs.IdOTSolicitud = ot.IdOTSolicitud
	INNER JOIN Petrovendor.dbo.S_Usuario usuPet ON usuPet.iDuSUARIO = bs.UsuarioPetrovendorID
	where ot.IdOTSolicitud = @pIdOTSolicitud AND	
	@pSemanaID in ('',bs.SemanaID )

	select distinct
		OT.IdOTSolicitud,
		OT.Folio,
		sc.NumeroSubContrato,
		FechaReporte = getdate(),
		FechaInicioBitacora =
					case when @pSemanaID = '' then
												 (
													select cast(substring(min(SemanaID),1,8) as datetime)
													from [OT_ProgramaBitacoraSemana] st1
													where st1.IdOTSolicitud = @pIdOTSolicitud
													--and (st1.SemanaID = @pSemanaID Or @pSemanaID = '')
												)
						else
							substring(@pSemanaID,1,8)
					End
		,
		FechaFinBitacora = (
			case when @pSemanaID = '' then
												 (
													select cast(substring(max(SemanaID),10,8) as datetime)
													from [OT_ProgramaBitacoraSemana] st1
													where st1.IdOTSolicitud = @pIdOTSolicitud
													--and (st1.SemanaID = @pSemanaID Or @pSemanaID = '')
												)
						else
							substring(@pSemanaID,10,8)
					End
		),
		FechaBitacora = bs.FechaRegistro,
		bs.Comentarios,
		TipoUsuarioID = bs.TipoUsuario,
		TipoUsuario = case when bs.TipoUsuario = 1 then 'Operador' else 'Subcontratista' end,
		Presupuesto = /*cast(pre.IdPresupuesto as varchar) + '-' + */isnull(pre.Nombre,''),
		Instalacion = isnull(ins2.NombreInstalacion,'SIN INSTALACIÓN'),
		ElaboroOperador = @ElaboroOperador,
		ElaboroSubcontratista = @ElaboroSubcontratista,
		/*****************INFO CONTRATISTA***********************/
		Contratista= con.RazonSocial,--case when bs.TipoUsuario = 1 then  con.RazonSocial COLLATE SQL_Latin1_General_CP1_CI_AS else PROV.RazonSocial COLLATE SQL_Latin1_General_CP1_CI_AS end,
		ContratistaDireccion = case when bs.TipoUsuario = 1  then upper(rtrim(isnull(con.Calle,'')) + ' ' +rtrim(isnull(con.Numero,'')) + ' ' + rtrim(isnull(con.Colonia,'')) + rtrim(isnull(con.Municipio,'')) + ' ' +
																	rtrim(isnull(con.CodigoPostal,'')) ) COLLATE SQL_Latin1_General_CP1_CI_AS
									else

									upper( rtrim(isnull(prov.NombreVialidad,'')) + ' ' +rtrim(isnull(prov.NumExterior,'')) + ' ' +rtrim(isnull(prov.NumInterior,'')) + 
									rtrim(isnull(prov.Colonia,'')) + rtrim(isnull(prov.Municipio,'')) + ' ' +
									rtrim(isnull(prov.CodigoPostal,'')) ) COLLATE SQL_Latin1_General_CP1_CI_AS

								End,
		ContratistaLogo =null,-- case when bs.TipoUsuario = 1  then con.LogoHtml COLLATE SQL_Latin1_General_CP1_CI_AS else prov.ImagenSrc COLLATE SQL_Latin1_General_CP1_CI_AS end,
		ContratistaRFC =case when bs.TipoUsuario = 1 then con.RFC COLLATE SQL_Latin1_General_CP1_CI_AS  else  prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS end,
		/**************INFO SUBCONTRATISTA*************************/
		Subcontratista =PROV.RazonSocial,
		SubcontratistaDireccion = upper( rtrim(isnull(prov.NombreVialidad,'')) + ' ' +rtrim(isnull(prov.NumExterior,'')) + ' ' +rtrim(isnull(prov.NumInterior,'')) + 
							rtrim(isnull(prov.Colonia,'')) + rtrim(isnull(prov.Municipio,'')) + ' ' +
							rtrim(isnull(prov.CodigoPostal,'')) ),
		SubcontratistaRFC = prov.RFC,
		SubcontratistaLogo = prov.ImagenSrc,
		TituloFirma = case when bs.TipoUsuario = 1 then 'Supervisor Operador' else 'Supervisor Subcontratista' end,
		NombreFirma = case when bs.TipoUsuario = 1 then @ElaboroOperador else @ElaboroSubcontratista end,
		FechaInicioSemana = cast(substring( bs.SemanaID,1,8) as datetime),
		FechaFinSemana = cast(substring( bs.SemanaID,10,8) as datetime),
		bs.SemanaID
	from OT_Solicitud ot
	inner join [dbo].[OT_ProgramaBitacoraSemana] bs on bs.IdOTSolicitud = ot.IdOTSolicitud
	inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato
	left join petrovendor..mm_pedido ped on ped.Idpedido = sc.IdPedido
	inner join [dbo].[OT_LineaPresupuesto] otlp on otlp.IdOTSolicitud = ot.IdOTSolicitud
	inner join [dbo].[CO_LineaPresupuestoMes] lp on lp.IdLineaPresupuestoMes = otlp.IdLineaPresupuestoMes
	inner join CO_Presupuesto pre on pre.IdPresupuesto = lp.IdPresupuesto
	left join [dbo].[OT_SolicitudInstalacion] ins on ins.IdOTSolicitud = ot.IdOTSolicitud
	left join CO_Instalacion ins2 on ins2.IdInstalacion = ins.IdInstalacion
	inner join CO_Contratista con on con.IdContratista = sc.IdContratista
	inner join PV_Subcontratista subCon on subCon.IdSubcontratista = sc.IdSubContratista
	inner join Petrovendor.dbo.S_Proveedor prov on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = subCon.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
	where ot.IdOTSolicitud = @pIdOTSolicitud AND
	(
		bs.SemanaID = @pSemanaID
		OR
		@pSemanaID = ''
	)
	group by OT.IdOTSolicitud,
		OT.Folio,
		sc.NumeroSubContrato,
		bs.FechaRegistro,
		bs.Comentarios	,
		bs.TipoUsuario,
		pre.IdPresupuesto,
		pre.Nombre,
		ins2.NombreInstalacion,
		con.RazonSocial,
		con.Calle,
		con.Numero,
		con.Colonia,
		con.Municipio,
		con.CodigoPostal,
		prov.RFC,
		con.RFC,
		prov.RazonSocial,
		prov.NombreVialidad,
		prov.NumExterior,
		prov.NumInterior,
		prov.Colonia,
		prov.Municipio,
		prov.CodigoPostal,
		prov.ImagenSrc,
		--cast(con.Logo as varbinary),
		con.LogoHtml,
		bs.SemanaID
	order by bs.FechaRegistro desc

