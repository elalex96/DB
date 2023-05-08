create procedure p_SC_EliminarImportacionCarga
@IdSCCarga int
as
begin
	delete from SC_Importacion 
	--where IdSCCarga = @IdSCCarga
end
