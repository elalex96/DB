CREATE PROCEDURE p_EN_EditaDocumentoEntegable
@ID INT,
@FechaRealEvidencia DATETIME,
@Comentario Varchar(500) = NULL
as
begin
	update EN_EntregableDocumento
	set FechaRealEvidencia = @FechaRealEvidencia,
	Comentario = @Comentario
	where DocumentoEntregableId = @ID

end