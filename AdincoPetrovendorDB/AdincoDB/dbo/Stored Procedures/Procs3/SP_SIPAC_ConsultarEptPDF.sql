-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2019-07-04
-- Description:	Devuelve el archivo para descargar y generar zip
-- =============================================
CREATE PROCEDURE [SP_SIPAC_ConsultarEptPDF] 
-- Add the parameters for the stored procedure here
@IdEPT INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT Archivo, 
                CONCAT(REPLACE(IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS NombreExtencionArchivo, 
                IdEstudioPrecioTransfer
         FROM dbo.FI_EstudioPreciosTransfer
         WHERE IdEstudioPrecioTransfer = @IdEPT;
     END;
