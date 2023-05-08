-- =============================================  
-- Author:  Josue Glez  
-- Create date: 04-Marzo-2020  
-- Description: Requerimiento DEA (Ramon / Juventino) 03-03-2020  
-- =============================================  
CREATE PROCEDURE SP_DEA_ConsultaTablero   
   
AS  
BEGIN  
DECLARE @IdProveedor INT = 907,  
        @IdContrato INT = 10038  
  
  
TRUNCATE TABLE dbo.ReporteTablero  
DECLARE @TablaSubTarea TABLE (IdSolicitudPedido INT, Tarea NVARCHAR(MAX), SubTarea NVARCHAR(MAX))  
DECLARE @TablaAprobacionParcialReq TABLE  
(  
    IdSolicitudPedido INT,  
    FechaAprobacionManager DATETIME,  
    FechaAprobadoPRSAP DATETIME  
)  
DECLARE @TablaTarea TABLE  
(  
    IdOperacion INT,  
    FechaCambioEstatus DATETIME,  
    FechaRegistro DATETIME,  
    IdEstatusOperacion INT,  
    IdTipoOperacion INT,  
    IdEstadoFlujo INT,  
    NoVersion INT  
)  
  
  
DECLARE @TablaFechaAprobacionPedido TABLE (IdOperacion INT, FechaAprobacionPedido DATETIME)  
  
  
DECLARE @TablaFechaAprobacionCN TABLE  
(  
    IdAceptacionPedido INT,  
    IdAceptacionCartaPCN INT,  
    FechaEvaluacion DATETIME,  
    CreadoEl DATETIME,  
    ResponsableAprobacionPCN NVARCHAR(MAX)  
)  
  
  
DECLARE @TablaAprobacionFactura TABLE  
(  
    IdAceptacionPedido INT,  
    IdAceptacionFactura INT,  
    IdEstatusOperacion INT,  
    FechaCambioEstatus DATETIME,  
    FechaRegistro DATETIME  
)  
  
  
DECLARE @TablaPedido TABLE  
(  
    IdPedido INT,  
    IdPedidos INT,  
    IdSolicitudPedido INT,  
    CreadoElPedido DATETIME,  
    FechaEnvioPedido DATETIME,  
    TotalPedido FLOAT,  
    Proveedor NVARCHAR(MAX),  
    RecepcionServicio NVARCHAR(MAX),  
    EstatusPedido NVARCHAR(MAX),  
    Version INT,  
    TipoMoneda NVARCHAR(100),  
    TipoPedido NVARCHAR(MAX),  
    IdTipoPedido INT,  
    FechaRegistroPedido DATETIME,  
    IdOperacion INT,  
    IdEstatusOperacion INT,  
    Cerrado BIT,  
    FechaRecepcionServicio DATETIME,  
    IdProveedor INT  
)  
  
  
DECLARE @TablaAceptacionPedido TABLE  
(  
    IdAceptacionPedido INT,  
    IdPedido INT,  
    ComentarioAceptcionPedido NVARCHAR(MAX),  
    CreadoAceptacion DATETIME,  
    DomicilioAceptacion NVARCHAR(MAX),  
    TipoDomicilio NVARCHAR(MAX),  
    Proveedor NVARCHAR(MAX),  
    IdPedidos INT,  
    TipoPedido NVARCHAR(MAX),  
    IdSolicitudPedido INT  
)  
  
-- Se obtiene los subtotales del pedido , el idpedido y el idpedido general  
INSERT INTO @TablaPedido  
(  
    IdPedido,  
    IdPedidos,  
    IdSolicitudPedido,  
    CreadoElPedido,  
    FechaEnvioPedido,  
    TotalPedido,  
    Proveedor,  
    RecepcionServicio,  
    EstatusPedido,  
    Version,  
    TipoMoneda,  
    TipoPedido,  
    IdTipoPedido,  
    FechaRegistroPedido,  
    IdOperacion,  
    IdEstatusOperacion,  
    Cerrado,  
    FechaRecepcionServicio,  
    IdProveedor  
)  
SELECT P.IdPedido,  
       PG.IdPedido AS IdPedidoGeneral,  
       P.IdSolicitudPedido,  
       P.CreadoEl AS CreadoEl,  
       P.FechaEnvioPedido AS FechaEnvioPedido,  
       SUM(PD.Subtotal) AS TotalPedido,  
       ISNULL(RazonSocial, '') + ' ' + ISNULL(RegimenCapital, '') AS Proveedor,  
       CASE  
           WHEN P.RecepcionServicio = 1 THEN  
               'Confirmación Aceptada'  
           WHEN P.RecepcionServicio = 0 THEN  
               'Confirmación Rechazada'  
           WHEN P.RecepcionServicio IS NULL  
                AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0  
                AND O.IdEstatusOperacion = 2 THEN  
               'Confirmación Vencida '  
           WHEN P.RecepcionServicio IS NULL  
                AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0  
                AND O.IdEstatusOperacion = 2 THEN  
               'En Confirmación'  
           ELSE  
               'Confirmación No Iniciada '  
       END AS RecepcionServicio,  
       E.Nombre,  
       P.Version,  
       TM.TipoMonedaCorto AS TipoMoneda,  
       TP.TipoPedido,  
       TP.IdTipoPedido,  
       O.FechaRegistro,  
       O.IdOperacion,  
       O.IdEstatusOperacion,  
       P.Cerrado,  
       P.FechaRecepcionServicio,  
       PV.IdProveedor  
FROM MM_Pedido AS P  
    INNER JOIN MM_PedidoDetalle AS PD  
        ON PD.IdPedido = P.IdPedido  
    INNER JOIN MM_PeticionOferta AS PO  
        ON PO.IdPeticionOferta = P.IdPeticionOferta  
    INNER JOIN S_Proveedor AS PV  
        ON PV.IdProveedor = P.IdSubcontratista  
    INNER JOIN TA_Operacion AS O  
        ON O.IdDocumento = P.IdSolicitudPedido  
           AND P.Version = O.NoVersion  
    INNER JOIN TA_Prioridad AS PR  
        ON PR.IdPrioridad = O.IdPrioridad  
    INNER JOIN TA_Vencimiento AS V  
        ON V.IdVencimiento = O.IdVigencia  
    INNER JOIN TA_TipoOperacion AS TTO  
        ON TTO.IdTipoOperacion = O.IdTipoOperacion  
    INNER JOIN TA_Estatus AS E  
        ON E.IdEstatus = O.IdEstatusOperacion  
    INNER JOIN MM_HorasVigenciaPedido AS HV  
        ON P.IdPedido = HV.IdPedido  
    INNER JOIN PV_TipoMoneda AS TM  
        ON TM.IdMoneda = P.IdMoneda  
    INNER JOIN MM_Pedidos AS PG  
        ON P.IdPedido = PG.IdIdentificador  
           AND PG.IdProveedorCliente = @IdProveedor  
    LEFT JOIN dbo.MM_TipoPedido AS TP  
        ON TP.IdTipoPedido = PG.IdTipoPedido  
WHERE O.IdTipoOperacion = 9  
      AND O.IdProveedor = @IdProveedor  
      AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO  
GROUP BY P.IdPedido,  
         P.IdSolicitudPedido,  
         P.FechaEnvioPedido,  
         RazonSocial,  
         +RegimenCapital,  
         P.RecepcionServicio,  
         E.Nombre,  
         P.Version,  
         TM.TipoMonedaCorto,  
         HV.FechaVigencia,  
         O.IdEstatusOperacion,  
         P.CreadoEl,  
         PG.IdPedido,  
         TP.TipoPedido,  
         TP.IdTipoPedido,  
         P.IdEstatusEliminado,  
         O.FechaRegistro,  
         O.IdOperacion,  
         P.Cerrado,  
         P.FechaRecepcionServicio,  
         PV.IdProveedor  
ORDER BY PG.IdPedido DESC  
  
  
--guarda todas las tareas, pero agrupa las tareas y solo toma al  
INSERT INTO @TablaTarea  
(  
    IdOperacion,  
    FechaCambioEstatus,  
    FechaRegistro,  
    IdEstatusOperacion,  
    IdTipoOperacion,  
    IdEstadoFlujo,  
    NoVersion  
)  
SELECT temp.IdOperacion,  
       temp.FechaCambioEstatus,  
       temp.FechaRegistro,  
       temp.IdEstatusOperacion,  
       temp.IdTipoOperacion,  
       temp.IdEstadoFlujo,  
       temp.NoVersion  
FROM  
(   SELECT ROW_NUMBER() OVER (PARTITION BY t.IdOperacion ORDER BY t.IdOperacion) AS rw,  
           t.IdOperacion,  
           MAX(t.FechaCambioEstatus) AS FechaCambioEstatus,  
           MAX(t.FechaRegistro) AS FechaRegistro,  
           tao.IdEstatusOperacion,  
           tao.IdTipoOperacion,  
           IdEstadoFlujo,  
           tao.NoVersion  
    FROM dbo.TA_Tarea t  
        INNER JOIN dbo.TA_Operacion tao  
            ON tao.IdOperacion = t.IdOperacion  
    WHERE tao.IdProveedor = @IdProveedor  
          AND t.IdOperacion IS NOT NULL  
    GROUP BY t.IdOperacion,  
             tao.IdEstatusOperacion,  
             tao.IdTipoOperacion,  
             tao.IdEstadoFlujo,  
             tao.NoVersion) AS temp  
WHERE temp.rw = 1  
  
  
-- solo obtiene la fecha en que se aprobo ya que de todos los aprobadores solo obtiene la ultima fecha  
INSERT INTO @TablaFechaAprobacionPedido (IdOperacion, FechaAprobacionPedido)  
SELECT t.IdOperacion,  
       CASE  
           WHEN t.IdEstadoFlujo = 3 THEN  
               MAX(t.FechaCambioEstatus)  
           ELSE  
               NULL  
       END  
FROM @TablaTarea t  
GROUP BY t.IdOperacion,  
         t.IdEstadoFlujo  
  
  
-- se Obtiene la fecha de aprobacion de la carta de contenido  
INSERT INTO @TablaFechaAprobacionCN  
(  
    IdAceptacionPedido,  
    IdAceptacionCartaPCN,  
    FechaEvaluacion,  
    CreadoEl,  
    ResponsableAprobacionPCN  
)  
SELECT ap.IdAceptacionPedido,  
       AC.IdAceptacionCartaPCN,  
       MAX(AC.FechaEvaluacion),  
       s3.CreadoEl,  
       u.Nombre  
FROM dbo.MM_AceptacionCartaPCN AC  
    LEFT JOIN dbo.S_Documento_S3 s3  
        ON s3.IdDocumento = AC.IdDocumento  
    LEFT JOIN dbo.MM_AceptacionPedido ap  
        ON ap.IdAceptacionPedido = AC.IdAceptacionPedido  
    LEFT JOIN dbo.S_Usuario u  
        ON AC.IdUsuarioEvaluador = u.IdUsuario  
WHERE ap.IdProveedor = @IdProveedor  
      AND AC.IdEstatus IN ( 2, 1 ) -- aprobada y aprobacion  
      AND ISNULL(AC.IdEstatusEliminado, 0) <> 1  
GROUP BY ap.IdAceptacionPedido,  
         AC.IdAceptacionCartaPCN,  
         s3.CreadoEl,  
         u.Nombre  
  
  
DECLARE @TablaAceptacionFactura TABLE  
(  
    IdAceptacionPedido INT,  
    IdPedidos INT,  
    IdPedido INT,  
    FechaRegistro DATETIME,  
    Proveedor NVARCHAR(MAX),  
    EstatusAceptacion NVARCHAR(MAX),  
    TipoPedido NVARCHAR(MAX),  
    TotalPedido FLOAT,  
    Moneda NVARCHAR(MAX),  
    RFC NVARCHAR(MAX),  
    IdSolicitudPedido INT,  
    IdEstatusAceptacion INT,  
    IdFactura INT,
	UUID NVARCHAR(MAX)  
)  
  
  
-- Toda la info de la factura excepto la fecha de aprobacion  
INSERT INTO @TablaAceptacionFactura  
(  
    IdAceptacionPedido,  
    IdPedidos,  
    IdPedido,  
    FechaRegistro,  
    Proveedor,  
    EstatusAceptacion,  
    TipoPedido,  
    TotalPedido,  
    Moneda,  
    RFC,  
    IdSolicitudPedido,  
    IdEstatusAceptacion,  
    IdFactura ,
	UUID 
)  
SELECT AF.IdAceptacionPedido,  
       PG.IdPedido,  
       PE.IdPedido,  
       O.FechaRegistro,  
       PR.RazonSocial + ' ' + ISNULL(PR.RegimenCapital, '') AS Proveedor,  
       E.Nombre,  
       TP.TipoPedido,  
       SUM(APD.Cantidad * PED.PrecioUnitario) AS TotalPedido,  
       TM.TipoMonedaCorto AS Moneda,  
       PR.RFC,  
       PE.IdSolicitudPedido,  
       E.IdEstatus,  
       AF.IdFactura ,
	   f.UUID
FROM dbo.MM_AceptacionFactura AS AF  
    INNER JOIN dbo.TA_Operacion AS O  
        ON O.IdDocumento = AF.IdAceptacionFactura  
    INNER JOIN dbo.TA_Estatus AS E  
        ON E.IdEstatus = O.IdEstatusOperacion  
    INNER JOIN dbo.MM_AceptacionPedido AS AP  
        ON AP.IdAceptacionPedido = AF.IdAceptacionPedido  
    INNER JOIN dbo.MM_AceptacionPedidoDetalle AS APD  
        ON APD.IdAceptacionPedido = AP.IdAceptacionPedido  
    INNER JOIN dbo.MM_Pedido AS PE  
        ON PE.IdPedido = AP.IdPedido  
           AND PE.IdSubcontratista = O.IdProveedor  
    INNER JOIN dbo.MM_PedidoDetalle AS PED  
        ON PED.IdPedido = PE.IdPedido  
           AND APD.IdPedidoDetalle = PED.IdPedidoDetalle  
    INNER JOIN dbo.MM_Pedidos AS PG  
        ON PE.IdPedido = PG.IdIdentificador  
           AND PG.IdProveedorCliente = @IdProveedor  
    INNER JOIN dbo.S_Proveedor AS PR  
        ON PR.IdProveedor = PE.IdSubcontratista  
    INNER JOIN dbo.PV_TipoMoneda AS TM  
        ON TM.IdMoneda = PE.IdMoneda  
    LEFT JOIN dbo.MM_TipoPedido AS TP  
        ON TP.IdTipoPedido = PG.IdTipoPedido  
    LEFT JOIN dbo.TA_Tarea t  
        ON t.IdOperacion = O.IdOperacion  
	LEFT JOIN dbo.FI_Factura f ON f.IdFactura = AF.IdFactura
		AND ISNULL(f.IsEliminado,0) = 0
WHERE O.IdTipoOperacion = 10  
      AND PE.IdProveedorCompras = @IdProveedor  
      AND ISNULL(AF.IdEstatusEliminado, 0) <> 1  
GROUP BY AF.IdAceptacionPedido,  
         PE.IdPedido,  
         O.FechaRegistro,  
         PR.RazonSocial,  
         PR.RegimenCapital,  
         E.Nombre,  
         PG.IdPedido,  
         TP.TipoPedido,  
         TM.TipoMonedaCorto,  
         PR.RFC,  
         AF.IdEstatusEliminado,  
         PE.IdSolicitudPedido,  
         E.IdEstatus,  
         AF.IdFactura,
		 f.UUID  
ORDER BY AF.IdAceptacionPedido DESC  
  
  
DECLARE @TablaFechaAprobacionFactura TABLE (IdOperacion INT, IdAceptacionPedido INT, FechaCambioEstatus DATETIME)  
  
  
-- solo obtener la fechas de aprobacion de la factura  
INSERT INTO @TablaFechaAprobacionFactura (IdOperacion, IdAceptacionPedido, FechaCambioEstatus)  
SELECT TAO.IdOperacion,  
       af.IdAceptacionPedido,  
       MAX(TT.FechaCambioEstatus)  
FROM dbo.TA_Estatus TE  
    INNER JOIN dbo.TA_Tarea TT  
        ON TE.IdEstatus = TT.IdEstatus  
    INNER JOIN dbo.S_Usuario U  
        ON U.IdUsuario = TT.IdAprobador  
    INNER JOIN dbo.TA_Operacion TAO  
        ON TT.IdOperacion = TAO.IdOperacion  
    INNER JOIN dbo.MM_AceptacionFactura af  
        ON TAO.IdDocumento = af.IdAceptacionFactura  
 INNER JOIN dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = af.IdAceptacionPedido  
WHERE TAO.IdTipoOperacion = 10  
      AND TAO.IdEstatusOperacion = 2  
   AND ap.IdProveedor = @IdProveedor  
GROUP BY TAO.IdOperacion,  
         af.IdAceptacionPedido  
  
INSERT INTO @TablaSubTarea (IdSolicitudPedido, Tarea, SubTarea)  
SELECT sp.IdSolicitudPedido,  
       CONCAT(t.id_Tarea, ' ', t.TareaPetrolera),  
       subTarea.NombreServicio  
FROM dbo.MM_SolicitudPedido sp  
    INNER JOIN dbo.MM_SolicitudPedidoDetalle spd  
        ON spd.IdSolicitudPedido = sp.IdSolicitudPedido  
    INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdi  
        ON spdi.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle  
    LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes linea  
        ON spdi.IdLineaPresupuesto = linea.IdLineaPresupuestoMes  
    LEFT JOIN Adinco.dbo.CO_Servicio subTarea  
        ON subTarea.IdServicio = linea.IdServicio  
    LEFT JOIN Adinco.dbo.CO_TareaPetrolera t  
        ON t.IdTareaPetrolera = linea.IdTareaPetrolera  
WHERE sp.IdProveedor = @IdProveedor  
GROUP BY t.id_Tarea,  
         t.TareaPetrolera,  
         sp.IdSolicitudPedido,  
         subTarea.NombreServicio  
  
INSERT INTO @TablaAprobacionParcialReq (IdSolicitudPedido, FechaAprobacionManager, FechaAprobadoPRSAP)  
SELECT sp.IdSolicitudPedido,  
       MAX(hist.Fecha),  
       MIN(dea.CreadoEl)  
FROM dbo.MM_SolicitudPedido sp  
    INNER JOIN dbo.TA_Operacion tao  
        ON tao.IdDocumento = sp.IdSolicitudPedido  
           AND tao.IdTipoOperacion = 2  
    INNER JOIN dbo.TA_HistorialFlujoTarea hist  
        ON hist.IdOperacion = tao.IdOperacion  
    LEFT JOIN dbo.DEA_AdjuntoPR dea  
        ON dea.IdSolicitudPedido = sp.IdSolicitudPedido  
           AND dea.Activo = 1  
WHERE sp.IdProveedor = @IdProveedor  
      AND hist.IdEstadoFlujo = 11  
GROUP BY sp.IdSolicitudPedido  
  
DECLARE @TablaAsignado TABLE (IdSolicitudPedido INT, Asignados NVARCHAR(MAX), FechaAsignado DATETIME)  
  
INSERT INTO @TablaAsignado (IdSolicitudPedido, Asignados, FechaAsignado)  
SELECT sp.IdSolicitudPedido,  
       STUFF(  
       (   SELECT CAST(', ' AS VARCHAR(MAX)) + u.Nombre  
           FROM dbo.MM_SolicitudPedidoComprador comp  
               INNER JOIN dbo.S_Usuario u  
                   ON comp.IdAsignadoA = u.IdUsuario  
           WHERE sp.IdProveedor = @IdProveedor  
                 AND comp.IdSolicitudPedido = sp.IdSolicitudPedido  
                 AND comp.Activo = 1  
           FOR XML PATH('')),  
       1,  
       1,  
       ''),  
       MIN(spCom.CreadoEl)  
FROM dbo.MM_SolicitudPedido sp  
    INNER JOIN dbo.MM_SolicitudPedidoComprador spCom  
        ON spCom.IdSolicitudPedido = sp.IdSolicitudPedido  
WHERE sp.IdProveedor = @IdProveedor  
GROUP BY sp.IdSolicitudPedido,  
         sp.IdProveedor  
  
DECLARE @TablaRelacionPO TABLE (IdPedido INT, FechaRelacion DATETIME, NumPO NVARCHAR(MAX))  
  
INSERT INTO @TablaRelacionPO (IdPedido, FechaRelacion, NumPO)  
SELECT p.IdPedido,  
       rel.FechaAltaRelacion,  
       rel.PO  
FROM dbo.MM_Pedido p  
    INNER JOIN dbo.DEA_Relacion_PR_PO rel  
        ON rel.IdPedido = p.IdPedido  
           AND rel.Activo = 1  
WHERE ISNULL(p.IdEstatusEliminado, 0) = 0  
      AND p.IdProveedorCompras = @IdProveedor  
  
DECLARE @TablaAprobadorFactura TABLE (IdFactura INT, NombreAprobador NVARCHAR(MAX))  
  
INSERT INTO @TablaAprobadorFactura (IdFactura, NombreAprobador)  
SELECT IdFactura,  
       STUFF(  
       (   SELECT CAST('/ ' AS VARCHAR(MAX)) + u.Nombre  
           FROM dbo.MM_AceptacionFactura af  
               INNER JOIN dbo.TA_Operacion tao  
                   ON tao.IdDocumento = af.IdAceptacionFactura  
               LEFT JOIN dbo.TA_Tarea t  
                   ON t.IdOperacion = tao.IdOperacion  
               LEFT JOIN dbo.S_Usuario u  
                   ON t.IdAprobador = u.IdUsuario  
               INNER JOIN dbo.FI_Factura f  
                   ON f.IdFactura = af.IdFactura  
           WHERE f.IdContrato = @IdContrato  
                 AND tao.IdEstatusOperacion = 2  
                 AND af.IdFactura = fp.IdFactura  
   ORDER BY t.NoSecuencia  
           FOR XML PATH('')),  
       1,  
    1,  
       '')  
FROM dbo.FI_Factura fp   
  
DECLARE @TablaFactura TABLE(IdAceptacionPedido int, IdFactura INT, Subtotal MONEY)

INSERT INTO @TablaFactura (IdAceptacionPedido, IdFactura, Subtotal)
SELECT ap.IdAceptacionPedido, f.IdFactura, f.SubTotal 
FROM dbo.MM_AceptacionPedido ap 
LEFT JOIN dbo.MM_AceptacionFactura af ON af.IdAceptacionPedido = ap.IdAceptacionPedido 
		AND ISNULL(af.IdEstatusEliminado, 0) = 0
INNER JOIN dbo.TA_Operacion tao ON tao.IdDocumento = af.IdAceptacionFactura
		AND tao.IdTipoOperacion = 10
		AND tao.IdEstatusOperacion = 2
		AND ISNULL(tao.IdEstatusEliminado,0) = 0
LEFT JOIN dbo.FI_Factura f ON f.IdFactura = af.IdFactura
--AND ISNULL(f.Activa, 0) = 0
AND ISNULL(f.IsEliminado, 0 ) = 0  
WHERE ap.IdProveedor = @IdProveedor
 
DECLARE @TablaMontoAceptacion TABLE(IdAceptacionPedido INT, Monto FLOAT)

INSERT INTO @TablaMontoAceptacion (IdAceptacionPedido, Monto)
SELECT ap.IdAceptacionPedido, SUM(pd.PrecioUnitario * apdi.Cantidad) FROM dbo.MM_AceptacionPedido ap 
INNER JOIN dbo.MM_AceptacionPedidoDetalle apd  ON apd.IdAceptacionPedido = ap.IdAceptacionPedido AND ISNULL(apd.IdEstatusEliminado, 0 ) = 0
INNER JOIN dbo.MM_AceptacionPedidoDetalleInstalacion apdi ON apdi.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle 
INNER JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
WHERE ap.IdProveedor = @IdProveedor 
GROUP BY ap.IdAceptacionPedido

DECLARE @TablaDiasSolicitudPedido TABLE(IdSolicitudPedido INT, DiasAprobacion INT)

			INSERT INTO @TablaDiasSolicitudPedido (IdSolicitudPedido, DiasAprobacion)
			SELECT sp.IdSolicitudPedido, DATEDIFF(DAY, sp.FechaAlta, CASE WHEN tao.IdEstatusOperacion = 1 THEN GETDATE() ELSE MAX(t.FechaCambioEstatus) end) 
			FROM dbo.MM_SolicitudPedido sp 
			INNER JOIN dbo.TA_Operacion tao ON tao.IdDocumento = sp.IdSolicitudPedido AND tao.IdTipoOperacion = 2
			AND sp.IdProveedor = @IdProveedor AND tao.IdEstatusOperacion IN(1, 2)
			LEFT JOIN dbo.TA_Tarea t ON t.IdOperacion = tao.IdOperacion
			AND t.IdEstatus = 2
			GROUP BY sp.FechaAlta,t.FechaCambioEstatus,
                     sp.IdSolicitudPedido, tao.IdEstatusOperacion
			

INSERT INTO dbo.ReporteTablero  
(  
    IdRequisicion,  
    Descripcion,  
    TareaRequisicion,  
    SubTareaRequisicion,  
    FechaRegistro,  
    Requisitor,  
    FechaRechazado,  
    FechaAprobacionManager,  
    FechaAprobadoPrSAP,  
    FechaAsignacion,  
    CompradorAsignado,  
    IdPeticionOferta,  
    FechaPeticionOferta,  
    RazonSocial,  
    IdProveedor,  
    FechaCotizacionOC,  
    FechaPedido,  
    NumPedido,  
    Version,  
    Aprobador1,  
    Aprobador2,  
    Aprobador3,  
    Aprobador4,  
    Aprobador5,  
    AprobacionPedido,  
    EstatusPedido,  
    Costo,  
    Moneda,  
    FechaRelacionPedidoPo,  
    NumPoSAP,  
    OrdenCompra,  
    IdAceptacionPedido,  
    EntregaRecepcion,  
    ResponsableAceptacion,  
    RegistroPCN,  
    AprobacionPCN,  
    RecepcionFactura,  
    AprobacionFactura,  
    NombreAreaContractual,  
    IdInstalacion,  
    NombreInstalacion,  
    EstatusRequisicion,  
    ResponsableRecepcionFactura,
	SubtotalFactura,
	MontoAceptado,
	DiasEnAprobacion,
	UUID
)  
SELECT sp.IdSolicitudPedido AS IdRequisicion,  
       sp.MotivoUrgencia AS Descripcion,  
       sub.Tarea AS TareaRequisicion,  
       sub.SubTarea AS SubTareaRequisicion,  
       sp.FechaAlta AS FechaRegistro,  
       requi.Nombre AS Requisitor,  
       CASE  
           WHEN tao.IdEstatusOperacion = 3 THEN  
               CASE  
                   WHEN t.FechaCambioEstatus IS NULL THEN  
                       t.FechaRegistro  
                   ELSE  
                       t.FechaCambioEstatus  
               END  
       END AS FechaRechazado,  
       parcial.FechaAprobacionManager,  
       parcial.FechaAprobadoPRSAP AS FechaAprobadoPrSAP,  
       asignado.FechaAsignado AS FechaAsignacion,  
       asignado.Asignados AS CompradorAsignado,  
       po.IdPeticionOferta,  
       po.CreadoEl AS FechaPeticionOferta,  
       prov.RazonSocial,  
       prov.IdProveedor,  
       po.FechaFinalizado AS FechaCotizacionOC,  
       p.CreadoElPedido AS FechaPedido,  
       p.IdPedidos AS NumPedido,  
       p.Version,  
       TA1.FechaCambioEstatus AS Aprobador1,  
       TA2.FechaCambioEstatus AS Aprobador2,  
       TA3.FechaCambioEstatus AS Aprobador3,  
       TA4.FechaCambioEstatus AS Aprobador4,  
       TA5.FechaCambioEstatus AS Aprobador5,  
       aprobacion.FechaAprobacionPedido AS AprobacionPedido,  
       CASE  
           WHEN p.Cerrado = 1 THEN  
               'Cerrado'  
           ELSE  
               EstatusPedido.Nombre  
       END AS EstatusPedido,  
       p.TotalPedido AS Costo,  
       p.TipoMoneda AS Moneda,  
       rel.FechaRelacion AS FechaRelacionPedidoPo,  
       rel.NumPO AS NumPoSAP,  
       p.FechaRecepcionServicio AS OrdenCompra,  
       AP.IdAceptacionPedido AS IdAceptacionPedido,  
       AP.Creado AS EntregaRecepcion,  
       AP.NombreRecibidoPor AS ResponsableAceptacion,  
       fechaCarta.CreadoEl AS RegistroPCN,  
       fechaCarta.FechaEvaluacion AS AprobacionPCN,  
       factura.FechaRegistro AS RecepcionFactura,  
       t2.FechaCambioEstatus AS AprobacionFactura,  
       AC.NombreAreaContractual,  
       spdl.IdInstalacion,  
       inst.NombreInstalacion,  
       E.Nombre AS EstatusRequisicion,  
       nomAprobFact.NombreAprobador,
	   montoFactura.Subtotal,
	   montoAceptacion.Monto,
	   diasSolped.DiasAprobacion,
	   factura.UUID
FROM dbo.MM_SolicitudPedido sp  
    LEFT JOIN dbo.MM_SolicitudPedidoDetalle spd  
        ON spd.IdSolicitudPedido = sp.IdSolicitudPedido  
    LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl  
        ON spdl.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle  
    LEFT JOIN dbo.MM_PeticionOferta po  
        ON po.IdSolicitudPedido = sp.IdSolicitudPedido  
    LEFT JOIN dbo.MM_PeticionOfertaDetalle pod  
        ON pod.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle  
           AND pod.IdSolicitudPedidoDetalle = spdl.IdSolicitudPedidoDetalle  
    LEFT JOIN dbo.TA_Operacion tao  
        ON tao.IdDocumento = sp.IdSolicitudPedido  
           AND tao.IdTipoOperacion = 2  
    LEFT JOIN dbo.TA_Estatus E  
        ON E.IdEstatus = tao.IdEstatusOperacion  
    LEFT JOIN dbo.S_Proveedor prov  
ON prov.IdProveedor = po.IdSubcontratista  
    LEFT JOIN @TablaTarea t  
        ON t.IdOperacion = tao.IdOperacion  
           AND t.IdEstatusOperacion = tao.IdEstatusOperacion  
           AND t.IdTipoOperacion = 2  
    LEFT JOIN @TablaPedido p  
        ON p.IdSolicitudPedido = sp.IdSolicitudPedido  
           AND p.IdProveedor = po.IdSubcontratista  
    LEFT JOIN dbo.TA_Operacion AS OPES  
        ON OPES.IdDocumento = p.IdSolicitudPedido  
           AND OPES.IdTipoOperacion = 9 --APROBACION DE PEDIDO  
           --AND OPES.IdEstatusOperacion = 2 -- PEDIDO APROBADO  
           --AND OPES.IdEstadoFlujo = 3 --FLUJO APROBADO PEDIDO  
           AND OPES.NoVersion = p.Version  
           AND ISNULL(OPES.IdEstatusEliminado, 0) <> 1  
    LEFT JOIN Petrovendor.dbo.TA_Tarea AS TA1  
        ON TA1.IdOperacion = OPES.IdOperacion  
           AND TA1.NoSecuencia = 1  
    LEFT JOIN Petrovendor.dbo.TA_Tarea AS TA2  
        ON TA2.IdOperacion = OPES.IdOperacion  
           AND TA2.NoSecuencia = 2  
    LEFT JOIN Petrovendor.dbo.TA_Tarea AS TA3  
        ON TA3.IdOperacion = OPES.IdOperacion  
           AND TA3.NoSecuencia = 3  
    LEFT JOIN Petrovendor.dbo.TA_Tarea AS TA4  
        ON TA4.IdOperacion = OPES.IdOperacion  
           AND TA4.NoSecuencia = 4  
    LEFT JOIN Petrovendor.dbo.TA_Tarea AS TA5  
        ON TA5.IdOperacion = OPES.IdOperacion  
           AND TA5.NoSecuencia = 5  
    LEFT JOIN dbo.MM_AceptacionPedido AP  
        ON AP.IdPedido = p.IdPedido  
    LEFT JOIN @TablaFechaAprobacionPedido aprobacion  
        ON aprobacion.IdOperacion = TA1.IdOperacion  
    LEFT JOIN dbo.TA_Estatus EstatusPedido  
        ON EstatusPedido.IdEstatus = OPES.IdEstatusOperacion  
    LEFT JOIN @TablaFechaAprobacionCN fechaCarta  
        ON fechaCarta.IdAceptacionPedido = AP.IdAceptacionPedido  
    LEFT JOIN @TablaAceptacionFactura factura  
        ON factura.IdAceptacionPedido = AP.IdAceptacionPedido  
           AND factura.IdSolicitudPedido = sp.IdSolicitudPedido  
    LEFT JOIN @TablaFechaAprobacionFactura t2  
        ON t2.IdAceptacionPedido = AP.IdAceptacionPedido  
    LEFT JOIN Adinco.dbo.CO_Contrato C  
        ON C.IdContrato = sp.IdContrato  
    LEFT JOIN Adinco.dbo.CO_AreaContractual AC  
        ON AC.IdAreaContractual = C.IdAreaContractual  
    LEFT JOIN Adinco.dbo.CO_Instalacion inst  
        ON inst.IdInstalacion = spdl.IdInstalacion  
    LEFT JOIN @TablaSubTarea sub  
        ON sub.IdSolicitudPedido = sp.IdSolicitudPedido  
    LEFT JOIN dbo.S_Usuario requi  
        ON sp.IdUsuarioSolicitante = requi.IdUsuario  
    LEFT JOIN @TablaAprobacionParcialReq parcial  
        ON parcial.IdSolicitudPedido = sp.IdSolicitudPedido  
    LEFT JOIN @TablaAsignado asignado  
        ON asignado.IdSolicitudPedido = sp.IdSolicitudPedido  
    LEFT JOIN @TablaRelacionPO rel  
        ON rel.IdPedido = p.IdPedido  
    LEFT JOIN @TablaAprobadorFactura nomAprobFact  
        ON nomAprobFact.IdFactura = factura.IdFactura
	LEFT JOIN @TablaFactura montoFactura ON montoFactura.IdAceptacionPedido = AP.IdAceptacionPedido  
	LEFT JOIN @TablaMontoAceptacion montoAceptacion ON montoAceptacion.IdAceptacionPedido = AP.IdAceptacionPedido
	LEFT JOIN @TablaDiasSolicitudPedido diasSolped ON diasSolped.IdSolicitudPedido = sp.IdSolicitudPedido
WHERE sp.IdProveedor = @IdProveedor  
      AND sp.IdContrato = @IdContrato  
      AND ISNULL(sp.IdEstatusEliminado, 0) <> 1  
GROUP BY sp.IdSolicitudPedido,  
         sp.MotivoUrgencia,  
         sp.FechaAlta,  
         tao.IdEstatusOperacion,  
         t.FechaCambioEstatus,  
         t.FechaRegistro,  
         p.Cerrado,  
         po.IdPeticionOferta,  
         po.CreadoEl,  
         prov.RazonSocial,  
         prov.IdProveedor,  
         po.FechaFinalizado,  
         p.CreadoElPedido,  
         p.IdPedidos,  
         p.Version,  
         TA1.FechaCambioEstatus,  
         TA2.FechaCambioEstatus,  
         TA3.FechaCambioEstatus,  
         TA4.FechaCambioEstatus,  
         TA5.FechaCambioEstatus,  
         EstatusPedido.Nombre,  
         aprobacion.FechaAprobacionPedido,  
         p.TotalPedido,  
         p.TipoMoneda,  
         p.FechaRecepcionServicio,  
         AP.IdAceptacionPedido,  
         AP.Creado,  
         fechaCarta.CreadoEl,  
         fechaCarta.FechaEvaluacion,  
         factura.FechaRegistro,  
         t2.FechaCambioEstatus,  
         AC.NombreAreaContractual,  
         spdl.IdInstalacion,  
         inst.NombreInstalacion,  
         E.Nombre,  
         sub.Tarea,  
         sub.SubTarea,  
         requi.Nombre,  
         parcial.FechaAprobacionManager,  
         asignado.Asignados,  
         asignado.FechaAsignado,  
         rel.FechaRelacion,  
         rel.NumPO,  
         AP.NombreRecibidoPor,  
         parcial.FechaAprobadoPRSAP,  
         E.Nombre,  
         nomAprobFact.NombreAprobador,
		 montoFactura.Subtotal,
		 montoAceptacion.Monto,
		 diasSolped.DiasAprobacion,
		 factura.UUID  
ORDER BY sp.IdSolicitudPedido,  
         p.IdPedidos  
  
  
  
SELECT IdRequisicion AS Requisicion,  
       Descripcion,  
       TareaRequisicion,  
       SubTareaRequisicion,  
       EstatusRequisicion,  
       FechaRegistro AS FechaRequisicion,  
       Requisitor,  
       FechaRechazado,  
       FechaAprobacionManager,  
       FechaAprobadoPrSAP,  
       FechaAsignacion,  
       CompradorAsignado,  
       FechaPeticionOferta,  
       RazonSocial AS Proveedor,  
       FechaCotizacionOC,  
       FechaPedido,  
       NumPedido,  
       Moneda,  
       Costo,  
       EstatusPedido,  
       AprobacionPedido,  
       FechaRelacionPedidoPo,  
       NumPoSAP,  
       OrdenCompra AS FechaAceptacionProveedor,  
       ResponsableAceptacion,  
       IdAceptacionPedido AS NumAceptacion,
	   MontoAceptado,  
       EntregaRecepcion,  
       RegistroPCN,  
       AprobacionPCN,  
       RecepcionFactura,  
       ResponsableRecepcionFactura,  
       AprobacionFactura,
	   SubtotalFactura,  
       NombreAreaContractual,
	   DiasEnAprobacion AS DiasEnAprobacionRequisicion,
	   UUID
FROM dbo.ReporteTablero  
  
  
  
  
  
  
  
END  