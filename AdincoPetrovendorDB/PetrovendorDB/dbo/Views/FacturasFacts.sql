CREATE VIEW dbo.FacturasFacts
AS

  SELECT     
   PE.IdSolicitudPedido as 'id de requisicion',    
   AP.IdAceptacionPedido AS 'IdaceptacionPedido',
   Fi.IdFactura AS 'IdunicoFactura',
   CAST(O.FechaRegistro as date) as 'Fecha de carga',
   CASE WHEN O.IdEstatusOperacion = 1 THEN  --> SI ESTA EN APROBACIÓN NO MOSTRAR FECHA DE MODIFICACIÓN
   NULL 
   ELSE 
   CAST(O.FechaModificacion as date)  
   END as 'Fecha de aprobacion',
   E.Nombre AS  'Estatus factura'   
  FROM
	MM_AceptacionFactura AS AF    (NOLOCK)
  INNER JOIN  TA_Operacion AS O (NOLOCK)
	ON O.IdDocumento = AF.IdAceptacionFactura  --AND O.IdProveedor = @IdProveedor     
  INNER JOIN TA_Estatus AS E (NOLOCK)
	ON E.IdEstatus = O.IdEstatusOperacion     
  INNER JOIN MM_AceptacionPedido AS AP (NOLOCK)
	ON AP.IdAceptacionPedido = AF.IdAceptacionPedido      
  INNER JOIN MM_Pedido AS PE (NOLOCK)
	ON PE.IdPedido = AP.IdPedido AND PE.IdSubcontratista = O.IdProveedor  
  INNER JOIN MM_Pedidos AS PG (NOLOCK)
	ON PE.IdPedido = PG.IdIdentificador  AND PG.IdProveedorCliente =PE.IdProveedorCompras    
  INNER JOIN S_Proveedor AS PR (NOLOCK)
	ON PR.IdProveedor = PE.IdSubcontratista
  LEFT JOIN dbo.FI_Factura AS fi (NOLOCK)
	ON fi.IdFactura = AF.IdFactura      
  WHERE     
	O.IdTipoOperacion = 10     --> APROBACIÓN DE TIPO APROBACIÓN DE FACTURA 
	AND PE.IdProveedorCompras IN  (606, 676, 690, 1315, 1424) 
	AND ISNULL(AF.IdEstatusEliminado,0)<>1  --> ACEPTACIÓN DE FACTURA NO ESTE ELIMINADA  
GROUP BY
	AF.IdAceptacionPedido,  
	AP.IdAceptacionPedido,
	O.FechaRegistro,   
	E.Nombre,
	PE.IdSolicitudPedido,  
	Fi.IdFactura,
	O.FechaModificacion,
	O.IdEstatusOperacion
--  ORDER BY AF.IdAceptacionPedido DESC 
  
-- SE CORRIJIO 
--LA RELACIÓN DE APROBACIONES DE FACTURA ES INCORRECTA SE HACE RELACIÓN CON 
-- MM_ACEPTACIÓNFACTURA.IdAceptacion
-- DUDA VAS A NECESITAR EL IDPEDIDOUNICO YA QUE UN PEDIDO PUEDE TENER MÁS DE N ACEPTACIONES DE FACTURAS ?


 
