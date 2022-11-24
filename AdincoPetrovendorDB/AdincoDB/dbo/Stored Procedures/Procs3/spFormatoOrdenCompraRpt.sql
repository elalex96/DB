-- spFormatoOrdenCompraRpt 55
create proc spFormatoOrdenCompraRpt
(
	@pIdOTSolicitud		int
)
as
begin

	declare @aprobador varchar(100),
		@usuarioProveedor varchar(100),
		@usuarioidProveedor int,
		 @total money

	select @aprobador = isnull(u.Nombre,'SIN DEFINIR')
	from OT_Solicitud ot
	inner join [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdCentroCosto = ot.IdCentroCosto
	inner join [dbo].[AP_FlujoAprobacionEstatusUsuarios] uf on uf.UsuarioId = ucc.IdUsuario and
														uf.FlujoAprobacionEstatusId = 2
	inner join AP_Usuario u on u.UsuarioId = uf.UsuarioId 
	where 	ot.IdOTSolicitud = @pIdOTSolicitud

	select @total = sum(ot.Cantidad*sc.PrecioUnitario) 
	from OT_SolicitudMaterial ot
	inner join SC_Materiales sc on sc.IdSCMaterial = ot.IdSCMaterial
	where ot.IdOTSolicitud = @pIdOTSolicitud and
	ot.Cantidad > 0

	select top 1 @usuarioidProveedor =  UsuarioPetroId
	from OT_solicitudBitacora
	where IdOTSolicitud = @pIdOTSolicitud
	and UsuarioPetroId is not null
	order by CreadoEl asc

	select @usuarioProveedor=Nombre
	from petrovendor..S_Usuario
	where idusuario = @usuarioidProveedor






	select		Operadora									=		con.NombreContratista,
				OperadoraDireccion							=		con.Calle + ' ' + con.Numero + ' ' + con.Colonia + ' ' + con.CodigoPostal+ ', '+ con.Municipio,
				
				OrdenCompra									=		ot.Folio,
				Fecha										=		getdate(),
				NumeroContrato								=		isnull(c.NumeroContrato,''),
				AreaContractual								=		ac.NombreAreaContractual,
				Requisicion									=		t.Nombre,
				AreaSolicitante								=		CentroCosto,

				Proveedor									=		prov.RazonSocial,
				ProveedorDireccion							=		prov.Colonia,
				ProveedorRFC								=		prov.RFC,
				ProveedorTelefono							=		prov.Telefono,
				ProveedorEmail								=		prov.CorreoProveedor,
				Partida										=		m.Concepto,
				Descripcion									=		m.Descripcion,
				UnidadMedida								=		lower(mu.Unidad),
				CTD											=		sm.Cantidad,
				PUnit										=		m.PrecioUnitario,
				SubTotal									=		sm.Cantidad * m.PrecioUnitario ,
				FechaEntrega								=		getdate(),
				LugarEntrega								=		'',
				Comentarios									=		sm.Comentarios,
				Presupuesto									=		p.Nombre,
				Notas										=		ot.Objeto,
				CodigoBidimencional							=		'',
				Elaboro										=		u.Nombre,
				FechaHora									=		ot.CreadoEl,
				IdFirmaElectrónica							=		NEWID(),
				Aprobador									=		@aprobador,
				Estatus										=		e.Descripcion,
				FechaCreacion								=		ot.CreadoEl,
				Firma										=		'',
				TerminosCondiciones							=		isnull(t.Nombre,''),
				ContratistaLogo								=		con.logo,
				ContratistaRFC								=		con.RFC,
				Logo										=		i.ImagenProveedor,
				AceptoProveedor								=		isnull(@usuarioProveedor,''),
				AceptoFechaHora								=		sm.FechaProgramaFin,
				AceptoIdFirmaElectronica					=		NEWID(),
				Moneda										=		mo.TipoMonedaCorto,
				Comprador									= uComprador.Nombre,
				CompradorEmail =							uComprador.Usuario,
				CompradorTelefono								= con.Telefono,
				TipoOrdenCompra								='Adjudicación directa',
				CantidadLetra = [dbo].[CantidadConLetra](@total) +' '+ mo.TipoMonedaCorto
	from		OT_Solicitud								ot		--on	ot.IdOTSolicitud								= est.IdOTSolicitud
	inner join	SC_SubContrato								subC	on	subC.IdSubcontrato								=	ot.IdSubContrato
	inner join  PV_TipoMoneda								mo on mo.IdMoneda = ot.IdMoneda
	left join	CO_Contrato									c		on	subC.IdContrato									=	c.IdContrato
	left join	petrovendor..CC_CentroCosto					cc		on	ot.IdCentroCosto								=	cc.IdCentroCosto
	inner join	CO_Contratista								con		on	con.IdContratista								=	subC.IdContratista
	inner join	AP_Usuario									usu1	on	usu1.UsuarioID									=	ot.CreadoPor
	inner join	PV_Subcontratista							scon	on	scon.IdSubcontratista							=	subC.IdSubcontratista
	inner join	Petrovendor.dbo.S_Proveedor					prov	on	prov.RFC collate SQL_Latin1_General_CP1_CI_AS	=	scon.RFC collate SQL_Latin1_General_CP1_CI_AS
	left join	Petrovendor.dbo.S_Usuario					usu2	on	usu2.Correo										=	prov.CorreoProveedor
	left join	CO_AreaContractual							ac		on	ac.IdAreaContractual							=	c.IdAreaContractual
	inner join	OT_SolicitudMaterial						sm		on	sm.IdOTSolicitud								=	ot.IdOTSolicitud and
																		sm.Cantidad > 0
	inner join	SC_Materiales								m		on	sm.IdSCMaterial									=	m.IdSCMaterial
	inner join	CO_Presupuesto								p		on	ot.IdPresupuesto								=	p.IdPresupuesto
	inner join	AP_Usuario									u		on	u.UsuarioID										=	ot.CreadoPor
	inner join	OT_Estatus									e		on	e.IdOtEstatus									=	ot.IdOTEstatus
	inner join	Petrovendor..PV_MM_MaterialUnidad			mu		on	mu.IdUnidad										=	m.IdUnidad
	left join	Petrovendor..S_ImagenPerfil					i		on	i.IdProveedor									=	prov.IdProveedor
	left  join	Petrovendor..TC_TerminosYCondicionesDocV2	t		on	t.IdTerminosYCondiciones						=	ot.IdTerminos
	inner join	AP_Usuario									uComprador on uComprador.usuarioId = ot.CreadoPor
	where		ot.IdOTSolicitud							=			@pIdOTSolicitud
	order by m.Concepto
	--select * from OT_SolicitudMaterial where IdOTSolicitud = @pIdOTSolicitud
	--select * from Petrovendor..S_ImagenPerfil

end

