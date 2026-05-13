use Petrovendor
go
drop proc if exists SP_PR_MM_PCN_AgregarCarta_S3
go
-- =============================================
-- Author:        Marcos Neri
-- Create date:	  20/05/2018
-- Description:   Se agrego el contrato y el area contractual
-- ============================================= 
-- Author:        Daniel Cruz
-- Create date:	  26-07-21
-- Description:   Se agrega columna de Bucket
-- ============================================= 
-- Author:        Luis David
-- Create date:	  12/09/2023
-- Description:   Se agrega el isusuarioAdinco para filtrar en el envio de correo
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
@C_CARPETA          NVARCHAR(MAX),
@C_BUCKET           NVARCHAR(MAX)
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
         [NombreDocumento],
		 [Bucket]		 
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
         @C_NOMBREARCHIVO,
		 @C_BUCKET
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

        DECLARE @CANTIDAD_APROBADORES INT=
        (
            SELECT COUNT(U.IdUsuario)
            FROM S_Usuario (NOLOCK) AS U
                 INNER JOIN S_UsuarioProveedor (NOLOCK) AS UP 
				 ON UP.IdUsuario = U.IdUsuario
                 INNER JOIN S_Proveedor (NOLOCK) AS PR 
				 ON UP.IdProveedor = PR.IdProveedor
                 LEFT JOIN dbo.S_UsuarioRol (NOLOCK) AS UR 
				 ON UP.IdUsuario = UR.IdUsuario
                 LEFT JOIN dbo.MM_AceptacionPedido (NOLOCK) AS AP 
				 ON UP.IdProveedor = AP.IdProveedor
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
                       ISNULL(U.Telefono, '') as Telefono, --7
                       REPLACE(CCO.NumeroContrato COLLATE Modern_Spanish_CI_AS, '', '') as NumeroContrato, --8
                       REPLACE(CAC.NombreAreaContractual COLLATE Modern_Spanish_CI_AS, '', '') as NombreAreaContractual, --9
						CASE WHEN UPPER(ISNULL(U.Dominio,'')) = 'ADINCO.MX' THEN 
							1
						ELSE 
							0
						END IsCorreoAdinco --10
                FROM S_Usuario (NOLOCK) AS U 
                     INNER JOIN S_UsuarioProveedor (NOLOCK) AS UP 
					 ON U.IdUsuario = UP.IdUsuario
                     INNER JOIN S_Proveedor (NOLOCK) AS PR 
					 ON UP.IdProveedor = PR.IdProveedor
                     LEFT JOIN dbo.S_UsuarioRol (NOLOCK) AS UR 
					 ON UP.IdUsuario = UR.IdUsuario
                     LEFT JOIN dbo.MM_AceptacionPedido (NOLOCK) AS AP 
					 ON UP.IdProveedor = AP.IdProveedor
                     LEFT JOIN dbo.MM_Pedido (NOLOCK) AS P 
					 ON AP.IdPedido = P.IdPedido
                     LEFT JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
					 ON P.IdSolicitudPedido = SP.IdSolicitudPedido
                     LEFT JOIN Adinco.dbo.CO_Contrato (NOLOCK) AS CCO 
					 ON P.IdContrato = CCO.IdContrato
                     LEFT JOIN adinco.dbo.CO_AreaContractual (NOLOCK) AS CAC 
					 ON CCO.IdAreaContractual = CAC.IdAreaContractual
                WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                      AND UR.IdRol = 3
                      AND ISNULL(U.Activo,0) = 1
                      AND ISNULL(U.IsEliminado,0) = 0
                      AND ISNULL(UR.Activo,0) = 1
                GROUP BY U.IdUsuario, 
                         U.Correo, 
                         PR.IdProveedor, 
                         U.Nombre, 
                         U.Telefono, 
                         CCO.NumeroContrato, 
                         CAC.NombreAreaContractual,
						 U.Dominio;

                ----- TU.IdRol = 3 Aprobador Contenido Nacional
        END;
            ELSE
            BEGIN
                SELECT 'false' AS Response, --0
                       'NO_EXISTEN_USUARIOS_ROL_ACN';
        END;
    END;
