-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Modified date: <02/Enero/2018>
-- Description:	<se insertan los comentarios url y id del proveedor que intenta acceder a una pagina ala cual su rol no tiene permitido acceder >
-- =============================================
CREATE PROCEDURE SP_DG_InsertUrlSinPermiso
    @Comentario NVARCHAR(MAX),
    @Url NVARCHAR(MAX),
    @IdProveedor INT,
    @IdUsuario INT,
    @IdContrato INT,
    @fchRegistro DATETIME
AS
BEGIN
    INSERT INTO dbo.SinPermisoUrlCorreo
    (
        Comentario,
        Url,
        IdProveedor
    )
    VALUES
    (   @Comentario, -- Comentario - nvarchar(max)
        @Url,        -- Url - nvarchar(max)
        @IdProveedor -- IdProveedor - int
    )
END