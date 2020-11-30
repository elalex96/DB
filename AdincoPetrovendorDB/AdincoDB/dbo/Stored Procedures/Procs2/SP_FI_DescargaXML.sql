-- =============================================
-- Author:	Josue Gonzalez
-- Create date: 15-05-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_DescargaXML]
 --10001 ,21356
-- Add the parameters for the stored procedure here
@IdContrato INT,
@Facturas varchar(max)
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
	

select xml, ArchivoXML 
	from FI_Factura 
	where 
	--idContrato = @IdContrato
	--and XML IS NOT NULL
	--AND xml != ''
	--AND 
	IdFactura in (select * from   [fn_FI_StringList2Table](@Facturas) )
END;