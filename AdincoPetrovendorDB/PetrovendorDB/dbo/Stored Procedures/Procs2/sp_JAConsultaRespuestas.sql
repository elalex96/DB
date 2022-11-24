-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
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
           0,
           respuesta.FechaCreado,
           usuario.Nombre,
		   respuesta.IdUsuario,
		   ISNULL(respuesta.IdProveedor,0),
		   CASE WHEN DATALENGTH(IP.ImagenProveedorThumb)>0 THEN
		   IP.ImagenProveedorThumb
		   ELSE 
		   IPD.ImagenThumb 
		   END AS ImageProveedor
    FROM dbo.JA_ComentarioRelacion relacion (NOLOCK)
        JOIN dbo.JA_ComentarioRespuesta respuesta (NOLOCK)
            ON relacion.IdComentarioRespuesta = respuesta.IdComentarioRespuesta 
        JOIN dbo.S_Usuario usuario (NOLOCK)
            ON respuesta.IdUsuario = usuario.IdUsuario 
		LEFT JOIN dbo.S_ImagenPerfil AS IP  (NOLOCK)
			ON respuesta.IdProveedor = IP.IdProveedor
		LEFT JOIN dbo.PV_ImagenPredeterminada IPD  (NOLOCK)
			ON IPD.IdImagenPredeterminada=2 --> CTE
    WHERE relacion.IdComentarioBase = @IdComentarioBase 
	ORDER BY relacion.IdComentarioBase DESC

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
    SELECT * FROM @tablaAux 
	ORDER BY FechaCreado DESC
END