USE Petrovendor
GO
DROP PROCEDURE IF EXISTS sp_JAConsultaComentarios
GO
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
-- Modified: Luis David
-- Updated date: 18/04/2022
-- Description: Se agrupan las cotizaciones para que no se repitan dependiendo los contratos (Issue#1727)
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
		IdImagen INT
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
		IdImagen
    )
    SELECT base.IdComentarioBase,
           base.Comentario,
           0,---dbo.fn_Ja_ObtenerPrimeraImagenSesion(base.IdPerfil, uProv.IdProveedor),
           base.IdSolPed,
           base.FechaCreado,
           usuario.Nombre,
           base.IdUsuario,
		   ISNULL(base.IdProveedor,0),
		   IP.IdImagen		   
    FROM dbo.JA_ComentarioBase base
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = base.IdUsuario
        INNER JOIN dbo.S_UsuarioProveedor uProv
            ON uProv.IdUsuario = usuario.IdUsuario AND uProv.IdProveedor = base.IdProveedor
		LEFT JOIN dbo.S_ImagenPerfil AS IP ON 
		IP.IdProveedor = base.IdProveedor
    WHERE base.IdSolPed = @IdSolPed
	GROUP BY base.IdComentarioBase,
           base.Comentario,
           base.IdSolPed,
           base.FechaCreado,
           usuario.Nombre,
           base.IdUsuario,
		   ISNULL(base.IdProveedor,0),
		   IP.IdImagen
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
    SELECT 
		TA.IdComentarioBase,
        TA.Comentario,
        TA.IdPerfil,
        TA.IdSolPed,
        TA.FechaCreado,
        TA.Nombre,
        TA.IdUsuario,
		TA.IdProveedor,
		CASE WHEN DATALENGTH(IP.ImagenProveedorThumb)>0 THEN
		   IP.ImagenProveedorThumb
		   ELSE 
		   (SELECT ImagenThumb FROM dbo.PV_ImagenPredeterminada WHERE IdImagenPredeterminada=2)
		   END AS ImageProveedor		   
    FROM @tablaAux AS TA
	LEFT JOIN dbo.S_ImagenPerfil AS IP ON 
		TA.IdImagen = IP.IdImagen 
	ORDER BY FechaCreado DESC 
END
