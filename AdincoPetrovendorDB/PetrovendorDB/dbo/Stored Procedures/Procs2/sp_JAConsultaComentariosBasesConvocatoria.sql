-- =============================================
-- Author:		DANIEL AC
-- update date: 09-01-2018
-- Description:Agregue parametros de contrato e imagen de proveedor 
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAConsultaComentariosBasesConvocatoria] 
(@IdEncabezado INT, 
@IdProveedor INT,
@IdContrato INT,
@IdUsuario INT,
@FechaRegistro DATETIME
)
AS
BEGIN
    DECLARE @tablaAux TABLE
    (
        IdComentarioBases INT,
        Comentario NVARCHAR(MAX),
        IdPerfil INT,
        IdEncabezado INT,
        FechaCreado DATETIME,
        Nombre NVARCHAR(MAX),
        IdUsuario INT,
		ImageProveedor IMAGE
    )

    INSERT INTO @tablaAux
    (
        IdComentarioBases,
        Comentario,
        IdPerfil,
        IdEncabezado,
        FechaCreado,
        Nombre,
        IdUsuario,
		ImageProveedor
    )
    SELECT base.IdComentarioBases,
           base.Comentario,
           base.IdPerfil,
           base.IdEncabezado,
           base.FechaCreado,
           usuario.Nombre,
           base.IdUsuario,
		   CASE WHEN  DATALENGTH(IP.ImagenProveedorThumb)> 0 THEN 
			IP.ImagenProveedorThumb
		   ELSE
			 (SELECT ImagenThumb FROM dbo.PV_ImagenPredeterminada WHERE IdImagenPredeterminada= 2) ---IMAGEN PREDERTERMINADA PARA PROVEEDOR
		   END AS ImageProveedor
    FROM dbo.JA_ComentariosBasesConvocatoria base
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = base.IdUsuario
		LEFT JOIN dbo.S_ImagenPerfil IP ON 
		IP.IdProveedor=BASE.IdProveedorCreador
    WHERE base.IdEncabezado = @IdEncabezado

    --Cambiar el estatus de los mensajes pendientes de notificacion
    UPDATE dbo.Ja_MensajesPendientesComentarios
    SET Visto = 1,
        Enviado = 1,
        FechaEnviado = GETDATE()
    WHERE IdPrimario IN (
                            SELECT IdComentarioBases FROM @tablaAux
                        )
          AND TipoMensaje = 2 --comentario base de la convocatoria
          AND Visto = 0
		  AND IdProveedor = @IdProveedor

	--Retorno a la vista
    SELECT * FROM @tablaAux
	ORDER BY FechaCreado DESC
END

