-- =============================================
-- Author: Manuel CD
-- Create date: 16-11-17
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_InsertUpdatePedComp] 
-- Add the parameters for the stored procedure here
@IdPedComp       INT,
@IdUsuario       INT,
@DocumentoPDF    IMAGE,
@IdTipoDocumento INT
AS
         BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
             SET NOCOUNT ON;
             DECLARE @id INT= 0;
             DECLARE @Nombre NVARCHAR(MAX);
         -- VALIDAR SI YA EXISTE FACTURA REEMPLAZAR SI NO AGREGAR NUEVA FACTURA 
             SET @id = ISNULL(
(
    SELECT IdPedimentoComprobante
    FROM dbo.FI_Documento
    WHERE IdPedimentoComprobante = @IdPedComp
), 0);
         -- SELECT @id;
             BEGIN
                 IF(@IdTipoDocumento = 4)
                     SET @Nombre = CONCAT('PI_', @IdPedComp, '.pdf');
                     ELSE
                 IF(@IdTipoDocumento = 5)
                     SET @Nombre = CONCAT('PE_', @IdPedComp, '.pdf');
             END;
	    -- SELECT @Nombre
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