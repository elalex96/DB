-- =============================================
-- Author:	Daniel AC
-- Create date: <02/02/2023>
-- Description:Se agrega opción para edición de la respuesta
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
		IdImagen INT,
		ImagenProveedor IMAGE,
		Editar VARCHAR(100)
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
		IdImagen,
		Editar
	)
    SELECT relacion.IdComentarioRespuesta,
           respuesta.Respuesta,
           0,
           respuesta.FechaCreado,
           usuario.Nombre,
		   respuesta.IdUsuario,
		   ISNULL(respuesta.IdProveedor,0),
		   MAX(IP.IdImagen),
		   CASE WHEN @IdProveedor =respuesta.IdProveedor THEN --> SOLO SE PUEDE EDITAR SI PERTENECE AL PROVEEDOR ACTUAL
		   '<br><a onclick="editarComentario('+CAST(respuesta.IdComentarioRespuesta AS VARCHAR(MAX))+',''RESPUESTA'')">Editar</a>'
		   ELSE 
		   ''
		   END
    FROM dbo.JA_ComentarioRelacion relacion (NOLOCK)
        JOIN dbo.JA_ComentarioRespuesta respuesta (NOLOCK)
            ON relacion.IdComentarioRespuesta = respuesta.IdComentarioRespuesta 
        JOIN dbo.S_Usuario usuario (NOLOCK)
            ON respuesta.IdUsuario = usuario.IdUsuario 
		LEFT JOIN dbo.S_ImagenPerfil AS IP  (NOLOCK)
			ON respuesta.IdProveedor = IP.IdProveedor	
    WHERE relacion.IdComentarioBase = @IdComentarioBase 
	GROUP BY 
	relacion.IdComentarioBase,
	respuesta.IdComentarioRespuesta,
	relacion.IdComentarioRespuesta,
    respuesta.Respuesta,
	respuesta.FechaCreado,
    usuario.Nombre,
	respuesta.IdUsuario,
	respuesta.IdProveedor
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
    SELECT 
		TA.IdComentarioRespuesta,
        TA.Respuesta,
        TA.IdPerfil,
        TA.FechaCreado,
        TA.Nombre,
		TA.IdUsuario,
		TA.IdProveedor,	
		CASE WHEN DATALENGTH(IP.ImagenProveedorThumb)>0 THEN
		   IP.ImagenProveedorThumb
		ELSE 
		   IPD.ImagenThumb
		END AS ImagenProveedor,
		TA.Editar 
	FROM @tablaAux TA
	LEFT JOIN dbo.S_ImagenPerfil AS IP (NOLOCK) ON 
		TA.IdImagen = IP.IdImagen 
	LEFT JOIN dbo.PV_ImagenPredeterminada IPD  (NOLOCK)
			ON IPD.IdImagenPredeterminada=2 --> CTE
	ORDER BY TA.FechaCreado DESC
END