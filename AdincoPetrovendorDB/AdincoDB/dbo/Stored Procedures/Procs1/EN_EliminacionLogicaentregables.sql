-- =============================================
-- Author:		Reyna Olvera
-- Create date:15/04/18
-- Description:	Eliminacion logica de documentos Entreables
-- =============================================
CREATE PROCEDURE [dbo].[EN_EliminacionLogicaentregables]
	@DocumentoEntregableId int,
	@idContrato int,
	@idUsuario int
AS
BEGIN
	SET NOCOUNT ON;

UPDATE EN_EntregableDocumento
Set	
	Activo	=	0,
	ModificadoPor	=	@idUsuario,
	ModificadoEl	=	GETDATE()	
WHERE
	DocumentoEntregableId=@DocumentoEntregableId

END

