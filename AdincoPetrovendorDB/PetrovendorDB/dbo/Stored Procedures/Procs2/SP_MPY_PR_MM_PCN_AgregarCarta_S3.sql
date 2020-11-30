-- =============================================
-- Author:		Daniel Cruz
-- Create date: 03-05-18
-- Description:	Agregar carta de contenido nacional con información del documento 
-- ============================================= 
-- Author:		Jose Roman
-- Create date: 19-09-18
-- Description:	Se devuelven los aprobadores de CN 
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_MPY_PR_MM_PCN_AgregarCarta_S3]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdUsuario INT,
    @IdTipoDocumento INT,
    @IdEstatusDocumento INT,
    @Comentario NVARCHAR(MAX),
    @IdAceptacionPedido INT,
    @CartaPCN NVARCHAR(MAX),
    @Verificable BIT,
    @IdContrato INT = NULL,
    @FechaRegistro DATETIME = NULL,

    /*PARAMETROS DE LOS DOCUMENTOS*/
    @C_IDENTIFICADOR NVARCHAR(MAX),
    @C_MIME NVARCHAR(MAX),
    @C_EXTENSION NVARCHAR(MAX),
    @C_NOMBREARCHIVO NVARCHAR(MAX),
    @C_CARPETA NVARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @IdDocumento INT;
    DECLARE @IdAceptacionCartaPCN INT;

    INSERT INTO [dbo].[S_Documento_S3]
    (
        [IdTipoDocumento],
        [IdUsuario],
        [IdTipoValidacionDocumento],
        [IdProveedor],
        [Activo],
        [Documento],
        [CreadoPor],
        [CreadoEl],
        [Identificador],
        [Carpeta],
        [Extension],
        [Mime],
        [NombreDocumento]
    )
    VALUES
    (@IdTipoDocumento,
     @IdUsuario,
     @IdEstatusDocumento,
     @IdProveedor,
     1  ,
     @CartaPCN,
     @IdUsuario,
     GETDATE(),
     @C_IDENTIFICADOR,
     @C_CARPETA,
     @C_EXTENSION,
     @C_MIME,
     @C_NOMBREARCHIVO
    );


    SET @IdDocumento =
    (
        SELECT @@IDENTITY
    );

    INSERT INTO [dbo].[MPY_MM_AceptacionCartaPCN]
    (
        [IdAceptacionPedido],
        [IdDocumento],
        [CreadoPor],
        [CreadoEl],
        [IdEstatus],
        [Activo],
        [ComentarioProveedor],
        [Verificable]
    )
    VALUES
    (@IdAceptacionPedido, @IdDocumento, @IdUsuario, GETDATE(), @IdEstatusDocumento, 1, @Comentario, @Verificable);

    SET @IdAceptacionCartaPCN =
    (
        SELECT @@IDENTITY
    );


	SELECT 'true' AS Response,
		@IdAceptacionCartaPCN,
		US.Nombre,
		US.Correo,
		US.IdUsuario,
		USR.IdRol
	FROM dbo.MPY_MM_AceptacionPedido AP
	LEFT JOIN Adinco.dbo.CO_Contratista AS C ON C.IdContratista = AP.IdProveedor
	LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE Modern_Spanish_CI_AS = C.RFC COLLATE Modern_Spanish_CI_AS
	LEFT JOIN dbo.S_UsuarioProveedor AS UP ON UP.IdProveedor = PR.IdProveedor
	LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = UP.IdUsuario AND US.Activo = 1 AND (US.IsEliminado = NULL OR US.IsEliminado = 0)
	LEFT JOIN dbo.S_UsuarioRol AS USR ON USR.IdUsuario = US.IdUsuario AND USR.Activo = 1
	WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
		AND US.IdUsuario IS NOT NULL
		AND USR.IdRol = 3
	GROUP BY US.Nombre,
		US.Correo,
		US.IdUsuario,
		USR.IdRol
END;