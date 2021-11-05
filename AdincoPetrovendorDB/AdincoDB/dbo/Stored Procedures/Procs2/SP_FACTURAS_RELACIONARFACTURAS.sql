--Created by: Luis David De La Cruz Bautista
--Made for: This is the relationship 
--Created at : 08/04/2018

--Usage: Get a bill and add more than one with relationship to that
CREATE PROCEDURE [dbo].[SP_FACTURAS_RELACIONARFACTURAS]
    @idFacturaPadre INT,
    @FirstName INT   
AS   
    SET NOCOUNT ON;  
   IF NOT EXISTS (
		SELECT 1
		FROM FI_RelacionRefacturas
		WHERE idFacturaPadre = @idFacturaPadre AND
		idFacturaHijo =@FirstName 
	)
	BEGIN
		insert into FI_RelacionRefacturas
		(idFacturaPadre,idFacturaHijo) 
		values (@idFacturaPadre,@FirstName);
	END

