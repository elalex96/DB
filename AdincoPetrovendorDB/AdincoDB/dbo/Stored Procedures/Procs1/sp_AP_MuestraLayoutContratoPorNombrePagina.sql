CREATE PROCEDURE [dbo].[sp_AP_MuestraLayoutContratoPorNombrePagina]
    @idUsuario INT = 1,
    @idContrato INT,
    @nombrePagina VARCHAR(MAX)
AS
BEGIN
    -- =============================================
    -- Author:	Daniel AC
    -- Create date: 03/05/2022
    -- Description:	Extrae la ruta del archivo por pagina y contrato
    -- =============================================
    SET NOCOUNT ON;

    
            SELECT TOP 1 doc.IdFormatoProduccionAWS,
                   doc.Bucket,
                   doc.Folder,
                   doc.UUIDAmazon,
                   doc.NombreArchivo,
                   doc.Meta
            FROM PR_FormatoProduccionAWS doc
			JOIN AP_PaginaLayout F
				ON DOC.IdTipoFormato= F.idPagina
            WHERE upper(f.NombrePagina) = upper(@nombrePagina)
                  AND doc.IdContrato = @idContrato
			ORDER BY CreadoEl DESC;
        
END;
