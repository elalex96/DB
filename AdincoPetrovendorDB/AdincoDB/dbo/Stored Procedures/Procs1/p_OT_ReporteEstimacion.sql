-- p_OT_ReporteEstimacion 1
CREATE proc [dbo].[p_OT_ReporteEstimacion]
@pIdOTEstimacion int
as			  


DECLARE @TOTAL MONEY 

	select @TOTAL = sum(Importe)
	from vwOTEstimacion
	where idOTEstimacion = @pIdOTEstimacion

	select est.IdOTSolicitud,
		est.IdOTEstimacion,
		est.FolioEstimacion,
		est.FolioOT,
		est.FolioSC,
		FechaInicioSubcontratista = est.FechaIniCorte,
		FechaFinSubcontratista =est.FechaFinCorte,
		est.Instalacion,
		est.Actividad,
		est.Presupuesto,
		--est.Subcontratista,
		est.AreaContractual,
		est.AceptaOperador,
		est.AceptaSubcontratista,
		est.IdSCMaterial,
		est.COncepto,
		est.Descripcion,
		est.Unidad,
		est.Cantidad,
		est.PrecioUnitario,
		est.Importe,
		/**********CONTRATISTA**************/
		Contratista = upper(con.RazonSocial),
		ContratistaDir = upper(isnull(rtrim(con.Calle),'') + ' ' +isnull(rtrim(con.Numero),'') + ' ' +isnull(rtrim(con.Colonia),'') + ' ' +isnull(rtrim(con.CodigoPostal),'') 
						+ ' ' +isnull(rtrim(con.Municipio),'') + ' ' +isnull(rtrim(con.Entidad),'')  ),
		ContratistaRFC = upper(con.RFC),
		ContratistaContac = upper(usu1.Nombre),
		ContratistaTel = upper(con.Telefono),
		ContratistaEmail = upper(con.CorreoElectronico),
		ContratistaLogo = con.Logo,--con.Logo,
		/**********SUBCONTRATISTA********************/
		Subcontratista =upper(prov.RazonSocial),
		SubcontratistaDir = upper(isnull(rtrim(prov.NombreVialidad),'') + ' ' +isnull(rtrim(prov.NumExterior),'') + ' ' +isnull(rtrim(prov.Colonia),'') + ' ' +
							isnull(rtrim(prov.CodigoPostal),'') + ' ' +isnull(rtrim(prov.Municipio),'') + ' ' +isnull(rtrim(prov.Entidad),'') ) ,
		SubcontratistaRFC = upper(prov.RFC),
		SubcontratistaContact = upper(usu2.Nombre),
		SubcontratistaTel=upper(prov.Telefono),
		SubcontratistaEmail = upper(prov.CorreoProveedor),
		est.Moneda,
		ImporteLetra = dbo.fnCantidadConLetraMoneda(@TOTAL,est.Moneda)
	from vwOTEstimacion est
	inner join OT_Solicitud ot on ot.IdOTSolicitud = est.IdOTSolicitud
	inner join SC_SubContrato subC on subC.IdSubcontrato = ot.IdSubContrato
	inner join CO_Contratista con on con.IdContratista = subC.IdContratista
	inner join AP_Usuario usu1 on usu1.UsuarioID = ot.CreadoPor
	inner join PV_Subcontratista scon on scon.IdSubcontratista = subC.IdSubcontratista
	inner join Petrovendor.dbo.S_Proveedor prov on prov.RFC collate SQL_Latin1_General_CP1_CI_AS = scon.RFC collate SQL_Latin1_General_CP1_CI_AS
	left join Petrovendor.dbo.S_Usuario usu2 on usu2.Correo = prov.CorreoProveedor
	where idOTEstimacion = @pIdOTEstimacion