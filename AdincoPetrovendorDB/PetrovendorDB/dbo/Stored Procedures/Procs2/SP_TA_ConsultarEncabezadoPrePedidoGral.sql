USE PETROVENDOR
GO
DROP PROCEDURE IF EXISTS SP_TA_ConsultarEncabezadoPrePedidoGral
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Daniel AC
-- Update date: 28-10-2019
-- Description:	Se agrega personalización de días de crédito por partida
-- =============================================
-- Author:		Luis David de la cruz Bautista
-- Update date: 20/01/2021
-- Description:	Se optimiza el script para el issue 920
-- =============================================
-- Author:		Luis David de la cruz Bautista
-- Update date: 15/08/2022
-- Description:	Se corrigen los errore ortográficos del detalle del pedido para issue #1963 (Petrovendor)
-- =============================================
-- Author:		Luis David de la cruz Bautista
-- Update date: 04/10/2022
-- Description:	Se agrega el tipo licitación a la consulta ya que se agregó para en el catalogo con prefijo SAP
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarEncabezadoPrePedidoGral] --420, 1343
	-- Add the parameters for the stored procedure here
	---execute  SP_TA_ConsultarEncabezadoPrePedidoGral 420, 1343
	@IdProveedor int, 
	@IdPedido int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdLineaPresupuesto int = (SELECT  
										TOP 1
										SPLP.IdLineaPresupuesto FROM 
										dbo.MM_SolicitudPedido AS SPC
											LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD 
												ON SPC.IdSolicitudPedido = SPD.IdSolicitudPedido
											LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP
												ON SPD.IdSolicitudPedidoDetalle = SPLP.IdSolicitudPedidoDetalle
											LEFT JOIN MM_Pedido AS P ON SPC.IdSolicitudPedido = P.IdSolicitudPedido
												WHERE P.IdPedido = @IdPedido
										GROUP BY SPLP.IdLineaPresupuesto);

	DECLARE @IdPresupuesto INT = (SELECT TOP 1 IdPresupuesto FROM Adinco.dbo.CO_LineaPresupuestoMes WHERE IdLineaPresupuestoMes = @IdLineaPresupuesto);

	DECLARE @texto varchar(max) = '',
						@ContTabla INT,
						@Cont INT,
						@TextLinea nvarchar(max) = '',
						@CondionesPago NVARCHAR(MAX);  
    -- Insert statements for procedure here
	
	----- IdTipoOperacion = 9--> Aprobaci�n de pedido
				drop table if exists #TEMP_PRESUPUESTOS
				 CREATE TABLE #TEMP_PRESUPUESTOS --CREAMOS UNA TABLA TEMPORAL
				( IdRow INT IDENTITY(1,1),Nombre VARCHAR(max));

				 --DROP TABLE #TEMP_PRESUPUESTOS

				INSERT INTO #TEMP_PRESUPUESTOS
				SELECT DISTINCT dbo.Fn_RetornarMesProgramadoActividadConcat(clp.IdLineaPresupuestoMes) AS LineaPresupuesto 
				FROM Petrovendor.dbo.MM_Pedido AS p
					LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido AS sp 
					ON p.IdSolicitudPedido = sp.IdSolicitudPedido 
					LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle AS spd 
					ON sp.IdSolicitudPedido = spd.IdSolicitudPedido 
					LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS lp 
					ON spd.IdSolicitudPedidoDetalle = lp.IdSolicitudPedidoDetalle 
					LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS clp 
					ON lp.IdLineaPresupuesto = clp.IdLineaPresupuestoMes
				WHERE p.IdPedido= @IdPedido
				GROUP BY clp.IdLineaPresupuestoMes;

				--SELECT * FROM #TEMP_PRESUPUESTOS
				SET @ContTabla = (SELECT COUNT(IdRow) FROM #TEMP_PRESUPUESTOS);
				SET @Cont = 1;

				WHILE @ContTabla >= @Cont
				BEGIN
					SET @TextLinea = (SELECT Nombre FROM #TEMP_PRESUPUESTOS WHERE IdRow = 1);
					SET @texto = CONCAT(@texto,@TextLinea,' ');
					SET @Cont = @Cont + 1;
					IF @ContTabla>=@Cont
						SET @texto = @texto + ', ';	
					ELSE 
						SET @texto = @texto + ' '	;			
				END
	SELECT 
	@CondionesPago=CASE WHEN pd.IdCondicionPago = 1 THEN --> CREDITO
	CONCAT(pd.DiasCredito, CASE WHEN PD.DiasCredito=1 THEN ' días' ELSE ' días' END,' de ',cp.CondicionPago)
	ELSE 
	CONCAT(cp.CondicionPago,'')
	END 
	FROM dbo.MM_PedidoDetalle pd
	LEFT JOIN dbo.MM_CondicionPago cp 
	ON pd.IdCondicionPago = cp.IdCondicionPago
	WHERE IdPedido =@IdPedido


			
	SELECT 	
	P.IdPedido,
	P.IdSolicitudPedido,
	SUM(PD.Subtotal) AS SubTotal,
	O.IdFlujoTarea, 
	O.IdOperacion, 
	O.IdEstatusOperacion, 
	O.Descripcion, 
	ISNULL(PV.RazonSocial,'') +' ' + ISNULL(PV.RegimenCapital,'') AS Proveedor,
	PV.Municipio +' '+PV.Entidad AS LugarProveedor,
	E.Nombre, 
	O.FechaRegistro,
	U.Nombre,
	H.FechaVigencia, 
	P.Version,
	CASE P.RecepcionServicio WHEN 1 THEN 'CONFIRMADA_ACEPTADA' WHEN 0 THEN 'CONFIRMACION_RECHAZADA' ELSE 'EN_RECEPCION' END,
	PG.IdPedido AS IdPedidoGeneral,
	TP.TipoPedido,
	TP.IdTipoPedido,
	CONCAT('Días Crédito: ',ISNULL (P.DiasCredito,0)) AS DiasCredito,	
	ISNULL(p.Cerrado, 0),
	CONCAT('Presupuesto: ', (SELECT  TOP 1(cop.Nombre) 
								FROM adinco.dbo.CO_Presupuesto AS cop
								WHERE cop.IdPresupuesto = @IdPresupuesto) COLLATE Modern_Spanish_CI_AS,
			' - | Línea de Presupuesto: ',@texto, 
			'- | Objeto del pedido (Justificación): ', sp.MotivoUrgencia) AS DetallePresupuesto,
	CASE WHEN P.UnicaCondicionPago = 1 THEN 
	CONCAT(@CondionesPago,'')
	ELSE 
	'Diferidas para las partidas de la orden de compra'
	END  AS CondicionesPago,
	CONCAT('Tipo de aprobación: ',TFT.Nombre) AS TipoFlujoAprobacion,
	TAOF.Descripcion AS ComentariosComprador
	FROM dbo.MM_Pedido AS P
	INNER JOIN dbo.MM_PedidoDetalle AS PD 
	ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO 
	ON P.IdPeticionOferta = PO.IdPeticionOFerta
	INNER JOIN dbo.S_Proveedor (NOLOCK) AS PV
	ON P.IdSubcontratista=PV.IdProveedor 
	INNER JOIN dbo.TA_Operacion AS O 
	ON P.IdSolicitudPedido=O.IdDocumento
	INNER JOIN dbo.S_Usuario (NOLOCK) AS U  
	ON O.IdAsignador = U.IdUsuario 
	INNER JOIN dbo.TA_Prioridad (NOLOCK) AS PR 
	ON O.IdPrioridad = PR.IdPrioridad 
	INNER JOIN dbo.TA_Vencimiento AS V
	ON O.IdVigencia = V.IdVencimiento
	INNER JOIN dbo.TA_TipoOperacion (NOLOCK) AS TTO 
	ON O.IdTipoOperacion = TTO.IdTipoOperacion
	INNER JOIN dbo.TA_Estatus (NOLOCK) AS E
	ON O.IdEstatusOperacion = E.IdEstatus 
	INNER JOIN dbo.MM_HorasVigenciaPedido AS H
	ON P.IdPedido = H.IdPedido
	INNER JOIN dbo.MM_Pedidos AS PG 
	ON P.IdPedido = PG.IdIdentificador 
	AND PG.IdProveedorCliente = @IdProveedor 
	AND PG.IdTipoPedido IN (2,3, 4, 6) ---(Mer,LICI, AD, OT)
	LEFT  JOIN dbo.MM_TipoPedido (NOLOCK) AS TP 
	ON PG.IdTipoPedido = TP.IdTipoPedido
	LEFT JOIN dbo.MM_SolicitudPedido sp 
	ON P.IdSolicitudPedido = sp.IdSolicitudPedido 
	LEFT JOIN dbo.TA_FlujoTarea (NOLOCK) FT 
	ON O.IdFlujoTarea = FT.IdFlujoTarea
	LEFT JOIN dbo.TA_TipoFlujoTarea TFT
	ON FT.IdTipoFlujo = TFT.IdTipoFlujoTarea
	LEFT JOIN dbo.TA_Operacion AS TAOF
	ON P.IdSolicitudPedido  = TAOF.IdDocumento
	and TAOF.IdTipoOperacion = 6
	WHERE O.IdTipoOperacion = 9 
	AND O.IdProveedor = @IdProveedor   
	AND P.IdPedido = @IdPedido 
	AND p.Version=o.NoVersion
	GROUP BY 
	P.IdPedido, 
	P.IdSolicitudPedido,
	O.IdFlujoTarea, 
	O.IdOperacion, 
	O.IdEstatusOperacion, 
	O.Descripcion, 
	PV.RazonSocial,	
	PV.RegimenCapital,
	Pv.Municipio,
	PV.Entidad, 
	E.Nombre,
	O.FechaRegistro,
	U.Nombre,
	H.FechaVigencia,
	P.Version,
	P.RecepcionServicio,
	PG.IdPedido,
	TP.TipoPedido,
    TP.IdTipoPedido,
	P.DiasCredito,
	p.Cerrado,
	sp.MotivoUrgencia,
	P.UnicaCondicionPago,
	TFT.Nombre,
	TAOF.Descripcion
END
