-- =============================================
-- Author:		<Jose Roman>
-- Create date: <17-04-2018>
-- Description:	<Consulta para armar la tabla de pedido del correo de notificación>
-- =============================================
-- Author:		DANIEL AC
-- Create date: <25-06-2018>
-- Description:	<Cambie retorno de No. de pedido al pedido publico>
-- =============================================
-- Author:		Marcos Garcia
-- Create date: <22-04-2019>
-- Description:	<Agregar Linea Presupuesto (Tarea y Subtarea) despues de DescripcionCorta
-- =============================================


CREATE procedure [dbo].[MM_SP_ConsultaPedidoNotificacion] --14183, 1
	@IdSolicitudPedido INT,
	@Version INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN

				
				 CREATE TABLE #TEMP_PRESUPUESTOS --CREAMOS UNA TABLA TEMPORAL
				( IdRow INT IDENTITY(1,1),Nombre VARCHAR(max));

				

				INSERT INTO #TEMP_PRESUPUESTOS
				SELECT DISTINCT dbo.Fn_RetornarMesProgramadoActividadConcat(clp.IdLineaPresupuestoMes) AS LineaPresupuesto FROM Petrovendor.dbo.MM_Pedido AS p
					LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido AS sp ON sp.IdSolicitudPedido = p.IdSolicitudPedido
					LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle AS spd ON spd.IdSolicitudPedido = sp.IdSolicitudPedido
					LEFT JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS lp ON lp.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
					LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS clp ON clp.IdLineaPresupuestoMes = lp.IdLineaPresupuesto
				WHERE p.IdPedido IN (SELECT PE.IdPedido  FROM dbo.MM_Pedido AS PE WHERE PE.IdSolicitudPedido = @IdSolicitudPedido)
				GROUP BY clp.IdLineaPresupuestoMes;

				DECLARE @texto varchar(max) = '',
						@ContTabla INT,
						@Cont INT,
						@TextLinea nvarchar(max) = '';

				
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

	SELECT pe.IdSubcontratista, 
		p.RazonSocial + ' ' + ISNULL(p.RegimenCapital, '') + '.<br/> <b> Objeto del pedido(Justificación): </b>' + sp.MotivoUrgencia,
		pg.IdPedido,
		'<b>'+ m.DescripcionCorta + '</b>' + ' | Linea Presupuesto - '+ @texto AS DescripcionCorta ,
		pd.PrecioUnitario,
		pd.Cantidad,
		u.Unidad,
		pd.Subtotal,
		tm.TipoMonedaCorto,
		ISNULL(C.NumeroContrato,'') + ' - ' + ISNULL(AC.NombreAreaContractual,'') AS Contrato,
		TP.TipoPedido
	FROM dbo.MM_Pedido pe
		INNER JOIN dbo.S_Proveedor p ON p.IdProveedor = pe.IdSubcontratista
		INNER JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedido = pe.IdPedido
		INNER JOIN dbo.MM_Material m ON m.IdMaterial = pd.IdMaterial
		INNER JOIN dbo.PV_MM_MaterialUnidad u ON u.IdUnidad = pd.IdUnidad
		INNER JOIN dbo.PV_TipoMoneda tm ON tm.IdMoneda = pd.IdMoneda
		LEFT JOIN dbo.MM_Pedidos pg ON pg.IdIdentificador=pe.IdPedido AND pe.IdProveedorCompras=pg.IdProveedorCliente
		INNER JOIN dbo.MM_SolicitudPedido sp ON pe.IdSolicitudPedido = sp.IdSolicitudPedido
		LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = pe.IdContrato
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
		LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = pg.IdTipoPedido
	WHERE pe.IdSolicitudPedido = @IdSolicitudPedido
		AND pe.Version = @Version
	ORDER BY pe.IdSubcontratista, pg.IdPedido,tm.TipoMonedaCorto ASC
	 
END
