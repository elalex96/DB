USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_SP_ConsultaPedidoNotificacion'
)
    DROP PROCEDURE MM_SP_ConsultaPedidoNotificacion;

/****** Object:  StoredProcedure [dbo].[MM_SP_ConsultaPedidoNotificacion]    Script Date: 06/07/2021 10:51:37 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Marcos Garcia
-- Create date: <22-04-2019>
-- Description:	<Agregar Linea Presupuesto (Tarea y Subtarea) despues de DescripcionCorta
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <06-07-2021>
-- Description:	Se modifico consulta para evitar html vacio
-- =============================================

CREATE PROCEDURE [dbo].[MM_SP_ConsultaPedidoNotificacion] --14183, 1
	@IdSolicitudPedido INT,
	@Version INT,	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
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

	SELECT PE.IdSubcontratista, 
		P.RazonSocial + ' ' + ISNULL(P.RegimenCapital, '') + '.<br/> <b> Objeto del pedido(Justificación): </b>' + SP.MotivoUrgencia,
		PG.IdPedido,
		'<b>'+ ISNULL(POD.MaterialCotizadoTextoC,ISNULL(M.DescripcionCorta,'')) + '</b>' + ' | Linea Presupuesto - '+ @texto AS DescripcionCorta ,
		PD.PrecioUnitario,
		PD.Cantidad,
		ISNULL(POD.UnidadProveedor,ISNULL(U.Unidad,'')) AS Unidad,
		PD.Subtotal,
		TM.TipoMonedaCorto,
		ISNULL(C.NumeroContrato,'') + ' - ' + ISNULL(AC.NombreAreaContractual,'') AS Contrato,
		TP.TipoPedido
	FROM MM_Pedido PE
		LEFT JOIN dbo.S_Proveedor p 
			ON PE.IdSubcontratista = P.IdProveedor 
		LEFT JOIN dbo.MM_PedidoDetalle PD 
			ON  PE.IdPedido = PD.IdPedido
		LEFT JOIN MM_PeticionOfertaDetalle POD
			ON PE.IdPeticionOferta = POD.IdPeticionOferta
			AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
		LEFT JOIN dbo.MM_Material M 
			ON PD.IdMaterial = M.IdMaterial 
		LEFT JOIN PV_MM_MaterialUnidad U 
			ON PD.IdUnidad = U.IdUnidad 
		LEFT JOIN dbo.PV_TipoMoneda TM 
			ON PD.IdMoneda = TM.IdMoneda 
		LEFT JOIN dbo.MM_Pedidos PG 
			ON PE.IdPedido  = PG.IdIdentificador
			AND PE.IdProveedorCompras=PG.IdProveedorCliente
			AND PG.IdTipoPedido IN (2,4,6)			
		LEFT JOIN dbo.MM_SolicitudPedido SP 
			ON PE.IdSolicitudPedido = SP.IdSolicitudPedido
		LEFT JOIN Adinco.dbo.CO_Contrato AS C 
			ON PE.IdContrato = C.IdContrato 
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC 
			ON  C.IdAreaContractual = AC.IdAreaContractual
		LEFT JOIN dbo.MM_TipoPedido AS TP 
			ON  PG.IdTipoPedido = TP.IdTipoPedido 
	WHERE PE.IdSolicitudPedido = @IdSolicitudPedido
		AND PE.Version = @Version
	ORDER BY PE.IdSubcontratista, PG.IdPedido,TM.TipoMonedaCorto ASC
	 
END
