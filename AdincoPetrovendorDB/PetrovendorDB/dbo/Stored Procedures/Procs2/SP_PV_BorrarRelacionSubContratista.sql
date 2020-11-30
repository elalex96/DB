
create PROCEDURE [dbo].[SP_PV_BorrarRelacionSubContratista]
	@IdRelacion int
AS
BEGIN
    
	delete from PV_ContratistaSubContratista
		where IdRelacion = @IdRelacion

END

