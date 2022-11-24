-- =============================================
-- Author:		Manuel Cruz
-- Create date: 07-12-2021
-- Description:	Insertar PDF complemento de pago desde Petrovendor para Adinco
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_AgregarPDF_CP_PetrovendorAdinco] 
-- Add the parameters for the stored procedure here 
@IdFactura			INT,
@IdUsuario			INT,
@IdTipoDocumento	INT,
@ComprobantePDFByte IMAGE = NULL,
@AoP				INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @ID_DOCUMENTO INT= 0
         DECLARE @NOMBRE_EXTENSION NVARCHAR(MAX)
		 DECLARE @IdCPA INT
	
         -- VALIDAR SI YA EXISTE FACTURA REEMPLAZAR SI NO AGREGAR NUEVA FACTURA 
	IF (@AoP = 1)
	BEGIN
         SET @ID_DOCUMENTO = ISNULL((SELECT ISNULL(MAX(IdDocumento),0)
                                     FROM Adinco.dbo.FI_Documento
                                     WHERE IdFactura = @IdFactura
                                             AND IdTipoDocumento = @IdTipoDocumento
											 AND ISNULL(IsEliminado,0) = 0
                                   ), 0)

         SET @NOMBRE_EXTENSION = 'FI_'+CAST(@IdFactura AS NVARCHAR(200))+'.pdf'

         IF(@ID_DOCUMENTO <> 0)
             BEGIN 
                 ---Actualizar Comprobante ---
                 UPDATE Adinco.dbo.FI_Documento
                   SET
                       FechaCarga = GETDATE(),
                       NombreExtensionArchivo = @NOMBRE_EXTENSION,
                       IdUsuario = @IdUsuario,
					   DocumentoByte = @ComprobantePDFByte
                 WHERE IdDocumento = @ID_DOCUMENTO
                       AND IdFactura = @IdFactura
                       AND IdTipoDocumento = @IdTipoDocumento
             END
         ELSE
             BEGIN 
                 ---Agregar nuevo comprobante ---
                 INSERT INTO Adinco.dbo.FI_Documento
                 (
                  IdTipoDocumento,
                  NombreExtensionArchivo,
                  FechaCarga,
                  IdUsuario,
                  IdFactura,
				  DocumentoByte
                 )
                 VALUES
                 (
                  @IdTipoDocumento,
                  @NOMBRE_EXTENSION,
                  GETDATE(),
                  @IdUsuario,
                  @IdFactura,
				  @ComprobantePDFByte
                 );
             END
	END
	IF (@AoP = 2)
	BEGIN

		SET @IdCPA = (SELECT FA.IdFactura FROM Petrovendor.dbo.FI_Factura FP
		JOIN Adinco.dbo.FI_Factura FA ON FP.UUID = FA.UUID COLLATE DATABASE_DEFAULT
		WHERE FP.IdFactura = @IdFactura)

	    ---Actualizar Comprobante ---
		UPDATE Adinco.dbo.FI_Documento
		SET
			FechaCarga = GETDATE(),
			IdUsuario = @IdUsuario,
			DocumentoByte = @ComprobantePDFByte
		WHERE IdFactura = @IdCPA
			AND IdTipoDocumento = @IdTipoDocumento

	END

    SELECT 'SUCCESS';

    END;