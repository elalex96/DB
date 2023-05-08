-- =============================================
-- Author:	Daniel AC
-- Create date: <30/08/2022>
-- Description:	<Consulta de detalle del flujo de las SAS>
-- =============================================
CREATE PROCEDURE dbo.APP_GenerarReporteTransacciones
AS
BEGIN
SET NOCOUNT ON;

BEGIN TRY

CREATE TABLE #Contratos(
ContratoId INT  PRIMARY KEY
)
CREATE NONCLUSTERED INDEX ix_tempContratos ON #Contratos (ContratoId);

CREATE TABLE #SolicitudPedidos(
IdSolicitudPedido INT, 
IdOperacion INT, 
DetalleRegistro VARCHAR(150), 
Solicitante VARCHAR(100), 
Estatus VARCHAR(100),
FechaAlta DATETIME,
DetalleAprobador1 VARCHAR(200),
DetalleAprobador2 VARCHAR(200),
DetalleComprador VARCHAR(200),
CentroCosto VARCHAR(300))
CREATE NONCLUSTERED INDEX ix_tempSolicitudPedidosIdSolicitudPedido ON #SolicitudPedidos (IdSolicitudPedido);
CREATE NONCLUSTERED INDEX ix_tempSolicitudPedidosIdOperacion ON #SolicitudPedidos (IdOperacion);


CREATE TABLE #Cotizaciones(
SolicitudPedidoId INT, 
EnvioCotizacion VARCHAR(200),
FinalizacionCotizacion VARCHAR(200))
CREATE NONCLUSTERED INDEX ix_tempCotizacionesSolicitudPedidoId ON #Cotizaciones (SolicitudPedidoId);

CREATE TABLE #Pedidos(
IdPedido INT, 
IdSolicitudPedido INT, 
DetalleNoPedido VARCHAR(150), 
ContratoId INT,
IdOperacion INT, 
DetalleRegistro VARCHAR(150), 
EstatusRelacionPO VARCHAR(150), 
NumPO VARCHAR(100),
Estatus VARCHAR(100),
EstatusConfirmacion VARCHAR(200),
FechaRegistro DATETIME,
DetalleAprobador1 VARCHAR(200),
DetalleAprobador2 VARCHAR(200),
Proveedor VARCHAR(150))
CREATE NONCLUSTERED INDEX ix_tempPedidosIdSolicitudPedido ON #Pedidos (IdSolicitudPedido);
CREATE NONCLUSTERED INDEX ix_tempPedidosIdPedido ON #Pedidos (IdPedido);
CREATE NONCLUSTERED INDEX ix_tempPedidosIdOperacion ON #Pedidos (IdOperacion);


CREATE TABLE #AceptacionPedidos(
PedidoId INT, 
AceptacionPedidoId INT,
PedirCarta BIT,
FechaPedirCarta DATETIME,
FechaRegistro DATETIME
)
CREATE NONCLUSTERED INDEX ix_tempAceptacionPedidosPedidoId ON #AceptacionPedidos(PedidoId);
CREATE NONCLUSTERED INDEX ix_tempAceptacionPedidosAceptacionPedidoId ON #AceptacionPedidos(AceptacionPedidoId);

CREATE TABLE #SAS(
SolicitudAceptacionPedidoId INT, 
PedidoId INT, 
Bloque VARCHAR(150), 
AceptacionPedidoId INT, 
IdOperacion INT,
DetalleRegistro VARCHAR(150),
AprobadorSolitante VARCHAR(150),
EstatusSolitante VARCHAR(100),
AprobadorOBS VARCHAR(150),
EstatusOBS VARCHAR(100),
)
CREATE NONCLUSTERED INDEX ix_tempSAS ON #SAS (SolicitudAceptacionPedidoId);
CREATE NONCLUSTERED INDEX ix_tempSASPedidoId ON #SAS (PedidoId);
CREATE NONCLUSTERED INDEX ix_tempSASIdOperacion ON #SAS (IdOperacion);


CREATE TABLE #AceptacionCartaCN (
IdAceptacionCartaCN INT, 
IdAceptacionPedido INT, 
CreadoPor INT, 
CreadoEl DATETIME, 
IdEstatus INT, 
IdUsuarioEvaluador INT, 
FechaEvaluacion DATETIME,
Estatus  VARCHAR(100),
UsuarioEvaluador VARCHAR(150))
CREATE NONCLUSTERED INDEX ix_tempAceptacionCartaCNIdAceptacionCartaCN ON #AceptacionCartaCN (IdAceptacionCartaCN);
CREATE NONCLUSTERED INDEX ix_tempAceptacionCartaCNIdAceptacionPedido ON #AceptacionCartaCN (IdAceptacionPedido);
CREATE NONCLUSTERED INDEX ix_tempAceptacionCartaCNIdEstatus ON #AceptacionCartaCN (IdEstatus);


CREATE TABLE #AceptacionFactura(
AceptacionPedidoId INT, 
AceptacionFacturaId INT,
IdOperacion INT, 
EstatusId VARCHAR(100), 
DetalleRegistro VARCHAR(100), 
Estatus VARCHAR(100),
FechaAlta DATETIME,
DetalleAprobador1 VARCHAR(150),
DetalleAprobador2 VARCHAR(150),
EstatusAprobador1 VARCHAR(150),
EstatusAprobador2 VARCHAR(150))
CREATE NONCLUSTERED INDEX ix_tempAceptacionFacturaAceptacionPedidoId ON #AceptacionFactura (AceptacionPedidoId);
CREATE NONCLUSTERED INDEX ix_tempAceptacionFacturaAceptacionFacturaId ON #AceptacionFactura (AceptacionFacturaId);
CREATE NONCLUSTERED INDEX ix_tempAceptacionFacturaIdOperacion ON #AceptacionFactura (IdOperacion);
CREATE NONCLUSTERED INDEX ix_tempAceptacionFacturaEstatusId ON #AceptacionFactura (EstatusId);

-- CONTRATOS WDEA
INSERT INTO #Contratos(ContratoId)
VALUES (10038), --> CNH-A4.OGARRIO/2018
    (10044), --> CNH-R03-L01-G-TMV-02/2018
    (10045), --> CNH-R03-L01-G-TMV-03/2018
    (10046), --> CNH-R03-L01-AS-CS-14/2018
    (10145) -->  CNH-WD ADMIN

-- BUSCAR SAS
INSERT INTO #SAS(
SolicitudAceptacionPedidoId, 
PedidoId,
IdOperacion,
DetalleRegistro,
AceptacionPedidoId,
Bloque)
SELECT 
SAS.IdSolicitudAceptacionPedido, 
SAS.IdPedido, 
TAO.IdOperacion, 
CONCAT(PRSAS.RazonSocial, ' ' , SAS.CreadoEl),
SAS.IdAceptacionPedido,
CO.NumeroContrato
FROM #Contratos C
JOIN Adinco..CO_Contrato CO  (NOLOCK)
	ON C.ContratoId = CO.IdContrato 
JOIN MM_Pedido P  (NOLOCK)
	ON C.ContratoId =  P.IdContrato
JOIN S_Proveedor PC  (NOLOCK)
	ON P.IdProveedorCompras = PC.IdProveedor
	AND PC.RFC='DDE151002QY9'  --> CTE Wintershall Dea Mexico S. de R.L. de C.V.
JOIN MM_SolicitudAceptacionPedido SAS (NOLOCK)
	ON  P.IdPedido  = SAS.IdPedido  
	AND SAS.Activo =  1 --> CTE SAS ACTIVA
	AND CAST(SAS.CreadoEl AS DATE) >= CAST('2022-04-26 00:00:00.000' AS DATE)
JOIN TA_Operacion TAO (NOLOCK)
	ON SAS.IdSolicitudAceptacionPedido = TAO.IdDocumento
	AND TAO.IdTipoOperacion = 20 --> CTE APROBACIÓN SAS
    AND TAO.IdEliminado IS NULL	
JOIN S_Proveedor AS PRSAS (NOLOCK)
	ON SAS.IdProveedorVenta = PRSAS.IdProveedor
GROUP BY 
SAS.IdSolicitudAceptacionPedido, 
SAS.IdPedido, 
TAO.IdOperacion, 
PRSAS.RazonSocial, 
SAS.CreadoEl,
SAS.IdAceptacionPedido,
CO.NumeroContrato


-- APROBADOR SOLICITANTE DE LA SAS
UPDATE  SAS
SET SAS.AprobadorSolitante = CONCAT('SAS: ',SAS.SolicitudAceptacionPedidoId , ' ', U.Nombre, ' ', TA.FechaCambioEstatus, ' ', EST.Nombre) ,
SAS.EstatusSolitante = EST.Nombre 
FROM #SAS SAS   	
  JOIN TA_Tarea TA (NOLOCK)
	  ON SAS.IdOperacion =  TA.IdOperacion
	  AND TA.Activo = 1 --> CTE TAREA ACTIVA
	  AND TA.IdEliminado IS NULL
	  AND ISNULL(TA.NoSecuencia,1) = 1 --> SOLO PRIMER APROBADOR , PARA HISTORICO SI NO TIENE NO SECUENCIA POR DEFAUL PONERLO COMO 1
  JOIN S_Usuario U (NOLOCK)
		on TA.IdAprobador =  U.IdUsuario
  JOIN TA_Estatus EST (NOLOCK)
		on TA.IdEstatus =  EST.IdEstatus

-- APROBADOR OBS DE LA SAS
UPDATE  SAS
SET SAS.AprobadorOBS = CONCAT('SAS: ',SAS.SolicitudAceptacionPedidoId , ' ', U.Nombre, ' ', TA.FechaCambioEstatus, ' ', EST.Nombre) ,
	SAS.EstatusOBS = EST.Nombre
  FROM #SAS SAS
  JOIN TA_Tarea TA (NOLOCK)
  ON SAS.IdOperacion =  TA.IdOperacion
  AND TA.Activo = 1
  AND Ta.IdEliminado IS NULL
  AND TA.NoSecuencia = 2
  JOIN S_Usuario U (NOLOCK)
  on TA.IdAprobador =  U.IdUsuario
  JOIN TA_Estatus EST (NOLOCK)
  on TA.IdEstatus =  EST.IdEstatus


-- BUSCAR PEDIDOS 
INSERT INTO #Pedidos(
IdPedido, 
IdSolicitudPedido,
DetalleNoPedido, 
IdOperacion, 
DetalleRegistro, 
Estatus,
EstatusConfirmacion,
Proveedor)
SELECT 
P.IdPedido,
P.IdSolicitudPedido,
CONCAT (PS.IdPedido,  ' ( V. ', P.Version ,')'),
PTAO.IdOperacion,
CONCAT(PSU.Nombre,' ',PS.CreadorEl),
CONCAT ('OC : ',PEST.Nombre),
CASE ISNULL(P.FechaRecepcionServicio, 0) WHEN 0 THEN 'Pendiente Confirmacion del proveedor' 
ELSE CONCAT( POP.RazonSocial, ', ',  P.FechaRecepcionServicio) END,
POP.RazonSocial
FROM #SAS SAS
JOIN MM_Pedido P  (NOLOCK)
	ON  SAS.PedidoId  = P.IdPedido
JOIN S_Proveedor POP (NOLOCK)
	ON P.IdSubcontratista = POP.IdProveedor	
JOIN MM_Pedidos PS (NOLOCK)
	ON P.IdPedido = PS.IdIdentificador
	AND P.IdProveedorCompras = PS.IdProveedorCliente
	AND PS.IdTipoPedido IN (2,4) --> CTES TIPOS DE PEDIDO	(MERCADEO Y AD DIRECTA)
JOIN S_usuario PSU (NOLOCK)
	ON P.CreadoPor = PSU.IdUsuario
JOIN TA_Operacion PTAO (NOLOCK)
	ON P.IdSolicitudPedido =  PTAO.IdDocumento 	
	AND P.Version =PTAO.NoVersion 
	AND PTAO.IdTipoOperacion =  9   --CTE APROBACIONES DE PEDIDO
	AND PTAO .IdEliminado IS NULL -- Operacion no eliminada
JOIN TA_Estatus PEST (NOLOCK)
	ON PTAO .IdEstatusOperacion =  PEST.IdEstatus
GROUP BY  
P.IdPedido,
P.IdSolicitudPedido,
PS.IdPedido,
P.Version,
PTAO.IdOperacion,
PSU.Nombre,
PS.CreadorEl,
PEST.Nombre,
P.FechaRecepcionServicio,
POP.RazonSocial,  
P.FechaRecepcionServicio,
POP.RazonSocial

-- ACTUALIZAR DETALLE DE RELACION DE PO
UPDATE  P
SET P.EstatusRelacionPO = CONCAT(RPO.FechaAltaRelacion, ' ', RPOUS.Nombre),
P.NumPO= RPO.PO
FROM #Pedidos P
JOIN DEA_Relacion_PR_PO AS RPO (NOLOCK)
	ON P.IdPedido = RPO.IdPedido 
	AND RPO.Activo = 1
JOIN S_Usuario AS RPOUS (NOLOCK)
	ON RPO.CreadoPor = RPOUS.IdUsuario

-- ACTUALIZAR APROBADOR PEDIDO
UPDATE  P
SET P.DetalleAprobador1=CONCAT(PTAU1.Nombre, ' ', PTA1.FechaCambioEstatus)
FROM #Pedidos P
JOIN TA_Tarea  PTA1  (NOLOCK)
	ON P.IdOperacion = PTA1.IdOperacion  -- 1er aprobador
	AND PTA1.Activo= 1 
	AND PTA1.NoSecuencia= 1 -- 1er aprobador
JOIN S_Usuario PTAU1 (NOLOCK)
	ON PTA1.IdAprobador = PTAU1.IdUsuario	
	

-- BUSCAR SOLPEDS	
INSERT INTO #SolicitudPedidos(IdSolicitudPedido,IdOperacion,DetalleRegistro, Solicitante,Estatus, FechaAlta)
SELECT
	SP.IdSolicitudPedido,
	SPTAO.IdOperacion,	
	CONCAT(USP.Nombre, ' ', SP.FechaAlta),
	USS.Nombre,
	CONCAT ('SOLPED :' ,SPEST.Nombre),
	SP.FechaAlta
FROM #Pedidos P
JOIN MM_SolicitudPedido AS SP (NOLOCK)
	ON P.IdSolicitudPedido = SP.IdSolicitudPedido 	
JOIN S_Usuario USP (NOLOCK)
	ON SP.IdUsuarioSolicitante = USP.IdUsuario 
JOIN TA_Operacion SPTAO (NOLOCK)
	ON SP.IdSolicitudPedido =  SPTAO.IdDocumento --OPERACIONES DE SOLICITUDES DE PEDIDO
	AND SPTAO.IdTipoOperacion =  2 --> CTE SOLPED
	AND SPTAO .IdEliminado IS NULL -- Operacion no eliminada
JOIN TA_Estatus SPEST (NOLOCK)
	ON SPTAO.IdEstatusOperacion =  SPEST.IdEstatus
LEFT JOIN S_Usuario AS USS (NOLOCK)
	ON SP.Solicitante = USS.IdUsuario	
GROUP BY
SP.IdSolicitudPedido,	
	SPTAO.IdOperacion,	
	USP.Nombre,  
	SP.FechaAlta,
	USS.Nombre,
	SPEST.Nombre,
	SP.FechaAlta

-- PRIMER APROBADOR DE SOLPED 
UPDATE SP
SET SP.DetalleAprobador1 = CASE WHEN SPTA1.IdEstatus=2 THEN CONCAT(SPTAU1.Nombre, ' ', SPTA1.FechaCambioEstatus) ELSE 'SOLPED PENDIENTE DE APROBAR(1)' END
FROM #SolicitudPedidos SP
JOIN TA_Tarea  SPTA1  (NOLOCK) 
	ON SP.IdOperacion = SPTA1.IdOperacion  -- 1ER APROBADOR
	AND SPTA1.Activo= 1 
	AND SPTA1.NoSecuencia= 1 -- 1er aprobador
JOIN S_Usuario SPTAU1 (NOLOCK)
ON SPTA1.IdAprobador = SPTAU1.IdUsuario

-- SEGUNDO APROBADOR DE SOLPED 
UPDATE SP
SET SP.DetalleAprobador2 = CASE WHEN SPTA2.IdEstatus=2 THEN CONCAT(SPTAU2.Nombre, ' ', SPTA2.FechaCambioEstatus) ELSE 'SOLPED PENDIENTE DE APROBAR(2)' END
FROM #SolicitudPedidos SP
JOIN TA_Tarea  SPTA2  (NOLOCK)
	ON SP.IdOperacion = SPTA2.IdOperacion 
	AND SPTA2.Activo= 1 
	AND SPTA2.NoSecuencia= 2 -- 2r aprobador
JOIN S_Usuario SPTAU2 (NOLOCK)
	ON SPTA2.IdAprobador = SPTAU2.IdUsuario

-- COMPRADOR SOLPED 
UPDATE SP
SET SP.DetalleComprador = CONCAT (SPCU.Nombre , ' ', SPC.CreadoEl)
FROM #SolicitudPedidos SP
JOIN MM_SolicitudPedidoComprador SPC (NOLOCK)
	ON SP.IdSolicitudPedido = SPC.IdSolicitudPedido
	AND SPC.Activo =  1
JOIN S_usuario SPCU (NOLOCK)
	ON SPC.IdAsignadoA =  SPCU.IdUsuario

-- BUSCAR DETALLES DE LAS COTIZACIONES
INSERT INTO #Cotizaciones(SolicitudPedidoId,EnvioCotizacion,FinalizacionCotizacion)
SELECT SP.IdSolicitudPedido,
CONCAT(POU.Nombre, ' ', PO.CreadoEl),
CONCAT(POP.RazonSocial, ' ', PO.FechaFinalizado)
FROM #SolicitudPedidos SP
JOIN MM_PeticionOferta PO (NOLOCK)
	ON SP.IdSolicitudPedido =  PO.IdSolicitudPedido
	AND PO.Activo =  1
JOIN S_usuario POU (NOLOCK)
	ON PO.CreadoPor =  POU.IdUsuario
JOIN S_Proveedor POP (NOLOCK)
	ON PO.IdSubcontratista = POP.IdProveedor
GROUP BY 
SP.IdSolicitudPedido,
POU.Nombre, 
PO.CreadoEl,
POP.RazonSocial, 
PO.FechaFinalizado
	
-- BUSCAR ACEPTACIONES RELACIONADAS A LAS SAS
INSERT INTO #AceptacionPedidos(PedidoId,AceptacionPedidoId,PedirCarta,FechaPedirCarta,FechaRegistro)
SELECT AP.IdPedido, AP.IdAceptacionPedido, RCN.PedirCarta,RCN.FechaCreacion, AP.Creado
FROM #SAS SAS  
JOIN MM_AceptacionPedido AP (NOLOCK)
	ON SAS.AceptacionPedidoId = AP.IdAceptacionPedido
JOIN RelacionCartaCNPedido AS RCN (NOLOCK)
	ON AP.IdAceptacionPedido=RCN.IdAceptacionPedido
WHERE AP.Activo = 1

-- DETALLE DE LA CARTA DE CN -- OBTENER PRIMERO LA CN MAS RECIENTE POR ACEPTACION DE PEDIDO
INSERT INTO #AceptacionCartaCN (IdAceptacionPedido,IdAceptacionCartaCN)
SELECT AP.AceptacionPedidoId,
       MAX(ACN.IdAceptacionCartaPCN)
FROM #AceptacionPedidos AP
JOIN MM_AceptacionCartaPCN AS ACN (NOLOCK)
        ON AP.AceptacionPedidoId = ACN.IdAceptacionPedido
WHERE  ACN.Activo = 1
GROUP BY AP.AceptacionPedidoId;

-- DETALLE DE LAS VERSION FINAL DE CN
UPDATE CN	
SET CN.CreadoPor = T1.CreadoPor,
	CN.CreadoEl = T1.CreadoEl,
	CN.IdEstatus = T1.IdEstatus,
	CN.IdUsuarioEvaluador = T1.IdUsuarioEvaluador,
	CN.FechaEvaluacion = T1.FechaEvaluacion,
	CN.Estatus = ECN.Nombre,
	CN.UsuarioEvaluador = USCN.Nombre
FROM #AceptacionCartaCN CN 
JOIN MM_AceptacionCartaPCN AS T1 (NOLOCK)
	ON  CN.IdAceptacionCartaCN = T1.IdAceptacionCartaPCN 
JOIN TA_Estatus AS ECN (NOLOCK)
	ON T1.IdEstatus = ECN.IdEstatus
LEFT JOIN S_Usuario AS USCN  (NOLOCK)
	ON T1.IdUsuarioEvaluador = USCN.IdUsuario
	   
-- OBTENER APROBACIONES DE FACTURA
INSERT INTO #AceptacionFactura(AceptacionPedidoId,AceptacionFacturaId,IdOperacion,EstatusId,FechaAlta)
SELECT AF.IdAceptacionPedido, AF.IdAceptacionFactura,AFO.IdOperacion ,AFO.IdEstatusOperacion,AF.ModificadoEl
FROM #AceptacionPedidos AP 
JOIN MM_AceptacionFactura AS AF (NOLOCK)
	ON AP.AceptacionPedidoId = AF.IdAceptacionPedido
JOIN TA_Operacion AS AFO (NOLOCK)
	ON AF.IdAceptacionFactura = AFO.IdDocumento 
	AND AFO.IdTipoOperacion = 10 --> CTE APROBACIÓN FACTURA
	AND ISNULL(AFO.IdEstatusEliminado, 0) <> 1 
	
-- PRIMER APROBADOR DE FACTURA
UPDATE 	AF
SET AF.DetalleAprobador1 = CONCAT(US.Nombre, ' ',T.FechaCambioEstatus),
	AF.EstatusAprobador1 = E.Nombre
FROM #AceptacionFactura AS AF 
JOIN TA_Tarea AS T (NOLOCK)
ON AF.IdOperacion = T.IdOperacion 	
	AND T.NoSecuencia = 1--PRIMER APROBADOR
	AND T.Activo = 1		
JOIN S_Usuario AS US (NOLOCK)
	ON T.IdAprobador = US.IdUsuario
JOIN TA_Estatus AS E (NOLOCK)
	ON T.IdEstatus = E.IdEstatus;


-- SEGUNDO APROBADOR DE FACTURA
UPDATE AF	
SET AF.DetalleAprobador2 = CONCAT(US.Nombre, ' ',T.FechaCambioEstatus),
	AF.EstatusAprobador2 = E.Nombre
FROM #AceptacionFactura AS AF 
	JOIN TA_Tarea AS T (NOLOCK)
	ON AF.IdOperacion = T.IdOperacion 		
		AND T.NoSecuencia = 2--SEGUNDO APROBADOR		
		AND T.Activo = 1
JOIN S_Usuario AS US  (NOLOCK)
	ON T.IdAprobador = US.IdUsuario
JOIN TA_Estatus AS E  (NOLOCK)
	ON T.IdEstatus = E.IdEstatus;

-- DETALLE DE LOS CENTROS DE COSTOS

UPDATE SP
	SET SP.CentroCosto = CC.CentroCosto
FROM #SolicitudPedidos AS SP (NOLOCK)
JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)		
	ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido
JOIN MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP (NOLOCK)
	ON SPD.IdSolicitudPedidoDetalle = SPDLP.IdSolicitudPedidoDetalle
JOIN CC_CentroCosto AS CC  (NOLOCK)
	ON SPDLP.IdCentroCosto = CC.IdCentroCosto

TRUNCATE TABLE APP_TransaccionesProcura
INSERT INTO APP_TransaccionesProcura
           ([Bloque]
           ,[IdSolicitudPedido]
           ,[SPDetalleRegistro]
           ,[SPCentroCosto]
           ,[SPSolicitante]
           ,[SPDetalleAprobador1]
           ,[SPDetalleAprobador2]
           ,[SPEstatus]
           ,[SPComprador]
           ,[EnvioCotizacion]
           ,[FinalizacionCotizacion]
           ,[DetalleNoPedido]
           ,[NumPO]
           ,[PedidoDetalleRegistro]
           ,[PedidoDetalleAprobador1]
           ,[PedidoEstatusRelacionPO]
           ,[PedidoEstatus]
           ,[PedidoEstatusConfirmacion]
           ,[SASDetalleRegistro]
           ,[SASAprobadorSolitante]
           ,[SASAprobadorOBS]
           ,[AceptacionPedido]
           ,[CargaCartaCN]
           ,[AceptacionCartaCN]
           ,[EstatusCartaCN]
           ,[CargaFactura]
           ,[AceptacionFactura]
           ,[AceptacionAP]
		   ,[EstatusFinal]
           ,[PeriodoEnADINCO])
SELECT 
	SAS.Bloque as BLOQUE,
	P.IdSolicitudPedido as SOLPEDS,
	SP.DetalleRegistro as 'Registro de SOLPED (OPERACIONES)',
	SP.CentroCosto AS 'Centros de costo',
	ISNULL(SP.Solicitante,'SOLPED SIN SOLICITANTE ASIGNADO') AS 'Solicitante',
	ISNULL(SP.DetalleAprobador1,'SOLPED  APROBAR(1) - NA') as 'Aprobacion de SOLPED (PROCURA)',
	ISNULL(SP.DetalleAprobador2,'SOLPED  APROBAR(2) - NA') as 'Aprobacion de SOLPED (OPERACIONES)',
	SP.Estatus as 'Estatus SOLPED',
	ISNULL(SP.DetalleComprador,'SOLPED PENDIENTE POR ASIGNAR') as 'Asignacion de comprador (PROCURA)',
	PO.EnvioCotizacion AS 'Envio de solicitud de cotizacion por comprador (PROCURA)',
	PO.FinalizacionCotizacion as 'Proveedor envìa su cotizacion (PROVEEDOR)',
	ISNULL(P.DetalleNoPedido,'PEDIDO NO GENERADO') AS pedido,
	ISNULL(P.NumPO,'PO SIN RELACIONAR') AS NumPO,
	ISNULL(P.DetalleRegistro,'PEDIDO NO GENERADO') as 'Registro el pedido',
	P.DetalleAprobador1 as 'Aprobacion de PEDIDO (PROCURA)',
	P.EstatusRelacionPO AS 'Relacion PO',
	P.Estatus  as  'Estatus de pedido',
	P.EstatusConfirmacion AS  'Confirmacion pedido PROVEEDOR',
	SAS.DetalleRegistro AS 'Solicitud Aceptacion Pedido',
	CASE 
		WHEN ISNULL(SAS.SolicitudAceptacionPedidoId, 0) = 0 THEN 'Pendiente de SAS' 
		WHEN SAS.EstatusSolitante = 'En Aprobación' THEN 'Pendiente de Aprobación Solicitante'
		ELSE ISNULL(SAS.AprobadorSolitante, 'Pendiente de SAS')
	END AS 'SAS Aprobacion Solicitante',
	CASE 
		WHEN ISNULL(SAS.SolicitudAceptacionPedidoId, 0) = 0 THEN 'Pendiente de SAS'  
		WHEN SAS.EstatusSolitante = 'En Aprobación' THEN 'Pendiente Aprobación OBS'
		WHEN SAS.EstatusSolitante = 'Aprobada' AND SAS.EstatusOBS IS NULL THEN 'Pendiente Aprobación OBS'
		WHEN SAS.EstatusSolitante = 'Aprobada' AND SAS.EstatusOBS = 'En Aprobación' THEN 'Pendiente Aprobación OBS'
		WHEN SAS.EstatusSolitante = 'Rechazada' THEN 'Aprobación Rechazada'
		ELSE ISNULL(SAS.AprobadorOBS, 'Pendiente de SAS')
	END as 'SAS Aprobacion OBS',
	CASE 
		WHEN AP.AceptacionPedidoId IS NULL THEN 'Pendiente de Aceptacion de Pedido'
		ELSE CONCAT( 'ACEPTACION: ',AP.AceptacionPedidoId, ' ', AP.FechaRegistro)
	END AS 'Aceptacion de pedido',
	CASE	
		WHEN AP.PedirCarta = 0 THEN CONCAT('CN EXCLUIDO ', AP.FechaPedirCarta)
		WHEN AP.PedirCarta = 1 AND CN.IdAceptacionCartaCN IS NULL THEN 'SIN CARTA CN REGISTRADA'
		WHEN AP.PedirCarta = 1 AND CN.IdAceptacionCartaCN IS NOT NULL THEN CONCAT(CN.CreadoEl,'')
		ELSE 'Pendiente de Aceptacion de Pedido'
	END AS 'Carga de Carta Contenido Nacional',
	CASE	
		WHEN AP.PedirCarta = 0 THEN CONCAT('CN EXCLUIDO ', AP.FechaPedirCarta)
		WHEN AP.PedirCarta = 1 AND CN.IdAceptacionCartaCN IS NULL THEN 'SIN CARTA CN REGISTRADA'
		WHEN AP.PedirCarta = 1 AND CN.IdAceptacionCartaCN IS NOT NULL AND CN.IdEstatus = 1 THEN 'PENDIENTE DE APROBACION'
		WHEN AP.PedirCarta = 1 AND CN.IdAceptacionCartaCN IS NOT NULL AND CN.IdEstatus IN (2,3) THEN CONCAT(CN.UsuarioEvaluador,' ', CN.FechaEvaluacion)
		ELSE 'Pendiente de Aceptacion de Pedido'
	END AS 'Aceptacion de Carta de Contenido Nacional',
	CASE	
		WHEN AP.PedirCarta = 0 THEN CONCAT('CN: CN EXCLUIDO ', AP.FechaPedirCarta)
		WHEN AP.PedirCarta = 1 AND CN.IdAceptacionCartaCN IS NULL THEN 'CN: Pendiente de Carga'
		WHEN AP.PedirCarta = 1 AND CN.IdAceptacionCartaCN IS NOT NULL THEN CONCAT('CN: ',CN.Estatus)
		ELSE 'CN: Pendiente de Aceptacion de Pedido'
	END AS 'Estatus Carta CN',
	CASE
		WHEN AF.AceptacionFacturaId IS NULL OR AF.IdOperacion IS NULL THEN 'PENDIENTE DE REGISTRAR FACTURA'
		WHEN AF.AceptacionFacturaId IS NOT NULL AND AF.EstatusId IS NOT NULL THEN CONCAT(P.Proveedor,' ', AF.FechaAlta)
	END AS 'Carga de Factura',		
	CASE
		WHEN AF.AceptacionFacturaId IS NULL OR AF.IdOperacion IS NULL THEN 'PENDIENTE DE REGISTRAR FACTURA'
		WHEN AF.AceptacionFacturaId IS NOT NULL AND AF.EstatusId = 1 AND AF.EstatusAprobador1 = 'En Aprobación' THEN 'PENDIENTE DE APROBAR FACTURA POR OBS'
		WHEN AF.AceptacionFacturaId IS NOT NULL AND AF.EstatusId != 1 AND AF.EstatusAprobador1 != 'En Aprobación' THEN ISNULL(AF.DetalleAprobador1,'-')
		ELSE
			'-'		 
	END AS 'Aceptacion de Factura',
	CASE
		WHEN AF.AceptacionFacturaId IS NULL OR AF.IdOperacion IS NULL THEN 'PENDIENTE DE REGISTRAR FACTURA'
		WHEN AF.AceptacionFacturaId IS NOT NULL AND AF.EstatusId = 1 AND AF.EstatusAprobador2 = 'En Aprobación' THEN 'PENDIENTE DE APROBAR FACTURA POR FINANZAS'
		WHEN AF.AceptacionFacturaId IS NOT NULL AND AF.EstatusId != 1 AND AF.EstatusAprobador2 != 'En Aprobación' THEN ISNULL(AF.DetalleAprobador2,'-')
		ELSE
			'-'		 
	END AS 'Aceptacion de AP',
	CASE
		WHEN AF.EstatusId = 2 THEN 'COMPLETADO'
		ELSE 'PENDIENTE'
	END AS 'Status',
	DATEDIFF(DAY,SP.FechaAlta,GETDATE()) AS 'Periodo en ADINCO'		
	FROM #SAS SAS  	
	JOIN #Pedidos P
		ON  SAS.PedidoId =  P.IdPedido 	
	JOIN #SolicitudPedidos SP 	
		ON  P.IdSolicitudPedido = SP.IdSolicitudPedido
	JOIN #Cotizaciones PO (NOLOCK)
		on SP.IdSolicitudPedido =  PO.SolicitudPedidoId		
	LEFT JOIN #AceptacionPedidos AP  (NOLOCK)
		on  SAS.AceptacionPedidoId = AP.AceptacionPedidoId  
	LEFT JOIN  #AceptacionCartaCN AS CN 
		ON AP.AceptacionPedidoId = CN.IdAceptacionPedido
	LEFT JOIN #AceptacionFactura AS AF (NOLOCK)
		ON AP.AceptacionPedidoId = AF.AceptacionPedidoId	
		

END TRY
BEGIN CATCH	
	SELECT 'ERROR  ['+ ERROR_MESSAGE() + '] LINEA ['+ CAST(ERROR_LINE() AS VARCHAR)+']';	
END CATCH

END;
