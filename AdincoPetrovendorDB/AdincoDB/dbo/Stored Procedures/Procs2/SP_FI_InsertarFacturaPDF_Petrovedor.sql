
-- =============================================
-- Author:		Daniel  AC
-- Create date: 26-12-2016
-- Description:	Anexar PDF de una factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_InsertarFacturaPDF_Petrovedor] 
-- Add the parameters for the stored procedure here

@Documento NVARCHAR(MAX),
@IdTipoDocumento INT, 
@NombreExtesionArchivo NVARCHAR(MAX),
@IdUsuario INT, 
@IdFactura INT 

AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here  SP_FI_InsertarFacturaPDF_Petrovedor 'jjj',1,'df.pdf', 12,18122
		  
		 INSERT INTO FI_Documento(Documento, IdTipoDocumento, NombreExtensionArchivo, IdUsuario, FechaCarga, IdFactura)
		 VALUES(@Documento, @IdTipoDocumento, @NombreExtesionArchivo, @IdUsuario, GETDATE(),@IdFactura)
			
		 SELECT 'SUCCESS'
     END





