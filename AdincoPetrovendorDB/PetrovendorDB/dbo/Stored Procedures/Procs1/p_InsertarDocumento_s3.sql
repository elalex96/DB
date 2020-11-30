
create proc [dbo].[p_InsertarDocumento_s3]
@pIdDocumento	int out,
@pIdTipoDocumento	int,
@pIdUsuario	int,
@pIdTipoValidacionDocumento	int,
@pIdProveedor	int,
@pActivo	bit,
@pDocumento	nvarchar(max),
@pCreadoPor	int,
@pDescripcion	nvarchar(max),
@pCarpeta	nvarchar(max),
@pIdentificador	nvarchar(max),
@pMime	nvarchar(max),
@pExtension	nvarchar(max),
@pNombreDocumento	nvarchar(max),
@pDuplicado	nvarchar(max)
as

	insert into s_documento_s3(
		/*IdDocumento,*/	IdTipoDocumento,	IdUsuario,		IdTipoValidacionDocumento,
		IdProveedor,	Activo,				Documento,		CreadoPor,
		CreadoEl,		ModificadoPor,		ModificadoEl,	Descripcion,
		Carpeta,		Identificador,		Mime,			Extension,
		NombreDocumento,Duplicado
	)
	values(

		/*@pIdDocumento,*/	@pIdTipoDocumento,	@pIdUsuario,		@pIdTipoValidacionDocumento,
		@pIdProveedor,	@pActivo,				@pDocumento,	@pCreadoPor,
		getdate(),		null,				null,				@pDescripcion,
		@pCarpeta,		@pIdentificador,		@pMime,			@pExtension,
		@pNombreDocumento,@pDuplicado
	)


	select @pIdDocumento = scope_identity() 
