CREATE VIEW dbo.RequisicionFacts
AS

SELECT Distinct
SPD.IdSolicitudPedido as 'idunico de requisicion', 
C.NumeroContrato as 'Contrato',
cast(R.FechaAlta as date) as 'FechaRegistro',
U.Nombre as 'Solicitante',
PC.NombrePeriodo as 'Plan',
P.Nombre as 'Presupuesto',
E.nombre as 'Estatus Requisicion',
TP.id_Tarea as 'Tarea',
ST.id_SubTarea as 'Subtarea',
I.NombreInstalacion as 'Nombre Instalacion',
Concat( D.Calle,' Colonia ', D.Colonia,' CP ', D.CodigoPostal,' ',D.Municipio,' ', D.Estado) as 'Lugar entrega',
I.UTMX as 'X',
I.UTMY as 'Y'
from MM_SolicitudPedido as R (NOLOCK)
Join TA_Operacion as TAO (NOLOCK)
	on R.IdSolicitudPedido = TAO.IdDocumento 
Join TA_Estatus as E (NOLOCK)
	on E.IdEstatus =TAO.IdEstatusOperacion 
Join Adinco.dbo.CO_contrato as C (NOLOCK)
	on R.IdContrato = C.IdContrato
Join MM_SolicitudPedidoDetalle as SPD (NOLOCK)
	on R.IdSolicitudPedido = SPD.IdSolicitudPedido
JOIN  DG_Domicilio as D (NOLOCK)
	on SPD.IdDomicilioEntrega = D.IdDomicilio
Join MM_SolicitudPedidoDetalleLineaPresupuesto as SPDL (NOLOCK)
	on SPD.IdSolicitudPedidoDetalle = SPDL.IdSolicitudPedidoDetalle
Join adinco.dbo.CO_LineaPresupuestoMes as L (NOLOCK)
	on SPDL.IdLineaPresupuesto = L.IdLineaPresupuestoMes
Join S_usuario as U (NOLOCK)
	on R.IdUsuarioSolicitante = U.IdUsuario
LEFT JOIN Adinco.dbo.CO_Presupuesto as P (NOLOCK)
	on R.IdPresupuesto = P.IdPresupuesto
LEFT JOIN adinco.dbo.CO_TareaPetrolera as TP (NOLOCK)
	on L.IdTareaPetrolera = TP.IdTareaPetrolera
LEFT JOIN adinco.dbo.CO_SubTareaPetrolera as ST (NOLOCK)
	on L.IdSubactividadPetrolera = ST.IdSubTareaPetrolera
LEFT JOIN adinco.dbo.CO_Instalacion as I (NOLOCK)
	on L.IdInstalacion = I.IdInstalacion
LEFT JOIN adinco.dbo.CO_ProgramaActividad as PA (NOLOCK)
	on P.IdProgramaActividad = PA.IdProgramaActividad
LEFT JOIN adinco.dbo.CO_PeriodoContrato PC (NOLOCK)
	on PC.IdPeriodo = PA.IdPeriodoContrato
WHERE 
R.IdProveedor in (606, 676, 690, 1315, 1424) 
AND ISNULL(R.IdEstatusEliminado,0)<>1 --> QUE NO ESTE ELIMINADA
AND TAO.IdTipoOperacion=2 --> APROBACIÓN DE SOLICITUD DE PEDIDO 

 --EN TAB REQUISICIÓN
--AQUI NECESITAS SOLO LAS REQUISICIONES QUE TIENEN UN PEDIDO RELACIONADO O SERIAN TODAS LAS REQUISICIONES SIN IMPORTAR TENGAN O NO PEDIDOS? -->SON TODAS 
--SI BUSCAS LAS REQUISICIONES APROBADAS SE ESTA REALIZADNO MAL LA RELACIÓN YA QUE ESTAS RELACIONANDO UN ID INCORRECTO CON LA OPERACIÓN --> CORREGIDO
--LAS APROBACIONES DE PEDIDO TIENEN UN TIPOOPERACION=2 EN TA_OPERACIÓN Y SE RELACIONAN DIRECMENTE CON MM_SOLICITUDPEDIDO.IDSOLICITUD=TA_OPERACION.IDDOCUMENTO -->SON TODAS 
--LOS DOMICILIOS DE ENTREGA SON POR PARTIDA 
--LA INSTALACION ES POR DETALLE
--EL PRESUPUESTO ES POR CABECERA
--LA LINEA PRESUPUESTO ES POR DETALLE 
--EL CENTRO DE COSTO ES POR DETALLE
--LA TAREA PETROLERA ES POR DETALLE 
-- APLICANDO EL Distinct SE REDUCE CANTIDAD SOLO POR REQUISICIÓN 

