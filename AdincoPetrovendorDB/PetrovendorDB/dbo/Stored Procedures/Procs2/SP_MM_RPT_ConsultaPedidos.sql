USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_RPT_ConsultaPedidos'
)
    DROP PROCEDURE SP_MM_RPT_ConsultaPedidos;
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_RPT_ConsultaPedidos]    Script Date: 13/03/2025 11:06:57 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 02-04-2018
-- Description:	Consultar Pedidos por proveedor para reporte
-- Author:		Daniel AC
-- Create date: 05-06-2018
-- Description:	Agregue columna de activo o eliminado
-- =============================================
-- Author:		Marcos Neri
-- Create date: 10-06-2019
-- Description:	Agregar en Descripcion Corta Numero de Material
-- =============================================
-- Author:		Marcos Neri
-- Create date: 24-06-2019
-- Description:	Agregar en TipoPedido(Tipo de Compra) el tipo de pedido (Capex /Opex)
-- Author:		Daniel AC
-- Create date: 13-03-2025
-- Description:	Se obtiene los número de aceptación fuera de la consulta principal para evitar resultados duplicados
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_RPT_ConsultaPedidos]
--	-- Add the parameters for the stored procedure here
	@IdProveedor int,
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
	CREATE TABLE #ListaPedidos(
		IdPedido INT,
		IdEstatus INT
	)

	CREATE TABLE #ListaAceptacionDetalleAgrupado(
		IdPedido INT,
		IdPedidoDetalle INT,
		NoAceptacion  NVARCHAR(MAX)
	)

	CREATE TABLE #ListaAceptacionDetalle(
		IdPedido INT,
		IdPedidoDetalle INT,
		IdAceptacionPedido INT
	)

	CREATE TABLE #Pedidos (
		IdAceptacionPedido NVARCHAR(MAX),
		IdPedido INT, 
		IdPedidoDetalle INT, 
		IdSolicitudPedido INT,
		CreadoEl DATETIME,
		FechaEnvioPedido DATETIME,
		TotalPedido FLOAT,
		Proveedor NVARCHAR(MAX),
		DescripcionCorta NVARCHAR(MAX),
		RecepcionServicio  NVARCHAR(300),
		Nombre NVARCHAR(200),
		Version INT,
		TipoMoneda NVARCHAR(MAX),
		IdPedidoGeneral INT,
		TipoPedido NVARCHAR(500),
		IdTipoPedido INT,
		Activo NVARCHAR(100)
	)
	-- FILTRAR PEDIDOS DEL PROVEEDOR 
	INSERT INTO #ListaPedidos(
		IdPedido,
		IdEstatus
	)
	SELECT P.IdPedido,
	O.IdEstatusOperacion
	FROM MM_Pedido AS P (NOLOCK)
	JOIN TA_Operacion AS O (NOLOCK)
		ON  O.IdProveedor = @IdProveedor
		AND P.IdSolicitudPedido = O.IdDocumento
		AND O.IdTipoOperacion = 9  --> CTE APROBACIÓN PEDIDO
		AND P.Version=O.NoVersion			
			
		-- OBTENER DETALLE DE LOS PEDIDOS
		INSERT INTO #Pedidos(
		IdAceptacionPedido,
		IdPedido, 
		IdPedidoDetalle, 
		IdSolicitudPedido,
		CreadoEl,
		FechaEnvioPedido,
		TotalPedido,
		Proveedor,			
		DescripcionCorta,
		RecepcionServicio,
		Nombre,
		Version,
		TipoMoneda,
		IdPedidoGeneral,
		TipoPedido,
		IdTipoPedido,
		Activo
		)
		SELECT 
			'Aceptación en Espera' AS IdAceptacionPedido,
			P.IdPedido,
			PD.IdPedidoDetalle,
			P.IdSolicitudPedido,
			P.CreadoEl, 
			P.FechaEnvioPedido AS FechaEnvioPedido,
			SUM(PD.Subtotal) AS TotalPedido,
			ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			CONCAT('Número de Servicio/Material: ',MA.IdMaterial,' | Descripción: ', MA.DescripcionCorta) AS DescripcionCorta ,
			CASE 
			WHEN P.RecepcionServicio = 1 THEN 'Confirmación Aceptada' 
			WHEN P.RecepcionServicio  = 0 THEN 'Confirmación Rechazada' 
			WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 AND LPF.IdEstatus = 2 THEN	
					'Confirmación Vencida '  
			WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  <= 0 AND LPF.IdEstatus = 2 THEN	
					'En Confirmación'  
			ELSE 	  
					'Confirmación No Iniciada ' 
			END AS RecepcionServicio,
			E.Nombre,
			P.Version,
			TM.TipoMonedaCorto AS TipoMoneda,
			PG.IdPedido AS IdPedidoGeneral,
			CONCAT('Tipo de Compra: ',TP.TipoPedido,(ISNULL(' | Tipo de Pedido: '+TG.TipoGasto,''))) AS TipoPedido,
			TP.IdTipoPedido,
			CASE WHEN ISNULL(P.IdEstatusEliminado,0)<> 1 THEN   
			'Activo'
			WHEN ISNULL(P.IdEstatusEliminado,0) = 1 THEN 
			'Eliminado'
			END AS Activo
		FROM #ListaPedidos LPF
		JOIN MM_Pedido AS P (NOLOCK)
			ON LPF.IdPedido = P.IdPedido
		JOIN MM_SolicitudPedido AS SP 
			ON P.IdSolicitudPedido = SP.IdSolicitudPedido 			
		JOIN MM_PedidoDetalle AS PD (NOLOCK)
			ON P.IdPedido = PD.IdPedido 			
		JOIN S_Proveedor AS PV (NOLOCK)
			ON P.IdSubcontratista = PV.IdProveedor 			
		JOIN TA_Estatus AS E (NOLOCK)
			ON LPF.IdEstatus = E.IdEstatus 
		JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
			ON P.IdPedido = HV.IdPedido
		JOIN PV_TipoMoneda AS TM (NOLOCK)
			ON TM.IdMoneda = P.IdMoneda			
		JOIN MM_Pedidos AS PG (NOLOCK)
			ON P.IdPedido = PG.IdIdentificador 				
			AND PG.IdProveedorCliente = @IdProveedor
			AND PG.IdTipoPedido IN (2,4,6) --> CTES MERCADEO, DIRECTA Y ORDEN DE TRABAJO
		LEFT  JOIN MM_TipoPedido AS TP (NOLOCK)
			ON PG.IdTipoPedido = TP.IdTipoPedido
		LEFT JOIN MM_Material AS MA (NOLOCK)
			ON PD.IdMaterial = MA.IdMaterial 
		LEFT JOIN MM_TipoGastos AS TG (NOLOCK)
			ON SP.IdTipoGasto = TG.IdTipoGasto	
		GROUP BY 
			LPF.IdEstatus,
			P.IdPedido, 
			PD.IdPedidoDetalle,
			P.IdSolicitudPedido, 
			P.FechaEnvioPedido, 
			MA.IdMaterial,
			RazonSocial,
			RegimenCapital, 
			P.RecepcionServicio,  
			E.Nombre,
			P.Version,
			TM.TipoMonedaCorto,
			HV.FechaVigencia, 
			P.CreadoEl,
			PG.IdPedido,
			TP.TipoPedido,
			TG.TipoGasto,
			TP.IdTipoPedido,
			MA.DescripcionCorta,
			P.IdEstatusEliminado
		ORDER BY PG.IdPedido DESC

		-- OBTENER LAS ACEPTACIONES POR PEDIDO DETALLE
		 INSERT INTO #ListaAceptacionDetalle(
		 IdPedido,
		 IdPedidoDetalle,
		 IdAceptacionPedido)

		 SELECT P.IdPedido,
		 P.IdPedidoDetalle,
		 AP.IdAceptacionPedido
		 FROM #Pedidos P 
		 JOIN MM_AceptacionPedido AP (NOLOCK)
			ON P.IdPedido = AP.IdPedido
		 JOIN MM_AceptacionPedidoDetalle APD  (NOLOCK)
			ON AP.IdAceptacionPedido =  APD.IdAceptacionPedido
			AND P.IdPedidoDetalle = APD.IdPedidoDetalle
		 WHERE ISNULL(AP.IdEstatusEliminado,0) = 0
		 AND ISNULL(APD.IdEliminado,0) = 0
		
		-- AGRUPAR LAS ACEPTACIONES POR PEDIDO DETALLE 
		INSERT INTO #ListaAceptacionDetalleAgrupado
		(
			IdPedido,
			IdPedidoDetalle,
			NoAceptacion
		)
		SELECT AP.IdPedido,
		   AP.IdPedidoDetalle,
           (
            SELECT STUFF(
                    (
                        SELECT ', ' + CAST(LAPI.IdAceptacionPedido AS nvarchar(MAX))
                        FROM #ListaAceptacionDetalle LAPI
                        WHERE LAPI.IdPedido = AP.IdPedido
						AND LAPI.IdPedidoDetalle = AP.IdPedidoDetalle
                        ORDER BY LAPI.IdAceptacionPedido ASC
                        FOR XML PATH('')
                    ),
                    1,
                    2,
                    ''
                        )
           ) AS Aceptaciones 
    FROM #ListaAceptacionDetalle AP
    GROUP BY AP.IdPedido,
		   AP.IdPedidoDetalle
	-- ACTUALIZAR LA ACEPTACION RELACIONADA AL PEDIDO Y AL PEDIDO DETALLE [UN PEDIDO PUEDE TENER VARIAS ACEPTACIONES]
	UPDATE P
	SET P.IdAceptacionPedido = AP.NoAceptacion
	FROM #Pedidos P
	JOIN #ListaAceptacionDetalleAgrupado AP
		ON P.IdPedido  = AP.IdPedido
		AND P.IdPedidoDetalle = AP.IdPedidoDetalle

	-- RETORNAR LISTA DE PEDIDOS Y SUS DETALLES 
	SELECT 
	IdAceptacionPedido,
	IdPedidoGeneral AS IdPedido, 
	IdSolicitudPedido,
	CreadoEl,
	FechaEnvioPedido,
	TotalPedido,
	Proveedor,			
	DescripcionCorta,
	RecepcionServicio,
	Nombre,
	Version,
	TipoMoneda,
	IdPedidoGeneral,
	TipoPedido,
	IdTipoPedido,
	Activo
	FROM #Pedidos
END