-- =============================================
-- Author:		<Jose Roman>
-- Create date: <14/05/2018>
-- Description:	<Consulta de oficios por contrato, muestra sus relaciones>
-- =============================================

create PROCEDURE OF_SP_ConsultaOficiosRelaciones
	@IdContrato INT,
	@IdEstatus INT
AS
BEGIN
	SELECT d.IdDocumentoOficio,
		d.NumDocumento,
		t.NombreTipoOficio,
		d.Descripcion,
		ISNULL(o.IdDocumentoOficioParent, 0) AS IdDocumentoOficioParent
	FROM dbo.OF_OficioRelacion o
	RIGHT JOIN dbo.OF_DocumentoOficio d ON d.IdDocumentoOficio = o.IdDocumentoOficio
	INNER JOIN dbo.OF_TipoOficio t ON t.idTipoOficio = d.IdTipoOficio
	WHERE d.IdContrato = @IdContrato
		AND (d.IdEstatus = @IdEstatus OR @IdEstatus = 0)
END