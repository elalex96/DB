
create view [dbo].[Estatus_de_pedidos] 
as 
select Contrato, 
       OrdenCompra				as [Pedido/OrdenCompra], 
	   NoAceptacionServicio		=	IdAceptacionPedido,
       SolicitudPedido, 
       CreadoEl, 
       DiasPedido as [Dias del Pedido], 
       Proveedor, 
       CorreoProveedor, 
       RFC, 
       Estado, 
       Version, 
       Moneda, 
       TipoPedido, 
       Aprobadores, 
       EstatusAprobador, 
       EstatusFactura, 
       EstatusPago, 
       Factura, 
       EstatusRecepcionServicio as ConfirmacionPedidoProveedor, 
       EstatusCN, 
       Entidad_Jaguar, 
       CuentaOrigen, 
       CuentaDestino, 
       FechaRegistroTranferencia, 
       MontoTransfer, 
       MonedaTransfer, 
       MontoTotalOrdenCompra, 
       Instalacion, 
       Motivo, 
       case 
              when PedidoCancelado = 0 then 'NO' 
              else 'SI' 
       end as PedidoCancelado, 
       MontoAceptacion, 
       DiasCredito, 
       FechaPagoSegunDiasCredito, 
       FechaIngreso as FechaRecepcionServicio, 
       UUIDFactura  as UUID_Procura, 
       UUID_Adinco, 
       UUIDComplemento, 
       UltimaFechaAprobaciones, 
       FechaTransferencia, 
       FechaCotizacion, 
       FechaAprobacionOC, 
       FechaAprobacionCartaCN, 
       FechaAprobacionFactura, 
       FechaFactura, 
       MontoPagadoFactura 
from   EstatusPedidosJaguar (nolock) 
where  IdProveedorCompras in (606, 
                              690,676, 
                              1315, 
                              2766, 
                              2958, 
                              1835) 
union 
select NumeroContrato as Contrato, 
       Pedido         as [Pedido/OrdenCompra], 
	   NoAceptacionServicio		=	'',
       '', 
       CreadoEl, 
       DiasPedido as [Dias del Pedido], 
       Proveedor, 
       '', 
       RFCProveedor as [RFC], 
       Estado, 
       '', 
       Moneda, 
       'Compra Directa' as [TipoPedido], 
       Aprobadores, 
       EstatusFactura as [EstatusAprobador], 
       EstatusFactura, 
       EstatusPago, 
       Ltrim(Rtrim(concat(isnull(CD.Serie,''),' ',isnull(CD.Folio,'')))) as [Factura], 
       '', 
       EstatusCN, 
       RSContratista as [Entidad_Jaguar], 
       CuentaOrigen, 
       CuentaDestino, 
       FechaRegistroTransferencia, 
       MontoTransfer, 
       MonedaTransfer, 
       MontoRegistro as [MontoTotalOrdenCompra], 
       Instalacion, 
       Motivo, 
       '', 
       '', 
       '', 
       '', 
       '', 
       UUID_Petrovendor as [UUID_Procura], 
       UUID_Adinco, 
       UUID_C                 as [UUIDComplemento], 
       FechaAprobacionFactura as [UltimaFechaAprobaciones], 
       FechaTransferencia, 
       '', 
       FechaAprobacionFactura as [FechaAprobacionOC], 
       FechaAprobacionFactura as [FechaAprobacionCartaCN], 
       FechaAprobacionFactura, 
       FechaFactura, 
       MontoTransferFactura as [MontoPagadoFactura] 
from   VISTA_ComprasDirectas CD 
union 
select    CO.NumeroContrato collate                                         modern_spanish_ci_as,
          null                                                              as [Pedido/OrdenCompra],
		  NoAceptacionServicio												=	APC.IdAceptacionPedido,
          null                                                              as SolicitudPedido, 
          PC.CreadoEn                                                       as CreadoEl, 
          null                                                              as [Dias del Pedido],
          P.RazonSocial collate modern_spanish_ci_as                        as Proveedor, 
          P.CorreoProveedor collate modern_spanish_ci_as                    as CorreoProveedor,
          isnull(P.RFC,'') collate modern_spanish_ci_as                     as [RFC], 
          ET.Nombre collate modern_spanish_ci_as                            as Estado, 
          ''                                                                as Version, 
          TM.TipoMonedaCorto collate modern_spanish_ci_as                   as Moneda, 
          'Comprobante'                                                     as [TipoPedido], 
          dbo.fngetaprobadores(OP.IdOperacion) collate modern_spanish_ci_as as Aprobadores, 
          ''                                                                as EstatusAprobador,
          ET.Nombre collate modern_spanish_ci_as                            as EstatusFactura, 
          EstatusPago = 
          case 
                    when tra.IdTransferFactura is null then 'NO PAGADO' 
                    else 'PAGADO' 
                                                                                                                                             end,
          '#: ' + Ltrim(Rtrim(concat(isnull(PC.NumeroPedimento,''),' - Clave: ',isnull(PC.ClavePedimento,'')))) collate modern_spanish_ci_as as [Factura],
          ''                                                                                                                                 as ConfirmacionPedidoProveedor,
          ''                                                                                                                                 as EstatusCN,
          P.RazonSocial collate modern_spanish_ci_as                                                                                         as Entidad_Jaguar,
          ''                                                                                                                                 as CuentaOrigen,
          ''                                                                                                                                 as CuentaDestino,
          null                                                                                                                               as FechaRegistroTranferencia,
          tr.MontoPagado                                                                                                                     as MontoTransfer,
          tmtr.TipoMonedaCorto                                                                                                               as MonedaTransfer,
          PCD.ImporteTotal                                                                                                                   as MontoTotalOrdenCompra,
          null                                                                                                                               as Instalacion,
          isnull(PCD.DescripcionMercancia,'') collate modern_spanish_ci_as                                                                   as Motivo,
          null                                                                                                                               as PedidoCancelado,
          null                                                                                                                               as MontoAceptacion,
          null                                                                                                                               as DiasCredito,
          null                                                                                                                               as FechaPagoSegunDiasCredito,
          null                                                                                                                               as FechaRecepcionServicio,
          null                                                                                                                               as UUID_Procura,
          null                                                                                                                               as UUID_Adinco,
          null                                                                                                                               as UUIDComplemento,
          dbo.fn_fechaaprobacionpedido (OP.IdOperacion)                                                                                      as UltimaFechaAprobaciones,
          null                                                                                                                               as FechaTransferencia,
          null                                                                                                                               as FechaCotizacion,
          null                                                                                                                               as FechaAprobacionOC,
          null                                                                                                                               as FechaAprobacionCartaCN,
          null                                                                                                                               as FechaAprobacionFactura,
          PC.FechaPago                                                                                                                       as FechaFactura,
          null                                                                                                                               as MontoPagadoFactura
from      dbo.FI_AceptacionPedido_PedimentoComprobante APC (nolock) 
join      dbo.TA_Operacion OP (nolock) 
on        APC.IdAceptacionPedidoPedimentoComprobante = OP.IdDocumento 
and       OP.IdTipoOperacion = 19 
and       OP.IdProveedor = APC.IdProveedor 
and       APC.IdProveedor in (606, 
                              690,676, 
                              1315, 
                              2766, 
                              2958, 
                              1835) 
and       APC.Activo = 1 
join      dbo.FI_PedimentoComprobante PC (nolock) --select * from sys.tables where name like '%adinco%' 
left join FI_RelacionComprobanteAdinco rca 
on        rca.IdComprobantePetrovendor = PC.IdPedimentoComprobante 
left join adinco..FI_TransferFactura tra 
on        tra.CvTipoDocFacturacion = 3 
and       tra.IdPedimentoComprobante = rca.IdComprobanteAdinco 
left join adinco..FI_Transfer tr 
on        tr.IdTransferencia = tra.IdTransfer 
left join PV_TipoMoneda tmtr 
on        tmtr.IdMoneda = tr.IdMoneda 
on        APC.IdPedimentoComprobante = PC.IdPedimentoComprobante 
join      FI_PedimentoComprobanteDetalle PCD (nolock) 
on        PCD.IdPedimentoComprobante = PC.IdPedimentoComprobante 
join      dbo.S_Usuario US (nolock) 
on        US.IdUsuario = APC.CreadoPor 
join      adinco.dbo.CO_Contrato CO (nolock) 
on        PC.IdContrato = CO.IdContrato 
join      adinco.dbo.PV_TipoMoneda TM (nolock) 
on        TM.IdMoneda = PC.IdMoneda 
join      dbo.TA_Estatus ET (nolock) 
on        OP.IdEstatusOperacion = ET.IdEstatus 
join      S_Proveedor P (nolock) 
on        APC.IdProveedor = P.IdProveedor 
where     APC.Activo = 1


