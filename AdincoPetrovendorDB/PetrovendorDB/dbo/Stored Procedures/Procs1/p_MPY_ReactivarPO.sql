CREATE PROCEDURE [dbo].p_MPY_ReactivarPO
@SAPPONumber varchar(20),
@IdUsuario int
as
begin
declare @CantidadDocs int;

	

	
		Update Adinco..CO_SAPPO
			set POActivo = 1			
			where SAPPONumber = @SAPPONumber and
			isnull(POActivo,0) = 0
	
end

