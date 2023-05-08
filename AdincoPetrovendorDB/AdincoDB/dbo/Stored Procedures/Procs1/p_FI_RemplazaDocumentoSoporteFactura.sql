-- =============================================
-- Author:		Reyna Olvera
-- Create date: 05/06/2018
-- Description:Elimina la relacion y el documento de soporte de una factura que ya tiene relacion  es decir 
--"Remplaza el documento soporte de una factura que ya tiene"
-- =============================================
Create proc [dbo].[p_FI_RemplazaDocumentoSoporteFactura]
@pAWSDocumentoId	int OUT,
@IdFactura int,
@idContrato int,
@pNombreArchivo	varchar(250),
@pFolder varchar(100),
@pUUIDAmazon	uniqueidentifier,
@pMeta	varchar(50),
@pBucket	varchar(50),
@pCreadoPor	int
as

Declare @DocSup int;
Select @DocSup= DocumentoSoporteId from FI_RelacionSoporteFactura where IdFactura=@IdFactura;

Delete from FI_RelacionSoporteFactura where idFactura=@IdFactura;
Delete from FI_DocumentoSoporte where DocumentoSoporteId=@DocSup;


	select @pAWSDocumentoId = isnull(max(DocumentoSoporteId),0) + 1
	from FI_DocumentoSoporte
	

	insert into FI_DocumentoSoporte(
		DocumentoSoporteId,
		idContrato,
		NombreArchivo,
		UUIDAmazon,
		Meta,
		Bucket,
		CreadoPor,
		CreadoEl,
		ModificadoPor,
		ModificadoEl,
		Folder,
		Activo)
	select @pAWSDocumentoId,
	@idContrato,
	@pNombreArchivo,
	@pUUIDAmazon,
	@pMeta,
	@pBucket,
	@pCreadoPor,
	getdate(),
	null,
	null,
	@pFolder,
	1


		insert into FI_RelacionSoporteFactura(DocumentoSoporteId,IdFactura,CreadoEl,CreadoPor,ModificadoPor,ModificadoEl,Activo)
		select @pAWSDocumentoId,@IdFactura,getdate(),@pCreadoPor,null,null,1



