-- =============================================
-- Author:		Miguel Gomez
-- Create date: 10 Noviembre 2014
-- Description:	Presupuestos
-- =============================================
-- Modified:      <Jose Roman>
-- Updated date: <07/01/2018>
-- Description: <Se reduce la consulta para agilisarla>
-- Updated date: <17/01/2018>
-- Description: <Se agregan columnas faltantes>
-- =============================================
-- Modified:      <Pedro, Acuña>
-- Updated date: <02/04/2018>
-- Description: <Se agrega el numero de fila de retorno para sacar el numero de pagina en donde se encuentra el presupuesto seleccionado>
-- =============================================
-- Modified:      <Alexander Gomez>
-- Updated date: <18/12/2019>
-- Description: <Se homologo ocn el spo de adinco sp_CO_ConsultaLineaPresupuestoMes>
-- =============================================
CREATE PROCEDURE [dbo].[CO_SP_ConsultaLineaPresupuestoMesv2] --3
-- Add the parameters for the stored procedure here
@presupuesto INT
AS
     BEGIN
        SET NOCOUNT ON;
        SET LANGUAGE spanish; 

		DECLARE @PedidosAprobados TABLE (Id INT IDENTITY, IdPedido INT, IdPedidoDetalle INT, CantidadFaltante FLOAT, PrecioUnitario FLOAT, IdMoneda INT, FechaPedido DATE, IdLineaPresupuesto INT)
		DECLARE @PedidosCerrados TABLE (Id INT IDENTITY, IdPedido INT, IdPedidoDetalle INT, Cantidad FLOAT, PrecioUnitario FLOAT, IdMoneda INT, FechaPedido DATE, IdLineaPresupuesto INT)
		DECLARE @MontosDolaresDetalle TABLE (id INT IDENTITY, idLineaPresupuesto INT, MontoEjercido DECIMAL)
		DECLARE @MontoEjercidoPorLinea TABLE (Id INT IDENTITY, IdLineaPresupuesto INT, MontoEjercido DECIMAL)
		
		--De todos los pedidos que esten aprobados, se calcula la diferencia entre la cantidad aceptada vs la solicitada
		INSERT INTO @PedidosAprobados
		(
			IdPedido,
			IdPedidoDetalle,
			CantidadFaltante,
			PrecioUnitario,
			IdMoneda,
			FechaPedido,
			IdLineaPresupuesto
		)
		SELECT  p.IdPedido, 
				pd.IdPedidoDetalle, 
				(pd.Cantidad - SUM(apd.Cantidad)) AS CantidadFaltante, 
				pod.PrecioUnitario, 
				pod.IdMoneda, 
				CAST(p.CreadoEl AS DATE),
				lpm.IdLineaPresupuestoMes
		FROM Adinco.dbo.CO_LineaPresupuestoMes lpm
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp ON spdlp.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd ON spd.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
			INNER JOIN petrovendor.dbo.MM_SolicitudPedido sp ON sp.IdSolicitudPedido = spd.IdSolicitudPedido AND ISNULL(sp.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle pod ON pod.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
			INNER JOIN petrovendor.dbo.MM_PeticionOferta po ON po.IdPeticionOferta = pod.IdPeticionOferta AND ISNULL(po.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PedidoDetalle pd ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
			INNER JOIN Petrovendor.dbo.MM_Pedido p ON p.IdPedido = pd.IdPedido AND ISNULL(p.IdEstatusEliminado, 0) = 0 AND ISNULL(p.Cerrado, 0) = 0
			INNER JOIN petrovendor.dbo.TA_Operacion o ON o.IdDocumento = p.IdSolicitudPedido AND o.IdTipoOperacion = 9 AND o.NoVersion = p.Version AND o.IdEstatusOperacion = 2 AND ISNULL(o.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle apd ON apd.IdPedidoDetalle = pd.IdPedidoDetalle 
			INNER JOIN petrovendor.dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = apd.IdAceptacionPedido AND ISNULL(ap.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_AceptacionFactura af ON af.IdAceptacionPedido = apd.IdAceptacionPedido AND ISNULL(af.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.TA_Operacion op ON op.IdDocumento = af.IdAceptacionFactura AND op.IdTipoOperacion = 10 AND op.IdEstatusOperacion = 2 AND ISNULL(op.IdEstatusEliminado, 0) = 0
		WHERE lpm.IdPresupuesto = @presupuesto
		GROUP BY p.IdPedido, pd.IdPedidoDetalle, pd.Cantidad, pod.PrecioUnitario, pod.IdMoneda, p.CreadoEl, lpm.IdLineaPresupuestoMes
				
		--Todos los pedidos que esten cerrados, con aceptaciones de pedido pero sin factura aprobada	
		INSERT INTO @PedidosCerrados
		(
			IdPedido,
			IdPedidoDetalle,
			Cantidad,
			PrecioUnitario,
			IdMoneda,
			FechaPedido,
			IdLineaPresupuesto
		)
		SELECT p.IdPedido,
				pd.IdPedidoDetalle,
				apd.Cantidad AS CantidadAceptada,
				pod.PrecioUnitario,
				pod.IdMoneda,
				CAST(p.CreadoEl AS DATE),
				lpm.IdLineaPresupuestoMes
		FROM Adinco.dbo.CO_LineaPresupuestoMes lpm
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp ON spdlp.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd ON spd.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
			INNER JOIN petrovendor.dbo.MM_SolicitudPedido sp ON sp.IdSolicitudPedido = spd.IdSolicitudPedido AND ISNULL(sp.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle pod ON pod.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
			INNER JOIN petrovendor.dbo.MM_PeticionOferta po ON po.IdPeticionOferta = pod.IdPeticionOferta AND ISNULL(po.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PedidoDetalle pd ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
			INNER JOIN Petrovendor.dbo.MM_Pedido p ON p.IdPedido = pd.IdPedido AND ISNULL(p.IdEstatusEliminado, 0) = 0 AND ISNULL(p.Cerrado, 0) = 1
			INNER JOIN petrovendor.dbo.TA_Operacion o ON o.IdDocumento = p.IdSolicitudPedido AND o.IdTipoOperacion = 9 AND o.NoVersion = p.Version AND o.IdEstatusOperacion = 2 AND ISNULL(o.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle apd ON apd.IdPedidoDetalle = pd.IdPedidoDetalle 
			INNER JOIN petrovendor.dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = apd.IdAceptacionPedido AND ISNULL(ap.IdEstatusEliminado, 0) = 0
			LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura af ON af.IdAceptacionPedido = apd.IdAceptacionPedido 
			LEFT JOIN Petrovendor.dbo.TA_Operacion op ON op.IdDocumento = af.IdAceptacionFactura AND op.IdTipoOperacion = 10 
		WHERE lpm.IdPresupuesto = @presupuesto
			AND ISNULL(af.IdEstatusEliminado, 0) = 0
			AND ISNULL(op.IdEstatusOperacion, 0) <> 2 --Solo facturas que no esten aprobadas, una factura rechazada solo implica que se haran correcciones, la aceptacion y el pedido aun sigue vigente
			AND ISNULL(op.IdEstatusEliminado, 0) = 0

		--Se uniran todos los montos de las diferentes consultas realizadas, convirtiendo todos los montos de pesos a dolares
		INSERT INTO @MontosDolaresDetalle
		(
		    idLineaPresupuesto,
		    MontoEjercido
		)
		--Primero de todas las facturas aprobadas, se agregan el monto total de la cantidad NO recibida por su precio unitario
		SELECT 
			idLineaPresupuesto,
			CASE 
				WHEN IdMoneda = 1 THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio((CantidadFaltante * PrecioUnitario), FechaPedido)
				ELSE (CantidadFaltante * PrecioUnitario) 
			END
		FROM @PedidosAprobados
		WHERE CantidadFaltante > 0

		UNION

		--Despues se agregan todos los pedidos aprobados pero sin una factura aprobada
		SELECT 
			lpm.IdLineaPresupuestoMes,
			CASE
				WHEN pd.IdMoneda = 1 THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(pd.Subtotal, CAST(p.CreadoEl AS DATE))
				ELSE pd.Subtotal
			END
		FROM Adinco.dbo.CO_LineaPresupuestoMes lpm
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp ON spdlp.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd ON spd.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
			INNER JOIN petrovendor.dbo.MM_SolicitudPedido sp ON sp.IdSolicitudPedido = spd.IdSolicitudPedido AND ISNULL(sp.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle pod ON pod.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
			INNER JOIN petrovendor.dbo.MM_PeticionOferta po ON po.IdPeticionOferta = pod.IdPeticionOferta AND ISNULL(po.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PedidoDetalle pd ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
			INNER JOIN Petrovendor.dbo.MM_Pedido p ON p.IdPedido = pd.IdPedido AND ISNULL(p.IdEstatusEliminado, 0) = 0 AND ISNULL(p.Cerrado, 0) = 0
			INNER JOIN petrovendor.dbo.TA_Operacion o ON o.IdDocumento = p.IdSolicitudPedido AND o.IdTipoOperacion = 9 AND o.NoVersion = p.Version AND o.IdEstatusOperacion = 2 AND ISNULL(o.IdEstatusEliminado, 0) = 0
			LEFT JOIN @PedidosAprobados pa ON pa.IdPedido = p.IdPedido
		WHERE lpm.IdPresupuesto = @presupuesto
			AND pa.IdPedido IS NULL		--filtro para excluir todos los pedidos que ya cuentan con una factura aprobada

		UNION

		--Despues se agregan las cantidades aceptadas por su precio unitario de los pedidos cerrados que cuentan con alguna aceptacion, pero sin factura aprobada 
		SELECT 
			IdLineaPresupuesto,
			CASE
				WHEN IdMoneda = 1 THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio((Cantidad * PrecioUnitario), FechaPedido)
				ELSE (Cantidad * PrecioUnitario)
			END
		FROM @PedidosCerrados

		UNION

		--Despues se agrega las compras directas que no hallan sido aprobadas
		SELECT r.IdLineaPresupuestoMes,
			CASE 
				WHEN f.IdMoneda = 1 THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(r.MontoRegistro, CAST(f.FechaTimbrado AS DATE))
				ELSE r.MontoRegistro END AS MontoDls
		FROM Petrovendor.dbo.MM_Pedidos ps
		INNER JOIN Petrovendor.dbo.TA_Operacion o ON o.IdDocumento = ps.IdIdentificador AND o.IdTipoOperacion = 14 AND ISNULL(o.IdEstatusEliminado, 0) = 0
		INNER JOIN Petrovendor.dbo.CO_Registro r ON r.IdFactura = ps.IdIdentificador
		INNER JOIN Petrovendor.dbo.FI_Factura f ON f.IdFactura = ps.IdIdentificador
		INNER JOIN adinco.dbo.CO_LineaPresupuestoMes lpm ON lpm.IdLineaPresupuestoMes = r.IdLineaPresupuestoMes 
		WHERE ps.IdTipoPedido = 1
			AND lpm.IdPresupuesto = @presupuesto
			AND o.IdEstatusOperacion NOT IN (2,3,4,5,6,7,8,10)
			
		UNION

		--Por ultimo se agregan todos los registros de gastos en Adinco
		SELECT IdPrograma,
			CASE WHEN f.IdMoneda = 1 THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(r.MontoRegistro, CAST(f.FechaTimbrado AS DATE)) 
			ELSE r.MontoRegistro END
		 FROM dbo.CO_Registro r
		 INNER JOIN dbo.FI_Factura f ON f.IdFactura = r.IdFactura 
		 INNER JOIN dbo.CO_LineaPresupuestoMes lpm ON lpm.IdLineaPresupuestoMes = r.IdPrograma
		 WHERE lpm.IdPresupuesto = @presupuesto
		 

		 --Como paso final sumamos todos los montos por linea de presupuesto
		 INSERT INTO @MontoEjercidoPorLinea
		 (
		     IdLineaPresupuesto,
		     MontoEjercido
		 )
		 SELECT idLineaPresupuesto,
			SUM(MontoEjercido)
		 FROM @MontosDolaresDetalle
		 GROUP BY idLineaPresupuesto		 

           SELECT dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
                CONCAT(RIGHT('00'+CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', DATENAME(month, dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES), ' ', YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)) AS Mes_Presupuestado,
                --CO_Area.NombreArea AS Area,
                 CASE CO.IdTipoContrato
                    WHEN 1
                    THEN CONVERT(NVARCHAR(MAX), CO_TipoServicio.ID_TIPOSER )
                    ELSE
    id_Actividad end AS ID_TIPOSER, 
                CASE CO.IdTipoContrato
                    WHEN 1
                    THEN CONVERT(NVARCHAR(MAX), CO_TipoServicio.NombreTipoServicio)
                    ELSE CONVERT(NVARCHAR(MAX), DescripcionActividadPetrolera)
                END AS CO_TipoServicio,


               CASE CO.IdTipoContrato
                    WHEN 1
                    THEN CONVERT(NVARCHAR(MAX), CO_ActividadCIEP.ID_CATACTIV)
                    ELSE CONVERT(NVARCHAR(MAX), [id_Sub-actividad])
                END AS ID_CATACTIV,
                  CASE CO.IdTipoContrato
                    WHEN 1
                    THEN CONVERT(NVARCHAR(MAX), NombreActividad)
                    ELSE CONVERT(NVARCHAR(MAX), SubactividadPetrolera)
                END AS Actividad, 
			 --CO_SubactividadPetrolera.SubactividadPetrolera AS Actividad,
                CO_TareaPetrolera.id_Tarea AS ID_CATSUBACTIV,
                CO_TareaPetrolera.TareaPetrolera AS SubActividad,


                --CO_ClasificacionAnexo4.ClasificacionAnexo4 AS Anexo4,
                --dbo.CO_LineaPresupuestoMes.ID_PADRE,
                CO_Servicio.NombreServicio AS Servicio,
                CO_Instalacion.NombreInstalacion AS Instalacion,
                --CO_Instalacion.IdInstalacionPemex AS ID_PEMEX,
                dbo.CO_LineaPresupuestoMes.Monto AS [Presupuesto_USD],
                dbo.CO_LineaPresupuestoMes.IdExcel AS ID,
                CO_ActividadPetroleraCNH.id_Actividad,
                CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
                CO_SubactividadPetrolera.[id_Sub-actividad],
                CO_SubactividadPetrolera.SubactividadPetrolera,
                CO_TareaPetrolera.id_Tarea,
                CO_TareaPetrolera.TareaPetrolera,
				ROW_NUMBER() OVER (ORDER BY CONCAT(RIGHT('00'+CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', DATENAME(month, dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES), ' ', YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)), dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS fila,
				ISNULL(me.MontoEjercido, 0) AS MontoEjercido,
				(dbo.CO_LineaPresupuestoMes.Monto - ISNULL(me.MontoEjercido, 0)) AS Remanente,
				CASE WHEN dbo.CO_LineaPresupuestoMes.Monto = 0 THEN 0
					WHEN ((ISNULL(me.MontoEjercido, 0) / dbo.CO_LineaPresupuestoMes.Monto) * 100) > 100 THEN 100
					ELSE (ISNULL(me.MontoEjercido, 0) / dbo.CO_LineaPresupuestoMes.Monto) * 100 END AS PorcentajeUsado 
         FROM dbo.CO_LineaPresupuestoMes
              LEFT OUTER JOIN CO_ActividadPetroleraCNH ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
              LEFT OUTER JOIN CO_SubactividadPetrolera ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
              LEFT OUTER JOIN CO_TareaPetrolera ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
              LEFT OUTER JOIN CO_ActividadCIEP ON dbo.CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
              LEFT OUTER JOIN CO_TipoServicio ON dbo.CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.ID_TIPOSER
              LEFT OUTER JOIN CO_SubactividadCIEP ON dbo.CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
              LEFT OUTER JOIN CO_Servicio ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
              LEFT OUTER JOIN CO_Area ON dbo.CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
              LEFT OUTER JOIN CO_Instalacion ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
              LEFT OUTER JOIN CO_Registro ON dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
              LEFT OUTER JOIN CO_ClasificacionAnexo4 ON dbo.CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
              LEFT OUTER JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
              LEFT OUTER JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
                                                      AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)
                                                      AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)
              LEFT OUTER JOIN CO_RubroInterno ON dbo.CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
			  LEFT JOIN @MontoEjercidoPorLinea me ON me.IdLineaPresupuesto = dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes

			  LEFT JOIN co_presupuesto P on P.idpresupuesto = dbo.CO_LineaPresupuestoMes.idpresupuesto 
LEFT JOIN Adinco.dbo.CO_AnioContractual AC ON AC.IdAnioContractual = P.IdAnioContractual
              JOIN Adinco.dbo.CO_Contrato CO ON CO.IdContrato = AC.IdContrato

         WHERE(dbo.CO_LineaPresupuestoMes.IdPresupuesto = @presupuesto) --and MONTH ( CO_LineaPresupuestoMes.AC_FEC_INI ) = @mes 
         GROUP BY dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
                  dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
			   CO.IdTipoContrato,
                  --CO_Area.NombreArea,
                  CO_TipoServicio.ID_TIPOSER,
                  CO_TipoServicio.NombreTipoServicio,
                  CO_ActividadCIEP.ID_CATACTIV,
                  CO_ActividadCIEP.NombreActividad,
                  --CO_SubactividadCIEP.ID_CATSUBACTIV,
                  --CO_SubactividadCIEP.NombreSubactividad,
                  dbo.CO_LineaPresupuestoMes.ID_PADRE,
                  --CO_ClasificacionAnexo4.ClasificacionAnexo4,
                  CO_Servicio.NombreServicio,
                  CO_Instalacion.NombreInstalacion,
                  CO_Instalacion.IdInstalacionPemex,
                  dbo.CO_LineaPresupuestoMes.Monto,
                  dbo.CO_LineaPresupuestoMes.IdExcel,
                  --CO_RubroInterno.NombreRubro,
                  CO_ActividadPetroleraCNH.id_Actividad,
                  CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
                  CO_SubactividadPetrolera.[id_Sub-actividad],
                  CO_SubactividadPetrolera.SubactividadPetrolera,
                  CO_TareaPetrolera.id_Tarea,
                  CO_TareaPetrolera.TareaPetrolera,
				  me.MontoEjercido
         ORDER BY Mes_Presupuestado,
                  dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES
                  --Area;
     END