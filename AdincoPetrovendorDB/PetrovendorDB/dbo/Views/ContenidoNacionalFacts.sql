CREATE VIEW dbo.ContenidoNacionalFacts
AS

   SELECT   
   P.IdSolicitudPedido as 'Id requisicion',
   Ac.IdAceptacionPedido   as 'IdAceptacionPedido',
   Ac.CreadoEl AS 'Fecha de Carga',
   CAST(AC.FechaEvaluacion as date) as 'Fecha de Aprobacion',
   TD.TipoValidacion as 'Estatus CN'
  FROM MM_AceptacionCartaPCN AS AC  (NOLOCK)
  INNER JOIN S_Documento_S3 AS D (NOLOCK)
	ON D.IdDocumento = AC.IdDocumento  
  INNER JOIN MM_AceptacionPedido AS AP (NOLOCK)
	ON AP.IdAceptacionPedido = AC.IdAceptacionPedido  
  INNER JOIN MM_Pedido AS P (NOLOCK)
	ON P.IdPedido = AP.IdPedido 
  INNER JOIN S_TipoValidacionDoc AS TD (NOLOCK)
	ON TD.IdTipoValidacionDoc = AC.IdEstatus  
  INNER JOIN MM_Pedidos AS PG (NOLOCK)
	ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = P.IdProveedorCompras
  WHERE  P.IdProveedorCompras IN (606, 676, 690, 1315, 1424)
  AND ISNULL(AC.IdEstatusEliminado,0) <> 1  --> QUE NO ESTEN ELIMINADOS  
  --ORDER BY  Ac.IdAceptacionPedido DESC;  
 
--TAB CN 
-- SE REPITEN POR QUE PUEDE SER QUE LA CARTA SE SUBA N VECES HASTA SER APROBADA 
-- NECESITAS UNA RELACIÓN PARA LAS ACEPTACIONES QUE SE LES EXCLUYO LA CARTA DE CONTENIDO NACIONAL?
