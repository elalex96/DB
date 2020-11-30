-- ============================================= 
-- Modified: DANIEL AC 
-- Updated date: 08/01/2017 
-- Description: Agregue parametro de imagen de proveedor 
-- =============================================
-- ============================================= 
-- Modified: DANIEL AC 
-- Updated date: 16/01/2017  1:40PM
-- Description: Agregue CONDICION DE QUE EL USUARIO SEA DEL PROVEEDOR DEL COMENTARIO
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAConsultaComentarios]  
(
    @IdUsuario INT,
    @IdSolPed INT,
    @IdProveedor INT
)
AS
BEGIN
    DECLARE @tablaAux TABLE
    (
        IdComentarioBase INT,
        Comentario NVARCHAR(MAX),
        IdPerfil INT,
        IdSolPed INT,
        FechaCreado DATETIME,
        Nombre NVARCHAR(MAX),
        IdUsuario INT,
		IdProveedor INT,
		ImageProveedor IMAGE
    )

    INSERT INTO @tablaAux
    (
        IdComentarioBase,
        Comentario,
        IdPerfil,
        IdSolPed,
        FechaCreado,
        Nombre,
        IdUsuario,
		IdProveedor,
		ImageProveedor
    )
    SELECT base.IdComentarioBase,
           base.Comentario,
           0,---dbo.fn_Ja_ObtenerPrimeraImagenSesion(base.IdPerfil, uProv.IdProveedor),
           base.IdSolPed,
           base.FechaCreado,
           usuario.Nombre,
           base.IdUsuario,
		   ISNULL(base.IdProveedor,0),
		   CASE WHEN DATALENGTH(IP.ImagenProveedorThumb)>0 THEN
		   IP.ImagenProveedorThumb
		   ELSE 
		   (SELECT ImagenThumb FROM dbo.PV_ImagenPredeterminada WHERE IdImagenPredeterminada=2)
		   END AS ImageProveedor		   
    FROM dbo.JA_ComentarioBase base
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = base.IdUsuario
        INNER JOIN dbo.S_UsuarioProveedor uProv
            ON uProv.IdUsuario = usuario.IdUsuario AND uProv.IdProveedor = base.IdProveedor
		LEFT JOIN dbo.S_ImagenPerfil AS IP ON 
		IP.IdProveedor = base.IdProveedor
    WHERE base.IdSolPed = @IdSolPed
    ORDER BY base.IdComentarioBase


    --Cambiar el estatus de los mensajes pendientes de notificacion
    UPDATE dbo.Ja_MensajesPendientesComentarios
    SET Visto = 1,
        Enviado = 1,
        FechaEnviado = GETDATE()
    WHERE IdPrimario IN (
                            SELECT IdComentarioBase FROM @tablaAux
                        )
          AND TipoMensaje = 0 --comentario del material
          AND Visto = 0
          AND IdProveedor = @IdProveedor

    --Retorno a la vista
    SELECT *
    FROM @tablaAux
	ORDER BY FechaCreado DESC 
END



