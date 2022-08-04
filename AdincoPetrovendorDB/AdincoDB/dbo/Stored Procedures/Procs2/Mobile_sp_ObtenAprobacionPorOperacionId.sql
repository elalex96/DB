USE [Adinco]
GO
  IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Mobile_sp_ObtenAprobacionPorOperacionId'
)
    DROP PROCEDURE Mobile_sp_ObtenAprobacionPorOperacionId;   
	GO 
/****** Object:  StoredProcedure [dbo].[Mobile_sp_AprobacionesPorUsuario]    Script Date: 02/08/2022 12:25:48 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Danel AC
-- Create date: 02/02/2022
-- Description:	Se obtienen los pedidos por idOperacion
-- =============================================
CREATE  PROCEDURE [dbo].[Mobile_sp_ObtenAprobacionPorOperacionId] 
	@IdUsuario		INT,
	@IdTipo			INT,
	@IdOperacion	int	
AS
BEGIN 
	declare @PROVEDORRFC NVARCHAR(20),
			@SIGAPROBADOR INT,
			@TipoFlujoId int,			
			@IdUsuarioP int,
			@IdEstatusAprobacion int,
			@IdEstatusTarea int,
			@IdTareaOrigen int,
			@IdTarea int,
			@IdTareaAnterior int,
			@NoSecuencia int;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
	SELECT @IdUsuarioP= IdUsuario 
	FROM Petrovendor.dbo.S_Usuario 
	WHERE IdUsuarioADINCO = @IdUsuario;

	SELECT @IdEstatusAprobacion=O.IdEstatusOperacion,   
	@TipoFlujoId= FT.IdTipoFlujo
	FROM  Petrovendor..TA_Operacion O
	JOIN Petrovendor..TA_FlujoTarea FT
		on O.IdFlujoTarea = ft.IdFlujoTarea	
	WHERE O.IdOperacion =@IdOperacion;

	SELECT @IdTarea = t.IdTarea,
	@NoSecuencia =t.NoSecuencia,
	@IdEstatusTarea = T.IdEstatus
	FROM Petrovendor..TA_Operacion o				
		JOIN Petrovendor..TA_Tarea t 
			ON o.IdOperacion = t.IdOperacion 
	WHERE t.IdAprobador = @IdUsuarioP 
		AND O.IdTipoOperacion = @IdTipo 	
		AND O.IdOperacion =@IdOperacion
		AND t.IdEstatus <> 7  --> CTE ELIMINADO POR REASIGNACION
		AND ISNULL(O.IdEstatusEliminado,0) <> 1  --> que no esten eliminadas		
		AND t.IdEstatus = 1    -- Y que no este aprobado

	IF ISNULL(@IdEstatusAprobacion,0) = 1  AND ISNULL(@IdTarea,0) > 0 AND ISNULL(@IdEstatusTarea,0)=1
	BEGIN 
		--> VALIDAR SI EXISTE UN TAREA PARA EL USUARIO ACTUAL
		IF @TipoFlujoId=1  --> SERIAL
		AND @NoSecuencia>1 
		BEGIN 

			SELECT @IdTareaAnterior = T.IdTarea
			FROM  Petrovendor..TA_Operacion o	
			JOIN  Petrovendor..TA_Tarea t 
				ON o.IdOperacion  = t.IdOperacion 
			WHERE t.Activo = 1	-- Que esten activos			 
			AND  o.IdOperacion  = @IdOperacion
			AND t.NoSecuencia = (@NoSecuencia - 1)
			AND t.IdAprobador <> @IdUsuario -- Se excluye el usuario aprobador actual
			AND ISNULL(O.IdEstatusEliminado,0) <> 1  --> que no esten eliminadas
			AND t.IdEstatus <> 7  --> CTE ELIMINADO POR REASIGNACION
			AND t.IdEstatus = 1 --> QUE ESTE EN APROBACIÓN

			IF ISNULL(@IdTareaAnterior,0)=0 --> SI LA TAREA DEL APROBADOR ANTERIOR ES MAYOR A 0 ENTONCES NO CUMPLE QUE LE TOQUE APROBADAR, SI ES CERO ES QUE SI LE TOCA APROBAR
			BEGIN 
				SET @IdTareaOrigen = @IdTarea
			END 

		END 
		ELSE
		BEGIN
			SET @IdTareaOrigen = @IdTarea
		END 
	END 

-- SE CREA UNA TABLA PARA TODOS LOS REGISTROS DE TODOS LOS CONTRATOS // SIMILAR A AM_APROBACION
		DROP TABLE IF EXISTS #TM_Aprobacion
		CREATE TABLE #TM_Aprobacion
		(
			[IdOperacion]			int				NULL,
			[IdTipoAprobacion]		int				NULL,
			[IdStatusAprobacionM]	int				NULL,
			[IdTareaOrigen]			int				NULL,
			[IdContrato]			int				NULL,
			[FechaCreacion]			datetime		NULL,
			[IdDocumento]			int				NULL,
			[ComentarioDocumento]	nvarchar (max),
			[ComentarioAprobacion]	nvarchar (max),
			[NoVersion]				int				NULL,
			[TipoFlujo]				int				NULL,
			[IdPedido]				int				NULL
		) 

----------------------------------------------------------------
---------------------APROBACIÓN DE SOLICITUDES DE PEDIDO (2)----------------------
----------------------------------------------------------------

IF @IdTipo  = 2 -- SI SON SOLPED HACE ESTO
BEGIN
--se crea el cursor de para SOLPED
			INSERT INTO #TM_Aprobacion
			(
				IdOperacion,
				IdTipoAprobacion,
				IdStatusAprobacionM,
				IdTareaOrigen,
				IdContrato,
				FechaCreacion,
				IdDocumento,
				ComentarioDocumento,
				ComentarioAprobacion,
				NoVersion,
				TipoFlujo,
				IdPedido
			)
			SELECT 
				O.IdOperacion,
				2  AS IdTipoAprobacion,
				CASE WHEN ISNULL(@IdTareaOrigen,0)=0 THEN  O.IdEstatusOperacion ELSE @IdEstatusTarea END AS IdStatusAprobacionM,
				ISNULL(@IdTareaOrigen,0)AS 'IdTareaOrigen',
				SP.IdContrato,
				O.FechaRegistro AS FechaCreacion,
				O.IdDocumento,
				'Solicitud de pedido' AS ComentarioDocumento, 
				O.Descripcion AS ComentarioAprobacion,
				NULL AS 'NoVersion',
				TF.IdTipoFlujo AS TipoFlujo, 
				NULL AS IdPedido
				FROM Petrovendor.dbo.TA_Operacion AS O 				
				JOIN Petrovendor.dbo.MM_SolicitudPedido AS SP 
					ON O.IdDocumento = SP.IdSolicitudPedido 
				JOIN Petrovendor.dbo.TA_FlujoTarea AS TF 
					ON O.IdFlujoTarea = TF.IdFlujoTarea 
				WHERE 
				O.IdTipoOperacion = @IdTipo
				AND O.IdOperacion = @IdOperacion				
				AND ISNULL(O.IdEstatusEliminado, 0) <> 1  --> MOSTRAR NO ELIMINADAS 
				

END
----------------------------------------------------------------
----------------------------------------------------------------
------------------------ APROBACIÓN DE PEDIDO (9)---------------
----------------------------------------------------------------
---------------------------------------------------------------
IF @IdTipo = 9 -- SI SON PEDIDO HACE ESTO OTRO
BEGIN
	INSERT INTO #TM_Aprobacion
			(
				IdOperacion,
				IdTipoAprobacion,
				IdStatusAprobacionM,
				IdTareaOrigen,
				IdContrato,
				FechaCreacion,
				IdDocumento,
				ComentarioDocumento,
				ComentarioAprobacion,
				NoVersion,
				TipoFlujo,
				IdPedido
			)
	SELECT 
			O.IdOperacion,
			O.IdTipoOperacion,
			CASE WHEN ISNULL(@IdTareaOrigen,0)=0 THEN O.IdEstatusOperacion ELSE @IdEstatusTarea END  AS [IdStatusAprobacionM],
			ISNULL(@IdTareaOrigen,0) AS [IdTareaOrigen],
			p.IdContrato,
			O.FechaRegistro AS [FechaCreacion],
			O.IdDocumento,
			CASE 
				WHEN sp.IdTipoProceso = 2 THEN ISNULL(SP.JustificacionSolOferta,'')
				WHEN sp.IdTipoProceso = 4 THEN ISNULL(PO.JustificacionAdjDirecta,'')
				ELSE ''
		    END AS ComentarioDocumento, 
			o.Descripcion AS ComentarioAprobacion,
			P.Version AS 'NoVersion',
			P2.IdPedido,
			P2.IdPedido
		FROM Petrovendor.dbo.TA_Operacion AS O
			JOIN Petrovendor.dbo.MM_Pedido AS P 
				ON O.IdDocumento = P.IdSolicitudPedido
			JOIN    Petrovendor.dbo.MM_Pedidos P2 
				ON P.IdPedido = P2.IdIdentificador 
				AND P.IdProveedorCompras = P2.IdProveedorCliente 
				AND P2.IdTipoPedido IN (2,4,6) --> CTES TIPOS DE PEDIDO 
				 AND P.Version = O.NoVersion	
			LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido SP 
				ON P.IdSolicitudPedido = SP.IdSolicitudPedido 
			LEFT JOIN Petrovendor.dbo.MM_PeticionOferta AS PO
				ON SP.IdSolicitudPedido = PO.IdSolicitudPedido 
			AND PO.JustificacionAdjDirecta IS NOT NULL
		WHERE O.IdTipoOperacion = @IdTipo			 
			  AND O.IdOperacion = @IdOperacion
			  AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
			  AND ISNULL(p.IdEstatusEliminado, 0) <> 1 -->Pedido no eliminado

END

----------------------------------------------------------------
----------------------------------------------------------------
------------------------ APROBACIÓN DE COMPRA DIRECTA (14) -----
----------------------------------------------------------------
---------------------------------------------------------------
IF @IdTipo = 14
BEGIN
	
	INSERT INTO #TM_Aprobacion
			(
				IdOperacion,
				IdTipoAprobacion,
				IdStatusAprobacionM,
				IdTareaOrigen,
				IdContrato,
				FechaCreacion,
				IdDocumento,
				ComentarioDocumento,
				ComentarioAprobacion,
				NoVersion,
				TipoFlujo,
				IdPedido
			)
	SELECT O.IdOperacion,
			14 as IdTipoAprobacion,
			CASE WHEN ISNULL(@IdTareaOrigen,0)=0 THEN  O.IdEstatusOperacion ELSE @IdEstatusTarea END as IdStatusAprobacionM,
			ISNULL(@IdTareaOrigen,0) AS IdTareaOrigen,
			fac.IdContrato as IdContrato,
			fac.FechaTimbrado as FechaCreacion,
			O.IdDocumento as IdDocumento, 
			CONCAT(' Emisor: ',fac.Emisor ,' ','|',' Monto ejercido: ',FORMAT(reg.Montoregistro,'C'),' ',fac.Moneda collate SQL_Latin1_General_CP1_CI_AS,' ','|',' Instalación:',instalacion.NombreInstalacion) AS ComentarioDocumento,
			O.Descripcion AS ComentarioAprobacion,
			0 as NoVersion,			
			FT.IdTipoFlujo as TipoFlujo,
			PG.IdPedido as IdPedido
	FROM Petrovendor..TA_Operacion O				
		LEFT JOIN Petrovendor..MM_Pedidos PG
				ON O.IdDocumento = PG.IdIdentificador 
			   AND O.IdProveedor = PG.IdProveedorCliente
			   AND PG.IdTipoPedido = 1 ---> CTE COMPRA DE COMPRA
		LEFT JOIN Petrovendor..TA_FlujoTarea FT
			ON O.IdFlujoTarea= FT.IdFlujoTarea
		LEFT JOIN Petrovendor..FI_Factura fac
				ON O.IdDocumento = fac.IdFactura       
		LEFT JOIN Petrovendor..CO_Registro reg
				ON fac.IdFactura = reg.IdFactura 
		LEFT JOIN Adinco.dbo.CO_Instalacion instalacion
				ON reg.IdInstalacion = instalacion.IdInstalacion 	
	WHERE O.IdTipoOperacion = 14 ---> CTE COMPRA DE COMPRA	
		AND O.IdOperacion = @IdOperacion
	GROUP BY O.IdOperacion,		
			fac.IdContrato,
			fac.FechaTimbrado,
			O.IdDocumento, 
			O.Descripcion,			
			O.IdFlujoTarea,
			PG.IdPedido,
			fac.Emisor,
			reg.Montoregistro,
			fac.Moneda,
			O.IdEstatusOperacion,
			instalacion.NombreInstalacion,
			FT.IdTipoFlujo
	ORDER BY O.IdOperacion DESC;
	
END

----------------------------------------------------------------
----------------------------------------------------------------
------------------------ APROBACIÓN DE PEDIMENTO COMPROBANTE (19)
----------------------------------------------------------------
---------------------------------------------------------------
IF @IdTipo = 19
BEGIN
	INSERT INTO #TM_Aprobacion
			(
				IdOperacion,
				IdTipoAprobacion,
				IdStatusAprobacionM,
				IdTareaOrigen,
				IdContrato,
				FechaCreacion,
				IdDocumento,
				ComentarioDocumento,
				ComentarioAprobacion,
				NoVersion,
				TipoFlujo,
				IdPedido
			)
	SELECT
					OP.IdOperacion,
					19 as IdTipoAprobacion,
					CASE WHEN ISNULL(@IdTareaOrigen,0)=0 THEN  OP.IdEstatusOperacion ELSE @IdEstatusTarea END as IdStatusAprobacionM,
					ISNULL(@IdTareaOrigen,0) as IdTareaOrigen,
					PC.IdContrato as IdContrato,
					APC.CreadoEl as FechaCreacion,
					PC.IdPedimentoComprobante as IdDocumento,
					CONCAT('Exportador: ',PVS.RazonSocial,' | ','Folio Comprobante: ',PC.FolioComprobante,' | ','Fecha de Pago: ' ,PC.FechaPago ,' | ','Moneda: ',TM.TipoMonedaCorto collate Modern_Spanish_CI_AS,' | ', 'Número de Factura: ',PC.NumFacturaC,' |  Proveedor:'
					, APC.IdProveedor) as ComentarioDocumento,
					CONCAT('Cargado Por: ', US.Nombre, 'Flujo tipo' ,@TipoFlujoId) as ComentarioAprobacion,
					0 as NoVersion,
					OP.IdOperacion as TipoFlujo,
					PC.IdPedimentoComprobante as IdPedido
				FROM	Petrovendor..FI_AceptacionPedido_PedimentoComprobante AS APC
				JOIN	Petrovendor..TA_Operacion AS OP
					ON		APC.IdAceptacionPedidoPedimentoComprobante = OP.IdDocumento 
					AND		OP.IdTipoOperacion = 19
					AND		APC.IdProveedor = OP.IdProveedor 
				JOIN	Petrovendor..FI_PedimentoComprobante AS PC
					ON		APC.IdPedimentoComprobante = PC.IdPedimentoComprobante 
				JOIN	Petrovendor..S_Usuario AS US
					ON		APC.CreadoPor = US.IdUsuario 
				JOIN	Adinco.dbo.PV_Subcontratista AS PVS
					ON		PC.IdSubcontratistaExportador = PVS.IdSubcontratista 
				JOIN	Adinco.dbo.PV_TipoMoneda AS TM
					ON		PC.IdMoneda = TM.IdMoneda 
				JOIN	Petrovendor..TA_Estatus AS ET
					ON		OP.IdEstatusOperacion = ET.IdEstatus				
				WHERE 
					OP.IdOperacion = @IdOperacion
					AND APC.Activo = 1					
					AND OP.IdTipoOperacion = 19

END



SELECT 	IdOperacion,
		t.IdContrato,
		CONCAT(AC.NombreAreaContractual,'- - ',C.NumeroContrato) AS NumeroContrato,
		ta.NombreOperacion AS 'TipoAprobacion',
		t.IdTipoAprobacion AS 'idTipoAprobacion',
		CASE WHEN CONVERT(nvarchar(10),t.FechaCreacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaCreacion, 105) END AS 'FechaCreacion',
		t.ComentarioDocumento AS 'ComentarioDoc',
		t.ComentarioAprobacion AS 'ComentarioApr',
		e.Status AS 'Estatus',
		t.IdStatusAprobacionM AS 'IdStatusAprobacionM',
		t.IdTareaOrigen AS 'IdTareaOrigen',
		t.NoVersion AS 'NoVersion',
		t.IdPedido AS 'IdPedido',
		CASE 
			WHEN t.IdTipoAprobacion = 2 THEN t.IdDocumento 
			WHEN t.IdTipoAprobacion = 9 THEN t.IdPedido 
			WHEN t.IdTipoAprobacion = 14 THEN ISNULL(t.IdPedido,0) 
			WHEN t.IdTipoAprobacion = 19 THEN ISNULL(t.IdPedido,0) 
			END AS 'DisplayMember',
		t.IdDocumento AS 'IdDocumento',
		t.TipoFlujo,
		@IdUsuarioP as UsuarioPetro
		FROM #TM_Aprobacion AS t
		left JOIN dbo.AM_StatusAprobacionM AS e
			ON t.IdStatusAprobacionM = e.IdStatusAprobacionM 
		left JOIN Petrovendor..TA_TipoOperacion AS ta 
			ON t.IdTipoAprobacion = ta.IdTipoOperacion 
		left JOIN dbo.CO_CONTRATO as c
			ON t.IdContrato = c.IdContrato
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC
			ON C.IdAreaContractual = AC.IdAreaContractual	
		GROUP BY IdOperacion,
				t.IdContrato,
				AC.NombreAreaContractual,
				C.NumeroContrato,
				ta.NombreOperacion,
				t.IdTipoAprobacion,
				t.FechaCreacion,
				t.FechaCreacion,
				t.ComentarioDocumento,
				t.ComentarioAprobacion,
				e.Status,
				t.IdStatusAprobacionM,
				t.IdTareaOrigen,
				t.NoVersion,
				t.IdPedido,
				t.IdTipoAprobacion,
				t.IdDocumento,
				t.IdTipoAprobacion,t.IdPedido,
				t.IdDocumento,
			 t.TipoFlujo
		ORDER BY t.FechaCreacion ASC

END