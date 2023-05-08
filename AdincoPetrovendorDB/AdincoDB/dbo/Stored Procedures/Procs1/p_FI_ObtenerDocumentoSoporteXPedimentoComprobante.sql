-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/06/2018
-- Description:	<Description,,>
-- =============================================
CREATE Proc [dbo].[p_FI_ObtenerDocumentoSoporteXPedimentoComprobante]
@IdpedimentoComprobante int out
as

Declare @DocSup int;
Select @DocSup= DocumentoSoporteId from FI_RelacionSoporteFactura where IdPedimentoComprobante=@IdpedimentoComprobante;

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
	
