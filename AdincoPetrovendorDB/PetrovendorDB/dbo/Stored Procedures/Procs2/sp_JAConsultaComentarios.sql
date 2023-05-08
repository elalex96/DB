-- =============================================
-- Modified: Luis David
-- Updated date: 18/04/2022
-- Description: Se agrupan las cotizaciones para que no se repitan dependiendo los contratos (Issue#1727)
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <02/02/2023>
-- Description:Se agrega opción para edición del comentario
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
		IdImagen INT,
		Editar VARCHAR(100)
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
		IdImagen,
		Editar
    )
    SELECT  
		   base.IdComentarioBase,
           base.Comentario,
           0,
           base.IdSolPed,
           base.FechaCreado,
           usuario.Nombre,
           base.IdUsuario,
		   ISNULL(base.IdProveedor,0),
		   MAX(IP.IdImagen),	
		   CASE WHEN @IdProveedor =base.IdProveedor THEN --> SOLO SE PUEDE EDITAR SI PERTENECE AL PROVEEDOR ACTUAL
		   '<br><a onclick="editarComentario('+CAST(base.IdComentarioBase AS VARCHAR(MAX))+',''COMENTARIO'')">Editar</a>'
		   ELSE
		   ''
		   END
    FROM dbo.JA_ComentarioBase base  (NOLOCK)
        JOIN dbo.S_Usuario usuario (NOLOCK)
            ON  base.IdUsuario = usuario.IdUsuario
        JOIN dbo.S_UsuarioProveedor uProv   (NOLOCK)
            ON usuario.IdUsuario  = uProv.IdUsuario 
			AND base.IdProveedor = uProv.IdProveedor 
		LEFT JOIN dbo.S_ImagenPerfil AS IP (NOLOCK) 
		ON base.IdProveedor = IP.IdProveedor  	
    WHERE base.IdSolPed = @IdSolPed
	GROUP BY base.IdComentarioBase,
           base.Comentario,
           base.IdSolPed,
           base.FechaCreado,
           usuario.Nombre,
           base.IdUsuario,
		   base.IdProveedor,
		   ISNULL(base.IdProveedor,0)		  		  
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
		    IPD.ImagenThumb 
		   END AS ImageProveedor	,
		   Editar
    FROM @tablaAux AS TA
	LEFT JOIN dbo.S_ImagenPerfil AS IP (NOLOCK) ON 
		TA.IdImagen = IP.IdImagen 
	LEFT JOIN dbo.PV_ImagenPredeterminada IPD  (NOLOCK)
			ON IPD.IdImagenPredeterminada=2 --> CTE
	ORDER BY FechaCreado DESC 
END