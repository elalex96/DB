
create proc p_FI_TransferFilesImport_Validacion
@pIdContratista int,
@pFileName varchar(250),
@pError varchar(300) out
as


	if exists (
		select 1
		from [FI_TransferFilesImport] ti
		inner join AWS_Documentos aws on aws.AWSDocumentoId = ti.AWSDocumentoId
		where aws.NombreArchivo = @pFileName and
		ti.IdContratista = @pIdContratista

	)
	begin
		set @pError = 'Ya existe un archivo con el mismo nombre'
	end


	
