
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_FI_InsertUpdatePedComp'
    )
    DROP PROCEDURE SP_FI_InsertUpdatePedComp
GO
-- =============================================
-- Author: Manuel CD
-- Create date: 16-11-17
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_InsertUpdatePedComp] 
@IdPedComp       INT,
@IdUsuario       INT,
@DocumentoPDF    IMAGE,
@IdTipoDocumento INT
AS
         BEGIN
        
             SET NOCOUNT ON;
             DECLARE @id INT= 0;
             DECLARE @Nombre VARCHAR(500);

         -- VALIDAR SI YA EXISTE FACTURA REEMPLAZAR SI NO AGREGAR NUEVA FACTURA 
             SET @id = ISNULL(
(
    SELECT IdPedimentoComprobante
    FROM dbo.FI_Documento	 (NOLOCK)
    WHERE IdPedimentoComprobante = @IdPedComp
), 0);
             BEGIN
                 IF(@IdTipoDocumento = 4)
                     SET @Nombre = CONCAT('PI_', @IdPedComp, '.pdf');
                     ELSE
                 IF(@IdTipoDocumento = 5)
                     SET @Nombre = CONCAT('PE_', @IdPedComp, '.pdf');
             END;
             IF(@id <> 0)
                 BEGIN 
                 ---Actualizar Documento---
                     UPDATE dbo.FI_Documento
                       SET
                           DocumentoByte = @DocumentoPDF,
                           FechaCarga = GETDATE(),
                           NombreExtensionArchivo = @Nombre,
                           IdUsuario = @IdUsuario
                     WHERE IdPedimentoComprobante = @IdPedComp;
                 END;
                 ELSE
                 BEGIN
                     INSERT INTO [dbo].[FI_Documento]
([IdTipoDocumento],
 [IdPedimentoComprobante],
 [NombreExtensionArchivo],
 [IdUsuario],
 [FechaCarga],
 [IsEliminado],
 [DocumentoByte]
)
                     VALUES
(@IdTipoDocumento,
 @IdPedComp,
 @Nombre,
 @IdUsuario,
 GETDATE(),
 0,
 @DocumentoPDF
);
                 END;
             IF @@ERROR > 0
                 SELECT 'false' AS msj;
                 ELSE
             SELECT 'true' AS msj;
         END;

