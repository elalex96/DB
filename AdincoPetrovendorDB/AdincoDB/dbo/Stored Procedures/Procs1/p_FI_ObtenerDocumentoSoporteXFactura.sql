
Create Proc [dbo].[p_FI_ObtenerDocumentoSoporteXFactura]
@IdFactura int out
as

Declare @DocSup int;
Select @DocSup= DocumentoSoporteId from FI_RelacionSoporteFactura where IdFactura=@IdFactura;

	select 
		DocumentoSoporteId,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta,
		CreadoPor,
		CreadoEl,
		ModificadoPor,
		ModificadoEl
	from FI_DocumentoSoporte doc
	where DocumentoSoporteId = @DocSup
	
