CREATE PROCEDURE [dbo].[sp_JOB_CreaVistaPedidosJaguar] 
AS  
BEGIN  
  
SET NOCOUNT ON  
-- LLENA LA TABLA DE LA VISTA PARA JAGUAR   
-- Y SE AGREGO LA TABLA DE VISTA DE FACTURAS DE COMPRA DIRECTA  
  
CREATE TABLE #Vista  
(  
	 IdConsecutivo INT IDENTITY (1,1),  
	 IdContrato  INT,  
	 Contrato  VARCHAR(50),  
	 IdPedido  INT,  
	 OrdenCompra  INT,  
	 SolicitudPedido INT,  
	 CreadoEl  DATETIME,  
	 DiasPedido  VARCHAR(150),  
	 Proveedor  VARCHAR(500),  
	 CorreoProveedor VARCHAR(500),  
	 RFC    VARCHAR(100),  
	 Estado   VARCHAR(250),  
	 Version   INT,  
	 Moneda   VARCHAR(5),  
	 TipoPedido  VARCHAR(100),  
	 Aprobadores  VARCHAR(500),  
	 EstatusAprobador VARCHAR(100),  
	 IdEstatus   INT,  
	 EstatusFactura  VARCHAR(100),  
	 EstatusRecepcionServicio VARCHAR(250),  
	 EstatusCN   VARCHAR(250),  
	 MontoTotalOrdenCompra FLOAT,  
	 Instalacion   VARCHAR(3000),  
	 Motivo    VARCHAR(3000),  
	 PedidoCancelado  BIT,  
	 MontoAceptacion  FLOAT,  
	 DiasCredito   INT,  
	 FechaPagoSegunDiasCredito  DATE,  
	 FechaIngreso  DATETIME,  
	 UltimaFechaAprobaciones DATETIME,  
	 FechaTransferencia DATE,  
	 FechaCotizacion  DATETIME,  
	 FechaAprobacionOC DATETIME,  
	 RecepcionServicio BIT,  
	 IdOperacion   INT,  
	 IdProveedor   INT,  
	 IdProveedorCompras INT,  
	 UUID_Adinco   VARCHAR(500)  
)  
  
CREATE TABLE #VistaFinal  
(  
	IdConsecutivo INT IDENTITY (1,1),  
	IdConsecutivoVista INT,  
	IdContrato  INT,  
	Contrato  VARCHAR(50),  
	IdPedido  INT,  
	OrdenCompra  INT,  
	SolicitudPedido INT,  
	CreadoEl  DATETIME,  
	DiasPedido  VARCHAR(150),  
	Proveedor  VARCHAR(500),  
	CorreoProveedor VARCHAR(500),  
	RFC    VARCHAR(100),  
	Estado   VARCHAR(250),  
	Version   INT,  
	Moneda   VARCHAR(5),  
	TipoPedido  VARCHAR(100),  
	Aprobadores  VARCHAR(500),  
	EstatusAprobador VARCHAR(100),  
	IdEstatus   INT,  
	EstatusFactura  VARCHAR(100),  
	EstatusPago   VARCHAR(50),  
	Factura    VARCHAR(100),  
	EstatusRecepcionServicio VARCHAR(250),  
	EstatusCN   VARCHAR(250),  
	Entidad_Jaguar  VARCHAR(550),  
	CuentaOrigen  VARCHAR(150),  
	CuentaDestino  VARCHAR(150),  
	FechaRegistroTranferencia DATETIME,  
	MontoTransfer  FLOAT,  
	MontoTransferFactura FLOAT,  
	MonedaTransfer  VARCHAR(5),  
	MontoTotalOrdenCompra FLOAT,  
	Instalacion   VARCHAR(3000),  
	Motivo    VARCHAR(3000),  
	PedidoCancelado  BIT,  
	MontoAceptacion  FLOAT,  
	DiasCredito   INT,  
	FechaPagoSegunDiasCredito  DATE,  
	FechaIngreso  DATETIME,  
	UUIDFactura   VARCHAR(500),  
	UUIDComplemento  VARCHAR(500),  
	UltimaFechaAprobaciones DATETIME,  
	FechaTransferencia DATE,  
	FechaCotizacion  DATETIME,  
	FechaAprobacionOC DATETIME,  
	FechaAprobacionCartaCN DATETIME,  
	FechaAprobacionFactura DATETIME,  
	FechaFactura  DATETIME,  
	RecepcionServicio BIT,  
	IdOperacion   INT,  
	IdProveedor   INT,  
	IdFactura   INT,  
	IdAceptacionFactura INT,   
	IdAceptacionPedido INT,  
	IdFacturaAdinco  INT,  
	IdProveedorCompras INT,  
	UUID_Adinco   VARCHAR(500),  
	Actividad   VARCHAR(5000),  
	Subactividad  VARCHAR(5000),  
	Tarea    VARCHAR(5000),  
	Subtarea   VARCHAR(6000), 
	MetodoPago   VARCHAR(5000),  
	TotalFactura  MONEY,  
	ConceptoFactura  VARCHAR(8000),  
	SubTotalFactura  MONEY ,
	MesSIPAC	DATE
)  
  
CREATE TABLE #Aprobadores  
(  
	IdConsecutivo INT,  
	IdPedido INT,  
	IdEstatus INT,  
	Aprobador VARCHAR(300)  
)  
  
CREATE TABLE #AprobadoresConcat  
(  
	IdConsecutivo INT,  
	IdPedido INT,  
	IdEstatus INT,  
	Aprobador VARCHAR(3000)  
)  
  
CREATE TABLE #Pedidos  
(  
	IdPedido INT  
)  
  
CREATE TABLE #MontoPedidos  
(  
	IdPedido INT,  
	Monto  FLOAT  
)  
  
CREATE TABLE #Instalaciones  
(  
	IdConsecutivo INT,  
	IdPedido INT,  
	Instalacion VARCHAR(300)  
)  
  
CREATE TABLE #InstalacionesConcat  
(  
	IdConsecutivo INT,  
	IdPedido INT,  
	Instalacion VARCHAR(3000)  
)  
  
CREATE TABLE #Fechas  
(  
	IdConsecutivo INT,  
	SolicitudPedido INT,  
	Fecha DATETIME  
)  
  
CREATE TABLE #LineasPresupuesto  
(  
	IdConsecutivo INT,  
	IdPedido INT,  
	SolicitudPedido INT,  
	IdLineaPresupuesto INT ,
 PRIMARY KEY (IdConsecutivo, IdPedido, SolicitudPedido, IdLineaPresupuesto)  
)  
  
CREATE TABLE #ClasificacionPresupuesto  
(  
	IdConsecutivo INT,  
	IdPedido INT,  
	SolicitudPedido INT,  
	Actividad   VARCHAR(1000),  
	Subactividad  VARCHAR(1000),  
	Tarea    VARCHAR(1000),  
	Subtarea   VARCHAR(2000)
)  
  
CREATE TABLE #Clasificacion  
(  
	IdConsecutivo INT,  
	IdPedido INT,  
	SolicitudPedido INT,  
	Descripcion  VARCHAR(6000)  
	PRIMARY KEY (IdConsecutivo, IdPedido, SolicitudPedido)  
)  
  
CREATE TABLE #Conceptos  
(  
	IdConsecutivo INT,  
	IdFactura INT,  
	IdFacturaConcepto INT,  
	Concepto VARCHAR(500)  
)  
  
CREATE TABLE #FacturaConceptos  
(  
	IdConsecutivo INT,  
	IdFactura INT,  
	Concepto VARCHAR(8000)  
)  
  
/*************** VISTA FACTURAS COMPRA DIRECTA **************************************/  
  
CREATE TABLE #FechasAprobacion  
(idoperacion     INT,   
 idtareaMaxima   INT,   
 fechaaprobacion DATETIME,   
 idEstatus       INT,   
 Secuencia       INT  
)  
/*************** VISTA FACTURAS COMPRA DIRECTA **************************************/  
  
INSERT INTO #Vista  
(  
	IdContrato,  
	Contrato,  
	IdPedido,  
	SolicitudPedido,  
	CreadoEl,  
	DiasPedido,  
	Proveedor,  
	RFC,  
	Estado,  
	Version,  
	Moneda,  
	RecepcionServicio,  
	IdOperacion,  
	EstatusAprobador,  
	IdEstatus,  
	PedidoCancelado,  
	DiasCredito,  
	FechaCotizacion,  
	IdProveedor,  
	Motivo,  
	IdProveedorCompras  
)  
SELECT  
	C.IdContrato,  
	C.NumeroContrato,  
	P.IdPedido,  
	P.IdSolicitudPedido,  
	P.CreadoEl,  
	CASE  
		WHEN DATEDIFF(DAY, P.CreadoEl, GETDATE()) > 60  
		THEN 'Pedido con MAS DE 60 DIAS'  
		ELSE 'Pedido con MENOS DE 60 DIAS'  
	END,  
	ISNULL(PV.RazonSocial, ''),	--+' '+ISNULL(PV.RegimenCapital, ''),  
	ISNULL(PV.RFC, ''),  
	E.Nombre,  
	P.Version,   
	TM.TipoMonedaCorto,  
	P.RecepcionServicio,  
	O.IdOperacion,  
	ETA.Nombre,  
	ETA.IdEstatus,  
	CASE  
		WHEN ISNULL(P.IdEstatusEliminado, 0) = 0  
		THEN 0  
		ELSE 1  
	END,  
	P.DiasCredito,  
	CT.FechaFinalizado,  
	PV.IdProveedor,  
	ISNULL(SOLPED.MotivoUrgencia, ''),  
	P.IdProveedorCompras  
FROM  
	MM_Pedido  P (NOLOCK)
JOIN  
	Adinco.dbo.CO_Contrato C (NOLOCK) 
	ON P.IdContrato = C.IdContrato  
	AND P.IdSubcontratista IS NOT NULL
	AND P.IdProveedorCompras IN (606, 690, 1835, 863, 907)-- JAGUAR, CARDENAS-MORA, OGARRIO
JOIN   
	dbo.MM_SolicitudPedido SOLPED (NOLOCK) 
	ON P.IdSolicitudPedido = SOLPED.IdSolicitudPedido  
JOIN  
	dbo.S_Proveedor PV (NOLOCK)
	ON P.IdSubcontratista = PV.IdProveedor  
JOIN  
	dbo.TA_Operacion O (NOLOCK) 
	ON P.IdSolicitudPedido = O.IdDocumento  
	AND P.Version = O.NoVersion  
	AND P.IdProveedorCompras = O.IdProveedor
	AND O.IdTipoOperacion = 9  
	-- AND O.IdEstatusOperacion = 2  
JOIN  
	dbo.TA_Tarea TA (NOLOCK)
	ON O.IdOperacion = TA.IdOperacion  
JOIN  
	dbo.TA_Estatus ETA (NOLOCK)
	ON TA.IdEstatus = ETA.IdEstatus  
	AND ETA.IdEstatus NOT IN (4,6,7,10)  
JOIN  
	MM_PeticionOferta CT (NOLOCK)
	ON P.IdSolicitudPedido = CT.IdSolicitudPedido  
	AND P.IdPeticionOferta = CT.IdPeticionOferta  
JOIN  
	dbo.TA_Estatus E (NOLOCK)
	ON O.IdEstatusOperacion = E.IdEstatus  
JOIN  
	dbo.PV_TipoMoneda TM (NOLOCK)
	ON P.IdMoneda = TM.IdMoneda  
WHERE  
	P.IdProveedorCompras IN (606, 690, 1835, 863, 907)-- JAGUAR, CARDENAS-MORA, OGARRIO
GROUP BY  
	C.IdContrato,  
	C.NumeroContrato,  
	P.IdPedido,  
	P.IdSolicitudPedido,  
	P.CreadoEl,  
	CASE  
		WHEN DATEDIFF(DAY, P.CreadoEl, GETDATE()) > 60  
		THEN 'Pedido con MAS DE 60 DIAS'  
		ELSE 'Pedido con MENOS DE 60 DIAS'  
	END,  
	ISNULL(PV.RazonSocial, ''), --+' '+ISNULL(PV.RegimenCapital, ''),  
	ISNULL(PV.RFC, ''),  
	E.Nombre,  
	P.Version,   
	TM.TipoMonedaCorto,  
	P.RecepcionServicio,  
	O.IdOperacion,  
	ETA.Nombre,  
	ETA.IdEstatus,  
	CASE  
		WHEN ISNULL(P.IdEstatusEliminado, 0) = 0  
		THEN 0  
		ELSE 1  
	END,  
	P.DiasCredito,  
	CT.FechaFinalizado,  
	PV.IdProveedor,  
	ISNULL(SOLPED.MotivoUrgencia, ''),  
	P.IdProveedorCompras  
ORDER BY  
	C.IdContrato,  
	P.IdPedido,  
	P.IdSolicitudPedido,  
	ETA.IdEstatus  
  
UPDATE H  
SET EstatusRecepcionServicio =  CASE WHEN H.RecepcionServicio = 1 THEN 'Confirmación Aceptada'  
	WHEN H.RecepcionServicio = 0 THEN 'Confirmación Rechazada'  
	WHEN H.RecepcionServicio IS NULL AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0 AND O.IdEstatusOperacion = 2  
		THEN 'Confirmación Vencida '  
	/*LA OPERACION TIENE QUE ESTAR APROBADA PARA PODER CONTAR EL TIEMPO DE CONFIRMACIóN DE SERVICIO*/  
	WHEN H.RecepcionServicio IS NULL AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0 AND O.IdEstatusOperacion = 2  
		THEN 'En Confirmación'  
	WHEN H.RecepcionServicio IS NULL AND O.IdEstatusOperacion = 3 /*SI LA APROBACIóN DE PEDIDO ES RECHAZADA(3) NUNCA SE ENVIA LA CONFIRMACIóN AL PROVEEDOR*/  
		THEN 'Aprobación de pedido rechazada, confirmación no enviada al proveedor'  
	ELSE 'En espera de aprobación de pedido'  
	END  
FROM  
	#Vista H  
JOIN  
	dbo.MM_HorasVigenciaPedido HV (NOLOCK)
	ON H.IdPedido = HV.IdPedido  
JOIN  
	TA_Operacion O (NOLOCK)
	ON H.IdOperacion = O.IdOperacion  
  
UPDATE V  
SET OrdenCompra = PG.IdPedido,  
	TipoPedido  = TP.TipoPedido  
FROM  
	#Vista V  
JOIN  
	MM_Pedidos PG (NOLOCK)
	ON V.IdPedido = PG.IdIdentificador  
	AND V.IdProveedorCompras	=	PG.IdProveedorCliente
	AND PG.IdProveedorCliente IN (606, 690, 1835, 863, 907) 
	AND PG.IdTipoPedido in (2,4,6)
JOIN  
	dbo.S_Proveedor CLIENTE (NOLOCK)
	ON PG.IdProveedorCliente = CLIENTE.IdProveedor  
JOIN  
	dbo.MM_TipoPedido TP (NOLOCK)
	ON PG.IdTipoPedido = TP.IdTipoPedido  
  
UPDATE V  
	SET CorreoProveedor = LTRIM(RTRIM(U.Correo))  
FROM  
	#Vista V  
JOIN  
	S_UsuarioProveedor UP (NOLOCK)
	ON V.IdProveedor = UP.IdProveedor  
	AND UP.IsAdmin  = 1  
JOIN  
	S_Usuario    U (NOLOCK)
	ON UP.IdUsuario = U.IdUsuario  
	AND U.IsEliminado = 0  
   
UPDATE V  
	SET CorreoProveedor = LTRIM(RTRIM(U.Correo))  
FROM  
	#Vista V  
JOIN  
	S_UsuarioProveedor UP (NOLOCK)
	ON V.IdProveedor = UP.IdProveedor  
JOIN  
	S_Usuario    U (NOLOCK)
	ON UP.IdUsuario = U.IdUsuario  
	AND U.IsEliminado = 0  
	AND U.IdTipoUsuario IN (3, 4)  
WHERE  
	V.CorreoProveedor IS NULL  
  
INSERT INTO #Aprobadores  
(  
	IdConsecutivo,  
	IdPedido,  
	IdEstatus,  
	Aprobador  
)  
SELECT  
	V.IdConsecutivo, V.IdPedido, V.IdEstatus, RTRIM(LTRIM(U.Nombre))  
FROM  
	#VISTA V  
JOIN  
	TA_Tarea AS TA (NOLOCK)
	ON V.IdOperacion = TA.IdOperacion  
	AND V.IdEstatus  = TA.IdEstatus  
JOIN  
	dbo.S_Usuario AS U  (NOLOCK)
	ON U.IdUsuario = TA.IdAprobador  
ORDER BY  
	V.IdConsecutivo,  
	V.IdPedido,  
	TA.NoSecuencia  
  
INSERT INTO #AprobadoresConcat  
(  
 IdConsecutivo,  
 IdPedido,  
 IdEstatus,  
 Aprobador  
)  
SELECT  
	IdConsecutivo,  
	IdPedido,  
	IdEstatus,   
	STUFF(( SELECT  ', '+ Aprobador FROM #Aprobadores A  
	WHERE B.IdConsecutivo = A.IdConsecutivo AND B.IdEstatus = A.IdEstatus AND B.IdPedido = A.IdPedido  FOR XML PATH('')),1 ,1, '')  Members  
FROM  
	#Aprobadores B  
GROUP BY  
	IdConsecutivo,  
	IdPedido,  
	IdEstatus  
ORDER BY  
	IdConsecutivo,  
	IdPedido,  
	IdEstatus  
  
UPDATE V  
	SET Aprobadores = A.Aprobador  
FROM  
	#Vista V  
JOIN  
	#AprobadoresConcat A  
	ON V.IdConsecutivo = A.IdConsecutivo  
  
INSERT INTO #Pedidos  
(  
 IdPedido  
)  
SELECT IdPedido  
FROM #VISTA  
GROUP BY IdPedido  
  
INSERT INTO #MontoPedidos  
(  
	IdPedido,  
	Monto  
)  
SELECT  
	V.IdPedido, SUM(ISNULL(Subtotal,0))  
FROM  
	#Pedidos V  
JOIN  
	MM_PedidoDetalle PD (NOLOCK)
	ON V.IdPedido = PD.IdPedido  
GROUP BY  
	V.IdPedido  
  
  
UPDATE V  
	SET MontoTotalOrdenCompra = M.Monto  
FROM  
	#Vista V  
JOIN  
	#MontoPedidos M  
	ON V.IdPedido = M.IdPedido  
  
UPDATE P  
	SET FechaIngreso = AP.Creado  
FROM  
	#Vista P  
JOIN  
	MM_AceptacionPedido AP (NOLOCK) 
	ON P.IdPedido = AP.IdPedido  
	AND AP.IdEliminado IS NULL  
WHERE  
	ISNULL(AP.IdEstatusEliminado,0) = 0  
  
INSERT INTO #LineasPresupuesto  
(  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido,  
	IdLineaPresupuesto
)  
SELECT  
	V.IdConsecutivo,
	V.IdPedido,
	V.SolicitudPedido,
	SPDL.IdLineaPresupuesto 
FROM
	#Vista V  
JOIN  
	MM_SolicitudPedidoDetalle SPD (NOLOCK)
	ON V.SolicitudPedido = SPD.IdSolicitudPedido  
JOIN  
	MM_SolicitudPedidoDetalleLineaPresupuesto SPDL (NOLOCK)
	ON SPD.IdSolicitudPedidoDetalle = SPDL.IdSolicitudPedidoDetalle  
JOIN
	Adinco.dbo.CO_LineaPresupuestoMes ALP (NOLOCK)
	ON SPDL.IdLineaPresupuesto = ALP.IdLineaPresupuestoMes
GROUP BY  
	V.IdConsecutivo, V.IdPedido, V.SolicitudPedido, SPDL.IdLineaPresupuesto  
ORDER BY  V.IdConsecutivo  
  
INSERT INTO #ClasificacionPresupuesto  
(  
    IdConsecutivo,  
    IdPedido,  
    SolicitudPedido,  
    Actividad,  
    Subactividad,  
    Tarea,  
    Subtarea
)  
SELECT  
	TEMP.IdConsecutivo,  
	TEMP.IdPedido,  
	TEMP.SolicitudPedido,  
	LTRIM(AP.id_Actividad) + ' ' + LTRIM(AP.DescripcionActividadPetrolera) AS Actividad,  
	LTRIM(SP.[id_Sub-actividad]) + ' ' + LTRIM(SP.SubactividadPetrolera) AS Subactividad,  
	LTRIM(TP.id_Tarea) + ' ' + LTRIM(TP.TareaPetrolera) AS Tarea,  
	LTRIM(RTRIM(S.NombreServicio))
FROM  
	#LineasPresupuesto TEMP  
JOIN  
	Adinco.dbo.CO_LineaPresupuestoMes LPM (NOLOCK)
	ON TEMP.IdLineaPresupuesto = LPM.IdLineaPresupuestoMes  
JOIN  
	Adinco.dbo.CO_ActividadPetroleraCNH AP (NOLOCK)
	ON LPM.IdActividadPetrolera = AP.IdActividadPetrolera  
JOIN  
	Adinco.dbo.CO_SubactividadPetrolera SP (NOLOCK)
	ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera  
JOIN  
	Adinco.dbo.CO_TareaPetrolera TP (NOLOCK)
	ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera  
JOIN  
	Adinco.dbo.CO_Servicio S (NOLOCK)
	ON LPM.IdServicio = S.idServicio  
GROUP BY  
	TEMP.IdConsecutivo,  
	TEMP.IdPedido,  
	TEMP.SolicitudPedido,  
	LTRIM(AP.id_Actividad) + ' ' + LTRIM(AP.DescripcionActividadPetrolera),  
	LTRIM(SP.[id_Sub-actividad]) + ' ' + LTRIM(SP.SubactividadPetrolera),  
	LTRIM(TP.id_Tarea) + ' ' + LTRIM(TP.TareaPetrolera),  
	LTRIM(RTRIM(S.NombreServicio))
ORDER BY  
	TEMP.IdConsecutivo  
  
INSERT INTO #Instalaciones  
(  
	IdConsecutivo,  
	IdPedido,  
	Instalacion  
)  
SELECT 
	V.IdConsecutivo, V.IdPedido, I.NombreInstalacion  
FROM #Vista V  
JOIN  
	MM_SolicitudPedidoDetalle SPD (NOLOCK)
	ON V.SolicitudPedido = SPD.IdSolicitudPedido  
JOIN  
	MM_SolicitudPedidoDetalleLineaPresupuesto SPDL (NOLOCK)
	ON SPD.IdSolicitudPedidoDetalle = SPDL.IdSolicitudPedidoDetalle  
JOIN  
	Adinco.dbo.CO_Instalacion I (NOLOCK)
	ON SPDL.IdInstalacion = I.IdInstalacion  
GROUP BY  
	V.IdConsecutivo, V.IdPedido, I.NombreInstalacion  
  
INSERT INTO #InstalacionesConcat  
(  
	IdConsecutivo,  
	IdPedido,  
	Instalacion  
)  
SELECT 
	IdConsecutivo,  
	IdPedido,  
	STUFF(( SELECT  ', '+ Instalacion FROM #Instalaciones A  
	WHERE B.IdConsecutivo = A.IdConsecutivo AND B.IdPedido = A.IdPedido  FOR XML PATH('')),1 ,1, '')  Members  
FROM  
	#Instalaciones B  
GROUP BY  
	IdConsecutivo,  
	IdPedido  
ORDER BY  
	IdConsecutivo,  
	IdPedido  
  
UPDATE V  
	SET Instalacion = I.Instalacion  
FROM  
	#Vista V  
JOIN  
	#InstalacionesConcat I  
	ON V.IdConsecutivo = I.IdConsecutivo  
  
INSERT INTO #Fechas  
(  
	IdConsecutivo,  
	SolicitudPedido,  
	Fecha  
)  
SELECT  
	V.IdConsecutivo,   
	V.SolicitudPedido,   
	MAX(T.FechaCambioEstatus)  
FROM   
	#Vista V  
JOIN  
	TA_Operacion O (NOLOCK) 
	ON V.SolicitudPedido = O.IdDocumento  
	AND V.Version = O.NoVersion  
	AND V.IdProveedorCompras = O.IdProveedor  
	AND O.IdTipoOperacion = 9  
	AND O.IdEstatusOperacion = 2  
JOIN  
	TA_Tarea  T (NOLOCK)
    ON O.IdOperacion = T.IdOperacion  
GROUP BY  
	V.IdConsecutivo,  
	V.SolicitudPedido  
ORDER BY  
	V.IdConsecutivo,  
	V.SolicitudPedido  
  
UPDATE V  
	SET FechaAprobacionOC = F.Fecha  
FROM  
	#Vista V  
JOIN  
	#Fechas F  
	ON V.IdConsecutivo = F.IdConsecutivo  
  
-- SE BORRA LA INFORMACION DE LA TA TABLA DE FECHAS PARA REUTILIZARLA  
DELETE FROM #Fechas  
  
INSERT INTO #Fechas  
(  
	IdConsecutivo,  
	SolicitudPedido,  
	Fecha  
)  
SELECT  
	V.IdConsecutivo,   
	V.SolicitudPedido,   
	MAX(T.FechaCambioEstatus)  
FROM   
	#Vista V  
JOIN  
	TA_Operacion O  (NOLOCK) 
	ON V.SolicitudPedido = O.IdDocumento  
	AND V.Version = O.NoVersion  
	AND V.IdProveedorCompras = O.IdProveedor  
	AND O.IdTipoOperacion = 2  
	AND O.IdEstatusOperacion = 2  
JOIN  
	TA_Tarea  T (NOLOCK)
    ON O.IdOperacion = T.IdOperacion  
GROUP BY  
	V.IdConsecutivo,  
	V.SolicitudPedido  
ORDER BY  
	V.IdConsecutivo,  
	V.SolicitudPedido  
  
UPDATE V  
	SET UltimaFechaAprobaciones = F.Fecha  
FROM  
	#Vista V  
JOIN  
	#Fechas F  
	ON V.IdConsecutivo = F.IdConsecutivo  
  
INSERT INTO #VistaFinal  
(  
	IdConsecutivoVista,  
	IdContrato,  
	Contrato,  
	IdPedido,  
	OrdenCompra,  
	SolicitudPedido,  
	CreadoEl,  
	DiasPedido,  
	Proveedor,  
	CorreoProveedor,  
	RFC,  
	Estado,  
	Version,  
	Moneda,  
	TipoPedido,  
	Aprobadores,  
	EstatusAprobador,  
	IdEstatus,  
	EstatusRecepcionServicio,  
	EstatusCN,  
	MontoTotalOrdenCompra,  
	Instalacion,  
	Motivo,  
	PedidoCancelado,  
	MontoAceptacion,  
	DiasCredito,  
	FechaIngreso,  
	FechaCotizacion,  
	RecepcionServicio,  
	IdOperacion,  
	IdProveedor,  
	IdAceptacionPedido,  
	FechaAprobacionOC,  
	UltimaFechaAprobaciones,  
	IdProveedorCompras  
)  
SELECT DISTINCT  
	P.IdConsecutivo,  
	P.IdContrato,  
	P.Contrato,  
	P.IdPedido,  
	P.OrdenCompra,  
	P.SolicitudPedido,  
	P.CreadoEl,  
	P.DiasPedido,  
	P.Proveedor,  
	P.CorreoProveedor,  
	P.RFC,  
	P.Estado,  
	P.Version,  
	P.Moneda,  
	P.TipoPedido,  
	P.Aprobadores,  
	P.EstatusAprobador,  
	P.IdEstatus,  
	P.EstatusRecepcionServicio,  
	P.EstatusCN,  
	P.MontoTotalOrdenCompra,  
	P.Instalacion,  
	P.Motivo,  
	P.PedidoCancelado,  
	P.MontoAceptacion,  
	P.DiasCredito,  
	P.FechaIngreso,  
	P.FechaCotizacion,  
	P.RecepcionServicio,  
	P.IdOperacion,  
	P.IdProveedor,  
	AP.IdAceptacionPedido,  
	P.FechaAprobacionOC,  
	P.UltimaFechaAprobaciones,  
	P.IdProveedorCompras  
FROM  
	#Vista P  
JOIN  
	MM_AceptacionPedido AP (NOLOCK) 
	ON P.IdPedido = AP.IdPedido  
	AND AP.IdEliminado IS NULL  
WHERE  
	ISNULL(AP.IdEstatusEliminado,0) = 0  
ORDER BY   
	P.IdConsecutivo, P.IdPedido, AP.IdAceptacionPedido --AFF.IdFactura  
  
UPDATE V  
	SET IdAceptacionFactura = AFF.IdAceptacionFactura,  
		IdFactura = AFF.IdFactura  
FROM  
	#VistaFinal V  
JOIN  
	dbo.MM_AceptacionFactura AFF (NOLOCK)
	ON V.IdAceptacionPedido = AFF.IdAceptacionPedido  
  
UPDATE V  
SET FechaPagoSegunDiasCredito = CASE  
			WHEN APF.FechaModificacion IS NOT NULL AND V.DiasCredito IS NULL  
			THEN CONVERT(DATE, DATEADD(DAY, ISNULL(V.DiasCredito, 60), APF.FechaModificacion))  
			WHEN APF.FechaModificacion IS NOT NULL  
					AND V.DiasCredito = 0  
			THEN CONVERT(DATE, DATEADD(DAY, 60, APF.FechaModificacion))  
			WHEN APF.FechaModificacion IS NOT NULL  
					AND ISNULL(V.DiasCredito, 0) <> 0  
			THEN CONVERT(DATE, DATEADD(DAY, V.DiasCredito, APF.FechaModificacion))  
			ELSE NULL  
		END,  
	EstatusFactura = EAF.Nombre,  
	DiasCredito = CASE  
					WHEN V.DiasCredito IS NULL  
					THEN ISNULL(V.DiasCredito, 60)  
					WHEN V.DiasCredito = 0  
					THEN 60  
				ELSE V.DiasCredito  
		END  
FROM  
	#VistaFinal V  
JOIN  
	dbo.TA_Operacion APF (NOLOCK)
	ON V.IdAceptacionFactura = APF.IdDocumento  
	AND APF.IdTipoOperacion = 10 -->Aprobación Factura   
	AND V.IdProveedor = APF.IdProveedor  
JOIN  
	dbo.TA_Estatus EAF (NOLOCK)
	ON APF.IdEstatusOperacion = EAF.IdEstatus  
  
  
INSERT INTO #VistaFinal  
(  
	IdConsecutivoVista,  
	IdContrato,  
	Contrato,  
	IdPedido,  
	OrdenCompra,  
	SolicitudPedido,  
	CreadoEl,  
	DiasPedido,  
	Proveedor,  
	CorreoProveedor,  
	RFC,  
	Estado,  
	Version,  
	Moneda,  
	TipoPedido,  
	Aprobadores,  
	EstatusAprobador,  
	IdEstatus,  
	EstatusFactura,  
	EstatusRecepcionServicio,  
	EstatusCN,  
	MontoTotalOrdenCompra,  
	Instalacion,  
	Motivo,  
	PedidoCancelado,  
	MontoAceptacion,  
	DiasCredito,  
	FechaPagoSegunDiasCredito,  
	FechaIngreso,  
	FechaCotizacion,  
	RecepcionServicio,  
	IdOperacion,  
	IdProveedor,  
	IdFactura,  
	IdAceptacionFactura,  
	IdAceptacionPedido,  
	FechaAprobacionOC,  
	IdProveedorCompras  
)  
SELECT  
	V.IdConsecutivo,  
	V.IdContrato,  
	V.Contrato,  
	V.IdPedido,  
	V.OrdenCompra,  
	V.SolicitudPedido,  
	V.CreadoEl,  
	V.DiasPedido,  
	V.Proveedor,  
	V.CorreoProveedor,  
	V.RFC,  
	V.Estado,  
	V.Version,  
	V.Moneda,  
	V.TipoPedido,  
	V.Aprobadores,  
	V.EstatusAprobador,  
	V.IdEstatus,  
	'No se ha realizado ninguna aprobación de factura',  
	V.EstatusRecepcionServicio,  
	V.EstatusCN,  
	V.MontoTotalOrdenCompra,  
	V.Instalacion,  
	V.Motivo,  
	V.PedidoCancelado,  
	V.MontoAceptacion,  
	CASE  
		WHEN V.DiasCredito IS NULL  
		THEN ISNULL(V.DiasCredito, 60)  
		WHEN V.DiasCredito = 0  
		THEN 60  
		ELSE V.DiasCredito  
	END,  
	NULL AS FechaPagoSegunDiasCredito,  
	V.FechaIngreso,  
	V.FechaCotizacion,  
	V.RecepcionServicio,  
	V.IdOperacion,  
	V.IdProveedor,  
	NULL,  
	NULL,   
	NULL,  
	V.FechaAprobacionOC,  
	V.IdProveedorCompras  
FROM  
	#Vista V  
LEFT JOIN   
	#VistaFinal VF  
	ON V.IdConsecutivo = VF.IdConsecutivoVista  
WHERE  
	VF.IdConsecutivoVista IS NULL  
  
-- SE BORRA LA INFORMACION DE LA TABLA #MontoPedidos PARA REUSARLA, PARA OBTENER EL MONTO DE CADA ACEPTACION  
DELETE FROM #MontoPedidos  
  
INSERT INTO #MontoPedidos  
(  
	IdPedido,  
	Monto  
)  
SELECT  
	P.IdAceptacionPedido,  
	SUM(ISNULL(APD.Cantidad * PD.PrecioUnitario,0))  
FROM  
	#VistaFinal P 
JOIN  
	MM_AceptacionPedidoDetalle APD (NOLOCK)
	ON P.IdAceptacionPedido = APD.IdAceptacionPedido  
JOIN  
	MM_PedidoDetalle PD (NOLOCK)
	ON APD.IdPedidoDetalle = PD.IdPedidoDetalle  
GROUP BY  
	P.IdAceptacionPedido  
  
  
UPDATE V  
	SET MontoAceptacion = M.Monto  
FROM  
	#VistaFinal V  
JOIN  
	#MontoPedidos M  
	ON V.IdAceptacionPedido = M.IdPedido  
  
-- SI NO TIENEN MONTO DE ACEPTACION, NO TIENEN ACEPTACION DE PEDIDO  
UPDATE #Vista   
	SET EstatusCN = 'No se ha solicitado formato de carta de contenido nacional al proveedor'  
WHERE  
	MontoAceptacion IS NULL  
  
-- SE BORRA LA INFORMACION DE LA TABLA DE FECHAS PARA REUTILIZARLA  
DELETE FROM #Fechas  
  
INSERT INTO #Fechas  
(  
	IdConsecutivo,  
	SolicitudPedido,  
	Fecha  
)  
SELECT  
	V.IdConsecutivo,   
	V.IdAceptacionFactura,   
	MAX(T.FechaCambioEstatus)  
FROM   
	#VistaFinal V  
JOIN  
	TA_Operacion APF (NOLOCK)
	ON V.IdAceptacionFactura = APF.IdDocumento  
	AND APF.IdTipoOperacion = 10 -->Aprobación Factura   
	AND APF.IdEstatusOperacion = 2  
JOIN  
	TA_Tarea  T (NOLOCK)
	ON APF.IdOperacion = T.IdOperacion  
GROUP BY  
	V.IdConsecutivo,  
	V.IdAceptacionFactura  
ORDER BY  
	V.IdConsecutivo,  
	V.IdAceptacionFactura  
  
UPDATE V  
	SET FechaAprobacionFactura = F.Fecha  
FROM  
	#VistaFinal V  
JOIN  
	#Fechas F  
	ON V.IdConsecutivo = F.IdConsecutivo  
  
UPDATE VF  
	SET UUIDFactura = FP.UUID, --FA.UUID,  
	IdFacturaAdinco = FA.IdFactura,  
	Factura = LTRIM(RTRIM(CONCAT(ISNULL(FA.Serie,''),' ',ISNULL(fa.Folio,'')))),  
	FechaFactura = FA.Fecha,  
	TotalFactura = FA.montoconiva,  
	SubTotalFactura = FA.SubTotal  
FROM  
	#VistaFinal VF  
JOIN  
	dbo.FI_Factura FP (NOLOCK)
	ON VF.IdFactura = FP.IdFactura  
	--AND FP.Activa = 1  
JOIN  
	Adinco.dbo.FI_Factura FA (NOLOCK)
	ON FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = FA.UUID  
  
  
-- SE BUSCA LA RELACION DE LA FACTURA DE ADINCO PARA PONER EL UUID FINAL QUE QUEDO EN ADINCO, PARA EL CASO DE LAS SUSTITUCIONES  
UPDATE VF  
	SET UUID_Adinco = FA.UUID,  
	IdFacturaAdinco = FA.IdFactura,  
	Factura = LTRIM(RTRIM(CONCAT(ISNULL(FA.Serie,''),' ',ISNULL(fa.Folio,'')))),  
	FechaFactura = FA.Fecha  
FROM  
	#VistaFinal VF  
JOIN  
	Adinco.dbo.FI_FacturaAdincoPetrovendor FAP  (NOLOCK)
	ON VF.IdFactura = FAP.IdFacturaPetrovendor 
	AND FAP.Activo	=	1
JOIN  
	Adinco.dbo.FI_Factura FA (NOLOCK)
	ON FAP.IdFacturaAdinco = FA.IdFactura  
  
  
-- SE BORRA LA INFORMACION DE LA TA TABLA DE FECHAS PARA REUTILIZARLA  
DELETE FROM #Fechas  
  
INSERT INTO #Fechas  
(  
	IdConsecutivo,  
	SolicitudPedido,  
	Fecha  
)  
SELECT  
	V.IdConsecutivo,  
	V.IdAceptacionPedido,  
	MAX(CNN.CreadoEl)  
FROM  
	#VistaFinal V  
JOIN  
	MM_AceptacionCartaPCN CNN (NOLOCK)
	ON V.IdAceptacionPedido = CNN.IdAceptacionPedido  
	AND CNN.Activo = 1  
GROUP BY  
	V.IdConsecutivo,  
	V.IdAceptacionPedido  
ORDER BY  
	V.IdConsecutivo,  
	V.IdAceptacionPedido  
  
UPDATE V  
	SET EstatusCN = ECCN.Nombre,  
	FechaAprobacionCartaCN = CASE WHEN CNN.IdEstatus = 2 THEN CNN.FechaEvaluacion ELSE NULL END  
FROM  
	#VistaFinal V  
JOIN  
	#Fechas F  
	ON V.IdConsecutivo = F.IdConsecutivo  
JOIN  
	MM_AceptacionCartaPCN CNN (NOLOCK)
	ON V.IdAceptacionPedido = CNN.IdAceptacionPedido  
	AND F.Fecha = CNN.CreadoEl  
	AND CNN.Activo = 1  
JOIN  
	TA_Estatus ECCN  
	ON CNN.IdEstatus = ECCN.IdEstatus  
  
--Factura ligada dirctamente a la transferencia  
UPDATE VF  
SET EstatusPago = 'Pagado',  
	Entidad_Jaguar = CtaO.Titular,  
	CuentaOrigen = ISNULL(CtaO.NumeroCuenta, ''),  
	CuentaDestino = ISNULL(CtaD.NumeroCuenta, ''),  
	FechaTransferencia = TRANS.FechaPago,  
	MontoTransfer = TRANS.MontoPagado,  
	MontoTransferFactura = TRFAC.MontoPagado,  
	MonedaTransfer = MTRANS.TipoMonedaCorto,  
	FechaRegistroTranferencia = TRANS.CreadoEn  
FROM  
	#VistaFinal VF  
JOIN  
	Adinco.dbo.FI_TransferFactura TRFAC (NOLOCK)
	ON VF.IdFacturaAdinco = TRFAC.IdFactura  
JOIN  
	Adinco.dbo.FI_Transfer TRANS (NOLOCK)
	ON TRFAC.IdTransfer = TRANS.IdTransferencia  
JOIN  
	Adinco.dbo.PV_TipoMoneda MTRANS (NOLOCK)
	ON TRANS.IdMoneda = MTRANS.IdMoneda  
JOIN  
	Adinco.dbo.PV_CuentaBancaria CtaO (NOLOCK)
	ON TRANS.IdCuentaOrigen = CtaO.DatoBancarioID  
JOIN  
	Adinco.dbo.PV_CuentaBancaria CtaD (NOLOCK)
	ON TRANS.IdCuentaDestino = CtaD.DatoBancarioID  
  
--Factura ligada a traves del complemento  
UPDATE VF  
SET EstatusPago = 'Pagado con complemento',  
	Entidad_Jaguar = CtaO.Titular,  
	CuentaOrigen = ISNULL(CtaO.NumeroCuenta, ''),  
	CuentaDestino = ISNULL(CtaD.NumeroCuenta, ''),  
	FechaTransferencia = TRANS.FechaPago,  
	MontoTransfer = TRANS.MontoPagado,  
	MontoTransferFactura = DR.ImpPagado ,  
	MonedaTransfer = MTRANS.TipoMonedaCorto,  
	FechaRegistroTranferencia = TRANS.CreadoEn  
FROM  
	#VistaFinal VF  
JOIN  
	Adinco.dbo.FI_Factura ff (NOLOCK) 
	ON  VF.IdFacturaAdinco = ff.IdFactura  
JOIN  
	Adinco.dbo.FI_CPDocRelacionado DR   (NOLOCK)
	ON ff.UUID =  DR.IdDocumento COLLATE Modern_Spanish_CI_AS  
JOIN
	Adinco.dbo.FI_ComplementoDePago CPago (NOLOCK)
	ON Cpago.IdComplementoDePago = DR.IdComplementoDePago  
JOIN  
	Adinco.dbo.FI_TransferFactura TRFAC (NOLOCK)
	ON Cpago.IdFactura =  TRFAC.IdFactura  
JOIN  
	Adinco.dbo.FI_Transfer TRANS (NOLOCK)
	ON TRFAC.IdTransfer = TRANS.IdTransferencia  
JOIN  
	Adinco.dbo.PV_TipoMoneda MTRANS (NOLOCK)
	ON TRANS.IdMoneda = MTRANS.IdMoneda  
JOIN  
	Adinco.dbo.PV_CuentaBancaria CtaO (NOLOCK)
	ON TRANS.IdCuentaOrigen = CtaO.DatoBancarioID  
JOIN  
	Adinco.dbo.PV_CuentaBancaria CtaD (NOLOCK)
	ON TRANS.IdCuentaDestino = CtaD.DatoBancarioID  
WHERE EstatusPago IS NULL  
  
  
UPDATE #VistaFinal  
	SET EstatusPago = 'NO Pagado'   
WHERE EstatusPago IS NULL  
  
UPDATE #VistaFinal  
	SET  EstatusFactura = 'No se ha realizado ninguna aprobación de factura'  
WHERE  
	EstatusFactura IS NULL  
  
UPDATE #VistaFinal  
	SET EstatusCN = 'No se ha recibido solicitud de aprobación de Carta de Contenido Nacional por parte del proveedor'  
WHERE  
	EstatusCN IS NULL  
	AND  IdAceptacionPedido IS NOT NULL  
  
UPDATE VF  
	SET Entidad_Jaguar = CLIENTE.RazonSocial  
FROM   
	#VistaFinal VF  
JOIN  
	dbo.S_Proveedor CLIENTE (NOLOCK)
	ON VF.IdProveedorCompras = CLIENTE.IdProveedor  
WHERE  
	VF.Entidad_Jaguar IS NULL  
  
UPDATE VF  
	SET FechaRegistroTranferencia = TTFFCP.CreadoEn,  
		MontoTransfer = TTFFCP.MontoPagado,  
		MontoTransferFactura = CPDR.ImpPagado,  
		MonedaTransfer = MTTFFCP.TipoMonedaCorto,  
		UUIDComplemento = FCP.UUID,  
		EstatusPago = 'Pagado CON COMPLEMENTO',  
		FechaTransferencia = TTFFCP.FechaPago  
FROM   
	#VistaFinal    VF  
JOIN  
	dbo.FI_Factura FP  (NOLOCK)
	ON VF.IdFactura = FP.IdFactura  
JOIN  
	Adinco.DBO.FI_CPDocRelacionado CPDR (NOLOCK)
	ON FP.UUID = CPDR.IdDocumento COLLATE SQL_Latin1_General_CP1_CI_AS  
JOIN  
	Adinco.dbo.FI_ComplementoDePago CP (NOLOCK)
	ON CPDR.IdComplementoDePago = CP.IdComplementoDePago  
JOIN  
	Adinco.dbo.FI_Factura FCP (NOLOCK)
	ON CP.IdFactura = FCP.IdFactura   
	AND FCP.IdContrato <> 3  
JOIN  
	Adinco.dbo.FI_TransferFactura TFFCP (NOLOCK)
	ON FCP.IdFactura = TFFCP.IdFactura  
JOIN  
	Adinco.dbo.FI_Transfer TTFFCP (NOLOCK)
	ON TFFCP.IdTransfer = TTFFCP.IdTransferencia  
JOIN  
	Adinco.dbo.PV_TipoMoneda MTTFFCP (NOLOCK)
	ON TTFFCP.IdMoneda = MTTFFCP.IdMoneda  
  
UPDATE VF  
	SET  
		MetodoPago = CASE     
                WHEN REPLACE(F.MetodoPago, 'ó', 'O') LIKE '%SOL%'        
				    OR F.MetodoPago LIKE '%PUE%'       
					OR REPLACE(F.FormaPago, 'ó', 'O') LIKE '%SOL%'   
					OR F.FormaPago LIKE '%PUE%'    
					OR F.MetodoPago LIKE '%CONTADO%' 
					OR F.FormaPago LIKE '%CONTADO%'      
					OR F.MetodoPago LIKE '%UNA%'         
					OR F.FormaPago LIKE '%UNA%'          
					THEN 'PUE'        
				WHEN F.MetodoPago IS NULL   
				AND F.FormaPago IS NULL      
			       THEN ''           
				ELSE 'PPD'  
      END
FROM   
	#VistaFinal    VF  
JOIN  
	Adinco.dbo.FI_Factura F  (NOLOCK)
	ON VF.idfacturaadinco = F.IdFactura  
  
  
UPDATE VF  
	SET   EstatusPago = 'Pagado SIN COMPLEMENTO'  
FROM   
	#VistaFinal    VF  
JOIN  
	Adinco.dbo.FI_Factura FP  (NOLOCK)
	ON VF.idfacturaadinco = FP.IdFactura
WHERE
	VF.metodopago = 'PPD'  AND vf.estatuspago = 'Pagado'  
  
-- SE OBTIENE MES DE PRESENTACION DE LA FACTURA
UPDATE	VF
	SET	MesSIPAC	=	DATEFROMPARTS(AnioRC2102, MesRC2101, 1)
FROM
	#VistaFinal	VF
JOIN
	Adinco.dbo.SIPAC_RCCONT21M	SIPAC	(NOLOCK)
	ON	VF.UUID_Adinco	=	SIPAC.IdentificadorCFDIRC2105

UPDATE	VF
	SET	MesSIPAC	=	DATEFROMPARTS(AnioRC2102, MesRC2101, 1)
FROM
	#VistaFinal	VF
JOIN
	Adinco.dbo.SIPAC_RCCONT21M	SIPAC	(NOLOCK)
	ON	VF.UUIDComplemento	=	SIPAC.IdentificadorCFDIRC2105

  
-- SE OBTIENEN LAS DIFERENTES CLASIFICACIONES QUE TENGA SEGUN EL PRESUPUESTO  
-- ACTIVIDAD PETROLERA  
INSERT INTO #Clasificacion  
(  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido,  
	Descripcion  
)  
SELECT  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido,  
	STUFF(( SELECT  ', '+ Actividad FROM #ClasificacionPresupuesto A  
	WHERE B.IdConsecutivo = A.IdConsecutivo AND B.IdPedido = A.IdPedido AND B.SolicitudPedido = A.SolicitudPedido FOR XML PATH('')),1 ,1, '')  Members  
FROM  
	#ClasificacionPresupuesto B  
GROUP BY  
	IdConsecutivo,  
	IdPedido, 
	SolicitudPedido  
ORDER BY  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido  
  
UPDATE V 
	SET Actividad = I.Descripcion  
FROM  
	#VistaFinal V  
JOIN  
	#Clasificacion I  
	ON V.IdConsecutivo = I.IdConsecutivo  
  
-- SE BORRA LA TABLA PARA REUTILIZARLA  
DELETE FROM #Clasificacion  
  
-- SUBACTIVIDAD PETROLERA  
INSERT INTO #Clasificacion  
(  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido,  
	Descripcion  
)  
SELECT  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido,  
	STUFF(( SELECT  ', '+ Subactividad FROM #ClasificacionPresupuesto A  
	WHERE B.IdConsecutivo = A.IdConsecutivo AND B.IdPedido = A.IdPedido AND B.SolicitudPedido = A.SolicitudPedido FOR XML PATH('')),1 ,1, '')  Members  
FROM  
	#ClasificacionPresupuesto B  
GROUP BY  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido  
ORDER BY  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido  
  
UPDATE V  
	SET Subactividad = I.Descripcion  
FROM  
	#VistaFinal V  
JOIN  
	#Clasificacion I  
	ON V.IdConsecutivo = I.IdConsecutivo  
  
-- SE BORRA LA TABLA PARA REUTILIZARLA  
DELETE FROM #Clasificacion  
  
-- TAREA PETROLERA  
INSERT INTO #Clasificacion  
(  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido,  
	Descripcion  
)  
SELECT  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido,  
	STUFF(( SELECT  ', '+ Tarea FROM #ClasificacionPresupuesto A  
	WHERE B.IdConsecutivo = A.IdConsecutivo AND B.IdPedido = A.IdPedido AND B.SolicitudPedido = A.SolicitudPedido FOR XML PATH('')),1 ,1, '')  Members  
FROM  
	#ClasificacionPresupuesto B  
GROUP BY  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido  
ORDER BY  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido  
  
UPDATE V
	SET Tarea = I.Descripcion  
FROM 
	#VistaFinal V  
JOIN  
	#Clasificacion I  
	ON V.IdConsecutivo = I.IdConsecutivo  
  
-- SE BORRA LA TABLA PARA REUTILIZARLA  
DELETE FROM #Clasificacion  
  
-- SUBTAREA (SERVICIO)  
INSERT INTO #Clasificacion  
(  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido,  
	Descripcion  
)  
SELECT  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido,  
	STUFF(( SELECT  ', '+ Subtarea FROM #ClasificacionPresupuesto A  
	WHERE B.IdConsecutivo = A.IdConsecutivo AND B.IdPedido = A.IdPedido AND B.SolicitudPedido = A.SolicitudPedido FOR XML PATH('')),1 ,1, '')  
FROM  
	#ClasificacionPresupuesto B  
GROUP BY  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido  
ORDER BY  
	IdConsecutivo,  
	IdPedido,  
	SolicitudPedido  
  
UPDATE V  
	SET Subtarea = I.Descripcion  
FROM  
	#VistaFinal V  
JOIN  
	#Clasificacion I  
	ON V.IdConsecutivo = I.IdConsecutivo  

-- SE OBTIENEN TODOS LOS CONCEPTOS DE LAS FACTURAS CONSIDERADAS  
INSERT INTO #Conceptos  
(  
	IdConsecutivo,  
	IdFactura,  
	--IdFacturaConcepto,  
	Concepto  
)  
SELECT  
	VF.IdConsecutivo,  
	VF.IdFacturaAdinco,  
	--C.IdFacturaConcepto,  
	SUBSTRING(LTRIM(RTRIM(C.Descripcion)),1,500)  
FROM  
	#VistaFinal VF  
JOIN  
	Adinco.dbo.FI_CFDIConcepto C  (NOLOCK)
	ON VF.IdFacturaAdinco = C.IdFactura  
GROUP BY  
	VF.IdConsecutivo,  
	VF.IdFacturaAdinco,  
	--C.IdFacturaConcepto,  
	SUBSTRING(LTRIM(RTRIM(C.Descripcion)),1,500)  
  
-- SE CONCATENAN TODOS LOS CONCEPTOS DE LA FACTURA  
INSERT INTO #FacturaConceptos  
(  
	IdConsecutivo,  
	IdFactura,  
	Concepto  
)  
SELECT
	IdConsecutivo,
	IdFactura,
	SUBSTRING(STUFF(( SELECT '|'+ RTRIM(LTRIM(Concepto)) 
			FROM #Conceptos A 
			WHERE B.IdConsecutivo = A.IdConsecutivo 
				AND B.IdFactura = A.IdFactura FOR XML PATH('')),1 ,1, ''),1,8000)
FROM
	#Conceptos B
GROUP BY
	IdConsecutivo,
	IdFactura  
  
  
-- SE ACTUALIZA EL CONCEPTO EN LA TABLA PRINCIPAL  
UPDATE VF  
	SET ConceptoFactura = FC.Concepto  
FROM  
	#VistaFinal VF  
JOIN  
	#FacturaConceptos FC  
	ON VF.IdConsecutivo = FC.IdConsecutivo  

-- SE BORRA LA TABLA PARA REUTILIZARLA
INSERT INTO #MontoPedidos  
(  
	IdPedido,  
	Monto	-- DIAS DE CREDITO MENOR  
)
SELECT
	VF.IdPedido,
	MIN(pd.DiasCredito)
FROM  
	#VistaFinal VF  
JOIN
	MM_PedidoDetalle AS PD (NOLOCK)
    ON VF.IdPedido = PD.IdPedido
GROUP BY
	VF.IdPedido

--Actualiza dias credito
UPDATE VF  
	SET DiasCredito = DC.Monto 
FROM  
	#VistaFinal VF  
JOIN
	#MontoPedidos	DC
    ON VF.IdPedido = DC.IdPedido

  
-- SE BORRA LA INFORMACION DE LA TABLA  
TRUNCATE TABLE EstatusPedidosJaguar  

INSERT INTO dbo.EstatusPedidosJaguar  
(  
	IdConsecutivo,  
	IdContrato,  
	Contrato,  
	IdPedido,  
	OrdenCompra,  
	SolicitudPedido,  
	CreadoEl,  
	DiasPedido,  
	Proveedor,  
	CorreoProveedor,  
	RFC,  
	Estado,  
	Version,  
	Moneda,  
	TipoPedido,  
	Aprobadores,  
	EstatusAprobador,  
	IdEstatus,  
	EstatusFactura,  
	EstatusPago,  
	Factura,  
	EstatusRecepcionServicio,  
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
	PedidoCancelado,  
	MontoAceptacion,  
	DiasCredito,  
	FechaPagoSegunDiasCredito,  
	FechaIngreso,  
	UUIDFactura,  
	UUIDComplemento,  
	UltimaFechaAprobaciones,  
	FechaTransferencia,  
	FechaCotizacion,  
	FechaAprobacionOC,  
	FechaAprobacionCartaCN,  
	FechaAprobacionFactura,  
	FechaFactura,  
	RecepcionServicio,  
	IdProveedorCompras,  
	FecMovto,  
	UUID_Adinco,  
	ActividadPetrolera,  
	SubactividadPetrolera,  
	TareaPetrolera,   
	MetodoPago,  
	MontoPagadoFactura,   
	TotalFactura,  
	ConceptoFactura,  
	SubTotalFactura,  
	Servicio,
	IdAceptacionPedido,
	MesSIPAC
)  
SELECT  
	IdConsecutivo,  
	IdContrato,  
	Contrato,  
	IdPedido,  
	OrdenCompra,  
	SolicitudPedido,  
	CreadoEl,  
	DiasPedido,  
	Proveedor,  
	CorreoProveedor,  
	RFC,  
	Estado,  
	Version,  
	Moneda,  
	TipoPedido,  
	Aprobadores,  
	EstatusAprobador,  
	IdEstatus,  
	EstatusFactura,  
	EstatusPago,  
	Factura,  
	EstatusRecepcionServicio,  
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
	PedidoCancelado,  
	MontoAceptacion,  
	DiasCredito,  
	FechaPagoSegunDiasCredito,  
	FechaIngreso,  
	UUIDFactura,  
	UUIDComplemento,  
	UltimaFechaAprobaciones,  
	FechaTransferencia,  
	FechaCotizacion,  
	FechaAprobacionOC,  
	FechaAprobacionCartaCN,  
	FechaAprobacionFactura,  
	FechaFactura,  
	RecepcionServicio,  
	IdProveedorCompras,  
	GETDATE(),  
	UUID_Adinco,  
	Actividad,  
	Subactividad,  
	Tarea,  
	MetodoPago,  
	MontoTransferFactura,   
	TotalFactura,  
	ConceptoFactura,  
	SubTotalFactura,  
	Subtarea,
	IdAceptacionPedido,
	MesSIPAC
FROM  
	#VistaFinal 
  
/*************** VISTA FACTURAS COMPRA DIRECTA **************************************/  
/************Modificado por HV 09/07/2020 ticket #6243 *******************************************/

TRUNCATE TABLE VISTA_ComprasDirectas    

INSERT INTO VISTA_ComprasDirectas
(idFactura,     
 UUID_Petrovendor,     
 Serie,     
 Folio,     
 UUID_Adinco,     
 NumeroContrato,     
 Moneda,     
 TotalFactura,     
 --ConceptoFactura,     
 SubTotalFactura,     
 Receptor,     
 Proveedor,     
 RFCProveedor,     
 FechaAprobacionFactura,     
 idOperacion,
 --------------Campos ADD->
 Pedido,
 CreadoEl,
 DiasPedido,
 Estado,
 NombreOperacion,
 Aprobadores,
 EstatusFactura,
 --EstatusPago,
 EstatusCn,
 RSContratista,
 --CuentaOrigen,
 --CuentaDestino,
 --FechaRegistroTransferencia,
 --MontoTransfer,
 --MonedaTransfer,
 MontoRegistro,
 Instalacion,
 Motivo,
 --UUID_C,
 --FechaTransferencia,
 FechaFactura
 --MontoTransferFactura,
 --MetodoPago
)    
SELECT ff2.IdFactura,     
        ff.UUID AS UUID_Petrovendor,     
        ISNULL(ff2.Serie, '') AS Serie,     
        ISNULL(ff2.Folio, '') AS Folio,     
        ff2.UUID AS UUID_Adinco,     
        cc.NumeroContrato,     
        TM.TipoMonedaCorto,     
        ff2.MontoConIva,     
        --fc.Descripcion,     
        ff2.SubTotal,     
        ff2.Receptor,     
        sp.RazonSocial,     
        ff2.Emisor,     
        NULL,     
        TAO.idoperacion,
        PP.IdPedido,
        PP.CreadorEl,
        CASE    
            WHEN DATEDIFF(DAY, PP.CreadorEl, GETDATE()) > 60    
            THEN 'Pedido con MAS DE 60 DIAS'    
            ELSE 'Pedido con MENOS DE 60 DIAS'    
        END 'Dias del Pedido',
     E.Nombre,
        TTA.NombreOperacion,
        stuff ((select ', ' + U.Nombre from S_Usuario U
                        join TA_Tarea T on T.IdAprobador = U.IdUsuario
                        where T.IdOperacion = TAO.IdOperacion
                        for XML PATH ('')), 1, 2, '') Aprobadores,
        E.Nombre,         --------------------- Es el mismo estatus que la OC
        CASE WHEN ff.IDFactura = CCN.IdFactura THEN 'Aprobada' ELSE 'Sin Carta' end as EstatusCN,
        PJ.RazonSocial Entidad_Jaguar,
        R.MontoRegistro MontoTotalOrdenCompra,
        I.NombreInstalacion,
        R.Comentarios Motivo,
        ff.Fecha
FROM fi_factura ff    
    JOIN adinco..FI_Factura ff2 ON ff2.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = ff.UUID 
	left JOIN adinco..PV_TipoMoneda TM ON ff2.IdMoneda = TM.IdMoneda
    JOIN adinco..CO_Contrato cc ON ff.IdContrato = cc.IdContrato    
    left JOIN dbo.S_Proveedor sp ON sp.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = ff2.Emisor   
			AND sp.activo = 1
    JOIN adinco..FI_CFDIConcepto fc ON ff2.IdFactura = fc.IdFactura    
    JOIN TA_OPERACION TAO ON ff.idFactura = TAO.IdDocumento    
                                AND TAO.IdTipoOperacion = 14
    left join MM_Pedidos PP on TAO.IdDocumento = PP.IdIdentificador AND PP.IdTipoPedido = 1
    left join TA_Tarea T on TAO.IdOperacion = T.IdOperacion
    left join TA_Estatus E on T.IdEstatus = E.IdEstatus AND E.IdEstatus NOT IN (4,6,7,10)
    left join TA_TipoOperacion TTA on TAO.IdTipoOperacion = TTA.IdTipoOperacion
    left join S_Usuario U on T.IdAprobador = U.IdUsuario
    left join CN_CompraDirecta CCN on ff.IdFactura = CCN.IdFactura
    left join S_Proveedor PJ on ff.Receptor = PJ.RFC-- and PJ.IdProveedor in (606, 690)
    left join CO_Registro R on ff.IdFactura = R.IdFactura
    left join Adinco..CO_Instalacion I on R.IdInstalacion = I.IdInstalacion
	
WHERE TAO.IdEstatusOperacion = 2 AND ff2.Receptor IN('JEP1709042B1', 'PEP170906DI5', 'JSE1601292U8')

GROUP BY ff2.IdFactura,     
        ff.UUID,     
        ISNULL(ff2.Serie, ''),     
        ISNULL(ff2.Folio, ''),     
        ff2.UUID,     
        cc.NumeroContrato,     
        TM.TipoMonedaCorto,     
        ff2.MontoConIva,     
        ff2.SubTotal,     
        ff2.Receptor,     
        sp.RazonSocial,     
        ff2.Emisor,     
        TAO.idoperacion,
        PP.IdPedido,
        PP.CreadorEl,
        CASE    
            WHEN DATEDIFF(DAY, PP.CreadorEl, GETDATE()) > 60    
            THEN 'Pedido con MAS DE 60 DIAS'    
            ELSE 'Pedido con MENOS DE 60 DIAS'    
        END,
        E.Nombre,
        TTA.NombreOperacion,
        E.Nombre,         --------------------- Es el mismo estatus que la OC
        CASE WHEN ff.IDFactura = CCN.IdFactura THEN 'Aprobada' ELSE 'Sin Carta' end,
        PJ.RazonSocial,
        R.MontoRegistro,
        I.NombreInstalacion,
        R.Comentarios,
        ff.Fecha
  

UPDATE VCD
	SET Proveedor = SP.RazonSocial
FROM
	VISTA_ComprasDirectas	VCD
JOIN
	dbo.S_Proveedor SP
	ON VCD.RFCProveedor	=	SP.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE
	ISNULL(VCD.Proveedor,'')	=	''

DELETE FROM #Conceptos 
DELETE FROM #FacturaConceptos

INSERT INTO #Conceptos    
(IdFactura,     
 Concepto    
)    
       SELECT cd.idFactura,     
              SUBSTRING(LTRIM(RTRIM(C.Descripcion)), 1, 500)    
       FROM VISTA_ComprasDirectas cd    
            JOIN Adinco.dbo.FI_CFDIConcepto C ON cd.idFactura = C.IdFactura    
       GROUP BY cd.idFactura,     
                SUBSTRING(LTRIM(RTRIM(C.Descripcion)), 1, 500)    
    
INSERT INTO #FacturaConceptos    
(IdFactura,     
 Concepto    
)    
       SELECT IdFactura,     
              SUBSTRING(STUFF(    
       (    
     SELECT '|' + RTRIM(LTRIM(Concepto))    
           FROM #Conceptos A    
           WHERE B.IdFactura = A.IdFactura    
                 AND B.IdFactura = A.IdFactura FOR XML PATH('')    
       ), 1, 1, ''), 1, 8000)    
       FROM #Conceptos B    
     GROUP BY IdFactura    
    
--SE OBTIENE LA FECHA DE APROBACION DE LA COMPRA DIRECTA    
INSERT INTO #FechasAprobacion    
(  
 idoperacion,    
 fechaaprobacion  
)    
    SELECT cd.idoperacion, 
            MAX(tt.FechaCambioEstatus)--,     
    FROM VISTA_ComprasDirectas cd    
        LEFT JOIN dbo.TA_Tarea tt ON cd.idOperacion = tt.IdOperacion    
    GROUP BY cd.idoperacion,     
            tt.FechaCambioEstatus    
    
--SE ACTUALIZAN LAS FECHAS    
UPDATE cd    
  SET     
      cd.FechaAprobacionFactura = fa.fechaaprobacion    
FROM  
 VISTA_ComprasDirectas cd (NOLOCK)
JOIN  
 #FechasAprobacion FA   
 ON FA.idOperacion = cd.idoperacion    
    
-- SE ACTUALIZA EL CONCEPTO CONCATENADO     
UPDATE cd    
  SET     
      ConceptoFactura = FC.Concepto    
FROM  
 VISTA_ComprasDirectas cd  (NOLOCK)
JOIN  
 #FacturaConceptos FC  
 ON cd.idFactura = FC.IdFactura    

 ---------------------------------------------------------------------------------------------------------
 --Factura ligada directamente a la transferencia    
UPDATE VCD    
SET EstatusPago = 'Pagado',  
 CuentaOrigen = ISNULL(CtaO.NumeroCuenta, ''),    
 CuentaDestino = ISNULL(CtaD.NumeroCuenta, ''),    
 FechaTransferencia = TRANS.FechaPago,    
 MontoTransfer = TRANS.MontoPagado,    
 MontoTransferFactura = TRFAC.MontoPagado,    
 MonedaTransfer = MTRANS.TipoMonedaCorto,    
 FechaRegistroTransferencia = TRANS.CreadoEn    
FROM    
 VISTA_ComprasDirectas VCD    
JOIN    
 Adinco.dbo.FI_TransferFactura TRFAC (NOLOCK)
 ON VCD.IdFactura = TRFAC.IdFactura    
JOIN    
 Adinco.dbo.FI_Transfer TRANS (NOLOCK)
 ON TRFAC.IdTransfer = TRANS.IdTransferencia    
JOIN    
 Adinco.dbo.PV_TipoMoneda MTRANS (NOLOCK)  
 ON TRANS.IdMoneda = MTRANS.IdMoneda    
JOIN    
 Adinco.dbo.PV_CuentaBancaria CtaO (NOLOCK)  
 ON TRANS.IdCuentaOrigen = CtaO.DatoBancarioID    
JOIN    
 Adinco.dbo.PV_CuentaBancaria CtaD (NOLOCK)  
 ON TRANS.IdCuentaDestino = CtaD.DatoBancarioID    
    
--Factura ligada a traves del complemento    
UPDATE VCD    
SET EstatusPago = 'Pagado con complemento',   
 CuentaOrigen = ISNULL(CtaO.NumeroCuenta, ''),    
 CuentaDestino = ISNULL(CtaD.NumeroCuenta, ''),    
 FechaTransferencia = TRANS.FechaPago,    
 MontoTransfer = TRANS.MontoPagado,    
 MontoTransferFactura = DR.ImpPagado ,    
 MonedaTransfer = MTRANS.TipoMonedaCorto,    
 FechaRegistroTransferencia = TRANS.CreadoEn    
FROM    
 VISTA_ComprasDirectas VCD    
JOIN    
 Adinco.dbo.FI_Factura ff (NOLOCK)   
 ON  VCD.IdFactura = ff.IdFactura    
JOIN    
 Adinco.dbo.FI_CPDocRelacionado DR   (NOLOCK)  
 ON ff.UUID =  DR.IdDocumento COLLATE Modern_Spanish_CI_AS    
JOIN  
 Adinco.dbo.FI_ComplementoDePago CPago (NOLOCK)  
 ON Cpago.IdComplementoDePago = DR.IdComplementoDePago    
JOIN    
 Adinco.dbo.FI_TransferFactura TRFAC (NOLOCK)  
 ON Cpago.IdFactura =  TRFAC.IdFactura    
JOIN    
 Adinco.dbo.FI_Transfer TRANS (NOLOCK)  
 ON TRFAC.IdTransfer = TRANS.IdTransferencia    
JOIN    
 Adinco.dbo.PV_TipoMoneda MTRANS (NOLOCK)  
 ON TRANS.IdMoneda = MTRANS.IdMoneda    
JOIN    
 Adinco.dbo.PV_CuentaBancaria CtaO (NOLOCK)  
 ON TRANS.IdCuentaOrigen = CtaO.DatoBancarioID    
JOIN    
 Adinco.dbo.PV_CuentaBancaria CtaD (NOLOCK)  
 ON TRANS.IdCuentaDestino = CtaD.DatoBancarioID    
WHERE EstatusPago IS NULL    
    
    
UPDATE VISTA_ComprasDirectas    
 SET EstatusPago = 'NO Pagado'     
WHERE EstatusPago IS NULL    
    
UPDATE VISTA_ComprasDirectas    
SET    
    EstatusFactura = 'No se ha realizado ninguna aprobación de factura'    
WHERE    
 EstatusFactura IS NULL   
    
UPDATE VCD    
 SET FechaRegistroTransferencia = TTFFCP.CreadoEn,    
  MontoTransfer = TTFFCP.MontoPagado,    
  MontoTransferFactura = CPDR.ImpPagado,    
  MonedaTransfer = MTTFFCP.TipoMonedaCorto,    
  UUID_C = FCP.UUID,    
  EstatusPago = 'Pagado CON COMPLEMENTO',    
  FechaTransferencia = TTFFCP.FechaPago    
FROM     
 VISTA_ComprasDirectas VCD    
JOIN    
 Adinco.dbo.FI_Factura FP    
 ON VCD.IdFactura = FP.IdFactura    
JOIN    
 Adinco.DBO.FI_CPDocRelacionado CPDR (NOLOCK)  
 ON FP.UUID = CPDR.IdDocumento COLLATE SQL_Latin1_General_CP1_CI_AS    
JOIN    
 Adinco.dbo.FI_ComplementoDePago CP (NOLOCK)   
 ON CPDR.IdComplementoDePago = CP.IdComplementoDePago    
JOIN    
 Adinco.dbo.FI_Factura FCP (NOLOCK)   
 ON CP.IdFactura = FCP.IdFactura     
 AND FCP.IdContrato <> 3    
JOIN    
 Adinco.dbo.FI_TransferFactura TFFCP (NOLOCK)   
 ON FCP.IdFactura = TFFCP.IdFactura    
JOIN    
 Adinco.dbo.FI_Transfer TTFFCP (NOLOCK)   
 ON TFFCP.IdTransfer = TTFFCP.IdTransferencia    
JOIN    
 Adinco.dbo.PV_TipoMoneda MTTFFCP (NOLOCK)   
 ON TTFFCP.IdMoneda = MTTFFCP.IdMoneda    
    
UPDATE VCD    
 SET     
  MetodoPago = CASE       
                WHEN REPLACE(F.MetodoPago, 'Ó', 'O') LIKE '%SOL%'          
        OR F.MetodoPago LIKE '%PUE%'         
     OR REPLACE(F.FormaPago, 'Ó', 'O') LIKE '%SOL%'     
     OR F.FormaPago LIKE '%PUE%'      
     OR F.MetodoPago LIKE '%CONTADO%'   
     OR F.FormaPago LIKE '%CONTADO%'        
     OR F.MetodoPago LIKE '%UNA%'           
     OR F.FormaPago LIKE '%UNA%'            
     THEN 'PUE'          
       WHEN F.MetodoPago IS NULL     
          AND F.FormaPago IS NULL        
               THEN ''             
      ELSE 'PPD'    
      end    
FROM     
 VISTA_ComprasDirectas VCD    
JOIN    
 adinco.dbo.FI_Factura F    
 ON VCD.idfactura = F.IdFactura    
    
    
UPDATE VCD   
 SET   EstatusPago = 'Pagado SIN COMPLEMENTO'    
FROM     
 VISTA_ComprasDirectas  VCD
/*JOIN    
 adinco.dbo.FI_Factura FP    
 ON VCD.idfactura = FP.IdFactura  */
WHERE  
 VCD.metodopago = 'PPD'  AND VCD.estatuspago = 'Pagado' 

 /************Modificado por HV 07/07/2020 ticket #6243 *******************************************/
/*************** VISTA FACTURAS COMPRA DIRECTA **************************************/  
  
  
/**************  VISTA DE PEDIDOS CON DETALLES DE INSTALACIONES ******** CAPRICHO DE MARILU ***********/  
TRUNCATE TABLE EstatusPedidosJaguar_Detalle  

INSERT INTO EstatusPedidosJaguar_Detalle  
(  
	IdConsecutivo,  
	IdConsecutivoVista,  
	IdContrato,  
	Contrato,  
	IdPedido,  
	OrdenCompra,  
	SolicitudPedido,  
	CreadoEl,  
	DiasPedido,  
	Proveedor,  
	CorreoProveedor,  
	RFC,  
	Estado,  
	Version,  
	Moneda,  
	TipoPedido,  
	Aprobadores,  
	EstatusAprobador,  
	IdEstatus,  
	EstatusFactura,  
	EstatusPago,  
	Factura,  
	EstatusRecepcionServicio,  
	EstatusCN,  
	Entidad_Jaguar,  
	CuentaOrigen,  
	CuentaDestino,  
	FechaRegistroTranferencia,  
	MontoTransfer,  
	MontoTransferFactura,  
	MonedaTransfer,  
	MontoTotalOrdenCompra,  
	Instalaciones,  
	Motivo,  
	PedidoCancelado,  
	MontoAceptacion,  
	DiasCredito,  
	FechaPagoSegunDiasCredito,  
	FechaIngreso,  
	UUIDFactura,  
	UUIDComplemento,  
	UltimaFechaAprobaciones,  
	FechaTransferencia,  
	FechaCotizacion,  
	FechaAprobacionOC,  
	FechaAprobacionCartaCN,  
	FechaAprobacionFactura,  
	FechaFactura,  
	RecepcionServicio,  
	IdOperacion,  
	IdProveedor,  
	IdFactura,  
	IdAceptacionFactura,  
	IdAceptacionPedido,  
	IdFacturaAdinco,  
	IdProveedorCompras,  
	UUID_Adinco,  
	Actividad,  
	Subactividad,  
	Tarea,  
	MetodoPago,  
	TotalFactura,  
	ConceptoFactura,  
	SubTotalFactura,  
	Instalacion,  
	Servicio,
	ADN
)  
SELECT DISTINCT  
	V.IdConsecutivo,  
	V.IdConsecutivoVista,  
	V.IdContrato,  
	V.Contrato,  
	V.IdPedido,  
	V.OrdenCompra,  
	V.SolicitudPedido,  
	V.CreadoEl,  
	V.DiasPedido,  
	V.Proveedor,  
	V.CorreoProveedor,  
	V.RFC,  
	V.Estado,  
	V.Version,  
	V.Moneda,  
	V.TipoPedido,  
	V.Aprobadores,  
	V.EstatusAprobador,  
	V.IdEstatus,  
	V.EstatusFactura,  
	V.EstatusPago,  
	V.Factura,  
	V.EstatusRecepcionServicio,  
	V.EstatusCN,  
	V.Entidad_Jaguar,  
	V.CuentaOrigen,  
	V.CuentaDestino,  
	V.FechaRegistroTranferencia,  
	V.MontoTransfer,  
	V.MontoTransferFactura,  
	V.MonedaTransfer,  
	V.MontoTotalOrdenCompra,  
	V.Instalacion,  
	V.Motivo,  
	V.PedidoCancelado,  
	V.MontoAceptacion,  
-- SE COMENTAS PARA EN EL DETALLE DEL PEDIDO TOMAR LOS DIAS DE CREDITO DE MM_PEDIDODETALLE, COMO EXISTEN NULOS EN ESE CAMPO, SE PONE ISNULL PARA MOSTRAR LOS DIAS DE CREDITO DEL PEDIDO
	--V.DiasCredito,  
	ISNULL(PD.DiasCredito,V.DiasCredito),
	V.FechaPagoSegunDiasCredito,  
	V.FechaIngreso,  
	V.UUIDFactura,  
	V.UUIDComplemento,  
	V.UltimaFechaAprobaciones,  
	V.FechaTransferencia,  
	V.FechaCotizacion,  
	V.FechaAprobacionOC,  
	V.FechaAprobacionCartaCN,  
	V.FechaAprobacionFactura,  
	V.FechaFactura,  
	V.RecepcionServicio, 
	V.IdOperacion,  
	V.IdProveedor,  
	V.IdFactura,  
	V.IdAceptacionFactura,  
	V.IdAceptacionPedido,  
	V.IdFacturaAdinco,  
	V.IdProveedorCompras,  
	V.UUID_Adinco,  
	V.Actividad,  
	V.Subactividad,  
	V.Tarea,  
	V.MetodoPago,  
	V.TotalFactura,  
	V.ConceptoFactura,  
	V.SubTotalFactura,  
	I.NombreInstalacion,  
	S.NombreServicio,
	SPD.observaciones
FROM
	#VistaFinal V
JOIN
	MM_Pedido	P	(NOLOCK)
	ON	V.IdPedido	=	P.IdPedido
JOIN  
	MM_AceptacionPedidoDetalle APD	(NOLOCK)
	ON V.IdAceptacionPedido = APD.IdAceptacionPedido
	AND ISNULL(APD.IdEstatusEliminado,0)	=	0  
JOIN
	MM_PedidoDetalle AS PD (NOLOCK)
    ON V.IdPedido = PD.IdPedido
    AND APD.IdPedidoDetalle = PD.IdPedidoDetalle
JOIN
	dbo.MM_PeticionOfertaDetalle POD (NOLOCK)
    ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
    AND P.IdPeticionOferta = POD.IdPeticionOferta
JOIN
	dbo.MM_SolicitudPedidoDetalle SPD (NOLOCK)
    ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
    AND V.SolicitudPedido = SPD.IdSolicitudPedido
JOIN  
	MM_AceptacionPedidoDetalleInstalacion APDI  (NOLOCK)
	ON APD.IdAceptacionPedido = APDI.IdAceptacionPedido  
	AND APD.IdAceptacionPedidoDetalle = APDI.IdAceptacionPedidoDetalle  
	AND APD.IdPedidoDetalle = APDI.IdPedidoDetalle  
JOIN  
	Adinco.dbo.CO_Instalacion I (NOLOCK)
	ON APDI.IdInstalacion = I.IdInstalacion  
JOIN  
	Adinco.dbo.CO_LineaPresupuestoMes LPM (NOLOCK)
	ON APDI.IdLineaPresupuesto = LPM.IdLineaPresupuestoMes  
JOIN  
	Adinco.dbo.CO_Servicio S  (NOLOCK)
	ON LPM.IdServicio = S.IdServicio  
WHERE   
	ISNULL(APD.IdEstatusEliminado,0)=0  
ORDER BY  
	V.IdConsecutivo, V.IdPedido, V.IdAceptacionPedido, I.NombreInstalacion 

IF (DATEPART(HOUR, GETDATE()) % 2) = 0
BEGIN
	EXEC dbo.sp_BI_LlenaTabla_BI_Aprobaciones
	EXEC dbo.sp_BI_LlenaTabla_BI_Requisicion
	EXEC dbo.sp_BI_LlenaTabla_BI_Oferta
	EXEC dbo.sp_BI_LlenaTabla_BI_Pedido
	EXEC dbo.sp_BI_LlenaTabla_BI_Recepcion
	EXEC dbo.sp_BI_LlenaTabla_BI_Facturas    
	EXEC dbo.sp_BI_LlenaTabla_BI_AvancePedido  
END

END