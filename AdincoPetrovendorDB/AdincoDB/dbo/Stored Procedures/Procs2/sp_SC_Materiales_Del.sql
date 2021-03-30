
CREATE proc sp_SC_Materiales_Del
(
	
	@IdSCMaterial	int,
	@pError varchar(250) out
)
as
begin
	set @pError = ''
	if not exists(
		select	1 
		from	OT_SolicitudMaterial
		where	IdSCMaterial = @IdSCMaterial
	)
	begin

		BEGIN TRY  
			delete 
			from		SC_Materiales
			where		IdSCMaterial	=	@IdSCMaterial
		
			select result = ''
		END TRY  
		BEGIN CATCH  
			 if( ERROR_NUMBER() = 547)
			 begin
				set @pError = 'No se puede eliminar el registro por que esta siendo utilizado'
			 end
			 else
			 begin
				set @pError = ERROR_NUMBER();
			 end
		END CATCH
	end
	else
	begin
		set @pError = 'No se puede eliminar el registro por que esta siendo utilizado'
	end		
end



