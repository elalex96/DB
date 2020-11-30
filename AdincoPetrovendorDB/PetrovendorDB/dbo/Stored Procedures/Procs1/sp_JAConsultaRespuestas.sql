-- ============================================= 
-- Modified: DANIEL AC 
-- Updated date: 08/01/2017 
-- Description: Agregue parametro de imagen de proveedor 
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAConsultaRespuestas] (
@IdComentarioBase INT,
@IdProveedor INT)
AS
BEGIN
 DECLARE @tablaAux TABLE
    (
        IdComentarioRespuesta INT,
        Respuesta NVARCHAR(MAX),
        IdPerfil INT,
        FechaCreado DATETIME,
        Nombre NVARCHAR(MAX),
		IdUsuario INT,
		IdProveedor INT,
		ImagenProveedor IMAGE
    )

	INSERT INTO @tablaAux
	(
	    IdComentarioRespuesta,
	    Respuesta,
	    IdPerfil,
	    FechaCreado,
	    Nombre,
	    IdUsuario,
		IdProveedor,
		ImagenProveedor
	)
    SELECT relacion.IdComentarioRespuesta,
           respuesta.Respuesta,
           0,---respuesta.IdPerfil, Se comenta para no generar conflictos de imagen del proveedor 
           respuesta.FechaCreado,
           usuario.Nombre,
		   respuesta.IdUsuario,
		   ISNULL(respuesta.IdProveedor,0),
		   CASE WHEN DATALENGTH(IP.ImagenProveedorThumb)>0 THEN
		   IP.ImagenProveedorThumb
		   ELSE 
		   (SELECT ImagenThumb FROM dbo.PV_ImagenPredeterminada WHERE IdImagenPredeterminada=2)
		   END AS ImageProveedor
    FROM dbo.JA_ComentarioRelacion relacion
        INNER JOIN dbo.JA_ComentarioRespuesta respuesta
            ON respuesta.IdComentarioRespuesta = relacion.IdComentarioRespuesta
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = respuesta.IdUsuario
		LEFT JOIN dbo.S_ImagenPerfil AS IP ON 
		IP.IdProveedor = respuesta.IdProveedor
    WHERE relacion.IdComentarioBase = @IdComentarioBase ORDER BY relacion.IdComentarioBase DESC

	--Cambiar el estatus de los mensajes pendientes de notificacion
    UPDATE mensajes
    SET Visto = 1,
        Enviado = 1,
        FechaEnviado = GETDATE()
    FROM Ja_MensajesPendientesComentarios mensajes
    WHERE IdPrimario IN (
                            SELECT IdComentarioRespuesta FROM @tablaAux
                        )
          AND TipoMensaje = 1 -- respuesta al comentario de la convocatoria
		  AND Visto = 0
		  AND IdProveedor = @IdProveedor

	--Retorno a la vista
    SELECT * FROM @tablaAux ORDER BY FechaCreado DESC
END