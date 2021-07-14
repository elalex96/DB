---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC p_CO_WDEA_Produccion_Diaria_Download
@pId int
as

	select AWS.*
	from CO_WDEA_Produccion_Diaria b
	inner join AWS_Documentos aws on aws.AWSDocumentoId = b.IdAWS
	where b.Id = @pid 

