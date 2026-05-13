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
-- =============================================
-- Author:		Daniel AC
-- Update date: 20-06-2023
-- Description:	Se alias a a las columnas sin alias 
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarEncabezadoPrePedidoGral] 
	-- Add the parameters for the stored procedure here
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
										dbo.MM_SolicitudPedido AS SPC(NOLOCK)
											LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD  (NOLOCK)
												ON SPC.IdSolicitudPedido = SPD.IdSolicitudPedido
											LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP (NOLOCK)
												ON SPD.IdSolicitudPedidoDetalle = SPLP.IdSolicitudPedidoDetalle
											LEFT JOIN MM_Pedido AS P (NOLOCK)
												ON SPC.IdSolicitudPedido = P.IdSolicitudPedido
												WHERE P.IdPedido = @IdPedido
										GROUP BY SPLP.IdLineaPresupuesto);

	DECLARE @IdPresupuesto INT = (SELECT TOP 1 IdPresupuesto FROM Adinco.dbo.CO_LineaPresupuestoMes (NOLOCK)
									WHERE IdLineaPresupuestoMes = @IdLineaPresupuesto);

	DECLARE @PresupuestoNombre NVARCHAR(MAX) = (SELECT  TOP 1(cop.Nombre) 
												FROM adinco.dbo.CO_Presupuesto AS cop (NOLOCK)
												WHERE cop.IdPresupuesto = @IdPresupuesto)

	DECLARE @texto varchar(max) = '',
						@ContTabla INT,
						@Cont INT,
						@TextLinea nvarchar(max) = '',
						@CondionesPago NVARCHAR(MAX);  
    -- Insert statements for procedure here
	
	----- IdTipoOperacion = 9--> Aprobación de pedido
	DROP TABLE IF exists #TEMP_PRESUPUESTOS
	CREATE TABLE #TEMP_PRESUPUESTOS --CREAMOS UNA TABLA TEMPORAL
	(IdRow INT IDENTITY(1,1),Nombre VARCHAR(max));

				 

	INSERT INTO #TEMP_PRESUPUESTOS
	SELECT DISTINCT dbo.Fn_RetornarMesProgramadoActividadConcat(clp.IdLineaPresupuestoMes) AS LineaPresupuesto 
	FROM Petrovendor.dbo.MM_Pedido AS p (NOLOCK)
		LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido AS sp (NOLOCK)
		ON p.IdSolicitudPedido = sp.IdSolicitudPedido 
		LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle AS spd (NOLOCK)
		ON sp.IdSolicitudPedido = spd.IdSolicitudPedido 
		LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS lp (NOLOCK)
		ON spd.IdSolicitudPedidoDetalle = lp.IdSolicitudPedidoDetalle 
		LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS clp (NOLOCK)
		ON lp.IdLineaPresupuesto = clp.IdLineaPresupuestoMes
	WHERE p.IdPedido= @IdPedido
	GROUP BY clp.IdLineaPresupuestoMes;

	
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
	FROM dbo.MM_PedidoDetalle pd (NOLOCK)
	LEFT JOIN dbo.MM_CondicionPago cp  (NOLOCK)
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
	CONCAT(ISNULL(PV.RazonSocial,''),' ',ISNULL(PV.RegimenCapital,'')) AS Proveedor,
	CONCAT(ISNULL(PV.Municipio,''),' ',ISNULL(PV.Entidad,'')) AS LugarProveedor,
	E.Nombre AS Estatus, 
	O.FechaRegistro,
	U.Nombre AS NombreAsignador,
	H.FechaVigencia, 
	P.Version,
	CASE P.RecepcionServicio WHEN 1 THEN 'CONFIRMADA_ACEPTADA' WHEN 0 THEN 'CONFIRMACION_RECHAZADA' ELSE 'EN_RECEPCION' END AS EstatusNombreRecepcion,
	PG.IdPedido AS IdPedidoGeneral,
	CASE WHEN ISNULL(PDI.MECANISMO_CONTRATACION,'')='L' THEN 
		'Licitación'  --> CTE 
		ELSE 
		ISNULL(TP.TipoPedido,'')
	END AS TipoPedido,
	TP.IdTipoPedido,
	CONCAT('Días Crédito: ',ISNULL (P.DiasCredito,0)) AS DiasCredito,	
	ISNULL(p.Cerrado, 0) AS Cerrado,
	CONCAT('Presupuesto: ', (ISNULL(@PresupuestoNombre,'')) COLLATE Modern_Spanish_CI_AS,
			' - | Línea de Presupuesto: ',ISNULL(@texto,''), 
			'- | Objeto del pedido (Justificación): ', ISNULL(sp.MotivoUrgencia,'')) AS DetallePresupuesto,
	CASE WHEN P.UnicaCondicionPago = 1 THEN 
	ISNULL(@CondionesPago,'')
	ELSE 
	'Diferidas para las partidas de la orden de compra'
	END  AS CondicionesPago,
	CONCAT('Tipo de aprobación: ',ISNULL(TFT.Nombre,'')) AS TipoFlujoAprobacion,
	TAOF.Descripcion AS ComentariosComprador
	FROM dbo.MM_Pedido AS P (NOLOCK)
	JOIN dbo.MM_PedidoDetalle AS PD  (NOLOCK)
		ON P.IdPedido = PD.IdPedido
	JOIN dbo.MM_PeticionOferta AS PO  (NOLOCK)
		ON P.IdPeticionOferta = PO.IdPeticionOFerta
	JOIN dbo.S_Proveedor (NOLOCK) AS PV
		ON P.IdSubcontratista=PV.IdProveedor 
	JOIN dbo.TA_Operacion AS O  (NOLOCK)
		ON P.IdSolicitudPedido=O.IdDocumento
	JOIN dbo.S_Usuario (NOLOCK) AS U  
		ON O.IdAsignador = U.IdUsuario 
	JOIN dbo.TA_Prioridad (NOLOCK) AS PR 
		ON O.IdPrioridad = PR.IdPrioridad 
	JOIN dbo.TA_Vencimiento AS V (NOLOCK)
		ON O.IdVigencia = V.IdVencimiento
	JOIN dbo.TA_TipoOperacion (NOLOCK) AS TTO 
		ON O.IdTipoOperacion = TTO.IdTipoOperacion
	JOIN dbo.TA_Estatus (NOLOCK) AS E
		ON O.IdEstatusOperacion = E.IdEstatus 
	JOIN dbo.MM_HorasVigenciaPedido AS H (NOLOCK)
		ON P.IdPedido = H.IdPedido
	JOIN dbo.MM_Pedidos AS PG  (NOLOCK)
		ON P.IdPedido = PG.IdIdentificador 
		AND PG.IdProveedorCliente = @IdProveedor 
		AND PG.IdTipoPedido IN (2,3,4, 6) ---(Mer,LICI, AD, OT)
	LEFT  JOIN dbo.MM_TipoPedido (NOLOCK) AS TP 
		ON PG.IdTipoPedido = TP.IdTipoPedido
	LEFT JOIN dbo.MM_SolicitudPedido sp  (NOLOCK)
		ON P.IdSolicitudPedido = sp.IdSolicitudPedido 
	LEFT JOIN dbo.TA_FlujoTarea (NOLOCK) FT 
		ON O.IdFlujoTarea = FT.IdFlujoTarea
	LEFT JOIN dbo.TA_TipoFlujoTarea TFT  (NOLOCK)
		ON FT.IdTipoFlujo = TFT.IdTipoFlujoTarea
	LEFT JOIN dbo.TA_Operacion AS TAOF  (NOLOCK)
		ON P.IdSolicitudPedido  = TAOF.IdDocumento
		and TAOF.IdTipoOperacion = 6 --> APROBACION DE PEDIDO
	LEFT JOIN WDEA_PurchasingDocumentsImportados PDI  (NOLOCK)
		ON  P.IdPedido = PDI.IdPedidoADINCO
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
	TAOF.Descripcion,
	PDI.MECANISMO_CONTRATACION
END