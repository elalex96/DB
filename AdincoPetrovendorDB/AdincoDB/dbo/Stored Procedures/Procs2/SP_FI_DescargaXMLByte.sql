-- =============================================
-- Author:Reyna Olvera
-- Create date: 27-06-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_DescargaXMLByte]
    @IdContrato INT,
    @Facturas VARCHAR(MAX)
AS
BEGIN

    SET NOCOUNT ON;


    SELECT FIAX.ArchivoXml AS xml,
           FIF.ArchivoXML AS ArchivoXml
      FROM FI_ArchivoXml FIAX
      JOIN FI_Factura FIF
        ON FIAX.IdFactura = FIF.IdFactura
     WHERE FIAX.IdFactura IN ( SELECT * FROM [fn_FI_StringList2Table](@Facturas) );
END;