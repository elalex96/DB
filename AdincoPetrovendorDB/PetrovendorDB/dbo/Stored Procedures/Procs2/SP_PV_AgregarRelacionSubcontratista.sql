
create PROCEDURE [dbo].[SP_PV_AgregarRelacionSubcontratista]
	@IdContratista int,
	@IdSubContratista int
	
AS
BEGIN
    
	insert into PV_ContratistaSubContratista(IdContratista, IdSubContratista)
	values (@IdContratista, @IdSubContratista)

END

