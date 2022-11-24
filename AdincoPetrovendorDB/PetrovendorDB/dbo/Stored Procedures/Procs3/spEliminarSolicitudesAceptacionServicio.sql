
create proc spEliminarSolicitudesAceptacionServicio
(
	@IdSolicitudAceptacionPedido	int
)
as
begin

	select IdProveedor from S_Proveedor where RazonSocial like '%Wintershall Dea Mexico S. de R.L. de C.V.%'

	declare @IdProveedor					int

	--select	@IdSolicitudAceptacionPedido	=	1039--,		@IdProveedor					=	573
	select	@IdProveedor					=	IdProveedor from S_Proveedor where RazonSocial like '%Wintershall Dea Mexico S. de R.L. de C.V.%'

	--select	'MM_SolicitudAceptacionPedido', * 
	--from	MM_SolicitudAceptacionPedido 
	--where	IdSolicitudAceptacionPedido		=	@IdSolicitudAceptacionPedido -- order by IdSolicitudAceptacionPedido desc

	update	MM_SolicitudAceptacionPedido 
	set		Activo							=	0 
	where	IdSolicitudAceptacionPedido		=	@IdSolicitudAceptacionPedido 

	--select	'MM_SolicitudAceptacionPedidoDetalle', * 
	--from	MM_SolicitudAceptacionPedidoDetalle 
	--where	IdSolicitudAceptacionPedido		=	@IdSolicitudAceptacionPedido --order by IdSolicitudAceptacionPedidoDetalle desc

	--select	* 
	--from	TA_Operacion 
	--where	IdDocumento						=	@IdSolicitudAceptacionPedido 
	--and		IdProveedor						=	@IdProveedor--order by IdOperacion desc

	update	TA_Operacion
	set		IdEstatusOperacion				=	9
	where	IdDocumento						=	@IdSolicitudAceptacionPedido

	update	TA_Tarea
	set		Activo			=	0
	where	IdOperacion in (	select	IdOperacion 
								from	TA_Operacion 
								where	IdDocumento		=	@IdSolicitudAceptacionPedido 
								and		IdProveedor		=	@IdProveedor				)

	--select	'TA_Tarea',* 
	--from	TA_Tarea --order by IdTarea desc
	--where	IdOperacion in (	select	IdOperacion 
	--							from	TA_Operacion 
	--							where	IdDocumento		=	@IdSolicitudAceptacionPedido 
	--							and		IdProveedor		=	@IdProveedor				)

	update	TA_HistorialFlujoTarea --order by IdHistorial desc
	set		IdEstadoFlujo	=	9
	where	IdOperacion in (	select	IdOperacion 
								from	TA_Operacion 
								where	IdDocumento		=	@IdSolicitudAceptacionPedido 
								and		IdProveedor		=	@IdProveedor)

--select	'TA_HistorialFlujoTarea ',* 
--from	TA_HistorialFlujoTarea --order by IdHistorial desc
--where	IdOperacion in (	select	IdOperacion 
--							from	TA_Operacion 
--							where	IdDocumento		=	@IdSolicitudAceptacionPedido 
--							and		IdProveedor		=	@IdProveedor)
end

