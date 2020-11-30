
CREATE PROCEDURE [dbo].[SP_MM_ConsultarHistorialFechaCotizacion]
	@IdProveedor INT,
	@IdSolicitudPedido INT,
	@IdOperacion INT
AS
BEGIN
     
	  SELECT HC.Id_Historial, U.Nombre, HC.FechaEdicion, HC.Motivo,'De:'+ CAST(HC.FechaActual AS NVARCHAR(150)) + ' a: '+CAST(HC.FechaNueva AS NVARCHAR(150)) AS Cambio
	  FROM dbo.MM_HistorialCambiosCotizacion AS HC
	  INNER JOIN dbo.TA_Operacion AS O ON O.IdOperacion= HC.IdOperacion
	  INNER JOIN dbo.S_Usuario AS U ON U.IdUsuario = HC.IdEditadoPor
	  WHERE O.IdOperacion =	@IdOperacion
	  AND HC.IdSolicitudPedido= O.IdDocumento
	  AND O.IdTipoOperacion= 6
	  AND HC.IdSolicitudPedido =  @IdSolicitudPedido
	  AND O.IdProveedor=@IdProveedor
END




