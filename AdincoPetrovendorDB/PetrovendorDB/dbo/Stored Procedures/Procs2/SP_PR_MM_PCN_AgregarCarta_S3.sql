-- =============================================
-- Author:        Daniel Cruz
-- Create date:	  07-08-18
-- Description:   Agregar carta de contenido nacional con información del documento 
-- ============================================= 
-- Author:        Jose Roman
-- Create date:	  22-08-2018
-- Description:   Se consulta el telefono de los aprobadores
-- ============================================= 
-- Author:        Marcos Neri
-- Create date:	  20/05/2018
-- Description:   Se agrego el contrato y el area contractual
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_PR_MM_PCN_AgregarCarta_S3]
-- Add the parameters for the stored procedure here
@IdProveedor        INT, 
@IdUsuario          INT, 
@IdTipoDocumento    INT, 
@IdEstatusDocumento INT, 
@Comentario         NVARCHAR(MAX), 
@IdAceptacionPedido INT, 
@CartaPCN           NVARCHAR(MAX), 
@Verificable        BIT, 
@IdContrato         INT           = NULL, 
@FechaRegistro      DATETIME      = NULL,

/*PARAMETROS DE LOS DOCUMENTOS*/

@C_IDENTIFICADOR    NVARCHAR(MAX), 
@C_MIME             NVARCHAR(MAX), 
@C_EXTENSION        NVARCHAR(MAX), 
@C_NOMBREARCHIVO    NVARCHAR(MAX), 
@C_CARPETA          NVARCHAR(MAX)
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        -- Insert statements for procedure here
        DECLARE @IdDocumento INT;
        DECLARE @IdAceptacionCartaPCN INT;
        INSERT INTO [dbo].[S_Documento_S3]
        ([IdTipoDocumento], 
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
         1, 
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
        INSERT INTO [dbo].[MM_AceptacionCartaPCN]
        ([IdAceptacionPedido], 
         [IdDocumento], 
         [CreadoPor], 
         [CreadoEl], 
         [IdEstatus], 
         [Activo], 
         [ComentarioProveedor], 
         [Verificable]
        )
        VALUES
        (@IdAceptacionPedido, 
         @IdDocumento, 
         @IdUsuario, 
         GETDATE(), 
         @IdEstatusDocumento, 
         1, 
         @Comentario, 
         @Verificable
        );
        SET @IdAceptacionCartaPCN =
        (
            SELECT @@IDENTITY
        );

        -- agrega una nueva notificacion interna al enviar la carta a aprobación
        DECLARE @IdProveedorOperadora INT=
        (
            SELECT IdProveedor
            FROM dbo.MM_AceptacionPedido
            WHERE IdAceptacionPedido = @IdAceptacionPedido
        );
        EXEC dbo.SP_N_AgregarNuevaNotificacion 
             @IdTipoOperacion = NULL, -- int
             @IdFlujoTarea = 0, -- int
             @IdProveedor = @IdProveedorOperadora, -- int
             @IdEstatusOperacion = 1, -- int
             @IdOperacion = @IdAceptacionPedido;  -- en este caso es la aceptacion de pedido

        DECLARE @CANTIDAD_APROBADORES INT=
        (
            SELECT COUNT(U.IdUsuario)
            FROM S_Usuario AS U
                 INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario = U.IdUsuario
                 INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = UP.IdProveedor
                 LEFT JOIN dbo.S_UsuarioRol AS UR ON UR.IdUsuario = UP.IdUsuario
                 LEFT JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdProveedor = UP.IdProveedor
            WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                  AND UR.IdRol = 3
                  AND U.Activo = 1
                  AND U.IsEliminado = 0
                  AND UR.Activo = 1
        );
        DECLARE @IDEDITADO INT=
        (
            SELECT TOP 1 IdAceptacionCartaPCN
            FROM dbo.MM_AceptacionCartaPCN
            WHERE IdAceptacionPedido = @IdAceptacionPedido
                  AND IdEstatus = 3
                  AND Editado = 1
                  AND IdAceptacionCartaPCN != @IdAceptacionCartaPCN
            ORDER BY CreadoEl DESC
        );
        IF ISNULL(@IDEDITADO, 0) > 0
            BEGIN
                UPDATE dbo.MM_AceptacionCartaPCN
                  SET 
                      Editado = 1, 
                      IdProceso = @IDEDITADO
                WHERE IdAceptacionCartaPCN = @IdAceptacionCartaPCN;
        END;
        IF ISNULL(@CANTIDAD_APROBADORES, 0) > 0
            BEGIN
                SELECT 'true' AS Response, --0
                       @IdAceptacionCartaPCN AS IdAceptacionCartaPCN, ---1
                       U.Nombre, --2
                       @IdDocumento AS IdDocumento, --3
                       U.Correo, --4
                       U.IdUsuario, --5
                       PR.IdProveedor, --6
                       ISNULL(U.Telefono, ''), --7
                       REPLACE(CCO.NumeroContrato COLLATE Modern_Spanish_CI_AS, '', '
		'), --8
                       REPLACE(CAC.NombreAreaContractual COLLATE Modern_Spanish_CI_AS, '', '
		') --9
                FROM S_Usuario AS U
                     INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario = U.IdUsuario
                     INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = UP.IdProveedor
                     LEFT JOIN dbo.S_UsuarioRol AS UR ON UR.IdUsuario = UP.IdUsuario
                     LEFT JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdProveedor = UP.IdProveedor
                     LEFT JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
                     LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
                     LEFT JOIN Adinco.dbo.CO_Contrato AS CCO ON CCO.IdContrato = P.IdContrato
                     LEFT JOIN adinco.dbo.CO_AreaContractual AS CAC ON CAC.IdAreaContractual = CCO.IdAreaContractual
                WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                      AND UR.IdRol = 3
                      AND U.Activo = 1
                      AND U.IsEliminado = 0
                      AND UR.Activo = 1
                GROUP BY U.IdUsuario, 
                         U.Correo, 
                         PR.IdProveedor, 
                         U.Nombre, 
                         U.Telefono, 
                         CCO.NumeroContrato, 
                         CAC.NombreAreaContractual;

                ----- TU.IdRol = 3 Aprobador Contenido Nacional
        END;
            ELSE
            BEGIN
                SELECT 'false' AS Response, --0
                       'NO_EXISTEN_USUARIOS_ROL_ACN';
        END;
    END;