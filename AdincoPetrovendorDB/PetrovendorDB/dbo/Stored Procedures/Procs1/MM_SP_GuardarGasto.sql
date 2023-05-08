-- =============================================
-- Author:	Daniel AC
-- Create date: 11/12/2019
-- Description: Se agrego validación para guardar PCN en CO_Registro si se solicito en la aceptación de pedido 
-- =============================================
CREATE PROCEDURE [dbo].[MM_SP_GuardarGasto]
    @IdFactura INT,
    @IdAceptacionPedido INT = NULL,  
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL

AS
BEGIN
	DECLARE @IncluyePCN BIT

	SELECT @IncluyePCN=PedirCarta
	FROM dbo.RelacionCartaCNPedido 
	WHERE IdAceptacionPedido=@IdAceptacionPedido
	

    IF NOT EXISTS (SELECT 1 FROM dbo.CO_Registro r INNER JOIN dbo.FI_Factura f ON f.IdFactura = r.IdFactura AND f.Activa = 1 WHERE r.IdFactura = @IdFactura)
    BEGIN
        INSERT INTO dbo.CO_Registro
        (
            IdFactura,
            MontoRegistro,
            InicioEjecucion,
            FinEjecucion,
            Comentarios,
            MesPresentacion,
            IdUsuarioCreadoPor,
            FecMovto,
            IdInstalacion,
            CreadoPor,
            IdCatalogoCuentasSH,
            CentroCostos,
            CuentaContable,
            IdLineaPresupuestoMes,
            Poliza,
            CostosAtribuiblesAdministracion,
            PCN,
            IdGastoRubro,
            IdCBSISH,
            IdAceptacionPedidoDetalle
        )
        SELECT @IdFactura,
               pd.PrecioUnitario * APDI.Cantidad,
               p.FechaRecepcionServicio,
               ap.Creado,
               CONCAT(pod.MaterialCotizadoTextoC, ' - ', i.NombreInstalacion COLLATE Modern_Spanish_CI_AS),
               DATEADD(MONTH, DATEDIFF(MONTH, 0, p.FechaRecepcionServicio), 0),
               @IdUsuario,
               GETDATE(),
               APDI.IdInstalacion,
               @IdUsuario,
               NULL,
               spdlp.IdCentroCosto,
               NULL,
               APDI.IdLineaPresupuesto,
               NULL,
               0,
			   CASE WHEN ISNULL(@IncluyePCN,0)=1 THEN 
               apd.PCN
			   ELSE 
			   NULL
			   END,
               apd.ClasificacionCN,
               vp.IdCatalogoHidrocarburos,
               apd.IdAceptacionPedidoDetalle
        FROM dbo.MM_AceptacionPedido ap
            INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
                ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
            INNER JOIN dbo.MM_PedidoDetalle pd
                ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
            INNER JOIN dbo.MM_Pedido p
                ON p.IdPedido = pd.IdPedido
            INNER JOIN dbo.MM_PeticionOfertaDetalle pod
                ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle
            INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp
                ON spdlp.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
            LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI
                ON APDI.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
            INNER JOIN Adinco.dbo.CO_Instalacion i
                ON i.IdInstalacion = APDI.IdInstalacion
            LEFT JOIN MM_PCN_ValoresPesos vp
                ON vp.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
        WHERE ap.IdAceptacionPedido = @IdAceptacionPedido

        SELECT @IdFactura,
               pd.PrecioUnitario * APDI.Cantidad,
               p.FechaRecepcionServicio,
               ap.Creado,
               CONCAT(pod.MaterialCotizadoTextoC, ' - ', i.NombreInstalacion COLLATE Modern_Spanish_CI_AS),
               DATEADD(MONTH, DATEDIFF(MONTH, 0, p.FechaRecepcionServicio), 0),
               @IdUsuario,
               GETDATE(),
               APDI.IdInstalacion,
               @IdUsuario,
               NULL,
               spdlp.IdCentroCosto,
               NULL,
               APDI.IdLineaPresupuesto,
               NULL,
               0,
			   CASE WHEN ISNULL(@IncluyePCN,0)=1 THEN 
               apd.PCN
			   ELSE 
			   NULL
			   END,
               apd.ClasificacionCN,
               vp.IdCatalogoHidrocarburos,
               apd.IdAceptacionPedidoDetalle
        FROM dbo.MM_AceptacionPedido ap
            INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
                ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
            INNER JOIN dbo.MM_PedidoDetalle pd
                ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
            INNER JOIN dbo.MM_Pedido p
                ON p.IdPedido = pd.IdPedido
            INNER JOIN dbo.MM_PeticionOfertaDetalle pod
                ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle
            INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp
                ON spdlp.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
            LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI
                ON APDI.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
            INNER JOIN Adinco.dbo.CO_Instalacion i
                ON i.IdInstalacion = APDI.IdInstalacion
            LEFT JOIN MM_PCN_ValoresPesos vp
                ON vp.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
        WHERE ap.IdAceptacionPedido = @IdAceptacionPedido
    END
END


