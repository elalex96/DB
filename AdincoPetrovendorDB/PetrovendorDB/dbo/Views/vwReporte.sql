CREATE view vwReporte

as
	select		--a.IdAceptacionPedido,
				Contrato				=		CO.NumeroContrato,
				IdSolicitudPedido		=		SP.IdSolicitudPedido,
				FechaAlta				=		SP.FechaAlta,
				Objeto					=		SP.MotivoUrgencia,
				Folio					=		CASE PS.IdTipoPedido	WHEN 4 THEN NULL
																		WHEN 2 THEN NULL
																		WHEN 6 THEN	REPLACE (SP.MotivoUrgencia,'Estimación Completa para OT:', '') END,
				PedidoADINCO			=		PS.IdPedido, 
				IdAceptacionPedido		=		APD.IdAceptacionPedido,
				DescripcionCorta		=		POD.MaterialCotizadoTextoC,
				DescripcionLarga		=		POD.MaterialCotizadoTextoL,
				Unidad					=		POD.UnidadProveedor,
				CantidadSolicitada		=		pd.Cantidad,	
				CantidadRecibida		=		APD.Cantidad, 
				PrecioUnitario			=		PD.PrecioUnitario,
				Moneda					=		TM.TipoMonedaCorto,
				Descripcion				=		POD.MaterialCotizadoTextoL,		--2.A
				NombreInstalacion		=		INS.NombreInstalacion,			--2.B
				Mes						=		dbo.Fn_RetornarMesEspanol ( MONTH ( lp.AC_PRESUP_MES )) ,
				Actividad				=		CASE WHEN CO.IdTipoContrato = 1 THEN
														 ts.NombreTipoServicio
												ELSE
													apCNH.DescripcionActividadPetrolera
												END COLLATE Modern_Spanish_CI_AS ,
				SubActividad			=		CASE WHEN CO.IdTipoContrato = 1 THEN
														 aCIEP.NombreActividad
												ELSE
													SAP.SubactividadPetrolera
												END COLLATE Modern_Spanish_CI_AS ,	
				Tarea					=		TaP.TareaPetrolera COLLATE Modern_Spanish_CI_AS,
				ClaveTarea				=		Tap.id_Tarea COLLATE Modern_Spanish_CI_AS ,
				SubTarea				=		s.NombreServicio COLLATE Modern_Spanish_CI_AS,
				TipoPedido				=		tp.TipoPedido,				--3.-Agregar la columna Tipo de pedido posterior a la columna PedidoADINCO.
				Proveedor				=		pro.RazonSocial,			--4.-Agregar la columna Proveedor, posterior a la columna Tipo de pedido.
				FechaConfirmacionPedido	=		p.FechaRecepcionServicio,	--5.-Agregar la columnna fecha de confirmación de pedido (Fecha en que el proveedor confirma)
				CentroCostos			=		cc.CentroCosto,				--6.- Agregar la columna Centro de costo posterior a la columna FechaAlta.
				MontoPedido				=		SUM(MP.MontoPedido),--(select	sum(Subtotal) 			from	MM_PedidoDetalle 			where	IdPedido			= p.IdPedido			group by  IdPedido),				--7.- Agregar la columna Monto Pedido (Subtotal pedido) posterior a la columna Precio Unitario.
				/**/MontoAceptado		=		SUM(MP.MontoAceptado),
													--(	
													--SELECT		SUM(t2.Cantidad) * t1.PrecioUnitario
													--FROM		dbo.MM_PedidoDetalle t1
													--JOIN		dbo.MM_AceptacionPedidoDetalle t2
													--ON			t1.IdPedidoDetalle = t2.IdPedidoDetalle
													--JOIN		dbo.MM_AceptacionPedido t3
													--ON			t2.IdAceptacionPedido = t3.IdAceptacionPedido
													--WHERE		t3.IdPedido = p.IdPedido
													--AND			ISNULL(t3.IdEstatusEliminado, 0) = 0--> QUE LA ACEPTACIÓN NO ESTE ELIMINADA
													--GROUP BY	t2.IdPedidoDetalle,
													--			t1.PrecioUnitario
													--),

				UUID					=		F.UUID,
				FechaCargaXML			=		AF.FechaCargaXML,
				Estatus_de_factura		=		E.Nombre,

				SolicitudPedido_Eliminada	=	case when SP.IdEstatusEliminado =	1 then 'SI' else 'NO'	end,	--a)	SolicitudPedido_Eliminada: con valores Si – No, donde “Si” es que la solicitud de 
																													--		pedido fue eliminada y “No” es que aún esta vigente en ADINCO y no se ha eliminado.
				AceptaciónPedido_Eliminada	=	case when A.IdEstatusEliminado	=	1 then 'SI' else 'NO'	end,	--b)	AceptaciónPedido_Eliminada: con valores Si – No donde “Si” es que la aceptación de
																													--		pedido fue eliminada y “No” es que aún esta vigente en ADINCO y no se ha eliminado.
				Pedido_Eliminado			=	case when P.IdEstatusEliminado	=	1 then	'SI' else 'NO'	end		--c)	Pedido_Eliminado: con valores Si – No donde “Si” es que el pedido fue eliminado y
				--TipoPedido				=		PS.IdTipoPedido--,
				--a.IdAceptacionPedido,
				--p.*
	from		MM_Pedido						p	(NOLOCK)
	join	MM_Pedidos							PS      (NOLOCK)	ON	PS.IdIdentificador				=	P.IdPedido
		AND PS.IdTipoPedido in (2, 4, 6)
	left join	MM_AceptacionPedido				a	(NOLOCK)
	on			a.IdPedido						=		p.IdPedido
	left join	MM_AceptacionPedidoDetalle		APD		(NOLOCK)	on			A.IdAceptacionPedido			=	APD.IdAceptacionPedido
	left join	MM_PedidoDetalle				PD		(NOLOCK)	ON			PD.IdPedidoDetalle				=	APD.IdPedidoDetalle
	left join	dbo.MM_PeticionOfertaDetalle	POD		(NOLOCK)	ON			POD.IdPeticionOfertaDetalle		=	PD.IdPeticionOfertaDetalle
	LEFT JOIn	MM_SolicitudPedido				SP		(NOLOCK)	ON			P.IdSolicitudPedido				=	SP.IdSolicitudPedido
	--left join	MM_SolicitudPedidoDetalle		spd		on			spd.IdSolicitudPedido			=	sp.IdSolicitudPedido --2.A
	--left join	MM_SolicitudPedidoDetalleLineaPresupuesto	spdlp	on	spdlp.IdSolicitudPedidoDetalle	=	spd.IdSolicitudPedidoDetalle
	
	left join	MM_TipoPedido								tp		(NOLOCK)	on	tp.IdTipoPedido					=	ps.IdTipoPedido
	left join	PV_TipoMoneda								TM		(NOLOCK)	ON	TM.IdMoneda						=	PD.IdMoneda 
	left join	dbo.MM_AceptacionPedidoDetalleInstalacion	APDI	(NOLOCK)	ON	APDI.IdAceptacionPedido			=	A.IdAceptacionPedido
	left join	S_Proveedor									pro		(NOLOCK)	on	pro.IdProveedor					=	p.IdSubcontratista
	left join	CC_CentroCosto								cc		(NOLOCK)	on	cc.IdCentroCosto				=	SP.IdCentroCosto
	left join	Adinco.dbo.CO_Instalacion					INS		(NOLOCK)	ON	INS.IdInstalacion				=	APDI.IdInstalacion	
	left join	Adinco.dbo.CO_LineaPresupuestoMes			lp 		(NOLOCK)	ON	lp.IdLineaPresupuestoMes		=	APDI.IdLineaPresupuesto	
	left join	Adinco..CO_Yacimiento						Y       (NOLOCK)	ON	INS.IdYacimiento				=	Y.IdYacimiento
	left join	adinco.dbo.CO_Contrato						CO		(NOLOCK)	on	CO.IdContrato					=	SP.IdContrato  
	left join	MM_AceptacionFactura						AF		(NOLOCK)	on	AF.IdAceptacionPedido			=	APDI.IdAceptacionPedido
	left join	Ta_operacion								OP		(NOLOCK)	on	AF.IdAceptacionFactura			=	OP.idDocumento					and OP.IdTipoOperacion				=	10
	left join	TA_Estatus									E		(NOLOCK)	on	OP.IdEstatusOperacion			=	E.IdEstatus
	left join	FI_Factura									F		(NOLOCK)	on	AF.IdFactura					=	F.IdFactura
	left join	Adinco.dbo.CO_TipoServicio					TS		(NOLOCK)	ON	LP.IdTipoServicio				=	TS.ID_TIPOSER
	left join	Adinco.dbo.CO_ActividadPetroleraCNH			APCNH	(NOLOCK)	ON	LP.IdActividadPetrolera			=	APCNH.IdActividadPetrolera
	left join	Adinco.dbo.CO_SubactividadPetrolera			SAP		(NOLOCK)	ON	LP.IdSubactividadPetrolera		=	SAP.IdSubactividadPetrolera
	left join	Adinco.dbo.CO_TareaPetrolera				TaP		(NOLOCK)	ON	LP.IdTareaPetrolera				=	TaP.IdTareaPetrolera
	left join	Adinco.dbo.CO_ActividadCIEP					ACIEP 	(NOLOCK)	ON	LP.IdActividad					=	ACIEP.IdActividad
	left join	Adinco.dbo.CO_Servicio						S		(NOLOCK)ON	LP.IdServicio					=	S.IdServicio
	left join	vwMontosPedidos								MP		(NOLOCK)ON  MP.IdPedido						=	PS.IdPedido
	--where		p.IdSolicitudPedido							=		14534
	where		--p.IdSolicitudPedido							=		25201 and			
	PS.IdTipoPedido in (2, 4, 6) 
	/*
	and			SP.IdContrato in (	10038, --> CNH-A4.OGARRIO/2018
									10044, --> CNH-R03-L01-G-TMV-02/2018
									10045, --> CNH-R03-L01-G-TMV-03/2018
									10046, --> CNH-R03-L01-AS-CS-14/2018
									10144, --> CNH-DEMMA
									10145) --> CNH-ADMIN
									*/
	group by	
	a.IdAceptacionPedido,
	CO.NumeroContrato,
	SP.IdSolicitudPedido,
	SP.FechaAlta,
	SP.MotivoUrgencia,
	PS.IdTipoPedido,
	PS.IdPedido,
	APD.IdAceptacionPedido,
	POD.MaterialCotizadoTextoC,
	POD.MaterialCotizadoTextoL,
	POD.UnidadProveedor,
	pd.Cantidad,	
	APD.Cantidad, 
	PD.PrecioUnitario,
	TM.TipoMonedaCorto,
	POD.MaterialCotizadoTextoL,		--2.A
	INS.NombreInstalacion,			--2.B
	lp.AC_PRESUP_MES,
	CO.IdTipoContrato,
	ts.NombreTipoServicio,
	apCNH.DescripcionActividadPetrolera,
	CO.IdTipoContrato,
	aCIEP.NombreActividad,
	SAP.SubactividadPetrolera,	
	TaP.TareaPetrolera,
	Tap.id_Tarea,
	s.NombreServicio,
	tp.TipoPedido,
	pro.RazonSocial,
	p.FechaRecepcionServicio,
	cc.CentroCosto,
	p.IdPedido,
	F.UUID,
	AF.FechaCargaXML,
	E.Nombre,
	SP.IdEstatusEliminado,
	A.IdEstatusEliminado,
	P.IdEstatusEliminado
