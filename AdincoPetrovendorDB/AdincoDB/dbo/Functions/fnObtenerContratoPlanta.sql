CREATE FUNCTION [dbo].[fnObtenerContratoPlanta]
(
	@pPO_SAPNumer varchar(50),
@pPOLineNumber varchar(50)
)
RETURNS int
AS
BEGIN

	declare @IdContratoPlanta int

	select @IdContratoPlanta = c.IdContrato
	from Adinco..CO_SAPPO po 	
	inner join Adinco..[CO_SAPContratista_Planta] plantaC on plantaC.Planta = po.PLant
	inner join Adinco..CO_Contrato c on c.IdContratista = plantaC.IdContratista
	where po.SAPPONumber = @pPO_SAPNumer and
	po.ItemNumber = @pPOLineNumber	
	
	return @IdContratoPlanta 	

END
