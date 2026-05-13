-- =============================================
-- Author:		Manuel Cruz
-- Create date: 28-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE SP_FI_InsertarPdfFactura 
	-- Add the parameters for the stored procedure here
@NombreFactura NVARCHAR(MAX),
@PDF           NVARCHAR(MAX)
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
         DECLARE @IdFatura INT;
         SELECT @IdFatura = IdFactura
         FROM faclukoi
         WHERE NombrePDF = @NombreFactura;
	    --
         INSERT INTO [dbo].[FI_Documento]
         ([Documento],
          [IdTipoDocumento],
          [IdFactura],
          [IdUsuario],
          [FechaCarga]
         )
         VALUES
         (@PDF,
          1,
          @IdFatura,
          1,
          GETDATE()
         );
     END;

	--EXEC SP_FI_InsertarPdfFactura '1. 102014 F-OCTUBRE ROSA MARGARITA TRUEBA TOGNOLA.pdf','HSDFJHGKSJDFHGKJD'
