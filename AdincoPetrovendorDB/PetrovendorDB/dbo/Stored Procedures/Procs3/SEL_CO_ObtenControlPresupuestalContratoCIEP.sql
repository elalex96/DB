USE [Petrovendor]
GO
DROP PROCEDURE IF EXISTS SEL_CO_ObtenControlPresupuestalContratoCIEP
/****** Object:  StoredProcedure [dbo].[SEL_CO_ObtenControlPresupuestalContratoCIEP]    Script Date: 04/06/2025 09:43:55 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luis David
-- Create date: 4/12/2024
-- Description:	Obtiene el control presupuestal para contratos CIEP
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/06/2025
-- Description:	se agregan las columnas fecha timbrado, mes programado y observaciones
-- =============================================
CREATE PROCEDURE [dbo].[SEL_CO_ObtenControlPresupuestalContratoCIEP]
@IdContrato INT,
@IdPresupuesto INT,
@IdUsuario INT,
@IdProveedor INT
AS
BEGIN
DECLARE @Presupuesto NVARCHAR(MAX);

SELECT @Presupuesto = Nombre
FROM Adinco.dbo.CO_Presupuesto (NOLOCK)
WHERE IdPresupuesto = @IdPresupuesto

DECLARE @TablaRequisicion TABLE
(
    IdSolicitudPedido INT,
    IdUsuarioSolicitante INT,
    NombreUsuarioSolped NVARCHAR(MAX),
    IdMaterialSolped INT,
    MaterialSolped NVARCHAR(MAX),
    IdUnidadSolped INT,
    UnidadSolped NVARCHAR(MAX),
    CantidadSolped FLOAT,
    IdLineaSolped INT,
    LineaSolped NVARCHAR(MAX),
    OrdenCompra INT,
    IdPedidoDetalle INT,
    IdMaterialPedido INT,
    MaterialPedido NVARCHAR(MAX),
    IdUnidadPedido INT,
    UnidadPedido NVARCHAR(MAX),
    CantidadPedido FLOAT,
    PrecioUnitario FLOAT,
    IdMonedaPedido INT,
    MonedaPedido NVARCHAR(MAX),
    MontoOrdenCompra FLOAT,
    FechaPedido DATETIME,
    PedidoCerrado BIT,
    IdPedido INT,
    Proveedor NVARCHAR(MAX),
    TipoDeCambio FLOAT,
    MontoOrdenCompraDLS FLOAT
)

DECLARE @Pedidos TABLE
(
    IdPedido INT,
    IdSolicitudPedido INT,
    IdPedidoGral INT,
    IdPeticionOfertaDetalle INT
)

DECLARE @AceptacionPedido TABLE
(
    IdPedido INT,
    IdAceptacionPedido INT,
    IdAceptacionPedidoDetalle INT,
    IdPedidoDetalle INT,
    CantidadAceptacion FLOAT,
    IdLineaAceptacion INT,
    LineaAceptacion NVARCHAR(MAX),
	UUID NVARCHAR(MAX),
	ContieneFactura VARCHAR(10),
	IdInstalacion INT,
	Instalacion NVARCHAR(MAX),
	FechaTimbrado NVARCHAR(100),
	MesProgramado NVARCHAR(100),
	ObservacionesEspecificas NVARCHAR(MAX),
	ObservacionesGenerales NVARCHAR(MAX)
)

DECLARE @CantidadAceptadaMontos TABLE
(
    IdAceptacionPedido INT,
    IdAceptacionPedidoDetalle INT,
    IdPedidoDetalle INT,
    CantidadPedido FLOAT,
    CantidadAceptacion FLOAT,
    CantidadRestante FLOAT,
    MontoAceptacion FLOAT,
    IdMoneda INT,
    MontoAceptacionDls FLOAT,
    MontoRestante FLOAT,
    MontoRestanteDls FLOAT
)

DECLARE @LineasPresupuesto TABLE (IdLineaPresupuesto INT, NombreLinea NVARCHAR(MAX))

DECLARE @AceptacionFactura TABLE
(    
    IdAceptacionPedido INT,
    IdAceptacionFactura INT,
    UUID NVARCHAR(MAX),
	FechaTimbrado DATETIME
)

-- SE OBTIENEN LAS LINEAS DE PRESUPUESTO DESDE ADINCO
-- ESTO DEBIDO A QUE ME TOPE CON EL 
-- CASO 1 DE QUE AL PRINCIPIO LAS LINEAS PERTENECIAN A UN PRESUPUESTO
-- Y SE QUEDO GRABADO EN MM_SOLICITUDPEDIDO, Y LUEGO AL PARECER CAMBIARON DE PRESUPUESTO ESAS LINEAS
-- CASO 2 LA LINEA SE MOVIO A OTRA LINEA DE OTRO PRESUPUESTO PERO NACIO EN OTRO PRESUPUESTO

INSERT INTO @LineasPresupuesto (IdLineaPresupuesto, NombreLinea)
SELECT mes.IdLineaPresupuestoMes,       
       CASE WHEN C.IdTipoContrato = 1 THEN 
		   CONCAT(
		   ISNULL(TSE.NombreTipoServicio,''),  ---> Actividad Petrolera
		   ' - ',
		   ISNULL(ACIEP.NombreActividad,''),--> SubActividad Petrolera
		   ' - ',
		   ISNULL(RU.NombreRubro,''),---> Tarea Petrolera
		   ' - ',
		   ISNULL(SER.NombreServicio,'') --> SubTarea Petrolera
		   ) COLLATE SQL_Latin1_General_CP1_CI_AS
	   ELSE
		CONCAT(
		   ISNULL(APC.DescripcionActividadPetrolera,''),  ---> Actividad Petrolera
		   ' - ',
		   ISNULL(SAP.SubactividadPetrolera,''),--> SubActividad Petrolera
		   ' - ',
		   ISNULL(TP.TareaPetrolera,''),---> Tarea Petrolera
		   ' - ',
		   ISNULL(SER.NombreServicio,'') --> SubTarea Petrolera
		   ) COLLATE SQL_Latin1_General_CP1_CI_AS
	   END 
FROM Adinco..CO_LineaPresupuestoMes MES WITH (NOLOCK)
	LEFT JOIN Adinco..CO_Presupuesto PRE(NOLOCK)
            ON MES.IdPresupuesto = PRE.IdPresupuesto
    LEFT JOIN Adinco..CO_AnioContractual ANC (NOLOCK)
            ON PRE.IdAnioContractual = ANC.IdAnioContractual
    LEFT JOIN Adinco..CO_Contrato C (NOLOCK)
            ON C.IdContrato = ANC.IdContrato
	LEFT JOIN Adinco..CO_Servicio SER WITH (NOLOCK)
        ON MES.IdServicio = SER.IdServicio
	LEFT JOIN CO_TipoServicio TSE (NOLOCK)
            ON MES.IdTipoServicio = TSE.IdTipoServicio    
    LEFT JOIN Adinco..CO_ActividadCIEP ACIEP (NOLOCK)
            ON MES.IdActividad = ACIEP.IdActividad
	LEFT JOIN Adinco.dbo.CO_Rubro RU (NOLOCK)
            ON MES.IdRubro = RU.IdRubro
	LEFT JOIN Adinco.dbo.CO_RubroInterno RI (NOLOCK)
            ON MES.IdRubroInterno = RI.IdRubroInterno
	LEFT JOIN Adinco..CO_ActividadPetroleraCNH APC (NOLOCK)
            ON MES.IdActividadPetrolera = APC.IdActividadPetrolera
	LEFT JOIN Adinco..CO_SubactividadPetrolera SAP (NOLOCK)
            ON MES.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera 
    LEFT JOIN Adinco..CO_TareaPetrolera TP (NOLOCK)
            ON MES.IdTareaPetrolera = TP.IdTareaPetrolera
WHERE MES.IdPresupuesto =  @IdPresupuesto


INSERT INTO @TablaRequisicion
(
    IdSolicitudPedido,
    IdUsuarioSolicitante,
    NombreUsuarioSolped,
    IdMaterialSolped,
    IdUnidadSolped,
    CantidadSolped,
    IdLineaSolped,
    LineaSolped,
    OrdenCompra,
    IdPedidoDetalle,
    IdMaterialPedido,
    IdUnidadPedido,
    CantidadPedido,
    PrecioUnitario,
    IdMonedaPedido,
    MonedaPedido,
    MontoOrdenCompra,
    FechaPedido,
    IdPedido,
    Proveedor,
    TipoDeCambio,
    MontoOrdenCompraDLS,
    PedidoCerrado
)
SELECT sp.IdSolicitudPedido,
       sp.IdUsuarioSolicitante,
       u.Nombre,
       spd.IdMaterial,
       spd.IdUnidad,
       spd.Cantidad,
       spdl.IdLineaPresupuesto,
       lineas.NombreLinea,
       ps.IdPedido,
       pd.IdPedidoDetalle,
       pd.IdMaterial,
       pd.IdUnidad,
       pd.Cantidad,
       pd.PrecioUnitario,
       pd.IdMoneda,
       mon.TipoMonedaCorto,
       pd.Cantidad * pd.PrecioUnitario,
       pd.CreadoEl,
       p.IdPedido,
       prov.RazonSocial,
       cambio.TipoCambio,
       (pd.Cantidad * pd.PrecioUnitario) / cambio.TipoCambio,
       p.Cerrado
FROM dbo.MM_SolicitudPedido sp WITH (NOLOCK)
    INNER JOIN dbo.MM_SolicitudPedidoDetalle spd WITH (NOLOCK)
        ON spd.IdSolicitudPedido = sp.IdSolicitudPedido
		AND sp.IdContrato = @IdContrato
		AND sp.IdProveedor = @IdProveedor
    INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl WITH (NOLOCK)
        ON spd.IdSolicitudPedidoDetalle = spdl.IdSolicitudPedidoDetalle 
    INNER JOIN dbo.MM_PeticionOferta po WITH (NOLOCK)
        ON sp.IdSolicitudPedido = po.IdSolicitudPedido 
    INNER JOIN dbo.MM_PeticionOfertaDetalle pod WITH (NOLOCK)
        ON po.IdPeticionOferta = pod.IdPeticionOferta 
           AND spd.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle 
           AND pod.Cotizado = 1 --> CTE PRODUCTO COTIZADO
    INNER JOIN dbo.MM_Pedido p WITH (NOLOCK)
        ON sp.IdSolicitudPedido = p.IdSolicitudPedido 
           AND po.IdPeticionOferta = p.IdPeticionOferta 
           AND p.RecepcionServicio = 1 --> CTE PEDIDO RECEPCIONADO
           AND ISNULL(p.IdEstatusEliminado, 0) = 0 --> CTE PEDIDO NO ELIMINADO
    INNER JOIN dbo.MM_PedidoDetalle pd WITH (NOLOCK)
        ON p.IdPedido = pd.IdPedido 
           AND pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle 
           AND ISNULL(pd.IdEstatusEliminado, 0) = 0 --> CTE PEDIDO DETALLE 
    INNER JOIN dbo.TA_Operacion taoPedido WITH (NOLOCK)
        ON p.IdSolicitudPedido = taoPedido.IdDocumento  
           AND taoPedido.NoVersion = p.Version 
           AND taoPedido.IdTipoOperacion = 9 --> CTE APROBACIÓN DE PEDIDO
           AND taoPedido.IdEstatusOperacion = 2 --> CTE PEDIDO APROBADOR
    INNER JOIN dbo.MM_Pedidos ps WITH (NOLOCK)
        ON p.IdPedido = ps.IdIdentificador 
		AND p.IdProveedorCompras = ps.IdProveedorCliente
        AND ps.IdTipoPedido IN ( 2, 4, 6 ) --> CTE 2 MERCADEO / 4 ADJ DIRECTA / 6 ORDEN DE TRABAJO   
	INNER JOIN @LineasPresupuesto lineas
        ON spdl.IdLineaPresupuesto = lineas.IdLineaPresupuesto 
    LEFT JOIN dbo.S_Usuario u WITH (NOLOCK)
        ON sp.IdUsuarioSolicitante = u.IdUsuario  
    LEFT JOIN dbo.PV_TipoMoneda mon WITH (NOLOCK)
        ON  pd.IdMoneda = mon.IdMoneda
    LEFT JOIN dbo.S_Proveedor prov WITH (NOLOCK)
        ON p.IdSubcontratista = prov.IdProveedor 
    LEFT JOIN Adinco.dbo.CO_TipoCambioDiario cambio WITH (NOLOCK)
        ON  pd.IdMoneda = cambio.IdMoneda
           AND DAY(pd.CreadoEl) = DAY(cambio.Fecha) 
           AND MONTH(pd.CreadoEl) = MONTH(cambio.Fecha) 
           AND YEAR(pd.CreadoEl) = YEAR(cambio.Fecha)      
WHERE ISNULL(sp.IdEstatusEliminado, 0) = 0 --> CTE SOLO PEDIDOS DE REQUISICIONES NO ELIMINADAS
     

--SE ACTUALIZA EL TIPO DE CAMBIO DE LAS FECHAS QUE NO SE ENCONTRO EN LA CARGA DE LAS REQUISICIONES
UPDATE t
SET t.FechaPedido = cambio.Fecha,
    t.TipoDeCambio = cambio.TipoCambio
FROM @TablaRequisicion t
    OUTER APPLY
(SELECT TOP 1
           *
    FROM Adinco.dbo.CO_TipoCambioDiario (NOLOCK)
    WHERE Fecha <= CAST(t.FechaPedido AS DATE)
          AND IdMoneda = t.IdMonedaPedido
    ORDER BY Fecha DESC) AS cambio
WHERE t.TipoDeCambio IS NULL


INSERT INTO @AceptacionPedido
(
    IdPedido,
    IdAceptacionPedido,
    IdAceptacionPedidoDetalle,
    IdPedidoDetalle,
    CantidadAceptacion,
    IdLineaAceptacion,
	IdInstalacion,
	MesProgramado,
	ObservacionesEspecificas,
	ObservacionesGenerales
)
SELECT req.IdPedido,
       ap.IdAceptacionPedido,
       apd.IdAceptacionPedidoDetalle,
       req.IdPedidoDetalle,
       apdi.Cantidad,
       apdi.IdLineaPresupuesto,
	   apdi.IdInstalacion,
	   LPM.AC_PRESUP_MES,
	   apd.Detalle,
	   ap.Comentario
FROM dbo.MM_AceptacionPedido ap WITH (NOLOCK)
    INNER JOIN dbo.MM_AceptacionPedidoDetalle apd WITH (NOLOCK)
        ON ap.IdAceptacionPedido = apd.IdAceptacionPedido 
           AND ISNULL(apd.IdEstatusEliminado, 0) = 0 --> CTE SOLO ACEPTACIONES DETALLE NO ELIMINADAS
    INNER JOIN dbo.MM_AceptacionPedidoDetalleInstalacion apdi WITH (NOLOCK)
        ON ap.IdAceptacionPedido = apdi.IdAceptacionPedido  
           AND apd.IdAceptacionPedidoDetalle = apdi.IdAceptacionPedidoDetalle 
    RIGHT JOIN @TablaRequisicion req
        ON  ap.IdPedido = req.IdPedido
		AND apd.IdPedidoDetalle = req.IdPedidoDetalle 
	INNER JOIN Adinco..CO_LineaPresupuestoMes LPM WITH (NOLOCK)
		ON apdi.IdLineaPresupuesto = LPM.IdLineaPresupuestoMES
WHERE ISNULL(ap.IdEstatusEliminado, 0) = 0


INSERT INTO @CantidadAceptadaMontos
(
    IdAceptacionPedido,
    IdAceptacionPedidoDetalle,
    IdPedidoDetalle,
    CantidadPedido,
    CantidadAceptacion,
    CantidadRestante,
    MontoAceptacion,
    IdMoneda,
    MontoAceptacionDls,
    MontoRestante,
    MontoRestanteDls
)
SELECT ap.IdAceptacionPedido,
       ap.IdAceptacionPedidoDetalle,
       req.IdPedidoDetalle,
       req.CantidadPedido,
       CASE
           WHEN ap.IdAceptacionPedido IS NULL THEN
               ISNULL(SUM(ap.CantidadAceptacion), 0)
           ELSE
               SUM(ap.CantidadAceptacion)
       END CantidadAceptacion,
       CASE
           WHEN ap.IdAceptacionPedido IS NULL THEN
               req.CantidadPedido - ISNULL(SUM(ap.CantidadAceptacion), 0)
           ELSE
               req.CantidadPedido - SUM(ap.CantidadAceptacion)
       END,
       CASE
           WHEN ap.IdAceptacionPedido IS NULL THEN
               ISNULL(SUM(ap.CantidadAceptacion), 0) * req.PrecioUnitario
           ELSE
               SUM(ap.CantidadAceptacion) * req.PrecioUnitario
       END,
       req.IdMonedaPedido,
       CASE
           WHEN ap.IdAceptacionPedido IS NULL THEN
       (ISNULL(SUM(ap.CantidadAceptacion), 0) * req.PrecioUnitario) / req.TipoDeCambio
           ELSE
       (SUM(ap.CantidadAceptacion) * req.PrecioUnitario) / req.TipoDeCambio
       END,
       CASE
           WHEN ap.IdAceptacionPedido IS NULL THEN
       (req.CantidadPedido - ISNULL(SUM(ap.CantidadAceptacion), 0)) * req.PrecioUnitario
           ELSE
       (req.CantidadPedido - SUM(ap.CantidadAceptacion)) * req.PrecioUnitario
       END,
       CASE
           WHEN ap.IdAceptacionPedido IS NULL THEN
       ((req.CantidadPedido - ISNULL(SUM(ap.CantidadAceptacion), 0)) * req.PrecioUnitario)
       / req.TipoDeCambio
           ELSE
       ((req.CantidadPedido - SUM(ap.CantidadAceptacion)) * req.PrecioUnitario) / req.TipoDeCambio
       END
FROM @TablaRequisicion req
    LEFT JOIN @AceptacionPedido ap
        ON req.IdPedido = ap.IdPedido 
           AND req.IdPedidoDetalle = ap.IdPedidoDetalle 
GROUP BY ap.IdAceptacionPedido,
         ap.IdAceptacionPedidoDetalle,
         req.IdPedidoDetalle,
         req.CantidadPedido,
         ap.CantidadAceptacion,
         req.IdMonedaPedido,
         req.PrecioUnitario,
         req.TipoDeCambio


--SE SETEAN LOS CATALOGOS QUE HACEN FALTA
UPDATE req
SET req.MaterialSolped = CONCAT(m.DescripcionCorta, ' - ', m.DescripcionLarga),
    req.UnidadSolped = u.Unidad,
    req.MaterialPedido = CONCAT(mP.DescripcionCorta, ' - ', mP.DescripcionLarga),
    req.UnidadPedido = uP.Unidad
FROM @TablaRequisicion req
    LEFT JOIN dbo.MM_Material m (NOLOCK)
        ON req.IdMaterialSolped = m.IdMaterial
    LEFT JOIN dbo.PV_MM_MaterialUnidad u (NOLOCK)
        ON req.IdUnidadSolped = u.IdUnidad
    LEFT JOIN dbo.MM_Material mP (NOLOCK)
        ON req.IdMaterialPedido = mP.IdMaterial
    LEFT JOIN dbo.PV_MM_MaterialUnidad uP (NOLOCK)
        ON req.IdUnidadPedido = uP.IdUnidad

--SE SETEAN LAS LINEAS DE ACEPTACION
-- DEBIDO A QUE ALGUNAS LINEAS CAMBIARON A OTROS PRESUPUESTOS SE HACE LA CONSULTA DE ESAS LINEAS
UPDATE A
SET A.LineaAceptacion = CASE WHEN C.IdTipoContrato = 1 THEN 
						CONCAT(
                             ISNULL(TSE.NombreTipoServicio,''),
                             ' - ',
                             ISNULL(ACIEP.NombreActividad,''),
                             ' - ',
                              ISNULL(RU.NombreRubro,''),
                             ' - ',
                             ISNULL(SER.NombreServicio,'')) COLLATE SQL_Latin1_General_CP1_CI_AS
					     ELSE
						CONCAT(
						   ISNULL(APC.DescripcionActividadPetrolera,''),  ---> Actividad Petrolera
						   ' - ',
						   ISNULL(SAP.SubactividadPetrolera,''),--> SubActividad Petrolera
						   ' - ',
						   ISNULL(TP.TareaPetrolera,''),---> Tarea Petrolera
						   ' - ',
						   ISNULL(SER.NombreServicio,'') --> SubTarea Petrolera
						   ) COLLATE SQL_Latin1_General_CP1_CI_AS
					   END 
FROM @AceptacionPedido A
    INNER JOIN Adinco.dbo.CO_LineaPresupuestoMes MES (NOLOCK)
        ON A.IdLineaAceptacion = MES.IdLineaPresupuestoMes 
	LEFT JOIN Adinco..CO_Presupuesto PRE(NOLOCK)
            ON MES.IdPresupuesto = PRE.IdPresupuesto
    LEFT JOIN Adinco..CO_AnioContractual ANC (NOLOCK)
            ON PRE.IdAnioContractual = ANC.IdAnioContractual
    LEFT JOIN Adinco..CO_Contrato C (NOLOCK)
            ON C.IdContrato = ANC.IdContrato
	LEFT JOIN Adinco.dbo.CO_Servicio SER WITH (NOLOCK)
        ON MES.IdServicio = SER.IdServicio
	LEFT JOIN CO_TipoServicio TSE (NOLOCK)
            ON MES.IdTipoServicio = TSE.IdTipoServicio    
    LEFT JOIN Adinco..CO_ActividadCIEP ACIEP (NOLOCK)
            ON MES.IdActividad = ACIEP.IdActividad
	LEFT JOIN Adinco.dbo.CO_Rubro RU (NOLOCK)
            ON MES.IdRubro = RU.IdRubro
	LEFT JOIN Adinco.dbo.CO_RubroInterno RI (NOLOCK)
            ON MES.IdRubroInterno = RI.IdRubroInterno    
	LEFT JOIN Adinco.dbo.CO_ActividadPetroleraCNH APC (NOLOCK)
        ON MES.IdActividadPetrolera = APC.IdActividadPetrolera 
    LEFT JOIN Adinco.dbo.CO_SubactividadPetrolera SAP (NOLOCK)
        ON MES.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera 
    LEFT JOIN Adinco.dbo.CO_TareaPetrolera TP (NOLOCK)
        ON  MES.IdTareaPetrolera = TP.IdTareaPetrolera 

--> REVISAR SI LA ACEPTACION PEDIDO YA CONTIENE FACTURA APROBADA
INSERT INTO @AceptacionFactura(IdAceptacionPedido, IdAceptacionFactura, UUID,FechaTimbrado)
SELECT AF.IdAceptacionPedido,AF.IdAceptacionFactura, F.UUID,F.FechaTimbrado
FROM @AceptacionPedido AP
JOIN MM_AceptacionFactura AF (NOLOCK)
	ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
JOIN FI_Factura F (NOLOCK)
	ON AF.IdFactura = F.IdFactura
JOIN TA_Operacion O (NOLOCK)
ON AF.IdAceptacionFactura = O.IdDocumento
AND O.IdTipoOperacion = 10 --> CTE APROBACIÓN DE FACTURA 
AND O.IdEstatusOperacion = 2 --> CTE FACTURA APROBADA
AND ISNULL(O.IdFlujoTarea,0) <> 0 --> CTE DEBE TENER UN FLUJO DE APORBACIÓN

UPDATE AP
SET AP.ContieneFactura =  'SI',
AP.UUID = AF.UUID,
AP.FechaTimbrado  = CAST(AF.FechaTimbrado AS DATE)
FROM @AceptacionPedido AP 
JOIN @AceptacionFactura AF
ON AP.IdAceptacionPedido = AF.IdAceptacionPedido

UPDATE @AceptacionPedido
SET ContieneFactura = 'NO',
UUID='',
FechaTimbrado = ''
WHERE ContieneFactura  IS NULL 

-- SE ACTUALIZA LA INSTALACIÓN RELACIONA A LA ACEPTACIÓN PEDIDO DETALLE 
UPDATE acepta
SET acepta.Instalacion =  I.NombreInstalacion
FROM @AceptacionPedido acepta
JOIN Adinco..CO_Instalacion I (NOLOCK)
	ON acepta.IdInstalacion = I.IdInstalacion


SELECT @Presupuesto Presupuesto,
       IdSolicitudPedido,
       NombreUsuarioSolped,
       IdMaterialSolped,
       MaterialSolped,
       UnidadSolped,
       CantidadSolped,
       IdLineaSolped,
       LineaSolped,
       OrdenCompra,
       IdMaterialPedido,
       MaterialPedido,
       UnidadPedido,
       CantidadPedido,
       PrecioUnitario,
       MonedaPedido,
       MontoOrdenCompra,
       FechaPedido,
       PedidoCerrado,
       Proveedor,
       TipoDeCambio,
       MontoOrdenCompraDLS
FROM @TablaRequisicion
ORDER BY IdSolicitudPedido DESC 

SELECT @Presupuesto Presupuesto,
       req.IdSolicitudPedido,
       req.NombreUsuarioSolped,
       req.IdMaterialSolped,
       req.MaterialSolped,
       req.UnidadSolped,
       req.CantidadSolped,
       req.IdLineaSolped,
       req.LineaSolped,
       req.OrdenCompra,
       req.IdMaterialPedido,
       req.MaterialPedido,
       req.UnidadPedido,
       req.CantidadPedido,
       req.PrecioUnitario,
       req.MonedaPedido,
       req.MontoOrdenCompra,
       req.FechaPedido,
       req.PedidoCerrado,
       req.Proveedor,
       req.TipoDeCambio,
       req.MontoOrdenCompraDLS,
       montoAcept.IdAceptacionPedido,
	   ISNULL(ap.ContieneFactura,'NO') DocFactura,
	   ISNULL(ap.UUID,'') AS UUID,
	   ISNULL(ap.FechaTimbrado ,'') AS FechaTimbrado,
       montoAcept.CantidadPedido,
       montoAcept.CantidadAceptacion,
       montoAcept.CantidadRestante,
       montoAcept.MontoAceptacion,
       montoAcept.MontoAceptacionDls,
       montoAcept.MontoRestante,
       montoAcept.MontoRestanteDls,
       ap.IdLineaAceptacion,
       ap.LineaAceptacion,
	   ISNULL(ap.Instalacion,'') AS InstalacionAceptacion,
	   ISNULL(ap.MesProgramado,'') AS MesProgramado,
	   ISNULL(ap.ObservacionesEspecificas,'') AS ObservacionesEspecificas,
	   ISNULL(ap.ObservacionesGenerales,'') AS ObservacionesGenerales
FROM @TablaRequisicion req
    LEFT JOIN @CantidadAceptadaMontos montoAcept
        ON montoAcept.IdPedidoDetalle = req.IdPedidoDetalle
    LEFT JOIN @AceptacionPedido ap
        ON ap.IdAceptacionPedido = montoAcept.IdAceptacionPedido
           AND ap.IdAceptacionPedidoDetalle = montoAcept.IdAceptacionPedidoDetalle
ORDER BY req.IdSolicitudPedido, req.IdPedido DESC 
END