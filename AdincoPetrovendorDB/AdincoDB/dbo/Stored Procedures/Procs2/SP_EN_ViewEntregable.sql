-- =============================================
-- Author:		Manuel CD
-- Create date: 22-11-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ViewEntregable] 
	-- Add the parameters for the stored procedure here
@IdDocumentoEntregable INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdDocumento,
                Archivo,
			 Extension,
			 NombreDocumento
         FROM dbo.EN_Documento
         WHERE IdDocumento = @IdDocumentoEntregable

     END