USE Petrovendor
GO
DROP PROCEDURE IF EXISTS MM_SP_GuardarGasto
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: 11/12/2019
-- Description: Se agrego validación para guardar PCN en CO_Registro si se solicito en la aceptación de pedido 
-- =============================================
-- Author:	DAVID
-- Create date: 04/05/20023
-- Description: Se agrega la validación para tomar los datos de fechainicio y fechafin a tabla de CO_Registro
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
               case when ap.InicioEjecucion is not null then
			   ap.InicioEjecucion else p.FechaRecepcionServicio end,
               case when ap.FinEjecucion is not null then
			   ap.FinEjecucion
			   else ap.Creado end,
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
        FROM dbo.MM_AceptacionPedido ap (NOLOCK)
            INNER JOIN dbo.MM_AceptacionPedidoDetalle apd (NOLOCK)
                ON ap.IdAceptacionPedido = apd.IdAceptacionPedido
            INNER JOIN dbo.MM_PedidoDetalle pd (NOLOCK)
                ON apd.IdPedidoDetalle = pd.IdPedidoDetalle
            INNER JOIN dbo.MM_Pedido p (NOLOCK)
                ON pd.IdPedido = p.IdPedido
            INNER JOIN dbo.MM_PeticionOfertaDetalle pod (NOLOCK)
                ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
            INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp (NOLOCK)
                ON pod.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
            LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI (NOLOCK)
                ON apd.IdAceptacionPedidoDetalle = APDI.IdAceptacionPedidoDetalle
            INNER JOIN Adinco.dbo.CO_Instalacion i (NOLOCK)
                ON APDI.IdInstalacion = i.IdInstalacion
            LEFT JOIN MM_PCN_ValoresPesos vp (NOLOCK)
                ON apd.IdAceptacionPedidoDetalle = vp.IdAceptacionPedidoDetalle
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
        FROM dbo.MM_AceptacionPedido ap (NOLOCK)
            INNER JOIN dbo.MM_AceptacionPedidoDetalle apd (NOLOCK)
                ON ap.IdAceptacionPedido = apd.IdAceptacionPedido
            INNER JOIN dbo.MM_PedidoDetalle pd (NOLOCK)
                ON apd.IdPedidoDetalle = pd.IdPedidoDetalle
            INNER JOIN dbo.MM_Pedido p (NOLOCK)
                ON pd.IdPedido = p.IdPedido
            INNER JOIN dbo.MM_PeticionOfertaDetalle pod (NOLOCK)
                ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
            INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp (NOLOCK)
                ON pod.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
            LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI (NOLOCK)
                ON apd.IdAceptacionPedidoDetalle = APDI.IdAceptacionPedidoDetalle
            INNER JOIN Adinco.dbo.CO_Instalacion i (NOLOCK)
                ON APDI.IdInstalacion = i.IdInstalacion
            LEFT JOIN MM_PCN_ValoresPesos vp (NOLOCK)
                ON apd.IdAceptacionPedidoDetalle = vp.IdAceptacionPedidoDetalle
        WHERE ap.IdAceptacionPedido = @IdAceptacionPedido
    END
END
