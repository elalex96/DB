
-- =============================================
-- Author:		<>
-- Create date: <>
-- Description:	<>
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <08-02-2019>
-- Description:	<Se borran los items agregados al carrito>
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ActualizarFechaFinalizacionCotizacion] 
	@IdSolicitudPedido INT,
	@IdProveedor INT,
	@NuevaFechaLimite DATETIME,
	@AntiguaFechaLimite DATETIME,
	@IdUsuario INT,
	@Motivo NVARCHAR(max),
	@IdOperacion INT
AS
BEGIN

   UPDATE O 
   SET O.FechaFinalizacion = @NuevaFechaLimite
   FROM dbo.TA_Operacion AS O
   INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = O.IdDocumento
   WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
   AND O.IdTipoOperacion= 6 
   AND O.IdProveedor = @IdProveedor

   UPDATE pod
	SET pod.AddPedidoTemp = 0,
		pod.AddCantidadTemp = NULL,
		pod.AddSubTotalTemp = NULL 
   FROM dbo.MM_PeticionOferta po
   INNER JOIN dbo.MM_PeticionOfertaDetalle pod ON pod.IdPeticionOferta = po.IdPeticionOferta
   WHERE po.IdSolicitudPedido = @IdSolicitudPedido

   INSERT INTO dbo.MM_HistorialCambiosCotizacion
   (
       IdSolicitudPedido,
       IdOperacion,
       FechaActual,
       FechaNueva,
       IdEditadoPor,
       FechaEdicion,
       Motivo
   )
   VALUES
   (  @IdSolicitudPedido,         -- IdSolicitudPedido - int
      @IdOperacion,         -- IdOperacion - int
      @AntiguaFechaLimite, -- FechaActual - datetime
      @NuevaFechaLimite, -- FechaNueva - datetime
      @IdUsuario,         -- IdEditadoPor - int
      GETDATE(), -- FechaEdicion - datetime
      @Motivo        -- Motivo - nvarchar(max)
       )

	SELECT 'SUCCCES'

   ---#IdTipoOperacion 6 Peticiones de oferta o cotizaciones 
    
END

