-- =============================================
-- Author:		DANIEL AC
-- update date: 09-01-2018
-- Description:Agregue parametros de contrato e imagen de proveedor 
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAConsultaRespuestasConvocatoria] (
@IdComentarioBase INT, 
@IdProveedor INT,
@IdUsuario INT,
@IdContrato INT,
@FechaRegistro DATETIME)
AS
BEGIN
    DECLARE @tablaAux TABLE
    (
        IdRespuestaConvocatoria INT,
        Respuesta NVARCHAR(MAX),
        IdPerfil INT,
        FechaCreado DATETIME,
        Nombre NVARCHAR(MAX),
		ImagenProveedor IMAGE
    )

    INSERT INTO @tablaAux
    (
        IdRespuestaConvocatoria,
        Respuesta,
        IdPerfil,
        FechaCreado,
        Nombre,
		ImagenProveedor
    )
    SELECT relacion.IdRespuestaConvocatoria,
           respuesta.Respuesta,
           respuesta.IdPerfil,
           respuesta.FechaCreado,
           usuario.Nombre,
		   CASE WHEN DATALENGTH(IP.ImagenProveedorThumb)> 0 THEN 
			 IP.ImagenProveedorThumb
			ELSE 
				(SELECT  ImagenThumb FROM dbo.PV_ImagenPredeterminada WHERE IdImagenPredeterminada=2)  --IMAGEN PREDETERMINADA DEL PROVEEDOR 
		   END AS ImagenProveedor
    FROM dbo.JA_ComentarioConvocatoriaRelacion relacion
        INNER JOIN dbo.JA_ComentariosBasesConvocatoriaRespuesta respuesta
            ON respuesta.IdRespuesta = relacion.IdRespuestaConvocatoria
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = respuesta.Idusuario
		LEFT JOIN dbo.S_ImagenPerfil IP 
			ON ip.IdProveedor=respuesta.IdProveedorCreador
    WHERE relacion.IdComentarioBase = @IdComentarioBase
    ORDER BY relacion.IdComentarioBase DESC

    --Cambiar el estatus de los mensajes pendientes de notificacion
    UPDATE mensajes
    SET Visto = 1,
        Enviado = 1,
        FechaEnviado = GETDATE()
    FROM Ja_MensajesPendientesComentarios mensajes
    WHERE IdPrimario IN (
                            SELECT IdRespuestaConvocatoria FROM @tablaAux
                        )
          AND TipoMensaje = 3 -- respuesta al comentario de la convocatoria
		  AND Visto = 0
		  AND IdProveedor = @IdProveedor
	
	--Retorno a la vista
    SELECT * FROM @tablaAux
	ORDER BY FechaCreado DESC
END
