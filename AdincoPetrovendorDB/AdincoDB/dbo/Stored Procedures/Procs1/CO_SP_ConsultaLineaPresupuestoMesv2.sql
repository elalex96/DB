-- =============================================
-- Author:		Miguel Gomez
-- Create date: 10 Noviembre 2014
-- Description:	Presupuestos
-- =============================================
-- =============================================
-- Modified:      <Pedro, Acuña>
-- Updated date: <02/04/2018>
-- Description: <Se agrega el numero de fila de retorno para sacar el numero de pagina en donde se encuentra el presupuesto seleccionado>
-- =============================================
-- Modified:      <Alexander Gomez>
-- Updated date: <18/12/2019>
-- Description: <Se homologo ocn el spo de adinco sp_CO_ConsultaLineaPresupuestoMes>
-- =============================================
-- Modified:      Daniel AC
-- Updated date: <08/01/2021>
-- Description: Se agrego NOLOCK en tablas 
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
		FROM Adinco.dbo.CO_LineaPresupuestoMes lpm (NOLOCK)
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp (NOLOCK) 
			ON lpm.IdLineaPresupuestoMes = spdlp.IdLineaPresupuesto AND  lpm.IdPresupuesto = @presupuesto
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd (NOLOCK) 
			ON spdlp.IdSolicitudPedidoDetalle=spd.IdSolicitudPedidoDetalle 
			INNER JOIN petrovendor.dbo.MM_SolicitudPedido sp (NOLOCK) 
			ON spd.IdSolicitudPedido = sp.IdSolicitudPedido AND ISNULL(sp.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle pod (NOLOCK) 
			ON spdlp.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle 
			INNER JOIN petrovendor.dbo.MM_PeticionOferta po (NOLOCK) 
			ON pod.IdPeticionOferta = po.IdPeticionOferta AND ISNULL(po.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PedidoDetalle pd (NOLOCK) 
			ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle 
			INNER JOIN Petrovendor.dbo.MM_Pedido p (NOLOCK) 
			ON pd.IdPedido=p.IdPedido  AND ISNULL(p.IdEstatusEliminado, 0) = 0 AND ISNULL(p.Cerrado, 0) = 0
			INNER JOIN petrovendor.dbo.TA_Operacion o (NOLOCK) 
			ON p.IdSolicitudPedido=o.IdDocumento  AND o.IdTipoOperacion = 9 AND p.Version=o.NoVersion AND o.IdEstatusOperacion = 2 AND ISNULL(o.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle apd  (NOLOCK) 
			ON pd.IdPedidoDetalle=apd.IdPedidoDetalle  
			INNER JOIN petrovendor.dbo.MM_AceptacionPedido ap  (NOLOCK) 
			ON apd.IdAceptacionPedido=ap.IdAceptacionPedido AND ISNULL(ap.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_AceptacionFactura af (NOLOCK) 
			ON apd.IdAceptacionPedido=af.IdAceptacionPedido AND ISNULL(af.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.TA_Operacion op (NOLOCK) 
			ON af.IdAceptacionFactura=op.IdDocumento AND op.IdTipoOperacion = 10 
			AND op.IdEstatusOperacion = 2 AND ISNULL(op.IdEstatusEliminado, 0) = 0
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
		FROM Adinco.dbo.CO_LineaPresupuestoMes lpm (NOLOCK)
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp (NOLOCK) 
			ON lpm.IdLineaPresupuestoMes=spdlp.IdLineaPresupuesto AND  lpm.IdPresupuesto = @presupuesto
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd (NOLOCK) 
			ON spdlp.IdSolicitudPedidoDetalle=spd.IdSolicitudPedidoDetalle 
			INNER JOIN petrovendor.dbo.MM_SolicitudPedido sp (NOLOCK) 
			ON spd.IdSolicitudPedido=sp.IdSolicitudPedido  AND ISNULL(sp.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle pod (NOLOCK) 
			ON  spdlp.IdSolicitudPedidoDetalle=pod.IdSolicitudPedidoDetalle
			INNER JOIN petrovendor.dbo.MM_PeticionOferta po (NOLOCK) 
			ON pod.IdPeticionOferta=po.IdPeticionOferta AND ISNULL(po.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PedidoDetalle pd (NOLOCK) 
			ON pod.IdPeticionOfertaDetalle= pd.IdPeticionOfertaDetalle 
			INNER JOIN Petrovendor.dbo.MM_Pedido p (NOLOCK) 
			ON pd.IdPedido=p.IdPedido AND ISNULL(p.IdEstatusEliminado, 0) = 0 AND ISNULL(p.Cerrado, 0) = 1
			INNER JOIN petrovendor.dbo.TA_Operacion o (NOLOCK) 
			ON p.IdSolicitudPedido=o.IdDocumento AND o.IdTipoOperacion = 9 
			AND p.Version =o.NoVersion  
			AND o.IdEstatusOperacion = 2 
			AND ISNULL(o.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle apd (NOLOCK) 
			ON pd.IdPedidoDetalle =apd.IdPedidoDetalle 
			INNER JOIN petrovendor.dbo.MM_AceptacionPedido ap (NOLOCK) 
			ON apd.IdAceptacionPedido=ap.IdAceptacionPedido  AND ISNULL(ap.IdEstatusEliminado, 0) = 0
			LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura af (NOLOCK) 
			ON apd.IdAceptacionPedido  = af.IdAceptacionPedido AND ISNULL(af.IdEstatusEliminado, 0) = 0
			LEFT JOIN Petrovendor.dbo.TA_Operacion op (NOLOCK) 
			ON af.IdAceptacionFactura  = op.IdDocumento AND op.IdTipoOperacion = 10 
				AND ISNULL(op.IdEstatusOperacion, 0) <> 2 --Solo facturas que no esten aprobadas, una factura rechazada solo implica que se haran correcciones, la aceptacion y el pedido aun sigue vigente
				AND ISNULL(op.IdEstatusEliminado, 0) = 0
		--WHERE

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
		FROM Adinco.dbo.CO_LineaPresupuestoMes lpm (NOLOCK)
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp (NOLOCK) 
			ON lpm.IdLineaPresupuestoMes =spdlp.IdLineaPresupuesto 
			AND lpm.IdPresupuesto = @presupuesto
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd (NOLOCK) 
			ON spdlp.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle 
			INNER JOIN petrovendor.dbo.MM_SolicitudPedido sp (NOLOCK) 
			ON  spd.IdSolicitudPedido = sp.IdSolicitudPedido 
			AND ISNULL(sp.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle pod (NOLOCK) 
			ON spdlp.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
			INNER JOIN petrovendor.dbo.MM_PeticionOferta po (NOLOCK) 
			ON pod.IdPeticionOferta = po.IdPeticionOferta 
			AND ISNULL(po.IdEstatusEliminado, 0) = 0
			INNER JOIN Petrovendor.dbo.MM_PedidoDetalle pd (NOLOCK) 
			ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle 
			INNER JOIN Petrovendor.dbo.MM_Pedido p (NOLOCK) 
			ON pd.IdPedido = p.IdPedido 
			AND ISNULL(p.IdEstatusEliminado, 0) = 0 
			AND ISNULL(p.Cerrado, 0) = 0
			INNER JOIN petrovendor.dbo.TA_Operacion o (NOLOCK) 
			ON p.IdSolicitudPedido = o.IdDocumento AND o.IdTipoOperacion = 9 
			AND  p.Version =o.NoVersion 
			AND o.IdEstatusOperacion = 2 
			AND ISNULL(o.IdEstatusEliminado, 0) = 0
			LEFT JOIN @PedidosAprobados pa ON p.IdPedido =pa.IdPedido AND pa.IdPedido IS NULL		--filtro para excluir todos los pedidos que ya cuentan con una factura aprobada

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
		FROM Petrovendor.dbo.MM_Pedidos ps (NOLOCK)
		INNER JOIN Petrovendor.dbo.TA_Operacion o (NOLOCK) 
		ON ps.IdIdentificador = o.IdDocumento AND o.IdEstatusOperacion NOT IN (2,3,4,5,6,7,8,10)
		AND o.IdTipoOperacion = 14 
		AND ISNULL(o.IdEstatusEliminado, 0) = 0
		INNER JOIN Petrovendor.dbo.CO_Registro r (NOLOCK) 
		ON ps.IdIdentificador= r.IdFactura 
		INNER JOIN Petrovendor.dbo.FI_Factura f (NOLOCK) 
		ON ps.IdIdentificador = f.IdFactura 
		INNER JOIN adinco.dbo.CO_LineaPresupuestoMes lpm (NOLOCK) 
		ON r.IdLineaPresupuestoMes  = lpm.IdLineaPresupuestoMes  AND lpm.IdPresupuesto = @presupuesto
		WHERE ps.IdTipoPedido = 1
			
			
			
		UNION

		--Por ultimo se agregan todos los registros de gastos en Adinco
		SELECT IdPrograma,
			CASE WHEN f.IdMoneda = 1 THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(r.MontoRegistro, CAST(f.FechaTimbrado AS DATE)) 
			ELSE r.MontoRegistro END
		 FROM dbo.CO_Registro r (NOLOCK)
		 INNER JOIN dbo.FI_Factura f (NOLOCK) 
		 ON r.IdFactura  = f.IdFactura
		 INNER JOIN dbo.CO_LineaPresupuestoMes lpm (NOLOCK) 
		 ON r.IdPrograma = lpm.IdLineaPresupuestoMes AND lpm.IdPresupuesto = @presupuesto
		 --WHERE 
		 

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
         FROM dbo.CO_LineaPresupuestoMes (NOLOCK)
              LEFT OUTER JOIN CO_ActividadPetroleraCNH (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
              LEFT OUTER JOIN CO_SubactividadPetrolera (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
              LEFT OUTER JOIN CO_TareaPetrolera (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
              LEFT OUTER JOIN CO_ActividadCIEP (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
              LEFT OUTER JOIN CO_TipoServicio (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.ID_TIPOSER
              LEFT OUTER JOIN CO_SubactividadCIEP (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
              LEFT OUTER JOIN CO_Servicio (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
              LEFT OUTER JOIN CO_Area (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
              LEFT OUTER JOIN CO_Instalacion (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
              LEFT OUTER JOIN CO_Registro (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
              LEFT OUTER JOIN CO_ClasificacionAnexo4 (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
              LEFT OUTER JOIN FI_Factura (NOLOCK) 
			  ON  CO_Registro.IdFactura = FI_Factura.IdFactura
              LEFT OUTER JOIN CO_TipoCambioMensual (NOLOCK) 
			  ON FI_Factura.IdMoneda = CO_TipoCambioMensual.IdMoneda 
                                                      AND  MONTH(CO_Registro.MesPresentacion) = CO_TipoCambioMensual.IdMes
                                                      AND YEAR(CO_Registro.MesPresentacion) = CO_TipoCambioMensual.Anio 
              LEFT OUTER JOIN CO_RubroInterno (NOLOCK) 
			  ON dbo.CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
			  LEFT JOIN @MontoEjercidoPorLinea me 
			  ON dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes=me.IdLineaPresupuesto
			  LEFT JOIN co_presupuesto P (NOLOCK) 
			  on  dbo.CO_LineaPresupuestoMes.idpresupuesto =  P.idpresupuesto
			  LEFT JOIN Adinco.dbo.CO_AnioContractual AC (NOLOCK) 
			  ON  P.IdAnioContractual = AC.IdAnioContractual
              JOIN Adinco.dbo.CO_Contrato CO (NOLOCK) 
			  ON AC.IdContrato = CO.IdContrato 
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