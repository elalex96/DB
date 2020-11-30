-- p_ReporteCompras 3,3
create proc p_ReporteCompras
@pIdContrato int,
@pIdPresupuesto int
as

DECLARE @IDPROVEEDOR INT = 0 ---> ID OPERADORA
declare @operadora varchar(200)
--SOLO SE TOMAN EN CUENTA LOS PEDIDOS QUE ESTAS APROBADOS Y CONFIRMADOS POR EL PROVEEDOR

select @IDPROVEEDOR = p.IdProveedor,
	@operadora = con.NombreContratista
from CO_Contrato c 
inner join CO_Contratista con on con.IdContratista = c.IdContratista
inner join Petrovendor..S_proveedor p on p.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = con.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
where c.IdContrato = @pIdContrato



SELECT 
CO.NumeroContrato AS Contrato,
CASE WHEN RE.IdRelacion IS NOT NULL THEN 'EXISTE RELACION' ELSE 'NO EXISTE RELACION' END AS RelacionOperadoraProveedor,
CONCAT(ISNULL(PV.RazonSocial,'')COLLATE SQL_Latin1_General_CP1_CI_AS ,' ', ISNULL(PV.RegimenCapital,'')COLLATE SQL_Latin1_General_CP1_CI_AS) AS Proveedor,
UPPER(TP.TipoPedido) AS MecanismoContratacion,
CONCAT(ISNULL(OP.RazonSocial,'') COLLATE SQL_Latin1_General_CP1_CI_AS,' ',ISNULL(OP.RegimenCapital,'') COLLATE SQL_Latin1_General_CP1_CI_AS) AS NombreContratoOperador,
CONCAT('OC','-',PV.RFC COLLATE SQL_Latin1_General_CP1_CI_AS,'-',CAST(PG.IdPedido AS NVARCHAR(200))COLLATE SQL_Latin1_General_CP1_CI_AS,'-', FORMAT(P.CreadoEl,'yyyy-MM-dd')) AS NoContratoOperador,
FORMAT(ISNULL(P.FechaRecepcionServicio,petrovendor.dbo.FN_FechaAprobacionPedido(O.IdOperacion)),'yyyy-MM-dd') AS FechaInicio,
FORMAT(ISNULL(P.FechaRecepcionServicio,petrovendor.dbo.FN_FechaAprobacionPedido(O.IdOperacion)),'yyyy-MM-dd') AS FechaTerminacion,
1 AS VigenciaContrato,
SP.MotivoUrgencia AS ObjetoContrato,
CASE WHEN P.IdMoneda = 1 THEN ROUND(petrovendor.dbo.FN_PesosDolaresTipoCambio(SUM(PD.Subtotal),CAST(ISNULL(P.FechaRecepcionServicio,petrovendor.dbo.FN_FechaAprobacionPedido(O.IdOperacion)) AS DATE)),4) ELSE SUM(PD.Subtotal) END AS MontoUSD,
CASE WHEN P.IdMoneda = 2 THEN ROUND(petrovendor.dbo.FN_DolaresPesosTipoCambio(SUM(PD.Subtotal),CAST(ISNULL(P.FechaRecepcionServicio,petrovendor.dbo.FN_FechaAprobacionPedido(O.IdOperacion)) AS DATE)),4) ELSE SUM(PD.Subtotal) END AS MontoMXN,
ROUND(petrovendor.dbo.FN_ValorTipoCambioIterativo(CAST(ISNULL(P.FechaRecepcionServicio,petrovendor.dbo.FN_FechaAprobacionPedido(O.IdOperacion)) AS DATE)),4) AS TipoCambio,
Petrovendor.dbo.FN_FechaTipoCambioIterativo(CAST(ISNULL(P.FechaRecepcionServicio,petrovendor.dbo.FN_FechaAprobacionPedido(O.IdOperacion)) AS varchar)) AS FechaTipoCambio,
P.Comentarios,
Operadora = @operadora
FROM Petrovendor..MM_Pedido AS P
INNER JOIN Petrovendor..MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
INNER JOIN Petrovendor..MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
INNER JOIN Petrovendor..S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
INNER JOIN Petrovendor..TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
INNER JOIN Petrovendor..TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
INNER JOIN Petrovendor..TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
INNER JOIN Petrovendor..TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
INNER JOIN Petrovendor..TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
INNER JOIN Petrovendor..MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
INNER JOIN Petrovendor..PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
INNER JOIN Petrovendor..MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR
LEFT  JOIN Petrovendor..MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
LEFT JOIN Adinco..CO_Contrato AS CO ON CO.IdContrato = P.IdContrato
LEFT JOIN Adinco..CO_AreaContractual AS AC ON AC.IdAreaContractual = CO.IdAreaContractual
inner JOIN Petrovendor..MM_SolicitudPedido SP ON SP.IdSolicitudPedido=P.IdSolicitudPedido
inner join Petrovendor..[MM_SolicitudPedidoDetalle] spd on spd.IdSolicitudPedido = sp.IdSolicitudPedido
inner join  Petrovendor..[MM_SolicitudPedidoDetalleLineaPresupuesto] spdl on spdl.IdSolicitudPedidoDetalle =  spd.IdSolicitudPedidoDetalle
inner join Adinco..[CO_LineaPresupuestoMes] lp on lp.IdLineaPresupuestoMes = spdl.IdLineaPresupuesto and lp.IdPresupuesto = @pIdPresupuesto
LEFT JOIN Petrovendor..S_Proveedor OP ON OP.IdProveedor=P.IdProveedorCompras
LEFT JOIN Petrovendor..PV_RelacionProveedorSubcotratista AS RE ON RE.IdProveedor = SP.IdProveedor AND RE.IdSubcontratista = P.IdSubcontratista
WHERE O.IdTipoOperacion = 9 
AND O.IdProveedor = @IDPROVEEDOR 
AND P.RecepcionServicio = 1  
AND  E.IdEstatus=2 
AND HV.FechaVigencia IS NOT NULL 
AND P.Version=O.NoVersion 
AND ISNULL(P.IdEstatusEliminado,0)<>1 --> QUE NO ESTE ELIMINADO EL PEDIDO
AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
GROUP BY 
P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, PV.RazonSocial,PV.RegimenCapital, 
P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto, PG.IdPedido,TP.TipoPedido,TP.IdTipoPedido,CO.DescripcionContrato,
OP.RazonSocial,OP.RegimenCapital,
CO.NumeroContrato,CO.FechaFirma ,CO.InicioVigencia ,CO.FinVigencia,SP.MotivoUrgencia ,
P.IdMoneda,P.FechaRecepcionServicio ,P.Comentarios,O.IdOperacion,RE.IdRelacion,PV.RFC,P.CreadoEl
ORDER BY  PG.IdPedido DESC
